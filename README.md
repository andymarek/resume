# Resume

This repository builds a PDF resume with [Typst](https://typst.app). The content lives in `data/resume.yaml`, which follows the [JSON Resume schema](https://jsonresume.org/schema), and the layout lives in `src/resume.typ`. Contact fields would go in `data/contact.yaml`, which is empty here.

## Building

`make` writes `dist/Andrew Marek Resume.pdf`. `make watch` rebuilds on every save.

The layout needs the Tahoma, Georgia, and Symbol fonts installed. Typst substitutes another font with only a warning when one is missing, so the build treats any warning as an error and deletes the PDF. macOS ships all three fonts.

## Formatting

`pre-commit run --all-files` runs Prettier on the YAML, Typstyle on the Typst source, and Checkmake on the `Makefile`.

## Pull requests

Every pull request builds the PDF on a macOS runner and attaches it as the `resume-pdf` artifact.
