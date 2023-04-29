TARGET  := `basename $PWD`
FLAGS   := '--shell-escape --interaction=nonstopmode'
EDITOR  := 'lvim'

# Open the last modified file
last:
  @{{EDITOR}} pages/`ls -t -1 pages | head -n 1`

# New entry with date as name, default editor `vi`
note:
  @{{EDITOR}} `bash -c "source ./src/format.sh; daily_note"`

# New entry with a given name, default editor `vi`
page NAME:
  @{{EDITOR}} `bash -c "source ./src/format.sh; simple_note {{NAME}}"`

# Compiles the main.tex to pdf
compile:
  @bash -c "source ./src/format.sh; remove_name"
  pdflatex {{FLAGS}} main.tex 1> /dev/null
  @pdflatex {{FLAGS}} main.tex 1> /dev/null # 2nd compilation for TOC
  @bash -c "source ./src/format.sh; restore_name"
  @mv main.pdf {{TARGET}}.pdf
  @cp {{TARGET}}.pdf `echo $HOME/Downloads/`
  @echo -e "📖 {{TARGET}}.pdf \e[32mis ready\e[0m"

# Compile the main.tex displaying the logs
dbg:
  pdflatex {{FLAGS}} main.tex | less

# Open the pdf with `evince` (opt: page number)
open +NUM='0':
  @evince --fullscreen --page-index=`bc <<< "{{NUM}} + 1"` {{TARGET}}.pdf

# A wrapper for easy usage (opt: page number)
run *NUM: compile clear
  @just open {{NUM}}

# Restore complete names from src/titles.txt
restore:
  @bash -c "source src/format.sh; restore_name"
  @echo -e "file names \e[32mrestored\e[0m"

# Remove unnecesary files after compile
clear:
  @rm -rdf _markdown_main/
  @rm -f *.out *.aux *.toc *.lua *.log *.err
  @clear && exa
