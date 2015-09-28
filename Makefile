all: README.html README.pdf

README.md: README.tex readme_content.tex
	pandoc readme_content.tex -t markdown_github -o README.md
README.html: README.md
	pandoc README.md -o README.html
README.pdf: README.tex readme_content.tex
	pdflatex README.tex && pdflatex README.tex

clean:
	rm -f *.log *.aux *.pdf  *.md *.html



