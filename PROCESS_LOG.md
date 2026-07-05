# Process Log

**AI-Driven Automatic Academic Book Report Generator**  
Version 1.0 | Bar-Ilan University, June 2026

---

## Overview

This log reconstructs the development timeline based on the project artifacts and the explicit development narrative documented in §7.1 and §9 of `untitled-1.tex`. It reflects the iterative workflow that combined Gemini CLI for content generation with LuaLaTeX for compilation and manual validation.

---

## Phase 1: Project Scoping and Architecture Design

### Milestone 1.1 — Course Requirements Analysis

**Objective:** Understand the deliverable requirements for the course "Advanced Artificial Intelligence Systems: Introduction to LLMs, Agents, and Multi-Agent Systems."

**Activities:**
- Identified that the deliverable must demonstrate understanding of LLMs, agent architectures, and multi-agent systems.
- Selected a practical domain (academic book report generation) that naturally maps to multi-agent decomposition.
- Defined the architectural thesis: replace monolithic LLM prompting with a hierarchical multi-agent pipeline.

**Decisions made:**
- Paper title: *AI-Driven Automatic Academic Book Report Generation Using LaTeX and Multi-Agent Systems*
- Primary framework: Hierarchical orchestration with specialized Level 0/1/2 agents
- Output format: LuaLaTeX-compiled academic PDF

---

### Milestone 1.2 — Custom LaTeX Class Design

**Objective:** Define the typographic environment for the paper.

**Activities:**
- Designed `custom-academic-report.cls` as an extension of the `article` class.
- Selected packages: geometry (margins), amsmath family (equations), booktabs (tables), tikz+pgfplots (diagrams), hyperref (navigation), listings (code), setspace (double spacing), microtype (typography).
- Configured TikZ libraries: `shapes.geometric`, `arrows.meta`, `positioning`.
- Set `pgfplots` compatibility to `1.18`.

**Decision: `filecontents*` embedding**
The class file is written inside a `filecontents*[overwrite]{custom-academic-report.cls}` block at the very beginning of `untitled-1.tex`. This guarantees the class is always written to disk before `\documentclass{custom-academic-report}` is processed, eliminating file-not-found errors.

**Outcome:** `custom-academic-report.cls` (36 lines) defined and testable.

---

### Milestone 1.3 — Document Structure Definition

**Objective:** Finalize the paper's section hierarchy and content roadmap.

**Outcome — Final section structure:**
```
§1  Introduction and Research Background (5 subsections)
§2  Methodological Framework (10 subsections)
§3  Conceptual Evaluation Framework (6 subsections)
§4  Data Analysis and Mathematical Modeling (6 subsections)
§5  System Output Generation and Autonomous Quality Assurance (4 subsections)
§6  Proposed Book Report Generation Subsystems and Agent Specifications (5 subsections)
§7  Conclusion and Future Horizons (8 subsections)
§8  Empirical Evaluation and Systemic Case Studies (4 subsections)
§9  Practical Implementation and Development Process
§10 System Performance Analysis, Discussion and Future Work (5 subsections)
A   Appendix: Extended Comprehensive Multi-Agent Codebase (16 subsections)
    References (12 entries)
```

---

## Phase 2: Content Generation via Gemini CLI

### Milestone 2.1 — Section 1: Introduction

**Objective:** Establish the theoretical motivation for the multi-agent approach.

**Key content generated:**
- Automated book report generation concept (§1.1)
- Paradigm shift from monolithic LLMs to multi-agent systems (§1.2)
- Agentic efficiency metric η_a formulation (§1.3):
  ```
  η_a = Σ (A_c · log(C_w)) / (T_s · Δt_i)
  ```
- RAG dual-layer memory model (§1.4)
- Token resource constraint problem (§1.5)

**Compilation check:** Title page, TOC, Section 1 compile cleanly.

---

### Milestone 2.2 — Section 2: Methodological Framework + Figure 1 + Table 1

