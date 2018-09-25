# About
Here is some scripts for using pandoc as a tool for literate programming.

# Setup

1. Install `pandoc`, `xelatex`, `ghostscript`, `texlive`, `graphviz` and `pygmentize`
2. Install fonts `ttf-google-fonts-typewolf`
3. Augment `pygments` with `https://github.com/vasil-sd/pygments-alloy`
4. Put contents of this repo somewhere and setup `$PATH` env var.

I recommend to setup `Emacs` with `markdown-mode`, `tuareg`, `plantuml-mode` etc, to
comfortly edit markdown files.

# Usage

1. Given an `some.md` file with source code blocks in Github markdown style
2. Run `md2all some.md`
3. It will produce `some.pdf`, `some.html` and `some.X` source code files, where X stands for: `c`, `ml`, `als` etc.
4. Supported languges: `ocaml`, `alloy`, `c`, `tla`. It is fairly easy to add more languages, see `md2sources` script.
5. For OCaml interface files use `some.i.md`. It will be extracted into `some.mli`, `some.i.pdf` etc.
6. PlantUML diagrams supported for both PDF and HTML files.
7. Generated PDFs may be set up to contain all needed glyphs from fonts, so they are truly platform/fonts/etc-independent.
8. HTMLs are generated as self-contained, i.e. all images are embedded into HTML, so they are fully standalone.
