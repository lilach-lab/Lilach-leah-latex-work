# Deployment Guide

**AI-Driven Automatic Academic Book Report Generator**  
Version 1.0 | Bar-Ilan University, June 2026

---

## 1. Overview

This guide covers everything needed to compile the LaTeX source (`untitled-1.tex`) into the final PDF deliverable (`untitled-1.pdf`). It also describes the workspace management utilities and the conceptual deployment topology for the multi-agent system described in the paper.

The project has two distinct deployment contexts:

| Context | Description |
|---------|-------------|
| **Document compilation** | Reproducing the 58-page PDF from the LaTeX source (this is the primary deliverable) |
| **Agent system deployment** | Deploying the multi-agent orchestration pipeline described in the paper (proof-of-concept; see §9) |

---

## 2. Prerequisites

### 2.1 LaTeX Distribution

A complete LaTeX distribution is required. Either of the following will work:

**Option A: TeX Live (recommended for Linux/macOS/Windows)**
```bash
# Ubuntu/Debian
sudo apt-get install texlive-full

# macOS (via Homebrew)
brew install --cask mactex

# Windows
# Download from https://www.tug.org/texlive/
```

**Option B: MiKTeX (Windows-native)**
```
Download from: https://miktex.org/download
Install with "Complete" package selection
```

**Minimum required packages** (all included in full TeX Live / complete MiKTeX):

| Package | Purpose |
|---------|---------|
| `geometry` | Page margins (2.5cm all sides) |
| `amsmath`, `amsfonts`, `amssymb` | Mathematical typesetting |
| `graphicx` | Graphics inclusion |
| `microtype` | Microtypographic enhancements |
| `booktabs` | Professional table rules |
| `cite` | Citation management |
| `listings` | Code listing environments |
| `hyperref` | PDF hyperlinks and bookmarks |
| `setspace` | Line spacing control |
| `tikz` | Vector diagram generation |
| `pgfplots` | Data plot generation |

### 2.2 Compiler

The project requires **LuaLaTeX**. It is included in all modern TeX distributions.

Verify installation:
```bash
lualatex --version
```

Expected output (example):
```
This is LuaHBTeX, Version 1.17.0 (TeX Live 2023)
```

### 2.3 No External Dependencies

The project has no external dependencies beyond the TeX distribution:
- No `.bib` bibliography database file required
- No external image files (all figures are TikZ/pgfplots)
- No Python environment required for compilation (the Python code in the appendix is a listing, not executed during compilation)
- No Gemini CLI or other AI tools required to reproduce the PDF

---

## 3. Compilation Procedure

### 3.1 Standard Two-Pass Compilation

```bash
# Navigate to the project directory
cd /path/to/LATECH

# Pass 1: Writes class file, cross-reference index, TOC, and bookmarks
lualatex --interaction=nonstopmode untitled-1.tex

# Pass 2: Resolves forward references, populates TOC page numbers, final PDF
lualatex --interaction=nonstopmode untitled-1.tex
```

**Why two passes?**
- **Pass 1** writes `custom-academic-report.cls` (via the embedded `filecontents*` block), generates `untitled-1.aux` (cross-reference index), `untitled-1.toc` (section→page map), and `untitled-1.out` (hyperref bookmarks).
- **Pass 2** reads those files to resolve all `\ref{...}`, `\pageref{...}`, `\cite{...}` forward references and populate the table of contents with correct page numbers.

### 3.2 Compilation on Windows (PowerShell)

```powershell
Set-Location "C:\Users\leahm\LATECH"
lualatex --interaction=nonstopmode untitled-1.tex
lualatex --interaction=nonstopmode untitled-1.tex
```

### 3.3 Compilation on Windows (Git Bash)

```bash
cd "/c/Users/leahm/LATECH"
lualatex --interaction=nonstopmode untitled-1.tex
lualatex --interaction=nonstopmode untitled-1.tex
```

### 3.4 Expected Output After Successful Compilation

```
LATECH/
├── untitled-1.pdf          ← 58-page deliverable (NEW/UPDATED)
├── untitled-1.aux          ← Cross-reference index (UPDATED)
├── untitled-1.toc          ← TOC data (UPDATED)
├── untitled-1.out          ← Hyperref bookmarks (UPDATED)
├── untitled-1.log          ← Full compilation log (UPDATED)
├── untitled-1.synctex.gz   ← SyncTeX map (UPDATED)
└── custom-academic-report.cls  ← Written by filecontents* block (UPDATED)
```

---

## 4. Verifying Compilation Success

### 4.1 Check PDF Page Count

The compiled PDF must be exactly **58 pages**. Verify by opening `untitled-1.pdf` in any PDF viewer.

Alternatively, check the `.aux` file:
```bash
grep "abspage@last" untitled-1.aux
```
Expected: `\gdef \@abspage@last{55}`

### 4.2 Check for Fatal Errors in Log

```bash
grep -i "fatal\|error\|emergency stop" untitled-1.log
```

