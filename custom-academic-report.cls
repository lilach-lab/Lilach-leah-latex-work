\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{custom-academic-report}[2026 Academic Report Class]

\LoadClass[11pt,a4paper]{article}

\RequirePackage[left=2.5cm,right=2.5cm,top=2.5cm,bottom=2.5cm]{geometry}
\RequirePackage{amsmath}
\RequirePackage{amsfonts}
\RequirePackage{amssymb}
\RequirePackage{graphicx}
\RequirePackage{microtype}
\RequirePackage{booktabs}
\RequirePackage{cite}
\RequirePackage{listings}
\RequirePackage[colorlinks=true, linkcolor=blue, citecolor=blue, urlcolor=blue]{hyperref}
\RequirePackage{setspace}
\RequirePackage{tikz}
\RequirePackage{pgfplots}

\usetikzlibrary{shapes.geometric, arrows.meta, positioning}
\pgfplotsset{compat=1.18}

\doublespacing
\raggedbottom

\lstset{
  basicstyle=\small\ttfamily,
  breaklines=true,
  columns=fixed,
  xleftmargin=2em,
  frame=single,
  lineskip=3pt
}

\endinput
