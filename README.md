# dice2tex

Generate a printer-ready LaTeX file from a Diceware word list. Each page contains all words where the first two digits are the same.

## Installation

Just make sure you have `ghc` and `cabal` installed. Then run

    cabal install

The binary `dice2tex` will be created.

## Usage

Just run `dice2tex <DICEWARE LIST>`. This will generate a LaTeX file to `stdout` with all the words. You can then create a PDF file by compiling the template `main.tex`.

Example:

    dice2tex eff_large_wordlist.txt > list.tex
    pdflatex main.tex

