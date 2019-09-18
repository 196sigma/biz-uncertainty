pdflatex -shell-escape main.tex

bibtex main

pdflatex -shell-escape main.tex

pdflatex -shell-escape main.tex

pdflatex -shell-escape lit-review.tex

bibtex lit-review

pdflatex -shell-escape lit-review.tex

pdflatex -shell-escape lit-review.tex

pdflatex -shell-escape annotated-bibliography.tex

bibtex annotated-bibliography

pdflatex -shell-escape annotated-bibliography.tex

pdflatex -shell-escape annotated-bibliography.tex
