# Chapter 1

In-text references to Figure [1](#fig:1)B and Table [1](#tab:foobar)
results in **Figure 1B and Table 1**.

Multi-reference to Figures [1](#fig:1) (A), the cool part of
[1](#fig:1) & [3](#fig:three) and Tables [1](#tab:foobar) (very
cool) & *especially* [1](#tab:foobar) is rendered as **Figures 1 (A),
the cool part of 1 & 2 and Tables 1 (verycool) & *especially* 1**

![Figure 1: The number one.](img/fig-1.png){#fig:1 width="1in"}

![Figure 2: The unlabeled number two.](img/fig-1.png){#fig: width="1in"}

![Figure 3: The number three.](img/fig-1.png){#fig:three width="1in"}

Plot [3](#fig:three) is given above, without adding the "Figure" prefix.

As seen in Table [1](#tab:foobar), commas are handled properly.

## Equations {#equationchapter}

Equations, such as Equation [1](#eq:pythagoras), have to be put into a
span with an id:

[$$a^2 + b^2 = c^2$$]{#eq:pythagoras}

## Tables

  Foo   Bar
  ----- -----
  1     2

  : [Table 1: ]{#tab:foobar}Caption

# Another chapter

References to Section [1.1](#equationchapter) and the unnamed
Section [2](#another-chapter)

Text at end.
