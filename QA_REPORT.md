# Quality Assurance Report

**AI-Driven Automatic Academic Book Report Generator**  
Version 1.0 | Bar-Ilan University, June 2026  
**QA Scope:** `untitled-1.tex` → `untitled-1.pdf` (55 pages)

---

## 1. Executive Summary

The QA subsystem for this project operates as a **closed autonomous feedback loop** between the LuaLaTeX compilation engine and a self-healing repair agent. Rather than modifying the compiled PDF directly, the QA Agent intercepts compilation logs, classifies structural errors by type, dispatches targeted repairs to the source `.tex` file, and re-triggers compilation.

This report documents the QA architecture, error taxonomy, self-healing protocols, risk priority mapping, and the validation outcomes for the compiled deliverable `untitled-1.pdf`.

**Final QA Status:** PASSED — PDF compiled successfully to 55 pages with no fatal errors.

---

## 2. QA Architecture

```mermaid
flowchart TD
    TEX[Assembled .tex source] --> P1[LuaLaTeX Pass 1]
    P1 --> LOG1[Compilation Log]
    LOG1 --> QAA{QA Agent\nLog Analysis}

    QAA -->|No errors| P2[LuaLaTeX Pass 2]
    QAA -->|hbox overflow| HFIX[Repair: Recalculate\ncolumn widths]
    QAA -->|Missing delimiter| DFIX[Repair: Inject\n$ or \} token]
    QAA -->|BiDi drift| BFIX[BiDi Agent:\nDirectional wrapper]
    QAA -->|Undefined ref| RFIX[Re-trigger compilation]

    HFIX --> TEX2[Updated .tex]
    DFIX --> TEX2
    BFIX --> TEX2
    RFIX --> P1

    TEX2 --> P1

    P2 --> LOG2[Compilation Log]
    LOG2 --> QAA2{QA Agent\nFinal Check}
    QAA2 -->|Clean| PDF[untitled-1.pdf — VALID]
    QAA2 -->|Residual warning| WARN[Log warning; proceed]
```

---

## 3. QA Self-Healing State Machine

The QA subsystem operates as a four-state deterministic finite automaton (documented in §5.4):

| State | Name | Description |
|-------|------|-------------|
| S1 | Document Assembled | `.tex` source assembled by Orchestrator; compilation not yet triggered |
| S2 | Compilation Running | LuaLaTeX invoked; engine processing in progress |
| S3 | Log Analysis | Compilation log intercepted; QA Agent classifying errors |
| S4 | Source Repair | `qa-repair-agent` dispatched to `.tex` file; fix applied |

### State Transition Table

| From | To | Trigger | Responsible Agent |
|------|-----|---------|------------------|
| S1 | S2 | `.tex` passed to LuaLaTeX | Orchestrator |
| S2 | S3 | Compiler exits (success or failure) | QA Agent |
| S3 | S4 | Error classified in log | `qa-repair-agent` |
| S3 | [Done] | No errors detected | QA Agent |
| S4 | S2 | Repaired `.tex` re-submitted (hbox / delimiter / BiDi) | QA Agent |
| S4 | S1 | `Undefined reference` — local repair impossible; Orchestrator restarts | `qa-super` |
| S4 | [Done] | Repair successful; Pass 2 clean | QA Agent |

---

## 4. Error Taxonomy and Remediation Protocols

The QA Agent recognizes and remediates four canonical error classes. Risk Priority Number (RPN) = Severity × Probability × Detection (documented in §5.3).

### 4.1 Error Class 1: Overfull `\hbox` Boundary

| Attribute | Value |
|-----------|-------|
| State Transition | S2 → S3 |
| Triggering Agent | `qa-repair-agent` |
| Log Pattern | `Overfull \hbox (Xpt too wide)` |
| Root Cause | Table column widths exceed text area; or long unbreakable strings in paragraphs |
| Remediation | Inject horizontal scaling filters; convert column spec to `p{width}`; apply `\resizebox{\textwidth}{!}{...}` wrapper |

**Instances in this document and their resolutions:**

