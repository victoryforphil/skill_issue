---
hash: "b2ca2dd674af18a7584a26686d9e8ce426dda2686499769a754f3293e37d3d72"
name: docs-scraper
description: Scrape technical documentation into cleaned reusable local reference notes with metadata and consistent headings.
---

# docs-scraper

# docs-scraper

Create cleaned local reference docs from external technical documentation.

## Goal

Given one or more documentation URLs:
1. fetch the important pages,
2. extract the high-signal content,
3. normalize formatting,
4. add frontmatter metadata,
5. save the result under the current project's `docs/external/`, and
6. optionally create/update a reusable skill for future scraping tasks.

## Output locations

- Scraped docs: `<project>/docs/external/<slug>.md`
- Reusable skill: `/Users/<user>/the relevant local/global skill <skill-name>/SKILL.md`

Always use absolute paths when writing skill files.

## When to use

Use this skill when the user asks to:
- scrape docs into the repo,
- turn external docs into cleaned markdown,
- build a reusable scraping workflow,
- normalize documentation for later agent use,
- capture format specs from official documentation.

## Workflow

### 1) Inspect target and scope

Determine:
- primary URL,
- doc family / product name,
- whether the user wants a single-page scrape or a grouped reference,
- desired destination slug,
- whether a reusable skill should also be created.

If the user does not specify a slug, derive one from the topic in kebab-case.

### 2) Fetch high-signal pages

Prefer 2-6 pages, not the whole site.

Fetch in this order:
1. the requested page,
2. its parent index page,
3. closely-linked foundational pages,
4. adjacent format/reference pages if the user asked for “other format docs”.

Use `fetch_content` and `get_search_content` to collect readable markdown.

### 3) Clean and normalize

Transform the fetched content into a reusable local reference:
- remove site navigation, footers, edit links, theme/language UI, and duplicated menus,
- keep official terminology and code/token examples,
- preserve important section names,
- convert noisy prose into concise bullets where helpful,
- explicitly mark unclear or undocumented sections as `Undocumented / unclear in source`,
- do not invent missing semantics.

### 4) Add frontmatter

Every generated markdown file should begin with YAML frontmatter like this:

```yaml
---
title: <human title>
source: <primary url>
sources:
  - <url1>
  - <url2>
retrieved: <YYYY-MM-DD>
owner: external
product: <product>
topic: <topic>
format: reference
status: scraped
last_verified_source_modified: <date if visible, else unknown>
slug: <slug>
---
```

### 5) Add a standard header block

After frontmatter, add:
- H1 title,
- one-line summary,
- a short “Captured from” list,
- a “How to use this note” section,
- then the cleaned reference content.

### 6) Prefer this document structure

```md
# <Title>

> Cleaned reference derived from official documentation.

## Captured from
- <url>
- <url>

## How to use this note
- What this file covers
- What it does not cover
- Version / date caveats

## Overview
...

## File / format identification
...

## Core structure
...

## Key sections / tokens
...

## Version notes
...

## Gaps / ambiguities in upstream docs
...
```

If the source is a formal file format specification, include:
- file extensions,
- root tokens / headers,
- mandatory sections,
- optional sections,
- special identifiers,
- compatibility/version notes,
- any explicit third-party generator guidance.

### 7) Save the scraped doc

Write to:

```text
<project>/docs/external/<slug>.md
```

Create `docs/external` if missing.

### 8) Reusable scrape skill creation/update

If the user asks for a reusable skill:
- create a dedicated skill under `/Users/<user>/the relevant local/global skill <skill-name>/SKILL.md`,
- make it generic enough for future external-doc scraping,
- include the same workflow and formatting rules,
- mention frontmatter + destination conventions.

Good skill names:
- `docs-scraper`
- `spec-scraper`
- `format-doc-scraper`

Use kebab-case names matching the directory exactly.

## Quality bar

Before saving, verify:
- frontmatter exists and is valid YAML,
- title and slug match the topic,
- all source URLs are listed,
- navigation chrome is removed,
- code blocks and token names are preserved,
- speculation is avoided,
- output is concise but complete enough to be useful offline,
- file paths are explicit in the final response.

## Confirmation format

After saving, respond with:

```text
Saved:
- <doc path>
- <skill path>   # if created

Captured:
- topic: <topic>
- sources: <n>
- output: cleaned reference markdown with frontmatter
```
