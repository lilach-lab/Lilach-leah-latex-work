# AI-Driven Automatic Academic Book Report Generation Using LaTeX and Multi-Agent Systems

> **Bar-Ilan University** | Faculty of Social Sciences — Technology Management  
> **Authors:** Leah Maman & Lilach Grad (3rd Year Undergraduate, Technology Management)  
> **Course:** Advanced Artificial Intelligence Systems: Introduction to LLMs, Agents, and Multi-Agent Systems  
> **Date:** June 2026

---

## Overview

This project delivers a 58-page academic research paper that proposes, designs, and conceptually evaluates a **hierarchical multi-agent AI pipeline** for automated academic book report generation. The deliverable is a fully compiled, publication-ready PDF produced by a two-pass **LuaLaTeX** compilation of a single self-contained source file.

The paper demonstrates how a network of specialized autonomous agents — governed by the **ReAct** (Reasoning and Acting) paradigm — can decompose the complex task of academic document synthesis into isolated, verifiable subtasks. Each agent owns a specific responsibility: text generation, table layout, bibliography management, TikZ diagram construction, or quality assurance. An **Orchestrator Agent** coordinates all agents, routes content, and manages a closed self-healing feedback loop.

---

## System at a Glance

The primary orchestration topology (matching Figure 1 and Table 1 in the paper):

```
User Request
      │
      ▼
┌─────────────────────────────────────────────────┐
│              Orchestrator Agent                  │  ← Level 0 (qa-super)
└─────────────────────────────────────────────────┘
   │                │                │
   ▼                ▼                ▼
Text Agent      Table Agent     Citation Agent     ← Level 1 specialists (parallel)
   │                │                │
   └────────┬────────┴────────┘
            ▼
         QA Agent                                  ← Level 2 (qa-repair-agent)
         │      └── BiDi Agent (conditional only)
         ▼
   LuaLaTeX Engine  (two passes)
         │
         ▼
  Final PDF Document (58 pages)
```

> This topology matches Figure 1 and Table 1 of the paper. Level-1 agents return structured JSON payloads to the Orchestrator, which assembles the complete `.tex` source before forwarding to the QA Agent. The BiDi Agent is invoked conditionally — only when bidirectional text drift is detected. A Visualization Agent (§6.3) generates the 6 TikZ/pgfplots figures as a diagram production subsystem; it does not appear in the primary Figure 1 orchestration flow. See `SYSTEM_ARCHITECTURE.md` for the full topology and sequence diagram.

**Inter-Agent Communication:** All agents communicate via structured JSON payloads over dedicated per-agent channels. A zero-trust sanitization layer scrubs every payload before it reaches the LuaLaTeX compiler. This design intentionally avoids a centralized message broker. For context, the standardized alternative — the Model Context Protocol (MCP) — defines a formalized protocol for agent-tool and agent-context communication; the architectural rationale for choosing direct JSON payloads over MCP is documented in `ADR.md §ADR-004`.

The system applies **Retrieval-Augmented Generation (RAG)** via a dual-layer memory model:
- **Short-term memory** — active context window caching intermediate state
- **Long-term memory** — external vector database storing style templates and historical fix patterns

---

## Project Artifacts

| Artifact | Description |
|----------|-------------|
| `untitled-1.tex` | Complete LaTeX source (1,064 lines). Contains the class definition, all 10 sections, 6 TikZ figures, 7 tables, 14+ equations, 2 code listings, and 12 references. |
| `custom-academic-report.cls` | Custom document class (auto-written from the source on first compile). Extends `article` with double spacing, booktabs, TikZ, pgfplots, and hyperref. |
| `untitled-1.pdf` | Compiled output — 58-page, double-spaced academic paper. |
| `untitled-1.aux/.toc/.out/.log/.synctex.gz` | Standard LuaLaTeX build artifacts. |

---

## Quick Start

### Prerequisites

| Dependency | Purpose |
|------------|---------|
| **TeX Live 2023+** or **MiKTeX 23+** | LaTeX distribution |
| **LuaLaTeX** | Compiler (included in any modern TeX distribution) |
| Packages: `amsmath`, `geometry`, `booktabs`, `cite`, `hyperref`, `listings`, `tikz`, `pgfplots`, `microtype`, `setspace`, `graphicx` | All included in TeX Live full / MiKTeX basic + manager |

### Compile