| Table | Initial Issue | Resolution Applied |
|-------|-------------|-------------------|
| Table 2 (Architectural Comparison) | `p{2.2cm}` columns too narrow for cell content | Widened to `p{5.5cm}` for the Status column |
| Table 4 (Self-Healing Transitions) | `p{5.5cm}` remediation column overflow | Applied `\makebox[\textwidth][c]{...}` wrapper |
| Tables 5, 6, 7 (Case Studies + Performance) | Multiple columns with data values exceeded margin | Applied `\resizebox{\textwidth}{!}{...}` |

---

### 4.2 Error Class 2: Missing Delimiter

| Attribute | Value |
|-----------|-------|
| State Transition | S2 → S3 |
| Triggering Agent | `qa-repair-agent` |
| Log Pattern | `Missing $ inserted`, `Missing } inserted`, `Runaway argument` |
| Root Cause | Mathematical expressions with unmatched `$` delimiters; unmatched `{...}` in macro arguments |
| Remediation | Parse mathematical token rows; insert missing `$` closure or `}` brace at detected position |

**Preventive measures implemented in this document:**
- All equation environments use the `equation` environment (not raw `$$...$$` except for two display-math expressions)
- TikZ node labels with mathematical content use `$...$` explicitly
- All `\frac`, `\sum`, `\sqrt` expressions validated for matching delimiters

---

### 4.3 Error Class 3: BiDi Alignment Shift

| Attribute | Value |
|-----------|-------|
| State Transition | S3 → S4 |
| Triggering Agent | `qa-repair-agent` (per Table 4 in source) |
| Log Pattern | Font encoding warning; misaligned text direction |
| Root Cause | Mixed RTL (Hebrew) and LTR (English) character sequences in compiled output |
| Remediation | Wrap mixed-language tokens in directional containment box; replace raw Unicode accents with LaTeX sequences |

**Implementation in this document:**
- All Hebrew-language text is confined to LaTeX comment lines (`%`) — it does not appear in compiled output. This eliminates BiDi compilation risk at the source level.
- Italian accent characters in Case Study IV (`Virtù`, `Il Principe`) replaced with `Virt\`u` and standard LaTeX accent commands throughout.
- QA Agent intercepted unescaped `ù` and corrected to `\`u` (documented as a system capability example in §8.4.3).

---

### 4.4 Error Class 4: Unresolved Reference

| Attribute | Value |
|-----------|-------|
| State Transition | S4 → S1 |
| Triggering Agent | `qa-super` (Orchestrator-level intervention) |
| Log Pattern | `LaTeX Warning: Reference ... undefined`, `Citation ... undefined` |
| Root Cause | Forward `\ref{}` used before auxiliary file is written; `\cite{}` keys without corresponding `.bib` entries |
| Remediation | Force secondary compilation pass to allow `.aux` file to populate; or add missing reference entry |

**Instances in this document:**

| Issue | Log Warning | Status |
|-------|------------|--------|
| Forward references to all `\label{fig:...}` | `Reference undefined` on Pass 1 | **Resolved** by Pass 2 |
| Forward references to all `\label{tab:...}` | `Reference undefined` on Pass 1 | **Resolved** by Pass 2 |
| `\cite{lamport1994latex}` | `Citation undefined` | **Non-fatal** — inline reference list used; no `.bib` file |
| `\cite{wooldridge2009multiagent}` | `Citation undefined` | **Non-fatal** — same |
| `\cite{alavi2025robust}` | `Citation undefined` | **Non-fatal** — same |

**Note on citation warnings:** These three citation warnings are expected and non-fatal. The `cite` package requires a `.bib` file for `\cite{}` key resolution. Since the document uses an inline reference list (§References) rather than BibTeX, the warnings persist in the `.log` file but do not cause compilation failure or missing text in the PDF. However, note that the 12-entry inline reference list contains an entry for Lamport (`lamport1994latex`) but has **no matching entries** for Wooldridge (`wooldridge2009multiagent`) or Alavi (`alavi2025robust`). Those two keys remain permanently unresolved — not just due to the absence of a `.bib` file, but because no inline entry for these authors exists anywhere in the document.

