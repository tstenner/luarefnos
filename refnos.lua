local pandoc = require 'pandoc'
---@type table<string, integer>
local Counter = {} -- counter for each namespace
---@type table<string, integer>
local Targets = {} -- maps reference IDs to reference numbers, e.g. {@fig:A=1, @fig:B=2, @tab:A=1}
---@type table<string, table<string, string>>
local Cap = {} -- localized caption strings


local debugmsg = function(logstr) end
-- local debugmsg = print
local warnmsg = print

--- returns the namespace portion from an id (i.e. 'fig' in 'fig:foobar') or nil
local function getnamespace(id)
	if id == nil then return nil end
	local colonidx = id:find(':')
	if colonidx ~= nil then
		return id:sub(1, colonidx - 1)
	else
		return nil
	end
end

--- to be overridden for some formats; escapes the reference ID if needed
---@param id string
local function EscapeId(id)
	return id
end

local function Link(text, id)
	return pandoc.Link(text, '#' .. id)
end

--- increments the counter for a namespace, saves and returns the index of refid
---@param namespace string
---@param refid string
---@return integer
local function storeRef(namespace, refid)
	local refno = (Counter[namespace] or 0) + 1

	debugmsg('	Adding ref to ' .. namespace .. ' -> ' .. refid .. '(#' .. refno .. ')')
	Counter[namespace] = refno
	if refid ~= nil then Targets[refid] = refno end
	return refno
end

local function getRefLink(namespace, refid)
	local t = Targets[refid]
	if refid:sub(1,4) == 'sec:' then
		refid = refid:sub(5)
	end
	if t == nil then
		warnmsg('Missing reference: (' .. namespace .. '): ' .. refid)
		return pandoc.Strong(refid .. '?')
	else
		return Link(tostring(t), EscapeId(refid))
	end
end

--- prepends "Figure XY: " to an image caption
local function InsertNumInImgCaption(caption, namespace, refno, identifier)
	if caption.long ~= nil then
		caption = caption.long[1].content
	end
	caption:insert(1, pandoc.Str(Cap[namespace].ref .. ' ' .. refno .. ': '))
end

--- prepends "Table XY: " to a table caption
function InsertNumInTabCaption(caption, namespace, refno, identifier)
	caption.long[1].content:insert(1, pandoc.Str(Cap[namespace].ref .. ' ' .. refno .. ': '))
end

--- appends "(XY)" to a span containing an equation
function InsertNumInEqCaption(caption, namespace, refno, identifier)
	caption.content:insert(pandoc.Str(' (' .. refno .. ')'))
end

--- formats and returns a reference, optionally with prefix (Table XY)
function InsertRef(id, namespace, withprefix)
	local reflink = getRefLink(namespace, id)
	if withprefix then
		return {pandoc.Str(Cap[namespace].ref .. ' '), reflink}
	end
	return {reflink}
end

--- format specific overrides, e.g. for native reference handling
if FORMAT == 'latex' then
	local function label(id)
		return pandoc.RawInline('latex', '\\label{' .. EscapeId(id) .. '}')
	end

	function InsertNumInTabCaption(caption, namespace, refno, identifier)
		-- no longer needed since pandoc 3
		-- caption.long[1].content:insert(label(identifier))
	end

	--- replaces the markdown equation with a native latex equation + prepended \\label
	function InsertNumInEqCaption(span, namespace, refno, identifier)
		local eq = span.content[1]
		local el = label(identifier)
		el.text = '$$' .. el.text .. eq.text .. '$$'
		return el
	end
	
	function getRefLink(namespace, refid)
		if refid:sub(1,4) == 'sec:' then
			refid = refid:sub(5)
		end
		return pandoc.RawInline('latex', '\\ref{' .. refid ..'}')
	end

