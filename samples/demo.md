---
title: Pandoc-fignos Demo
lang: de
luarefnos:
  strs:
    de:
      tab: {ref: 'Tabelle', plural: 'Tabellen'}
      fig: {ref: 'Plot', abbrev: 'Plot'}
...

![Plot eins](img/fig-1.png){#fig:1 width=1in}

![Plot zwei](img/fig-1.png){#fig:2 width=1in}

Wir verweisen auf @fig:1 und [@fig:1; die @fig:2 mit Postfix; fehlenden @fig:3].
