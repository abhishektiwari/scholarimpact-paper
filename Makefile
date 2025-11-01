# Paper build system
# Replaces build.sh with support for eisvogel and arxiv formats

# Configuration
PAPER_DIR = paper
ARTICLE_MD = $(PAPER_DIR)/article.md
ARTICLE_BIB = $(PAPER_DIR)/article.bibtex
METADATA = $(PAPER_DIR)/metadata.yaml
DATA_DIR = data
TEMPLATES_DIR = $(DATA_DIR)/templates
OUTPUT_DIR = output

# Output files
EISVOGEL_PDF = $(OUTPUT_DIR)/article-eisvogel.pdf
ARXIV_PDF = $(OUTPUT_DIR)/article-arxiv.pdf
ARXIV_TEX = $(OUTPUT_DIR)/article.tex
ARXIV_DIST = $(OUTPUT_DIR)/arxiv-submission
BIORXIV_PDF = $(OUTPUT_DIR)/article-biorxiv.pdf
BIORXIV_TEX = $(OUTPUT_DIR)/article-biorxiv.tex
BIORXIV_DIST = $(OUTPUT_DIR)/biorxiv-submission

# Default target
.PHONY: all clean eisvogel arxiv arxiv-dist biorxiv biorxiv-dist help

all: eisvogel

help:
	@echo "Available targets:"
	@echo "  eisvogel     - Build PDF using eisvogel template (default)"
	@echo "  arxiv        - Build PDF and TEX files using arxiv template"  
	@echo "  arxiv-dist   - Prepare files for arxiv submission (includes SVGs)"
	@echo "  biorxiv      - Build PDF using bioRxiv template"
	@echo "  biorxiv-dist - Prepare files for bioRxiv submission"
	@echo "  clean        - Remove generated files"
	@echo "  help         - Show this help message"

# Eisvogel format (current build.sh equivalent)
eisvogel: $(EISVOGEL_PDF)

$(EISVOGEL_PDF): $(ARTICLE_MD) $(ARTICLE_BIB) $(METADATA) | $(OUTPUT_DIR)
	@echo "Building PDF with eisvogel template..."
	cd $(PAPER_DIR) && pandoc \
		--bibliography article.bibtex \
		--citeproc \
		article.md \
		-o ../$(EISVOGEL_PDF) \
		--from markdown \
		--metadata-file=metadata.yaml \
		--data-dir=../$(DATA_DIR) \
		--template eisvogel.tex \
		--listings \
		-F panflute

# Arxiv format
arxiv: $(ARXIV_PDF)

$(ARXIV_PDF): $(ARTICLE_MD) $(ARTICLE_BIB) $(METADATA) | $(OUTPUT_DIR)
	@echo "Building PDF with arxiv template..."
	cd $(PAPER_DIR) && TEXINPUTS="../$(TEMPLATES_DIR):" pandoc \
		--bibliography article.bibtex \
		--citeproc \
		article.md \
		-o ../$(ARXIV_PDF) \
		--from markdown \
		--metadata-file=metadata.yaml \
		--data-dir=../$(DATA_DIR) \
		--template arxiv.tex \
		--listings \
		-F panflute

$(ARXIV_TEX): $(ARTICLE_MD) $(ARTICLE_BIB) $(METADATA) | $(OUTPUT_DIR)
	@echo "Generating LaTeX source with arxiv template..."
	cd $(PAPER_DIR) && TEXINPUTS="../$(TEMPLATES_DIR):" pandoc \
		--bibliography article.bibtex \
		--citeproc \
		article.md \
		-o ../$(ARXIV_TEX) \
		--from markdown \
		--metadata-file=metadata.yaml \
		--data-dir=../$(DATA_DIR) \
		--template arxiv.tex \
		--listings \
		-F panflute

# bioRxiv format
biorxiv: $(BIORXIV_PDF)

$(BIORXIV_PDF): $(ARTICLE_MD) $(ARTICLE_BIB) $(METADATA) | $(OUTPUT_DIR)
	@echo "Building PDF with bioRxiv template..."
	cd $(PAPER_DIR) && pandoc \
		--bibliography article.bibtex \
		--citeproc \
		article.md \
		-o ../$(BIORXIV_PDF) \
		--from markdown \
		--metadata-file=metadata.yaml \
		--data-dir=../$(DATA_DIR) \
		--template biorxiv.tex \
		--listings \
		-F panflute