---

## 5. Pre-Compilation Syntax Scan Results

Before each `lualatex` invocation, the QA Agent runs a regex-pattern scan of the assembled `.tex` source. Results for `untitled-1.tex`:

| Check | Pattern | Result |
|-------|---------|--------|
| Unescaped `_` outside math | `[^\\]_[^{]` outside `$...$`, `equation`, `lstlisting` | **PASS** — all underscores in code listings are protected |
| Unescaped `%` outside comments | `[^\\]%` in non-comment position | **PASS** — `%` in tables escaped as `\%` (e.g., `2.1\%`) |
| Unescaped `&` outside tabular | `&` outside `tabular`, `equation` | **PASS** — all `&` are within tabular or align environments |
| Unmatched `\begin{...}` | `\begin` without matching `\end` | **PASS** — all environments properly closed |
| Empty `\cite{}` keys | `\cite\{\}` | **PASS** — no empty citation commands |
| Undefined `\ref{}` targets | `\ref{...}` with no matching `\label` | **PASS** — all referenced labels exist in source |
| TikZ missing semicolons | `\path` or `\node` without `;` | **PASS** — all TikZ statements properly terminated |

---

## 6. Per-Section QA Validation Results

### Section 1–2: Introduction and Methodology

| Check | Status | Notes |
|-------|--------|-------|
| All equations numbered correctly | ✓ PASS | η_a displayed via `$$...$$`; subsequent equations use `equation` env |
| Figure 1 (TikZ) renders without errors | ✓ PASS | Node placement adjusted with `xshift` |
| Figure 2 (TikZ) renders without errors | ✓ PASS | `\tikzstyle` defined inline within figure |
| Table 1 (booktabs) no hbox overflow | ✓ PASS | `lp{3.0cm}p{3.0cm}p{5.5cm}` spec validated |

### Section 3: Conceptual Evaluation Framework

| Check | Status | Notes |
|-------|--------|-------|
| Table 2 (bordered) renders cleanly | ✓ PASS | `\makebox[\textwidth][c]` wrapper applied |
| Figure 3 (pgfplots ybar) renders | ✓ PASS | `xtick=data` added; `symbolic x coords` correct |
| Accuracy bar chart data (1, 2, 3) | ✓ PASS | Conceptual/illustrative values, not empirical |

### Section 4: Data Analysis

| Check | Status | Notes |
|-------|--------|-------|
| Table 3 (booktabs, 7 columns) no overflow | ✓ PASS | `lcccccc` narrow numeric columns; `\small` font |
| All MCDA equations compile | ✓ PASS | B_i, CER_i, x̂_ij, E_j, W̃_k — all equation environments valid |
| Statistical formulas (μ, σ, Cov, ρ) | ✓ PASS | Display math using `$$...$$` |

### Section 5: QA and Self-Healing

| Check | Status | Notes |
|-------|--------|-------|
| Table 4 (bordered, risk table) | ✓ PASS | `\makebox[\textwidth][c]` wrapper |
| Listing 1 (bash) | ✓ PASS | `language=bash, caption={...}` correctly formed |
| T_loop equation | ✓ PASS | Multi-term equation in `equation` environment |

### Section 6: Agent Specifications

| Check | Status | Notes |
|-------|--------|-------|
| W_cell formula in display math | ✓ PASS | `$$...$$` used for inline formula display |
| Citation agent RegEx equation | ✓ PASS | Uses `\leftarrow` and `\text{...}` correctly |

### Section 7: Conclusion

| Check | Status | Notes |
|-------|--------|-------|
| Figure 4 (TikZ practical workflow) | ✓ PASS | `agentblock` style with multi-line node content |

### Section 8: Case Studies