elseif FORMAT == 'docx' then
	function EscapeId(id)
		if id:sub(1,4) == 'sec:' then
			return id:sub(5)
		end
		return 'refnos_' .. id
	end
	local function DocxFieldFunction(instr, text, hlink)
		local xml = '<w:fldSimple w:instr="' .. instr .. '"><w:r><w:t>' .. text .. '</w:t></w:r></w:fldSimple>'
		if hlink ~= nil then
			-- return '<w:hyperlink anchor="' .. hlink .. '"><w:r>' .. xml .. '</w:r></w:hyperlink>'
			xml = '<w:fldSimple w:instr="HYPERLINK  \\l &quot;'..hlink..'&quot;">'.. xml ..'</w:fldSimple>'
		end
		return pandoc.RawInline('openxml', xml)
	end

	function InsertRef(id, namespace, withprefix)
		local t = Targets[id]
		if t == nil then
			warnmsg('	Missing reference: ' .. namespace .. ' -> ' .. id)
			return {pandoc.Strong(id .. '??')}
		end
		id = EscapeId(id)

		-- not yet usable
		if namespace == 'sec' then
			local field = DocxFieldFunction(' REF ' .. id .. ' \\w \\h ', t)
			if withprefix then
				return {pandoc.Str(Cap.sec.ref), field}
			else
				return {field}
			end
		end

		-- full fldChar XML:
		-- local xml = '<w:r><w:fldChar w:fldCharType="begin"/>' ..
		--	'<w:instrText xml:space="preserve"> REF ' .. EscapeId(id) .. ' \\h</w:instrText>' ..
		--	'<w:fldChar w:fldCharType="separate"/>'..
		--	'<w:t>' t .. '</w:t>' ..
		--	'<w:fldChar w:fldCharType="end"/></w:r>'
		-- local xml = '<w:fldSimple w:instr=" REF ' .. EscapeId(id) .. ' \\h "><w:r><w:t>'..prefix .. ' ' .. t .. '</w:t></w:r></w:fldSimple>'
		if withprefix then
			return {DocxFieldFunction(' REF ' .. id .. ' \\h', Cap[namespace].ref .. ' ' .. t)}
		end

		return {DocxFieldFunction(' SEQ ' .. Cap[namespace].ref .. ' ' .. id .. ' \\c', t, nil)}
	end

	function InsertNumInCaption(caption, namespace, refno, identifier)
		-- generate hopefully unique bookmark ID
		local span = pandoc.Span(Cap[namespace].ref .. ' ')
		span.attr.identifier = EscapeId(identifier)
		span.content:insert(DocxFieldFunction(' SEQ ' .. Cap[namespace].ref .. ' \\* ARABIC ', refno))
		-- span.content:insert(pandoc.Str(': '))
		caption:insert(1, span)
		caption:insert(2, pandoc.Str(': '))
	end
	function InsertNumInTabCaption(caption, namespace, refno, identifier)
		InsertNumInCaption(caption.long[1].content, namespace, refno, identifier)
	end
	function InsertNumInImgCaption(caption, namespace, refno, identifier)
		InsertNumInCaption(caption, namespace, refno, identifier)
	end

elseif FORMAT == 'markdown' then
	function InsertNumInTabCaption(caption, namespace, refno, identifier)
		local span = pandoc.Span(Cap[namespace].ref .. ' ' .. refno .. ': ')
		span.attr.identifier = EscapeId(identifier)
		caption.long[1].content:insert(1, span)
	end
end