**Objective:** Formalize the mathematical framework and produce the first TikZ architecture diagram.

**Key content generated:**
- Predictive modeling methodology (§2.1)
- Figure 1 (TikZ): System Architecture Flowchart — User → Orchestrator → [Text/Table/Citation Agents] → QA → LuaLaTeX → PDF
- Figure 2 (TikZ): Four-step horizontal pipeline (Query Ingestion → RAG Retrieval → Parallel Inference → QA Verification)
- Table 1 (booktabs): Agent Roles and Responsibilities (4 columns: Agent, Input, Output, Responsibility)
- MCDA formulation: B_i = Σ W_j · S_ij (§2.5)
- CEA formulation: CER_i = TokenCost_i / B_i (§2.6)
- Min-Max normalization formulas (§2.7)
- Shannon entropy weight model (§2.8)
- Sensitivity perturbation model: W̃_k = W_k − (δ·W_k)/(1−W_j) (§2.9)

**Compilation issue encountered:** TikZ `node distance` parameter for Figure 1 caused overlapping labels in the parallel agent layer. Adjusted `xshift` on left/right nodes.

**Resolution:** Added `xshift=-0.5cm` to the text agent node and `xshift=0.5cm` to the citation agent node.

---

### Milestone 2.3 — Section 3: Conceptual Evaluation Framework + Figure 3 + Table 2

**Objective:** Present the three-layer architecture and comparative framework.

**Key content generated:**
- Three-layer model: Software Layer → Skill Layer → Agent Layer (§3.3)
- Hierarchical orchestration levels (Level 0/1/2) (§3.4)
- Raft consensus protocol for state synchronization (§3.5)
- Concurrency containment rings (§3.6)
- Table 2: Illustrative Architectural Comparison (bordered table with `\hline`)
- Figure 3 (pgfplots ybar): Model Classification Accuracy Comparison (J48, Random Forest, Hierarchical Multi-Agent)

**Compilation issue encountered:** `pgfplots` `ybar` with `symbolic x coords` required explicit `xtick=data` setting to display labels correctly.

**Resolution:** Added `xtick=data` to the `axis` environment options.

---

### Milestone 2.4 — Section 4: Data Analysis and Mathematical Modeling + Table 3

**Objective:** Demonstrate the greedy CER optimization with concrete numerical examples.

**Key content generated:**
- Four evaluation criteria with weights: C_1(0.35), C_2(0.25), C_3(0.20), C_4(0.20) (§4.1)
- Table 3 (booktabs): Five content modules with scores and CER values (§4.2)
- Greedy selection: Philosophical Synthesis (3.0M) → Character Analysis (4.0M) → Thematic Summary (6.0M) = 13.0M tokens, B=228.5 (§4.3)
- Descriptive statistics: μ_text = 1,933.3 tokens, σ_text = 924.1 (§4.4)
- Covariance and Pearson correlation: ρ(complexity, citation density) = +0.86 (§4.5)
- OLS regression model: Y_p = β_0 + β_1X_thematic + ... + ε (§4.6)

---

### Milestone 2.5 — Section 5: QA and Self-Healing + Table 4 + Listing 1

**Objective:** Specify the autonomous QA loop and risk framework.

**Key content generated:**
- Deterministic compilation pipeline (§5.1)
- Listing 1 (bash): Two-pass LuaLaTeX invocation
- QA closed feedback loop description (§5.2)
- Table 4: Self-Healing State Transitions (S2↔S3↔S4; 4 error classes; RPN) (§5.3)
- Latency decomposition: T_loop = Δt_intercept + Δt_semantic_search + Δt_llm_inference + Δt_recompilation (§5.4.1)

---

### Milestone 2.6 — Section 6: Agent Specifications

**Objective:** Formally specify each agent's internal mechanics.

