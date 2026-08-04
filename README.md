# My-Professional-Website

Source for [www.michaeloverton.net](https://www.michaeloverton.net/).

The site is an [R Markdown **distill**](https://rstudio.github.io/distill/) website. The `research/` directory is a separate thing, a modified [CollectionBuilder](https://collectionbuilder.github.io/) site holding the publication catalogue. The two are described separately below because they are updated in completely different ways.

---

## Read this first

**GitHub Pages serves the `major` branch, not `main`.**

`main` is an abandoned stub from 2021 with five commits. Every change since then has lived on `major`. Merging anything to `main` will not affect the live site.

```
git branch --show-current     # should say: major
```

**`.nojekyll` is at the repo root.** GitHub Pages therefore runs no build at all and serves whatever files are committed, verbatim. Anything that needs building must be built locally and its output committed.

**`output_dir: "."` in `_site.yml`.** Distill renders into the repo root, so the rendered `.html` files sit next to their `.Rmd` sources and are committed.

---

## Updating the distill site

Edit the relevant `.Rmd`, then render in R.

```r
rmarkdown::render_site()
```

Then commit both the `.Rmd` and the `.html` it produced, and push to `major`.

Navigation lives in `_site.yml`. Note that **the navbar is baked into every rendered page**, so changing a navbar entry there does nothing until the pages are re-rendered. A single-link change can be patched across the rendered `.html` files instead, which is what was done when the Research link was repointed.

### Do not remove this line

```yaml
exclude: ["research"]
```

`render_site()` manages the output directory, and `clean_site()` deletes directories it does not recognise. Because `output_dir` is the repo root, that includes `research/`. Without the exclude, a routine site render will delete the entire publication catalogue.

---

## The publication catalogue at `/research/`

A modified CollectionBuilder site. **The source is not in this repo.** It lives in a separate workspace and only its built output is committed here.

| | |
|---|---|
| Source | `~/Documents/claude_workspace/collection_builder_4_research/` |
| Committed here | `research/`, built static output only |
| Content source of truth | `theme_review.csv` in that workspace |
| Live URL | https://www.michaeloverton.net/research/ |

CollectionBuilder is a Jekyll site, but `.nojekyll` stops GitHub Pages from building anything, so it has to be built locally and the result committed.

### To update the catalogue

```bash
cd ~/Documents/claude_workspace/collection_builder_4_research

# 1. rebuild (parses the CV, applies theme_review.csv, fetches abstracts,
#    regenerates cover art, topic network, timeline, then builds the site)
bash build/build_all.sh

# 2. copy the built output over
rsync -a --delete prototype/_site/ ~/Documents/My-Professional-Website/research/

# 3. commit and push to the branch Pages serves
cd ~/Documents/My-Professional-Website
git add research && git commit -m "Update the publication catalogue" && git push origin major
```

`--delete` matters. Without it, files removed from the catalogue linger in the published output.

### To change what appears in the catalogue

Edit **`theme_review.csv`** in the collection workspace, then rebuild. That one file controls both scope and grouping.

| Column | Effect |
|---|---|
| `Theme_MO` | The theme. Set it to `Drop` to remove a publication from the catalogue entirely |
| `Theme_lvl_2` | The sub-theme |
| `Shared Trajectory` | Groups publications that develop an argument together. A trajectory left with one member is demoted automatically |
| `objectid` | Join key. **Do not edit** |

Do not run `build/make_theme_review.py`. It regenerates a blank review sheet and would overwrite the markup.

---

## What changed when the catalogue went in

The Research page used to be `Research.Rmd`, an interactive igraph network followed by hand-maintained publication lists. It was replaced by the catalogue.

- `_site.yml` — the Research navbar entry now points at `research/index.html`, and `exclude: ["research"]` was added
- Eleven rendered pages — the navbar link was patched from `Research.html` to `research/index.html`
- `research/` — the built catalogue, roughly 2,300 files

**`Research.Rmd` and `Research.html` are still here, unlinked.** They no longer appear in the navbar but remain reachable by direct URL, which keeps the old page and its Google Drive full-text links recoverable. Delete them whenever the old version is no longer wanted.

---

## How the catalogue is built

Nine steps, run in order by `build/build_all.sh` in the collection workspace.

| Step | Does |
|---|---|
| `parse_cv.py` | Parses the CV into structured records |
| `apply_review.py` | Applies `theme_review.csv`: drops excluded rows, writes theme, sub-theme, trajectory |
| `fetch_abstracts.py` | Abstracts and citation counts from OpenAlex, matched by DOI, cached |
| `attach_objects.py` | Attaches locally hosted PDFs |
| `rake generate_derivatives` | Page-one thumbnails for those PDFs |
| `make_covers.py` | Typographic cover art, coloured by sub-theme |
| `make_topic_network.py` | Topic co-occurrence graph for the Topics page |
| `make_timeline.py` | Publication timeline data |
| `jekyll build` | Builds the site |

Rebuilding needs Ruby from Homebrew, since the macOS system Ruby is too old for Jekyll 4.

```bash
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
```

### Modifications to stock CollectionBuilder

Kept here so they are not lost if the framework is ever upgraded.

| File | Change |
|---|---|
| `_sass/_custom.scss` | Matches the distill design: `#0F2E3D` bar and footer, 17px system type, dark underlined links, 704px prose column, full width for the three visual pages |
| `_includes/head/scholar-meta.html` | **New.** Highwire Press `citation_*` tags so Google Scholar can index the catalogue. Varies by output type so a preprint is not filed as a journal article |
| `_includes/item/citation-box.html` | Rewritten from museum-style attribution to a formatted reference plus generated BibTeX |
| `_includes/js/topic-network-js.html` | **New.** d3 topic co-occurrence network, replacing the tag cloud |
| `_includes/js/publication-timeline-js.html` | **New.** d3 publication timeline, replacing TimelineJS |
| `_includes/collection-nav.html` | Site title moved into the navbar, links right aligned, matching distill |
| `_includes/collection-banner.html` | Suppressed. Distill puts the title in the navbar, so CollectionBuilder's separate banner would stack a second header |
| `pages/projects.md` | The theme and trajectory hierarchy page |
| `_config.yml` | `baseurl: /research`, and framework docs excluded from the build so they are not published |

---

## Wiki

The repository wiki is enabled but has never been initialized, and GitHub does not allow the first page to be created through the API. To use it, create any page once through the web interface, after which this file can be copied into it.