$(BIORXIV_TEX): $(ARTICLE_MD) $(ARTICLE_BIB) $(METADATA) | $(OUTPUT_DIR)
	@echo "Generating LaTeX source with bioRxiv template..."
	cd $(PAPER_DIR) && pandoc \
		--bibliography article.bibtex \
		--citeproc \
		article.md \
		-o ../$(BIORXIV_TEX) \
		--from markdown \
		--metadata-file=metadata.yaml \
		--data-dir=../$(DATA_DIR) \
		--template biorxiv.tex \
		--listings \
		-F panflute

# Prepare arxiv submission package
arxiv-dist: $(ARXIV_TEX) $(ARXIV_PDF)
	@echo "Preparing arxiv submission package..."
	@rm -rf $(ARXIV_DIST)
	@mkdir -p $(ARXIV_DIST)
	
	# Copy and fix image paths in tex file (convert to relative paths for arXiv)
	@echo "Fixing image paths in LaTeX file..."
	@sed 's|{../output/[^/]*/\([^}]*\)}|{\1}|g; s|{[^/{}]*\/\([^}]*\)}|{\1}|g' $(ARXIV_TEX) > $(ARXIV_DIST)/article.tex
	
	# Copy bibliography
	@cp $(ARTICLE_BIB) $(ARXIV_DIST)/
	
	# Copy arxiv style files
	@cp $(TEMPLATES_DIR)/arxiv.sty $(ARXIV_DIST)/ 2>/dev/null || true
	
	# Copy image files from paper directory and images folder
	@echo "Copying image files..."
	@find $(PAPER_DIR) -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.pdf" -o -name "*.eps" | \
		while read img; do \
			cp "$$img" $(ARXIV_DIST)/ 2>/dev/null || true; \
		done
	
	# Copy files from images folder if it exists
	@if [ -d "$(PAPER_DIR)/images" ]; then \
		find $(PAPER_DIR)/images -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.pdf" -o -name "*.eps" -o -name "*.svg" | \
			while read img; do \
				if [ "$${img##*.}" = "svg" ]; then \
					base=$$(basename "$$img" .svg); \
					echo "Converting image $$img to PDF..."; \
					if command -v inkscape >/dev/null 2>&1; then \
						inkscape --export-type=pdf --export-filename="$(ARXIV_DIST)/$$base.pdf" "$$img" 2>/dev/null || \
						echo "Warning: Failed to convert $$img to PDF with inkscape"; \
					elif command -v rsvg-convert >/dev/null 2>&1; then \
						rsvg-convert -f pdf -o "$(ARXIV_DIST)/$$base.pdf" "$$img" 2>/dev/null || \
						echo "Warning: Failed to convert $$img to PDF with rsvg-convert"; \
					else \
						echo "Warning: Cannot convert SVG $$img - no converter found"; \
					fi; \
				else \
					cp "$$img" $(ARXIV_DIST)/ 2>/dev/null || true; \
				fi; \
			done; \
		echo "Copied images from $(PAPER_DIR)/images/"; \
	fi
	
	# Copy and convert diagrams from organized output folders
	@echo "Copying and converting diagram files..."
	
	# Copy GraphViz images (already in correct format)
	@if [ -d "$(OUTPUT_DIR)/graphviz" ]; then \
		cp $(OUTPUT_DIR)/graphviz/* $(ARXIV_DIST)/ 2>/dev/null || true; \
		echo "Copied GraphViz images from $(OUTPUT_DIR)/graphviz/"; \
	fi
	
	# Handle PlantUML files - convert SVG to PDF, copy others directly
	@if [ -d "$(OUTPUT_DIR)/plantuml" ]; then \
		find $(OUTPUT_DIR)/plantuml -name "*.png" -o -name "*.pdf" -o -name "*.eps" | \
			while read img; do \
				cp "$$img" $(ARXIV_DIST)/ 2>/dev/null || true; \
			done; \
		find $(OUTPUT_DIR)/plantuml -name "*.svg" | while read svg; do \
			if [ -f "$$svg" ]; then \
				base=$$(basename "$$svg" .svg); \
				echo "Converting PlantUML $$svg to PDF..."; \
				if command -v inkscape >/dev/null 2>&1; then \
					inkscape --export-type=pdf --export-filename="$(ARXIV_DIST)/$$base.pdf" "$$svg" 2>/dev/null || \
					echo "Warning: Failed to convert $$svg to PDF with inkscape"; \
				elif command -v rsvg-convert >/dev/null 2>&1; then \
					rsvg-convert -f pdf -o "$(ARXIV_DIST)/$$base.pdf" "$$svg" 2>/dev/null || \
					echo "Warning: Failed to convert $$svg to PDF with rsvg-convert"; \
				else \
					echo "Warning: No SVG converter found, cannot convert SVG files to PDF"; \
					echo "Install either inkscape or librsvg:"; \
					echo "  brew install inkscape"; \
					echo "  brew install librsvg"; \
				fi; \
			fi; \
		done; \
		echo "Processed PlantUML images from $(OUTPUT_DIR)/plantuml/"; \
	fi
	
	@echo "Arxiv submission files ready in $(ARXIV_DIST)/"
	@echo "Note: SVG files have been converted to PDF for arxiv compatibility"
	@echo "Contents:"
	@ls -la $(ARXIV_DIST)/

# Prepare bioRxiv submission package
biorxiv-dist: $(BIORXIV_TEX) $(BIORXIV_PDF)
	@echo "Preparing bioRxiv submission package..."
	@rm -rf $(BIORXIV_DIST)
	@mkdir -p $(BIORXIV_DIST)
	
	# Copy and fix image paths in tex file (convert to relative paths for bioRxiv)
	@echo "Fixing image paths in LaTeX file..."
	@sed 's|{../output/[^/]*/\([^}]*\)}|{\1}|g; s|{[^/{}]*\/\([^}]*\)}|{\1}|g' $(BIORXIV_TEX) > $(BIORXIV_DIST)/article-biorxiv.tex
	
	# Copy bibliography
	@cp $(ARTICLE_BIB) $(BIORXIV_DIST)/
	
	# Copy image files from paper directory and images folder
	@echo "Copying image files..."
	@find $(PAPER_DIR) -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.pdf" -o -name "*.eps" | \
		while read img; do \
			cp "$$img" $(BIORXIV_DIST)/ 2>/dev/null || true; \
		done
	
	# Copy files from images folder if it exists (bioRxiv accepts SVG)
	@if [ -d "$(PAPER_DIR)/images" ]; then \
		find $(PAPER_DIR)/images -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.pdf" -o -name "*.eps" -o -name "*.svg" | \
			while read img; do \
				cp "$$img" $(BIORXIV_DIST)/ 2>/dev/null || true; \
			done; \
		echo "Copied images from $(PAPER_DIR)/images/"; \
	fi
	
	# Copy and process diagrams from organized output folders
	@echo "Copying diagram files..."
	
	# Copy GraphViz images (already in correct format)
	@if [ -d "$(OUTPUT_DIR)/graphviz" ]; then \
		cp $(OUTPUT_DIR)/graphviz/* $(BIORXIV_DIST)/ 2>/dev/null || true; \
		echo "Copied GraphViz images from $(OUTPUT_DIR)/graphviz/"; \
	fi
	
	# Copy PlantUML files (bioRxiv accepts SVG, so copy all formats)
	@if [ -d "$(OUTPUT_DIR)/plantuml" ]; then \
		cp $(OUTPUT_DIR)/plantuml/* $(BIORXIV_DIST)/ 2>/dev/null || true; \
		echo "Copied PlantUML images from $(OUTPUT_DIR)/plantuml/"; \
	fi
	
	@echo "bioRxiv submission files ready in $(BIORXIV_DIST)/"
	@echo "Note: SVG files are preserved (bioRxiv accepts SVG format)"
	@echo "Contents:"
	@ls -la $(BIORXIV_DIST)/

# Create output directory
$(OUTPUT_DIR):
	@mkdir -p $(OUTPUT_DIR)

clean:
	@echo "Cleaning generated files..."
	@rm -f $(EISVOGEL_PDF) $(ARXIV_PDF) $(ARXIV_TEX) $(BIORXIV_PDF) $(BIORXIV_TEX)
	@rm -rf $(ARXIV_DIST) $(BIORXIV_DIST)
	@rm -rf $(OUTPUT_DIR)/plantuml $(OUTPUT_DIR)/graphviz
	@echo "Clean complete."

# Ensure data directory and templates exist
$(TEMPLATES_DIR)/eisvogel.tex $(TEMPLATES_DIR)/arxiv.tex:
	@if [ ! -f $@ ]; then \
		echo "Error: Template $@ not found"; \
		exit 1; \
	fi