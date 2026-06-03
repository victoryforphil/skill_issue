---
hash: "08d03f0cd929d3bf3501dd64470e2a6c72ff4fb77e1f7fedddf42ccc13fd05a5"
name: skill-comparator
description: Find duplicates, compare versions, and verify agent skills using content hashes and ripgrep.
---

# Skill Comparator

Use this skill when comparing skill versions, finding duplicate skills in the workspace, or checking if a local skill matches its global or upstream counterpart.

## Core Design

Every `SKILL.md` contains a stable frontmatter hash:

```yaml
hash: "27b3a10af0ee9a36b9890ce28876d01b2a08d155eeb808ad758ac72d7face4e3"
```

This hash is calculated strictly on the **instructions body** (everything below the second `---` of the frontmatter, trimmed of leading and trailing whitespace). This makes the hash independent of title, file path, name, or description metadata, ensuring a reliable signature of the actual behavioral instructions.

---

## Workflow with ripgrep (rg)

Because the `hash` field is located on the second line of the file (fixed location right below the opening `---`), it is extremely fast and robust to search using `ripgrep`.

### 1. Find all skills and their hashes in the workspace

To get a quick overview of all skills and their signatures:

```bash
rg "^hash: " -g "**/SKILL.md"
```

### 2. Search for a specific skill content signature

If you have a skill and want to find any duplicate or matching versions across all repositories and global directories:

```bash
# Substitute the SHA-256 hash you are looking for
rg 'hash: "c4ac5295b1e2' -g "**/SKILL.md"
```

If multiple files return the same hash, they are guaranteed to have identical instruction bodies, even if they live in different folders or have different filenames/metadata.

### 3. Detect modified/diverged versions

If you have two skills with the same `name` but different paths, check if they have diverged:

```bash
# Search for the skill name and show the line containing its hash (which is next to it)
rg -B 1 -A 1 "^name: my-skill-name" -g "**/SKILL.md"
```

If the hashes differ, the instruction bodies have diverged. Use `diff` to see the actual instruction changes:

```bash
diff -u path/to/skill-a/SKILL.md path/to/skill-b/SKILL.md
```

---

## Verifying and Generating Hashes

When creating or modifying a skill, update its hash using the standard generation rule:

1. Extract all text *after* the second `---` delimiter.
2. Trim leading and trailing whitespace/newlines from that text.
3. Compute the SHA-256 hex string of the trimmed text.
4. Set the `hash` property in the YAML frontmatter:
   ```yaml
   hash: "<sha256-hex>"
   ```

### Quick CLI generation on Unix:

To generate the instruction-body hash of a single skill from your shell:

```bash
tail -n +$(grep -n '---' SKILL.md | tail -n 1 | cut -d: -f1) SKILL.md | tail -n +2 | awk '{$1=$1}1' | shasum -a 256
```
