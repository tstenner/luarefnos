---
title: Pandoc-fignos Demo
test: bar
...

# Chapter 1

In-text references to @fig:1 [B] and @tab:foobar results in
**Figure 1B and Table 1**.

Multi-reference to [@fig:1 (A); the cool part of @fig:1; @fig:three]
and [@tab:foobar (very cool); *especially* @tab:foobar] is rendered as
**Figures 1 (A), the cool part of 1 & 2 and Tables 1 (verycool) & *especially* 1**

![The number one.](img/fig-1.png){#fig:1 width=1in}

![The unlabeled number two.](img/fig-1.png){#fig: width=1in}

![The number three.](img/fig-1.png){#fig:three width=1in}

Plot [-@fig:three] is given above, without adding the "Figure" prefix.

As seen in @tab:foobar, commas are handled properly.

## Equations {#equationchapter}

Equations, such as @eq:pythagoras, have to be put into a span with an id:

[$$a^2 + b^2 = c^2$$]{#eq:pythagoras}

## Tables

Foo Bar
--- ---
1   2

Table: Caption {#tab:foobar width=1em attr2=foo}

# Another chapter

References to @sec:equationchapter and the unnamed @sec:another-chapter

Text at end.
