# Builds the resume PDF from data/resume.yaml with Typst, and a cover letter
# PDF from a letter's YAML file with `make letter LETTER=<path>`.
#
# Typst substitutes a fallback font with only a warning when one is missing, so
# any warning fails the build.

PDF := dist/Andrew Marek Resume.pdf
TYPST_ARGS := --root . src/resume.typ "$(PDF)"
STYLE := src/style.typ data/resume.yaml data/contact.yaml

# The letter's `company` field names its PDF. Make can't parse YAML, so this
# reads the field from its line, dropping any quotes.
LETTER_COMPANY = $(shell sed -n 's/^company: *//p' "$(LETTER)" | tr -d "\"'")
LETTER_PDF = dist/Andrew Marek Cover Letter - $(LETTER_COMPANY).pdf

# $(call compile,<typst arguments>,<pdf>) compiles to <pdf> and deletes it if
# Typst printed any warning.
define compile
	@mkdir -p dist
	@out=$$(typst compile --root . $(1) "$(2)" 2>&1); status=$$?; \
	if [ -n "$$out" ]; then echo "$$out" >&2; fi; \
	if [ $$status -ne 0 ]; then exit $$status; fi; \
	if echo "$$out" | grep -q '^warning'; then \
		rm -f "$(2)"; echo "make: Typst warnings fail the build." >&2; exit 1; \
	fi
	@echo "Built $(2)"
endef

.PHONY: pdf watch letter

pdf: dist/Andrew\ Marek\ Resume.pdf

dist/Andrew\ Marek\ Resume.pdf: src/resume.typ $(STYLE)
	$(call compile,src/resume.typ,$(PDF))

watch:
	@mkdir -p dist
	typst watch $(TYPST_ARGS)

# Typst reads the letter from a root-relative path, hence the leading slash.
letter: src/letter.typ $(STYLE)
	$(if $(LETTER),,$(error Set LETTER to the letter's YAML file))
	$(if $(LETTER_COMPANY),,$(error $(LETTER) has no company field))
	$(call compile,--input letter=/$(LETTER) src/letter.typ,$(LETTER_PDF))