| Check | Status | Notes |
|-------|--------|-------|
| r > g equation (Case Study I) | ✓ PASS | Single-line `equation` environment |
| Table 5 (resizebox) | ✓ PASS | `\resizebox{\textwidth}{!}` applied |
| Virtù accent (Case Study IV) | ✓ PASS | `Virt\`u` used throughout; not raw `ù` |
| E = ψ(Virtù, Fortuna) equation | ✓ PASS | `\psi` and `\text{Virt\`u}` correctly escaped |
| Table 6 (resizebox) | ✓ PASS | `\resizebox{\textwidth}{!}` applied |

### Section 9–10: Implementation and Performance

| Check | Status | Notes |
|-------|--------|-------|
| L(t) = α·log(t) + β·t² equation | ✓ PASS | `equation` environment; `\alpha`, `\beta`, `\log` commands |
| Table 7 (resizebox) | ✓ PASS | `\resizebox{\textwidth}{!}` applied |

### Appendix

| Check | Status | Notes |
|-------|--------|-------|
| Figure 5 (TikZ chunking) | ✓ PASS | `teal!80` color; `Stealth` arrows |
| Listing 2 (Python) | ✓ PASS | `language=Python` correctly specified |
| Figure 6 (pgfplots line) | ✓ PASS | Two `addplot` coordinates; `ymajorgrids=true` |
| `\setcounter{section}{0}` appendix reset | ✓ PASS | Appendix lettering works: A.1–A.16 |

---

## 7. Compilation Artifacts Validation

| Artifact | Expected | Actual | Status |
|---------|----------|--------|--------|
| `untitled-1.pdf` | 55 pages | 55 pages (`.aux` line: `\gdef \@abspage@last{55}`) | ✓ PASS |
| `untitled-1.aux` | Cross-reference index | Present; 129 lines | ✓ PASS |
| `untitled-1.toc` | 94 TOC entries | Present; 94 entries | ✓ PASS |
| `untitled-1.out` | Hyperref bookmarks | Present | ✓ PASS |
| `untitled-1.log` | Compilation diagnostics | Present | ✓ PASS |
| `untitled-1.synctex.gz` | SyncTeX mapping | Present | ✓ PASS |
| `custom-academic-report.cls` | Written by filecontents* | Present; 36 lines | ✓ PASS |

---

## 8. Known Limitations and Accepted Risks

| Issue | Severity | Decision |
|-------|----------|---------|
| `\cite{wooldridge2009multiagent}` and `\cite{alavi2025robust}` warnings — no matching inline entries | Low | Accepted — warnings are non-fatal; the two cited works are not in the 12-entry reference list |
| `\cite{lamport1994latex}` warning | Low | Accepted — Lamport entry exists inline but `cite` package cannot link without `.bib` |
| Minor `Underfull \hbox` warnings from double spacing | Low | Accepted — no visual impact on output |
| `\nocite{*}` with no `.bib` file | Low | Accepted — design decision to use inline references |
| Illustrative data in Tables 2, 3, 7 and Figures 3, 6 | N/A | Documented explicitly in paper as conceptual/illustrative |
| §6 refers to "50-page manuscript"; actual PDF is 55 pages | Low | Discrepancy in source paper; final compiled artifact is 55 pages (confirmed via `.aux`) |
| §9 refers to "BibLaTeX for bibliography management"; no BibLaTeX toolchain used | Low | Implementation used inline reference section; BibLaTeX mention in §9 is inaccurate |
| Figure 4 agentblock excludes Table Agent | Low | Source paper omission; Table Agent appears in Figure 1 and Table 1 but not in Figure 4 |

---

## 9. QA Sign-Off

| Deliverable | QA Status | Validator |
|-------------|-----------|-----------|
| `untitled-1.pdf` — 55 pages | **PASSED** | QA Agent (automated) + Manual review |
| All 7 tables — no hbox overflow | **PASSED** | QA Agent |
| All 6 figures — compile without error | **PASSED** | QA Agent |
| All 14+ equations — numbered correctly | **PASSED** | QA Agent |
| TOC — all 94 entries with page numbers | **PASSED** | LuaLaTeX Pass 2 |
| Hyperlinks — blue, clickable | **PASSED** | Visual inspection |
| Custom class — loaded from filecontents* | **PASSED** | LuaLaTeX Pass 1 |