**Key content generated:**
- Text Agent: CoT framework, drift prevention, narrative scope (§6.1)
- Table Agent: W_cell(c) = W_total · (γ_c / Σγ_k) formula; p{width} enforcement (§6.2)
- Visualization Agent: TikZ coordinate mapping from topology metadata (§6.3)
- Citation Agent: RegEx replace pipeline; IEEE style; cross-reference validation (§6.4)
- QA/BiDi Agent: String buffer monitoring; directional containment; accent handling (§6.5)

---

### Milestone 2.7 — Section 7: Conclusion + Figure 4

**Objective:** Synthesize findings, document lessons learned, and produce the practical workflow diagram.

**Key content generated:**
- Practical development experience narrative (§7.1) — including explicit mention of Gemini CLI
- Figure 4 (TikZ): Practical Multi-Agent Workflow (User → Orchestrator → [Text/Citation/QA Agents] → LuaLaTeX → PDF). Note: the `agentblock` in Figure 4 shows Text Agent, Citation Agent, and QA Agent only — Table Agent is not represented in this diagram, unlike Figure 1 which shows all five agents.
- Document chunking topology (§7.3)
- System limitations: inference latency, context window dilution (§7.6)
- Future research directions: RL, symbolic reasoning, multimodal agents (§7.8)

---

### Milestone 2.8 — Section 8: Case Studies + Tables 5 and 6

**Objective:** Validate the architecture across four literary genres.

**Case studies generated:**

| Case Study | Book | Key Challenge | Notable Output |
|------------|------|--------------|----------------|
| CS-I | Piketty, *Capital in the 21st Century* | Quantitative data, r > g formula | Table 5 with resizebox; context allocation metrics |
| CS-II | Turing, *On Computable Numbers* | Code notation, escaped specials | lstlisting compartmentalization; state machine description |
| CS-III | Kuhn, *The Structure of Scientific Revolutions* | Abstract philosophy, citation linking | `\begin{quote}` environments; CoT adaptation |
| CS-IV | Machiavelli, *The Prince* | Archaic rhetoric, `Virtù` accents, BiDi | E=ψ(Virtù,Fortuna) formula; Table 6; QA accent repair |

**Compilation issue encountered (Case Study IV):** Raw accent character `ù` in Italian phrases caused font encoding error. 

**Resolution:** Replaced with `Virt\`u` and `Il Principe` LaTeX accent sequences throughout. QA accent repair documented as a system capability demonstration.

---

### Milestone 2.9 — Sections 9–10: Implementation and Performance

**Objective:** Document the practical implementation experience and performance characteristics.

**Key content generated:**
- Practical implementation summary (§9): LuaLaTeX environment, iterative workflow
- Latency model: L(t) = α·log(t) + β·t² (§10.2)
- Table 7 (resizebox): Comprehensive performance matrix across 4 document tiers (§10.3)
- Discussion of architectural trade-offs: overhead vs. robustness (§10.5)

---

## Phase 3: Appendix, Code Listings, and Figures

### Milestone 3.1 — Appendix A (16 subsections)

**Objective:** Provide extended technical depth including code, advanced methodology, and enterprise topics.

**Key content generated:**
- Figure 5 (TikZ): Dynamic Book Chunking Flowchart (§A.1)
- Listing 2 (Python): `LocalWorkspaceManager` class — `write_agent_artifact()`, `purge_temporary_artifacts()` (§A.2)
- Figure 6 (pgfplots line chart): QA Repair Latency — automated vs. manual (data points at 5, 10, 15, 20 chapters) (§A.3)
- WEKA subsystem: J48 decision tree, Random Forest, Naive Bayes evaluation (§A.7)
- Genetic algorithm vs. linear search analysis (§A.8)
- Cybersecurity zero-trust topology (§A.10)
- Vector store optimization and cluster pruning (§A.12)
- Ethical alignment and intellectual property safeguards (§A.15)

**Note on Figure 6 source:** The `pgfplots` line chart source retains `fill=blue!20, thick` inside the `addplot` options (lines 914–953 of `untitled-1.tex`). The `fill` attribute is non-standard for line charts (it applies to area-fill charts), but LuaLaTeX compiles the figure without a fatal error. The line chart renders correctly in the PDF; the `fill` attribute has no effect on a standard `addplot` without `\closedcycle`.