A successful compilation produces no fatal errors. Expected non-fatal warnings (acceptable):
```
Underfull \hbox (badness ...) in paragraph at lines ...
Overfull \hbox (...pt too wide) in paragraph at lines ...
```

**Note on citation warnings (FIX_REPORT.md §Fix 3):** All `\cite{}` commands were removed from the body text in the final source. `\cite{lamport1994latex}` was replaced with `[2]`; `\cite{wooldridge2009multiagent}` and `\cite{alavi2025robust}` were removed. A clean compilation of the current source produces **zero** `Citation undefined` warnings. If you see citation warnings, you are compiling an older version of the file.

### 4.3 Check TOC Resolution

```bash
grep "contentsline" untitled-1.toc | wc -l
```
Expected: 94 entries.

### 4.4 Validate Section Numbering

Open the PDF and verify:
- [ ] Title page (no page number)
- [ ] Table of contents (page 2–4)
- [ ] Section 1 starts on page 5 (per `.aux` file)
- [ ] Appendix A on page 42 (per `.aux` file)
- [ ] References on page 53 (per `.aux` file)

---

## 5. Troubleshooting

### 5.1 Error: `File 'custom-academic-report.cls' not found`

**Cause:** The `filecontents*` block did not execute before `\documentclass` was processed. This can happen if the `.cls` file was deleted and the source is being compiled for the first time in an environment with caching.

**Resolution:**
```bash
# Force fresh compilation (no cached files)
rm -f untitled-1.aux untitled-1.toc untitled-1.out custom-academic-report.cls
lualatex --interaction=nonstopmode untitled-1.tex
lualatex --interaction=nonstopmode untitled-1.tex
```

The `filecontents*[overwrite]` option ensures the `.cls` is always (re)written on Pass 1.

---

### 5.2 Error: `LaTeX Error: Environment tabular undefined` or pgfplots crash

**Cause:** Missing LaTeX package (booktabs, pgfplots, tikz not installed).

**Resolution (TeX Live):**
```bash
# Install missing packages
tlmgr install booktabs pgfplots tikz
# Or install everything:
tlmgr install scheme-full
```

**Resolution (MiKTeX):**
Open MiKTeX Console → Packages → search for and install `booktabs`, `pgfplots`, `pgf`.

---

### 5.3 Error: `Overfull \hbox` on Tables

**Cause:** Table content exceeds text width. Already mitigated in the source via `\resizebox` and `\makebox`, but may re-appear if the source is modified.

**Resolution:** Check the affected table and either:
- Apply `\resizebox{\textwidth}{!}{...}` wrapper around the `tabular` environment
- Narrow the `p{Xcm}` column width specifications
- Use `\small` or `\footnotesize` font within the table

---

### 5.4 Error: pgfplots `compat` warning

**Cause:** pgfplots version mismatch with `compat=1.18` setting.

**Resolution:**
The class file sets `\pgfplotsset{compat=1.18}`. If your installed pgfplots version is older, upgrade via:
```bash
tlmgr update pgfplots
```

---

### 5.5 Error: `! Emergency stop.` after TikZ node

**Cause:** Missing semicolon at the end of a TikZ statement, or unmatched brace in a node label.

**Resolution:** Locate the `tikzpicture` block generating the error (line number in `.log`). Check that:
- Every `\node [...]` statement ends with `;`
- Every `\path [...]` statement ends with `;`
- Mathematical content inside node labels uses `$...$`

---

### 5.6 Compilation Takes Very Long

**Cause:** LuaLaTeX compiles TikZ/pgfplots figures from scratch each time. This project has 6 such figures.

**Resolution (enable tikz external library):**
If compilation speed is critical, add to the preamble (not in the class file):
```latex
\usetikzlibrary{external}
\tikzexternalize[prefix=figures/]
```
This caches compiled figures as PDF files and skips re-rendering unchanged diagrams.

---

## 6. Clean Build Procedure

To ensure a completely fresh compilation with no cached state:

```bash
# Remove all LaTeX build artifacts (Windows PowerShell)
Remove-Item untitled-1.aux, untitled-1.toc, untitled-1.out, untitled-1.log, untitled-1.synctex.gz, custom-academic-report.cls -ErrorAction SilentlyContinue

# Compile fresh
lualatex --interaction=nonstopmode untitled-1.tex
lualatex --interaction=nonstopmode untitled-1.tex
```

```bash
# Remove all LaTeX build artifacts (Bash)
rm -f untitled-1.{aux,toc,out,log,synctex.gz} custom-academic-report.cls

# Compile fresh
lualatex --interaction=nonstopmode untitled-1.tex
lualatex --interaction=nonstopmode untitled-1.tex
```

---

## 7. IDE / Editor Integration

### 7.1 Visual Studio Code

Install the **LaTeX Workshop** extension (James-Yu.latex-workshop). Add to `settings.json`:
```json
{
  "latex-workshop.latex.tools": [
    {
      "name": "lualatex",
      "command": "lualatex",
      "args": ["--interaction=nonstopmode", "--synctex=1", "%DOC%"]
    }
  ],
  "latex-workshop.latex.recipes": [
    {
      "name": "lualatex × 2",
      "tools": ["lualatex", "lualatex"]
    }
  ]
}
```