-- parses and removes an ID and attributes like
-- This is a caption {#id attr1=val1 foobar=baz}
-- into "This is a caption", {attr1="val1", foobar="baz"}
function GetAttrsFromCaption(e)
	if e.caption == nil or #e.caption.long == 0 then return e, nil end

	local cap = e.caption.long[1]
	local attrstr = (' '..pandoc.utils.stringify(cap)):match(' ({.*})$')
	if attrstr == nil then return e, nil end

	-- reuse pandocs span attribute parser
	local attrs = pandoc.read('[text]' .. attrstr).blocks[1].content[1].attr

	-- remove string from caption, starting at the end
	local i = #cap.content
	while i > 1 do
		local el = cap.content:remove(i)
		if el.tag == 'Str' and el.text:sub(1, 1) == '{' then break end
		i = i - 1
	end
	-- also remove preceding space
	if #cap.content > 0 and cap.content[#cap.content].t == 'Space' then
		cap.content:remove(#cap.content)
	end

	-- remove strings from caption
	while i <= #cap.content do cap.content:remove(#cap.content) end

	return e, attrs
end

--- Parse ID, class and attributes in the caption
-- Markdown has no native syntax for table attributes (unlike images), so
-- this function parses an attribute string at the end of the caption
local function MoveCaptionAttrsToTable(tab)
	local tbl, attr = GetAttrsFromCaption(tab)
	if attr ~= nil then
		tbl.attr.identifier = attr.identifier
		tbl.attr.classes:extend(attr.classes)
		for k, v in pairs(attr.attributes) do tbl.attr.attributes[k] = v end
		debugmsg('Extracted table id ' .. attr.identifier)
		return tbl
	end
end

local function HandleTable(tbl)
	if tbl.attr.identifier then
		local refno = storeRef('tab', tbl.attr.identifier)
		InsertNumInTabCaption(tbl.caption, 'tab', refno, tbl.attr.identifier)
		return tbl
	end
end

local function HandleFigure(fig)
	local id = fig.identifier
	if id:sub(1, 4) == 'fig:' then
		local figno = storeRef('fig', id)
		if fig.caption ~= nil and fig.caption.long ~= nil then
			InsertNumInImgCaption(fig.caption, 'fig', figno, id)
			return fig
		end
	end
end

local function HandleImage(img)
	local id = img.identifier
	if id:sub(1, 4) == 'fig:' then
		local figno = storeRef('fig', id)

		if img.caption ~= nil then
			InsertNumInImgCaption(img.caption, 'fig', figno, id)
			return img
		end
	end
end

local function HandleEquationInSpan(sp)
	if sp.content[1].t ~= 'Math' or sp.content[1].mathtype ~= 'DisplayMath' then
		return
	end
	local id = sp.attr.identifier
	local ns = getnamespace(id)
	if ns ~= nil then
		local refno = storeRef(ns, id)
		return InsertNumInEqCaption(sp, ns, refno, id)
	end
end

CurChapter = {0, 0, 0, 0, 0, 0, 0, 0, 0}
local function HandleHeader(h)
	CurChapter[h.level] = CurChapter[h.level] + 1
	for i = h.level + 1, 9 do
		CurChapter[i] = 0
	end
	local chapterNumber = CurChapter[1]
	for i = 2, #CurChapter do
		if CurChapter[i] == 0 then break end
		chapterNumber = chapterNumber .. '.' .. CurChapter[i]
	end
	if h.identifier then
		Targets['sec:' .. h.identifier] = chapterNumber
	end
end

local function HandleCitation(c)
	local namespace = getnamespace(c.citations[1].id)
	if namespace == nil then return end

	local res = pandoc.List()
	-- special case: AuthorInText, e.g. "As seen in @tab:foobar, …"
	if #c.citations == 1 and c.citations[1].mode == pandoc.AuthorInText then
		local ct = c.citations[1]
		res:extend(InsertRef(ct.id, namespace, true))
		res:extend(ct.suffix)
		return res
	end

	if c.citations[1].mode ~= pandoc.SuppressAuthor then
		if #c.citations == 1 then
			res:insert(pandoc.Str(Cap[namespace].ref .. ' '))
		else
			res:insert(pandoc.Str(Cap[namespace].plural .. ' '))
		end
	end

	for i, ct in ipairs(c.citations) do
		if namespace ~= getnamespace(ct.id) then
			warnmsg('Found mixed references in citation' .. c.content)
			res:insert(pandoc.Strong('… unprocessed citations'))
			return res
		end

		if i == 1 then
			-- nothing to do
		elseif i == #c.citations then
			res:insert(pandoc.Str(' & '))
		else
			res:insert(pandoc.Str(', '))
		end
		if #ct.prefix > 0 then
			res:extend(ct.prefix)
			res:insert(pandoc.Space())
		end
		res:extend(InsertRef(ct.id, namespace, false))
		res:extend(ct.suffix)
	end
	return res
end

local function MetaToStr(m)
	if m == nil then
		return nil
	elseif type(m) == 'string' then
		return m
	elseif m.t == 'MetaInlines' or m.t == 'Str' then
		return pandoc.utils.stringify(m)
	elseif m.t == 'MetaString' then
		return m.str
	elseif type(m) == 'table' then
		return MetaToStr(m[1])
	else
		warnmsg('unhandled type ' .. type(m))
		warnmsg(m.t)
		return nil
	end
end

function SetStrings(opts, lang)
	local Localized = {
		de = {
			tab = {ref = 'Tabelle', plural = 'Tabellen', abbrev = 'Tab.'},
			fig = {ref = 'Abbildung', plural = 'Abbildungen', abbrev = 'Abb.'},
			eq = {ref = 'Gleichung', plural = 'Gleichungen', abbrev = 'Gl.'},
			sec = {ref = 'Abschnitt', plural = 'Abschnitte', abbrev = 'Abs.'}
		},
		en = {
			tab = {ref = 'Table', plural = 'Tables', abbrev = 'Tab.'},
			fig = {ref = 'Figure', plural = 'Figures', abbrev = 'Fig.'},
			eq = {ref = 'Equation', plural = 'Equations', abbrev = 'Eq.'},
			sec = {ref = 'Section', plural = 'Sections', abbrev = 'Sec.'}
		}
	}

	if opts.strs == nil or type(opts.strs) ~= 'table' then opts.strs = Localized end
	if opts.strs[lang] == nil then lang = 'en' end

	for namespace, strs in pairs(opts.strs[lang]) do
		for k, v in pairs(strs) do
			if k ~= 'ref' and k~='plural' and k~='abbrev' then
				warnmsg('Unknown key luarefnos.'..lang..'.'..namespace..'.'..k)
			end
			strs[k] = MetaToStr(v)
		end

		if strs.ref == nil then
			warnmsg('Missing "ref" in luarefnos.'..lang..'.'..namespace)
			strs.ref = '???'
		end
		if strs.plural == nil then
			strs.plural = strs.ref .. 's'
		end
		if strs.abbrev == nil then
			strs.abbrev = strs.ref:sub(1,3)
		end
	end
	Cap = opts.strs[lang]
end

function Init(m)
	local opts = m.luarefnos
	-- if opts == nil then return end

	local lang = MetaToStr(m.lang) or 'en'

	SetStrings(m.luarefnos or {}, lang)
end

return {{Meta = Init},
	{Table = MoveCaptionAttrsToTable},
	{
		Header = HandleHeader,
		Table = HandleTable,
		Image = HandleImage,
		Figure = HandleFigure,
		Span = HandleEquationInSpan
	},
	{Cite = HandleCitation}}
