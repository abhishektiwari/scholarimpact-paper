# Markdown Academic Paper Template

A template repository for writing academic research papers using Markdown and generating professional PDFs with Pandoc. This template supports multiple output formats including arXiv submission, bioRxiv preprint, and Eisvogel (professional academic papers).

## Features

- **Multiple Output Formats**: [arXiv template](https://github.com/kourgeorge/arxiv-style), [bioRxiv template](https://www.overleaf.com/latex/templates/arxiv-slash-biorxiv-template/phncddwqtxpc), [Eisvogel template](https://github.com/Wandmalfarbe/pandoc-latex-template)
- **Markdown-First**: Write in Markdown with full LaTeX math support
- **Citation Management**: Automatic bibliography generation with BibTeX
- **Diagram Support**: Integrated GraphViz and PlantUML diagram generation
- **Cross-References**: Automatic numbering and referencing of sections, figures, and tables
- **Professional Styling**: Clean, academic-quality PDF output
- **Submission Ready**: Complete submission package generation for arXiv and bioRxiv including LaTeX source and assets

## Quick Start

1. Create a new Github repository using this template by clicking `Use this template` → `Create a new repository`.

2. After creating a new repository, enable `Workflow permissions` to `Read and write permissions` for your Github repository by going to `Settings` → `Actions` → `General`. This allows Github Actions to build PDF output and upload it to release.

## Steps for local build

- Update paper metadata `paper/metadata.yaml`
- Update paper content `paper/article.md`
- Update the citation `paper/article.bibtex` and cite them in `article.md`. See [Pandoc guide on citation ](https://pandoc.org/chunkedhtml-demo/8.20-citation-syntax.html).
- Add images to `paper/images` folder and include them in `article.md` as markdown images. See [Pandoc guide on images](https://pandoc.org/chunkedhtml-demo/8.17-images.html).

### Make Commands

The template uses a Makefile-based build system that replaces the old `build.sh` script. All output files are generated in the `output/` directory.

#### Basic Commands

```bash
# Build with eisvogel template (default - professional academic paper)
make
make eisvogel

# Build with arxiv template (generates both PDF and LaTeX source)
make arxiv

# Build with bioRxiv template (preprint format with wide figures)
make biorxiv

# Prepare complete arxiv submission package with all assets
make arxiv-dist

# Prepare complete bioRxiv submission package with all assets
make biorxiv-dist

# Clean all generated files
make clean

# Show available commands and help
make help
```

#### Output Formats

| Command | Output Files | Description |
|---------|-------------|-------------|
| `make eisvogel` | `output/article-eisvogel.pdf` | Professional academic paper with clean typography, ideal for submissions to journals and conferences |
| `make arxiv` | `output/article-arxiv.pdf` | arXiv-compatible PDF following arXiv guidelines with proper section numbering |
| `make biorxiv` | `output/article-biorxiv.pdf` | bioRxiv preprint format with wide figures extending into margins, author emails, and ORCID links |
| `make arxiv-dist` | `output/arxiv-submission/` directory | Complete submission package containing:<br>• LaTeX source file<br>• Bibliography (.bibtex)<br>• All images (PNG, JPG, PDF, EPS)<br>• SVG files converted to PDF (arXiv compatible)<br>• Style files (arxiv.sty)<br>• Generated diagrams |
| `make biorxiv-dist` | `output/biorxiv-submission/` directory | Complete submission package containing:<br>• LaTeX source file<br>• Bibliography (.bibtex)<br>• All images (PNG, JPG, PDF, EPS, SVG)<br>• Generated diagrams<br>• SVG files preserved (bioRxiv compatible) |

#### Template Differences

**Eisvogel Template:**
- Professional academic styling with Source Sans Pro fonts
- Customizable title page with author information and ORCID links
- Header/footer with paper details and page numbers
- Optimized for general academic publication

**arXiv Template:**
- Follows arXiv submission guidelines and formatting requirements
- Section numbering starts from 1 (required by arXiv)
- Includes required arXiv style files
- Optimized for arXiv preprint submission

**bioRxiv Template:**
- bioRxiv preprint format with wide figure layout
- Figures automatically extend into left margin for maximum width utilization
- Author emails displayed with ORCID links and corresponding author marking (*)
- Gray figure captions with justified text formatting
- SVG format support (no conversion required)

## Steps for Action build

- Commit your paper changes and push.
- If you have changed the following folders Github Action will perform `article.pdf` build. Due to large size of `texlive-full`, currently build takes anywhere between 6-8 minutes.
    - `paper/**`
    - `paper/images/**`
    - `csl/**`
    - `data/templates/**`
- On successful build `article.pdf` will be uploaded to `Releases` section of your Github repository. 


# Prerequisite
On Mac Install `texlive`, `pandoc` using `brew`,

```
brew install pandoc texlive graphviz pygraphviz
```

Install only required `texlive` packages,
```
sudo tlmgr install beamerarticle pgfpages amsmath amssymb setspace inputenc mathspec unicode-math lmodern xeCJK upquote parskip fancyvrb xcolor hang flushmargin bottom multiple adjustbox graphicx listings etoolbox fvextra multirow longtable booktabs array caption headsepline footsepline titling footnotebackref sourcesanspro mdframed csquotes pagecolor afterpage tikz hyperref bookmark biblatex selnolig natbib babel calc subcaption soul luacolor svg float ccicons datetime2 algorithm2e ifoddpage relsize neuralnetwork pgf
```

Alternatively, install `texlive-full`,

```
brew install pandoc texlive-full
```

Install Python packages using `pip` to run `panflute` filters.

```bash
pip install panflute graphviz

python3 -m pip install -U --no-cache-dir  \
            --config-settings="--global-option=build_ext" \
            --config-settings="--global-option=-I$(brew --prefix graphviz)/include/" \
            --config-settings="--global-option=-L$(brew --prefix graphviz)/lib/" \
            pygraphviz
```

For PlantUML diagrams support, install PlantUML:

```bash
brew install plantuml batik
```

For SVG to PDF conversion (required for arXiv submission), install either Inkscape or librsvg:

```bash
# Option 1: Inkscape (preferred - higher quality)
brew install inkscape

# Option 2: librsvg (lighter alternative)
brew install librsvg
```

## Supported features

- **Bibliographies**: Automatic citation processing with BibTeX
- **Images**: Support for PNG, JPG, PDF, and SVG formats
- **Code blocks**: Syntax highlighting for programming languages
- **Tables**: Professional table formatting with booktabs
- **Mathematical expressions**: Full LaTeX math support
- **Diagrams**: GraphViz and PlantUML diagram generation
- **Cross-references**: Automatic numbering and referencing