The `.synctex.gz` file (already present in the project) enables **SyncTeX** bidirectional navigation: Ctrl+click in the PDF jumps to the source line; Ctrl+Alt+J in the source jumps to the PDF position.

### 7.2 TeXstudio

1. Go to Options → Configure TeXstudio → Commands
2. Set the Default Compiler to `lualatex`
3. Compile with F5 (triggers two compilation passes automatically)

### 7.3 Overleaf

1. Create a new project
2. Upload `untitled-1.tex`
3. Set the compiler to **LuaLaTeX** in Menu → Compiler
4. Click Compile — Overleaf automatically runs two passes

---

## 8. Conceptual Agent System Deployment

The paper describes a proof-of-concept multi-agent system. For teams who wish to implement the architecture described in the paper, the following deployment notes apply based on the system specification.

### 8.1 Workspace Setup (Python)

The `LocalWorkspaceManager` class is defined as a code listing in Appendix A.2 of the paper (lines 878–902 of `untitled-1.tex`). It is **not a separate file** in this repository — it exists only as a printed listing within the LaTeX source. An implementer would need to copy the class into a standalone Python module. The class definition uses only the Python standard library (`os`, `shutil`). Usage example:

```python
# The class must first be extracted from Appendix A.2 into a standalone .py file
from workspace_manager import LocalWorkspaceManager

mgr = LocalWorkspaceManager(base_path="./workspace")

# Write an agent's output artifact
path = mgr.write_agent_artifact(
    session_id="session-001",
    file_name="untitled-1.tex",
    content=assembled_latex_source
)

# Clean up after PDF is confirmed valid
mgr.purge_temporary_artifacts("session-001")
```

### 8.2 LuaLaTeX CLI Integration

The paper specifies CLI-based compilation (§5.1, Listing 1):

```bash
lualatex --interaction=nonstopmode untitled-1.tex
lualatex --interaction=nonstopmode untitled-1.tex
```

In a Python-based agent system:
```python
import os
import subprocess

def compile_latex(tex_path: str) -> tuple[int, str]:
    result = subprocess.run(
        ["lualatex", "--interaction=nonstopmode", tex_path],
        capture_output=True,
        text=True,
        cwd=os.path.dirname(tex_path)
    )
    return result.returncode, result.stdout + result.stderr

# Two-pass compilation
rc1, log1 = compile_latex("/workspace/session-001/untitled-1.tex")
rc2, log2 = compile_latex("/workspace/session-001/untitled-1.tex")
```

### 8.3 QA Log Analysis Integration

```python
import re

KNOWN_ERRORS = {
    r"Overfull \\hbox": "hbox_overflow",
    r"Missing \$ inserted": "missing_delimiter",
    r"undefined.*direction": "bidi_drift",
    r"Reference .* undefined": "unresolved_reference",
    r"Citation .* undefined": "unresolved_citation",
}

def classify_errors(log: str) -> list[dict]:
    errors = []
    for pattern, error_type in KNOWN_ERRORS.items():
        matches = re.findall(pattern, log)
        if matches:
            errors.append({"type": error_type, "count": len(matches)})
    return errors
```

### 8.4 Data Mining Subsystem (WEKA)

The paper (§A.7) specifies a WEKA integration for predictive analysis of layout failure modes:

- **Classifier:** J48 Decision Tree (preferred for structural clarity)
- **Alternative classifiers:** Random Forest (high stability, higher latency), Naive Bayes (lightweight)
- **Input format:** ARFF (Attribute-Relation File Format)
- **Target variable:** Predicted layout failure mode class
- **Features:** Token density, context window saturation, nesting depth, column count, math density

---

## 9. Distribution

### 9.1 Distributing the PDF

The compiled `untitled-1.pdf` is self-contained. No LaTeX installation is required to read it. Distribute as a standard PDF file.

### 9.2 Distributing the Source

The source is self-contained in `untitled-1.tex` (single file). Recipients need only:
1. A complete TeX Live or MiKTeX installation
2. The two compilation commands (Pass 1 + Pass 2)

`custom-academic-report.cls` is auto-generated and does not need to be distributed separately.

---

## 10. Compilation Summary Card

```
┌─────────────────────────────────────────────────────────┐
│         QUICK COMPILE REFERENCE                         │
│                                                         │
│  Prerequisite: TeX Live 2023+ with LuaLaTeX             │
│                                                         │
│  Command:                                               │
│    lualatex --interaction=nonstopmode untitled-1.tex    │
│    lualatex --interaction=nonstopmode untitled-1.tex    │
│                                                         │
│  Expected output: untitled-1.pdf (58 pages)             │
│                                                         │
│  Acceptable warnings in .log:                           │
│    - Citation `xxx' undefined  (3 occurrences)          │
│    - Underfull \hbox            (minor; cosmetic only)  │
│                                                         │
│  Fatal errors: NONE expected                            │
└─────────────────────────────────────────────────────────┘
```
