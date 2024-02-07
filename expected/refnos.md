# Chapter 1

In-text references to Figure [1](#fig:1)B and Table [1](#tab:foobar)
results in **Figure 1B and Table 1**.

Multi-reference to Figures [1](#fig:1) (A), the cool part of
[1](#fig:1) & [3](#fig:three) and Tables [1](#tab:foobar) (very
cool) & *especially* [1](#tab:foobar) is rendered as **Figures 1 (A),
the cool part of 1 & 2 and Tables 1 (verycool) & *especially* 1**

<figure id="fig:1">
<img src="img/fig-1.png" style="width:1in" alt="The number one." />
<figcaption>Figure 1: The number one.</figcaption>
</figure>

<figure id="fig:">
<img src="img/fig-1.png" style="width:1in"
alt="The unlabeled number two." />
<figcaption>Figure 2: The unlabeled number two.</figcaption>
</figure>

<figure id="fig:three">
<img src="img/fig-1.png" style="width:1in" alt="The number three." />
<figcaption>Figure 3: The number three.</figcaption>
</figure>

Plot [3](#fig:three) is given above, without adding the "Figure" prefix.

As seen in Table [1](#tab:foobar), commas are handled properly.

## Equations {#equationchapter}

Equations, such as Equations [1](#eq:pythagoras) & [2](#eq:einstein)
(however short it is), have to be put into a span with an id:

[$$a^2 + b^2 = c^2$$ (1)]{#eq:pythagoras}

They can also be inline: [$$e=mc^2$$ (2)]{#eq:einstein}.

Most people prefer Equation [1](#eq:pythagoras), but know
Equation [2](#eq:einstein).

## Tables

  Foo   Bar
  ----- -----
  1     2

  : [Table 1: ]{#tab:foobar}Caption

# Another chapter

References to Section [1.1](#equationchapter) and the unnamed
Section [2](#another-chapter)

Text at end.
