---
title: Pandoc-fignos Demo
lang: de
luarefnos:
  strs:
    de:
      tab: {ref: 'Tabelle', plural: 'Tabellen'}
      tbl: {ref: 'Tableu', plural: 'Tableus'}
      fig: {ref: 'Plot', abbrev: 'Plot'}
...

![Plot eins](img/fig-1.png){#fig:1 width=1in}

![Plot zwei](img/fig-1.png){#fig:2 width=1in}

Wir verweisen auf @fig:1 und [@fig:1; die @fig:2 mit Postfix; fehlenden @fig:3].

Foo Bar
--- ---
1   2

Table: Caption {#tbl:foobar}

Note that @tbl:foobar has a special namespace name.
