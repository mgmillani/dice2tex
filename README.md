# dice2tex

Generate a printer-ready LaTeX file from a Diceware word list. Each page contains all words where the first two digits are the same.

## License

`dice2tex` is released under the free software license GPLv3.

## Installation

Just make sure you have `ghc` and `cabal` installed. Then run

    cabal install

The binary `dice2tex` will be created. This project is also available on [Hackage](http://hackage.haskell.org/package/dice2tex)

## Usage

    dice2tex [OPTIONS...] <FILE>

where `OPTIONS` are

    -c, --columns N      Number of columns in each page for the output (default is 4).
    -o, --output FILE    Writes output to FILE instead of stdout.

Usually running `dice2tex <DICEWARE LIST>` will be okay. This will generate a LaTeX file to `stdout` with all the words. You can then create a PDF file by compiling the template `main.tex`.

Example:

    dice2tex eff_large_wordlist.txt > list.tex
    pdflatex main.tex

## Wordlists

You can get some wordlists from EFF [here](https://www.eff.org/deeplinks/2016/07/new-wordlists-random-passphrases).