```bash
# Two passes required to resolve cross-references, TOC, and figure/table labels
lualatex --interaction=nonstopmode untitled-1.tex
lualatex --interaction=nonstopmode untitled-1.tex
```

The first pass writes `untitled-1.aux`, `untitled-1.toc`, and `custom-academic-report.cls` (via the embedded `filecontents*` block). The second pass reads those files and resolves all forward references.

### Expected Output

```
untitled-1.pdf   (58 pages)
```

---

## Paper Structure

| Section | Title | Key Content |
|---------|-------|-------------|
| 1 | Introduction and Research Background | Problem statement; paradigm shift from monolithic LLMs; η_a efficiency metric; RAG memory topology |
| 2 | Methodological Framework | MCDA/CEA formulations; agent execution mechanics; Shannon entropy weight tuning; Figure 1 (architecture); Table 1 (agent roles) |
| 3 | Conceptual Evaluation Framework | Three-layer agentic framework; Raft consensus protocol; concurrency containment rings; Figure 3 (accuracy bar chart) |
| 4 | Data Analysis and Mathematical Modeling | Five-component optimization under 18M-token budget; CER greedy selection; statistical variance (μ=1,933 tokens, σ=924) |
| 5 | System Output Generation and Autonomous Quality Assurance | LuaLaTeX CLI pipeline; self-healing feedback loop; state machine S1→S4; RPN risk table |
| 6 | Proposed Book Report Generation Subsystems and Agent Specifications | Per-agent specifications: Text, Table, Visualization, Citation, QA/BiDi agents |
| 7 | Empirical Evaluation and Systemic Case Studies | Four case studies: Piketty, Turing, Kuhn, Machiavelli |
| 8 | Practical Implementation and Development Process | Development environment; iterative workflow; challenges encountered |
| 9 | System Performance Analysis, Discussion and Future Work | Latency model L(t); repair rates; performance matrix (Table 7) |
| 10 | Conclusion and Future Horizons | Practical lessons from Gemini CLI development; document chunking; ethical safeguards |
| A | Appendix | Python workspace manager; chunking flowchart; WEKA subsystem; 16 extended subsections |

---

## Mathematical Models Implemented

| Symbol | Model | Location |
|--------|-------|----------|
| η_a | Agentic efficiency metric | §1.3 |
| B_i | MCDA weighted benefit score | §2.5 |
| CER_i | Cost-Effectiveness Ratio | §2.6 |
| x̂_ij | Min-Max normalization | §2.7 |
| E_j | Shannon entropy objective weight | §2.8 |
| W̃_k | Sensitivity perturbation model | §2.9 |
| W_cell(c) | Table column width allocation | §6.2 |
| T_loop | Self-healing latency decomposition | §5.4.1 |
| L(t) | Compilation latency function α·log(t)+β·t² | §9.2 |
| Y_p | Regression priority index (OLS) | §4.6 |
| μ_text / σ_text | Token density mean and standard deviation across chapters | §4.4 |
| ρ_XY | Pearson inter-criterion correlation (ρ = +0.86 for complexity vs. citation density) | §4.5 |

---

## Authors

**Leah Maman** — Bar-Ilan University, Technology Management  
**Lilach Grad** — Bar-Ilan University, Technology Management

---

## References

12 references spanning AutoGen, ReAct, Reflexion, Attention Is All You Need, Generative Agents, Neural Turing Machines, GPT-3, LaTeX documentation (Knuth 1984, Lamport 1994), and autonomous chemical research. Of the 12 entries: 5 are peer-reviewed conference or journal papers (Vaswani et al. NeurIPS 2017, Boiko et al. Nature 2023, Park et al. UIST 2023, Brown et al. NeurIPS 2020, Williams 1992 Machine Learning), 5 are arXiv preprints (Wu et al., Xi et al., Shinn et al., Yao et al., Graves et al.), and 2 are foundational books (Knuth 1984, Lamport 1994).

**Citation notes (as of FIX_REPORT.md):**
- All `\cite{}` commands have been removed from the body text. The document compiles with zero undefined citation warnings. `\cite{lamport1994latex}` was replaced with `[2]`; `\cite{wooldridge2009multiagent}` and `\cite{alavi2025robust}` were removed.
- Reference [10] (Yao et al., ReAct) arXiv ID corrected from 2303.11366 → **arXiv:2210.03629**.

See `untitled-1.tex` §References for full citations.
