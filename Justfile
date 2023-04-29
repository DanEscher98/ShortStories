TARGET  := `basename $PWD`
FLAGS   := '--shell-escape --interaction=nonstopmode'

# Compiles a main.txt to pdf
compile:
  @bash -c "source ./format.sh; remove_name"
  pdflatex {{FLAGS}} main.tex 1> /dev/null
  @pdflatex {{FLAGS}} main.tex 1> /dev/null # 2nd compilation for TOC
  @bash -c "source ./format.sh; restore_name"
  @mv main.pdf {{TARGET}}.pdf
  @echo -e "📖 {{TARGET}}.pdf \e[32mready\e[0m"
 
open:
  @evince --fullscreen --page-index=1 {{TARGET}}.pdf
  @cp {{TARGET}}.pdf `echo $HOME/Downloads`
 
clear:
  @rm -rdf _markdown_main/
  @rm -f *.out *.aux *.toc *.lua *.log *.err
  @clear && exa

name:
  echo {{TARGET}}