---

### Milestone 3.2 — References Section

**Objective:** Format 12 references in IEEE style as inline LaTeX.

**Format used:**
```latex
\section*{References}
\addcontentsline{toc}{section}{References}
\noindent [1] Author, Title, Venue, Year.
\vspace{0.3cm}
\noindent [2] ...
```

**Note:** No `.bib` file or BibTeX/BibLaTeX toolchain. Citation keys `lamport1994latex`, `wooldridge2009multiagent`, `alavi2025robust` used in body text via `\cite{}` produce `undefined citation` warnings (non-fatal) since the cite package does not find a `.bib` file. The 12-entry inline reference list contains entries for Lamport (`lamport1994latex`) but has no matching entries for Wooldridge (`wooldridge2009multiagent`) or Alavi (`alavi2025robust`); those two keys remain unresolved. Section §9 of the paper also refers to "BibLaTeX for bibliography management" despite no BibLaTeX toolchain being used — the implementation decision was to use the manually-typeset inline section instead (see DEVELOPMENT_PROCESS.md §6.2).

---

## Phase 4: Final Compilation and Validation

### Milestone 4.1 — Two-Pass Final Compilation

```bash
lualatex --interaction=nonstopmode untitled-1.tex  # Pass 1
lualatex --interaction=nonstopmode untitled-1.tex  # Pass 2
```

**Pass 1 outputs:**
- `custom-academic-report.cls` written to disk via `filecontents*`
- `untitled-1.aux` created (cross-reference index)
- `untitled-1.toc` created (section→page map for 94 entries)
- `untitled-1.out` created (hyperref bookmarks)

**Pass 2 outputs:**
- All `\ref{}` and `\pageref{}` resolved
- TOC page numbers populated
- Figure and table numbers finalized
- `untitled-1.pdf` (55 pages) generated
- `untitled-1.synctex.gz` generated

### Milestone 4.2 — PDF Validation

**Checks performed:**

| Check | Result |
|-------|--------|
| Total page count | 55 pages (`\gdef \@abspage@last{55}`) |
| Table of contents entries | 94 entries (§1–§10, Appendix A.1–A.16, References) |
| Figure count | 6 (all numbered, all captioned, all labeled) |
| Table count | 7 (all numbered, all captioned, all labeled) |
| Equation environments | 14+ numbered equations |
| Code listings | 2 (Listing 1: bash, Listing 2: Python) |
| Reference entries | 12 inline entries |
| Hyperlinks | Blue, clickable (linkcolor, citecolor, urlcolor = blue) |
| Double spacing | Applied via `\doublespacing` in class |
| Custom class loaded | `custom-academic-report.cls` loaded correctly |

**Outstanding non-fatal warnings (log):**
- `undefined citations` for `lamport1994latex`, `wooldridge2009multiagent`, `alavi2025robust` — expected; no `.bib` file used
- Minor `Underfull \hbox` warnings from double spacing in narrow text blocks — non-impacting

---

## Phase 5: Documentation Generation

### Milestone 5.1 — Engineering Documentation Suite

**Objective:** Reverse-engineer the completed project into professional software engineering documentation.

**Documents generated:**
1. `PROJECT_STRUCTURE.md` — File inventory and anatomy
2. `README.md` — Project overview and quick start
3. `PRD.md` — Product requirements document
4. `SYSTEM_ARCHITECTURE.md` — Architecture with Mermaid diagrams
5. `AGENTS.md` — Full agent specifications with interaction matrices
6. `DEVELOPMENT_PROCESS.md` — Methodology and architectural decisions
7. `PROCESS_LOG.md` — This document
8. `QA_REPORT.md` — Quality assurance analysis
9. `TESTING_REPORT.md` — Case study testing report
10. `DEPLOYMENT_GUIDE.md` — Compilation and deployment instructions
