# Architecture Decision Records

**AI-Driven Automatic Academic Book Report Generation Using LaTeX and Multi-Agent Systems**  
Bar-Ilan University — Technology Management | June 2026  
Authors: Leah Maman & Lilach Grad

---

## Document Purpose

This document records the significant architectural decisions made during the design and implementation of the multi-agent academic book report generation system. Each record follows a consistent structure: the context that created the need for a decision, the alternatives that were evaluated, the advantages and trade-offs of the chosen path, and the final rationale.

ADRs are write-once records. They capture the reasoning at the time of decision, including constraints and knowledge that may not be apparent from the code or the final document alone.

---

## Index

| ID | Decision | Status |
|----|----------|--------|
| ADR-001 | Multi-Agent Architecture over Monolithic LLM | Accepted |
| ADR-002 | LuaLaTeX as the Compilation Engine | Accepted |
| ADR-003 | Inline Reference Section over BibLaTeX/BibTeX | Accepted |
| ADR-004 | Direct JSON Payload Communication over Standardized Agent Protocol | Accepted |
| ADR-005 | Retrieval-Augmented Generation (RAG) for Memory Architecture | Accepted |
| ADR-006 | Hierarchical Three-Level Agent Orchestration | Accepted |
| ADR-007 | TikZ/pgfplots for All Figures | Accepted |
| ADR-008 | Closed Autonomous Self-Healing QA Loop | Accepted |
| ADR-009 | Two-Pass Compilation with Automated PDF Validation | Accepted |
| ADR-010 | Modular Section-by-Section Content Generation | Accepted |

---

## ADR-001: Multi-Agent Architecture over Monolithic LLM

**Status:** Accepted  
**Date:** June 2026  
**Decided by:** Architecture team (Leah Maman, Lilach Grad)  
**Paper reference:** §1.2 — *The Paradigm Shift: From Monolithic LLMs to Autonomous Multi-Agent Systems*

### Decision

Design the system as a **hierarchical network of specialized autonomous agents** coordinated by a central Orchestrator, rather than using a single large language model invoked with a compound prompt.

### Context

Early automated document synthesis pipelines relied on single-prompt LLM instances. While these baseline configurations produce cohesive high-level prose, they fail to sustain formatting constraints across lengthy academic manuscripts. When a monolithic entity attempts to process divergent tasks concurrently — summarizing literary themes while maintaining strict citation mappings and computing table column widths — layout and semantic drift emerge.

The target deliverable is a publication-ready 58-page LaTeX document containing 7 tables, 6 diagrams, 14+ equations, and a structured bibliography. A monolithic LLM prompt for a document of this complexity faces two compounding failure modes: (1) context window exhaustion causing semantic drift as the document grows, and (2) simultaneous multi-domain constraint satisfaction degrading structural output quality (§1.2). The LaTeX compilation environment amplifies these failures — any structural error in the generated source produces a broken or empty PDF.

### Alternatives Considered

| Alternative | Assessment |
|-------------|-----------|
| **Single-prompt LLM** | Lowest engineering complexity. Fails on long documents due to context dilution, layout drift, and the inability to maintain synchronized constraints across prose, tables, citations, and diagrams simultaneously. |
| **Sequential single-agent pipeline** | One agent handles all tasks in sequence. Avoids context fragmentation but remains bottlenecked by a single context window; failures in one subtask propagate to all downstream steps. |
| **Rule-based templating system** | No LLM involvement; purely template-driven. Highly reproducible but completely inflexible — cannot adapt prose style, bibliography depth, or table layout to the specific literary source. |
| **Multi-agent with flat peer topology** | Agents coordinate without a central orchestrator. Eliminates orchestration bottleneck but introduces conflict resolution complexity: two agents may produce conflicting layout parameters with no authority to adjudicate. |

### Advantages

- **Functional isolation:** Each agent owns a single responsibility domain. Failures remain localized and do not cascade across the pipeline.
- **Parallel execution:** Level-1 agents (Text, Table, Citation) and the Visualization Agent diagram subsystem (§6.3) can execute concurrently, reducing total generation time.
- **Independent optimization:** Each agent can apply domain-specific techniques (e.g., Chain-of-Thought for prose, width pre-computation for tables) without interference.
- **Deterministic error attribution:** When a LaTeX compilation error occurs, the error class (hbox overflow, missing delimiter, BiDi drift, unresolved reference) maps to a specific agent's output, enabling targeted repair rather than full regeneration.
- **Scalability:** New agent types (e.g., a dedicated equation agent, a footnote agent) can be inserted into the pipeline without redesigning the Orchestrator.

### Trade-offs

- **Orchestration overhead:** Coordinating seven agents introduces latency, state management complexity, and potential message-channel failures absent in a single-model approach.
- **Consistency risk at assembly:** Merging outputs from parallel agents into a single coherent LaTeX source requires careful deduplication and boundary checking. If the Orchestrator's assembly logic is incorrect, inconsistencies can be introduced that no individual agent would have produced alone.
- **Engineering investment:** The multi-agent architecture requires significantly more design work than a single-prompt approach. For a proof-of-concept, this overhead is the principal cost.

### Final Choice

The multi-agent architecture was adopted because the compilation target — a structured, 58-page LaTeX academic paper with strict typographic constraints — exceeds what any single-context LLM invocation can reliably sustain. The cost of orchestration overhead is justified by the reduction in cascading failures and by the deterministic error attribution that the self-healing QA loop (ADR-008) requires to function.

---

## ADR-002: LuaLaTeX as the Compilation Engine

**Status:** Accepted  
**Date:** June 2026  
**Paper reference:** §5.1 — *The Deterministic Compilation Pipeline*; §9 — *Practical Implementation*

### Decision

Use **LuaLaTeX** (`lualatex --interaction=nonstopmode`) as the compilation engine, invoked twice per cycle via a secure CLI subprocess.

### Context

The system generates raw LaTeX source as its output format. A compilation engine must be chosen that: (1) supports the pgfplots and TikZ packages used for all six figures, (2) handles Unicode input cleanly for multi-language content (Italian accent sequences, Hebrew comment lines), (3) is invocable as a non-interactive CLI subprocess from an automated pipeline, and (4) produces a deterministic, reproducible PDF output.

### Alternatives Considered

| Alternative | Assessment |
|-------------|-----------|
| **pdfLaTeX** | Most widely used; faster than LuaLaTeX for simple documents. Does not natively support Unicode input or OpenType fonts. Less well-suited for pgfplots compat=1.18 in complex multi-figure documents. |
| **XeLaTeX** | Full Unicode and OpenType support. Supports the same packages. However, pgfplots performance and compat behaviour differ from LuaLaTeX; Lua scripting capability is absent. Less commonly used in automated pipeline contexts. |
| **Latexmk wrapper** | Automates multi-pass compilation by monitoring auxiliary files. Adds an external dependency and abstraction layer over the raw compiler; the system already manages pass control explicitly, making latexmk's automation redundant. |
| **Online compilation (Overleaf API)** | Removes local installation requirement. Introduces network dependency, authentication complexity, and rate-limiting — incompatible with autonomous pipeline design. |

### Advantages

- **Native Unicode support:** LuaLaTeX handles UTF-8 input natively, eliminating the `inputenc` package dependency and the risk of encoding failures on non-ASCII characters (§4.4 Case Study IV: `Virtù` accent handling).
- **OpenType font engine:** Provides clean microtypographic output via the `microtype` package.
- **pgfplots compatibility:** `compat=1.18` setting in `custom-academic-report.cls` is fully supported under LuaLaTeX, ensuring consistent rendering of all six TikZ/pgfplots figures.
- **Scripting capability:** Lua scripting is available within the document if needed for dynamic content generation in future iterations.
- **Deterministic non-interactive mode:** `--interaction=nonstopmode` ensures the compiler never pauses for user input, enabling fully automated pipeline operation. Exit codes signal success or failure to the QA Agent's log parser.

### Trade-offs

- **Compilation speed:** LuaLaTeX is meaningfully slower than pdfLaTeX for documents with multiple TikZ diagrams. For a 58-page document with 6 figures, each compilation pass takes noticeably longer than it would under pdfLaTeX. This is mitigated for development by the `tikzexternalize` library (noted in DEPLOYMENT_GUIDE.md §5.6) but not enabled by default.
- **Memory consumption:** LuaLaTeX's Lua VM consumes more RAM than pdfLaTeX. On constrained systems this can cause failures for very large documents.

### Final Choice

LuaLaTeX was selected because its Unicode handling, pgfplots compatibility, and non-interactive CLI mode are directly required by this system's design. The speed trade-off is acceptable for a proof-of-concept academic paper where compilation correctness takes priority over compilation throughput.

---

## ADR-003: Inline Reference Section over BibLaTeX/BibTeX

**Status:** Accepted  
**Date:** June 2026  
**Paper reference:** §6.4 — *The Bibliographic Parser and Citation Vector Agent*; §9 — *Practical Implementation*

### Decision

Format the document's 12 references as a **manually typeset inline `\section*{References}` block** using `\noindent [N] Author, Title, Venue, Year.` entries, rather than using a BibLaTeX or BibTeX toolchain with an external `.bib` file.

### Context

The project requires a bibliography of 12 references in IEEE style. Two toolchain architectures are available: (a) an external bibliography database (`.bib` file) processed by BibTeX or BibLaTeX/Biber, or (b) a manually formatted inline reference section requiring no additional compiler passes.

> **Documentation gap note:** §9 of the source paper states "the implementation environment was based on LuaLaTeX for document compilation and BibLaTeX for bibliography management." §6.4 describes the Citation Agent as building "a central `references.bib` flat-file database." Both statements describe the intended conceptual architecture. In the actual implementation, no `.bib` file was created and no BibTeX/BibLaTeX pass was executed — the references were manually typeset inline. This ADR documents the decision as actually implemented. The discrepancy between §9's stated intent and the implementation is recorded as a known limitation in `QA_REPORT.md §8`.

### Alternatives Considered

| Alternative | Assessment |
|-------------|-----------|
| **BibLaTeX + Biber** | Most powerful option: automatic formatting, cross-reference linking, re-ordering, de-duplication. Requires a `.bib` file, a `biber` execution pass, and a three-pass compilation sequence (pdflatex → biber → pdflatex × 2). Adds complexity to the autonomous pipeline. |
| **BibTeX (natbib / plain)** | Simpler than BibLaTeX; widely supported. Still requires a `.bib` file and an external `bibtex` pass between compiler invocations. Introduces a fourth build artifact that the pipeline must manage. |
| **`filecontents` embedded `.bib`** | Embeds the `.bib` file content inside the `.tex` source using `filecontents`, written to disk on Pass 1. Maintains the single-file design philosophy but still requires a BibTeX/Biber pass. |
| **Inline `\section*{References}` (chosen)** | Full manual control over formatting; no external tool dependency; no additional compilation pass; preserves the single-file, two-pass design. IEEE-style entries can be typed directly. |

### Advantages

- **Zero additional dependencies:** No BibTeX or Biber binary required in the deployment environment.
- **Preserved two-pass compilation:** The QA pipeline and DEPLOYMENT_GUIDE are built around exactly two LuaLaTeX passes. Adding a BibTeX pass would require a three-or-four-pass sequence and corresponding pipeline changes.
- **Single-file design coherence:** The entire document — content, class definition, figures, tables, and references — is contained in `untitled-1.tex`. Introducing a `.bib` file breaks this invariant.
- **Complete formatting control:** IEEE-style entries are formatted exactly as required without relying on a bibliography style file (`.bst`).

### Trade-offs

- **No programmatic linking:** Inline reference entries are reached only by scrolling to the §References section; there is no hyperlinked cross-reference from body text to entries as would exist in a BibTeX/BibLaTeX workflow.
- **Manual maintenance burden:** Adding, removing, or re-ordering references requires editing the inline entries by hand.
- **`\cite{}` commands removed from body text (FIX_REPORT.md §Fix 3):** All `\cite{Key}` commands in the document body were replaced with inline bracket citations (e.g., `[2]`) or removed, eliminating all `Citation undefined` warnings. The `lamport1994latex`, `wooldridge2009multiagent`, and `alavi2025robust` keys that previously produced non-fatal warnings no longer appear in the compiled source. The document now compiles with zero undefined citation warnings.

### Final Choice

Inline references were chosen to maintain the single-file, two-pass compilation design and to avoid introducing BibTeX/BibLaTeX as pipeline dependencies. For a 12-entry proof-of-concept bibliography, the maintenance burden is acceptable. As of FIX_REPORT.md, all unresolved citation warnings have been resolved by replacing `\cite{}` commands with direct inline bracket notation.

---

## ADR-004: Direct JSON Payload Communication over Standardized Agent Protocol

**Status:** Accepted  
**Date:** June 2026  
**Paper reference:** §2.4.1 — *The Orchestrator Agent and Dynamic Context Routing*; §5.2 — *QA and Environment-Aware Repair*; §A.10 — *Distributed Cybersecurity Validation Perimeters*

### Decision

Implement inter-agent communication via **structured JSON payloads over dedicated per-pair message channels**, rather than adopting a standardized agent communication protocol such as the Model Context Protocol (MCP) or an equivalent published specification.

### Context

Any multi-agent system requires a mechanism for agents to pass data, state, and instructions to one another. The choice of communication protocol affects: message structure predictability, the ability to validate and sanitize payloads at boundaries, debuggability of inter-agent state, and the dependency footprint of the system.

Standardized protocols such as MCP (Model Context Protocol) define a formal schema for tool invocation, context passing, and agent capability advertisement. They offer interoperability benefits but introduce a runtime dependency on the protocol implementation and a schema conformance requirement that may over-engineer a proof-of-concept system.

This project used **Gemini CLI** as its development environment. The agent communication model described in the paper reflects an architecture in which agents exchange structured data directly rather than through a named external protocol. No MCP implementation, schema registry, or protocol broker is referenced anywhere in the source.

### Alternatives Considered

| Alternative | Assessment |
|-------------|-----------|
| **MCP (Model Context Protocol)** | Formal, machine-readable schema for tool and context exchange between agents. Enables interoperability with MCP-compatible tooling. Requires a broker/server component; adds an external runtime dependency; designed primarily for tool-calling integrations rather than document assembly pipelines. |
| **OpenAI function calling schema** | Structured JSON schema for tool invocations. Well-defined and widely implemented. Vendor-specific; introduces dependency on OpenAI's API specification even if the underlying LLM is different (in this project, Gemini). |
| **Apache Kafka / message queue** | Durable, ordered message passing between agents via topics. Appropriate for production distributed systems. Massively over-engineered for a single-session proof-of-concept running on a local machine. |
| **Shared file system (artifacts on disk)** | Agents write output to disk; next agent reads it. Simple, debuggable, and platform-agnostic. Vulnerable to race conditions under concurrent execution unless file-locking is implemented (see `LocalWorkspaceManager`, Appendix A.2). |
| **Direct JSON payloads (chosen)** | Agents return structured JSON to the Orchestrator over dedicated per-pair message channels. No external broker. Format is schema-less but constrained by the Orchestrator's assembly logic. |

### Advantages

- **Zero external broker dependency:** The system requires no message queue server, protocol daemon, or schema registry. The entire communication infrastructure is the Orchestrator's state ledger.
- **Structural predictability:** Each agent returns a known payload shape (e.g., `{sections: [...]}` from the Text Agent, `{tables: [...]}` from the Table Agent). The Orchestrator can validate structure before assembly.
- **Security perimeter alignment:** A dedicated sanitization layer at the Orchestrator boundary scrubs all incoming agent payloads for illegal LaTeX macros and unescaped characters before assembly. This zero-trust model (§A.10) is straightforwardly implemented when all payloads pass through a single Orchestrator gateway — it would be architecturally awkward with a broadcast message bus.
- **Debuggability:** The Orchestrator's transient state ledger holds a complete record of all agent outputs for a given session. Failed assembly can be diagnosed by inspecting the ledger directly.
- **Simplicity at proof-of-concept scale:** The system is single-session (one user, one document at a time). A full protocol stack would add complexity with no benefit at this scale.

### Trade-offs

- **No interoperability:** Agent implementations are coupled to the Orchestrator's specific payload contracts. A third-party agent cannot participate in the pipeline without knowing the internal JSON schema.
- **No schema enforcement:** Without a formal schema (as MCP would provide), malformed payloads are caught only at assembly time, not at serialization time. This increases the surface area for subtle data-contract bugs.
- **No capability advertisement:** Agents cannot dynamically declare their capabilities or accept new task types at runtime. Adding a new agent type requires updating both the Orchestrator dispatch logic and the new agent's payload contract manually.
- **Undocumented protocol:** The JSON payload format is implicit in the Orchestrator's assembly code, not captured in any formal specification. Future maintainers must reverse-engineer the expected payload shape from the assembly logic.

### Final Choice

Direct JSON payload communication was selected for its low dependency footprint and clean fit with the zero-trust sanitization model. The absence of a standardized protocol such as MCP is an acceptable trade-off for a proof-of-concept proof-of-concept. A production system serving multiple users and integrating with external tooling should revisit this decision and evaluate MCP or an equivalent formal protocol for its interoperability and schema-enforcement benefits.

---

## ADR-005: Retrieval-Augmented Generation (RAG) for Memory Architecture

**Status:** Accepted  
**Date:** June 2026  
**Paper reference:** §1.4 — *Memory Topology and RAG in Academic Systems*; §7.3 — *Advanced Document Splitting Frameworks*; §A.12 — *Vector Store Optimization*

### Decision

Implement a **dual-layer memory model** combining an active context window (short-term) with an external vector database (long-term), using cosine similarity search with overlapping chunk splitting and adaptive cluster pruning to retrieve style templates, historical fix patterns, and book source content.

### Context

Long-form academic document generation has two distinct memory requirements: (1) **working memory** — the intermediate compilation state, layout constraints, and section outlines that must be accessible throughout a single generation run; and (2) **persistent knowledge** — style guidelines, historical error-fix templates, and the source book's content, which must be retrievable across multiple sessions and for documents that exceed any single context window.

A 58-page multi-section academic paper with complex cross-references cannot be generated in a single context window without semantic drift. The system requires a mechanism to inject relevant historical context into each agent's active prompt precisely when needed — without loading the entire knowledge base into every prompt (which would exhaust the token budget).

### Alternatives Considered

| Alternative | Assessment |
|-------------|-----------|
| **Full document in context (no RAG)** | Simplest implementation; no external database. For a 58-page target document with source book content, this approach exhausts the context window during generation, producing the semantic drift the architecture is designed to prevent. |
| **Static few-shot examples** | Hardcode representative examples into every agent's system prompt. Provides consistent style anchoring but cannot adapt to novel book content or incorporate learned fix patterns from prior runs. |
| **Fine-tuned domain-specific model** | Train the LLM directly on academic book report corpora. Eliminates runtime retrieval overhead. Requires a labelled training dataset, GPU compute, and model maintenance — well beyond scope for a proof-of-concept course project. |
| **Keyword-based search (BM25)** | Traditional information retrieval; no embedding model required. Fast and interpretable. Does not capture semantic similarity — a query about "capital inequality" would not retrieve chunks discussing "r > g dynamics" unless the exact terms match. |
| **RAG with dense retrieval (chosen)** | Embeds chunks as dense vectors; retrieves by cosine similarity. Captures semantic relationships that keyword matching misses. Requires an embedding model and vector store, but both can be lightweight at proof-of-concept scale. |

### Advantages

- **Semantic retrieval:** Cosine similarity search retrieves contextually relevant chunks (style templates, fix patterns) even when the query does not share exact vocabulary with the stored chunks.
- **Token efficiency:** Only the top-k most relevant chunks are appended to the agent's prompt, not the entire knowledge base. This directly addresses the token budget constraint (18,000,000-token ceiling, §1.5).
- **Stylistic coherence:** The Text Agent loads historical style vectors before generating each chapter section. Fetching the same style template consistently across all sections maintains vocabulary and tone uniformity without manual editorial review.
- **Adaptive error repair:** The QA Agent retrieves historical fix patterns when it encounters a compilation error. This means the system learns from prior repair cycles rather than attempting the same failed fix repeatedly.
- **Overlapping chunking:** Splitting the source book at overlapping character boundaries ensures that multi-chapter sub-narratives are not severed at chunk perimeters, preserving cross-chapter context for long thematic arguments (§7.3).

### Trade-offs

- **Infrastructure dependency:** A production RAG implementation requires an embedding model, a vector database (e.g., Pinecone, FAISS, Weaviate), and an ingestion pipeline. In this proof-of-concept, the vector database is described conceptually — no specific vector store was deployed as a software artefact in the project directory.
- **Retrieval latency:** Each agent query to the vector store adds a round-trip retrieval step to the generation pipeline. Under the T_loop latency model (§5.4.1: T_loop = Δt_intercept + Δt_semantic_search + Δt_llm_inference + Δt_recompilation), retrieval time (Δt_semantic_search) is a non-negligible component.
- **Chunk boundary sensitivity:** Poor chunk boundary choices — splitting in the middle of a sentence or at an equation boundary — can produce incoherent retrieval results. The overlapping boundary strategy mitigates this but does not eliminate it entirely.
- **Embedding model alignment:** The quality of retrieval depends on the embedding model's alignment with the academic writing domain. A general-purpose embedding model may underperform on highly technical LaTeX-encoded content.

### Final Choice

RAG was adopted as the memory architecture because it is the only approach that scales to the document length and content diversity of this system without either exhausting the context window (full-document-in-context) or requiring a training pipeline (fine-tuning). The infrastructure dependency is accepted as a known limitation of the proof-of-concept scope.

---

## ADR-006: Hierarchical Three-Level Agent Orchestration

**Status:** Accepted  
**Date:** June 2026  
**Paper reference:** §3.3 — *The Three-Layer Agentic Framework*; §3.4 — *Hierarchical Multi-Agent Orchestration*; §3.5 — *Distributed Consensus Extensions*

### Decision

Structure the agent system across **three hierarchical levels** — Level 0 (Orchestrator), Level 1 (Specialist Supervisors), Level 2 (Formatting Nodes) — rather than a flat peer topology or a two-level master/worker design.

### Context

A multi-agent system for document generation must coordinate four fundamentally different types of work: high-level content planning and assembly (Orchestrator), domain-specific content production (prose, tables, citations, diagrams), low-level structural repair and validation (QA, BiDi), and deterministic compilation (LuaLaTeX). These responsibilities differ in scope, authority, and timing. A flat topology where all agents are peers provides no mechanism for authority hierarchy when conflicting layout decisions arise. A two-level master/worker design conflates the structural repair function with the content production function, making the QA feedback loop architecturally ambiguous.

### Alternatives Considered

| Alternative | Assessment |
|-------------|-----------|
| **Flat peer topology** | All agents are equal; communication is broadcast. Simple to reason about locally. No mechanism for resolving layout conflicts between peers (e.g., Citation Agent and Table Agent producing overlapping spacing constraints). Requires an external consensus mechanism for every disagreement. |
| **Two-level master/worker** | One Orchestrator dispatches to N workers. Works well when all workers perform the same type of task. Fails to model the qualitative difference between content production (Level 1) and structural validation/repair (Level 2). |
| **Three-level hierarchy (chosen)** | Level 0 coordinates globally; Level 1 handles domain-specific content production; Level 2 handles structural validation. Mirrors the natural dependency chain: content must be produced before it can be validated, and it must be validated before it can be compiled. |
| **Microservices with event sourcing** | Each agent is a stateless service; all state is in an event log. Highly fault-tolerant and auditable. Massively over-engineered for a single-session proof-of-concept; the event log infrastructure alone exceeds the scope of the project. |

### Advantages

- **Authority hierarchy:** When Level-1 agents produce conflicting layout parameters, the Orchestrator (Level 0) has unambiguous authority to adjudicate using the Raft leader-election mechanism (§3.5).
- **Separation of generation from validation:** Level-2 agents (QA, BiDi) operate on the *assembled* output, not on individual agent outputs. This means they see the full document context and can catch errors that only manifest at integration boundaries.
- **Concurrency control:** Level-1 agents can execute in parallel (prose generation, table construction, citation validation, diagram rendering) within the same Level-0 session. The Orchestrator coordinates their outputs without requiring them to be aware of each other.
- **Scalability by level:** New Level-1 agents (e.g., a dedicated equation agent) can be added without affecting Level-2 logic. New Level-2 validators (e.g., an accessibility checker) can be added without affecting Level-1 agents.

### Trade-offs

- **Orchestrator as single point of failure:** All Level-1 payloads and all Level-2 repair directives pass through the Orchestrator. A failure at Level 0 halts the entire pipeline. Mitigation (not implemented in this proof-of-concept): Orchestrator state checkpointing.
- **Three-level overhead:** Messages traverse more hops than in a flat topology. A flat system where agents communicate directly might have lower latency per interaction. For a document generation pipeline where each interaction is already seconds-long, the hop overhead is negligible.
- **Complexity of authority escalation:** The S4→S1 transition (unresolved reference requiring Orchestrator-level intervention) must cross from Level-2 back to Level-0. This reverse escalation path must be explicitly modelled in the state machine (§5.4) and is easy to inadvertently break.

### Final Choice

The three-level hierarchy was chosen because it precisely models the natural dependency structure of the document generation task: plan → generate → validate → compile. The authority hierarchy it provides is directly necessary for both the conflict resolution (Raft, §3.5) and the QA escalation path (S4→S1, §5.4) to function correctly.

---

## ADR-007: TikZ/pgfplots for All Figures

**Status:** Accepted  
**Date:** June 2026  
**Paper reference:** §6.3 — *The Vector Graphics and Algorithmic Diagram Agent*; §5.3 — *Risk Assessment and Failure Modes*

### Decision

Generate **all six figures as programmatic vector graphics** using TikZ (flowcharts, pipeline diagrams) and pgfplots (bar chart, line chart) commands embedded directly in the LaTeX source, with no external raster image files.

### Context

The system produces six figures: four architectural flowcharts (Figures 1, 2, 4, 5) and two data charts (Figures 3, 6). Each figure must be generated by an automated agent without human intervention, be reproducible from the same source, scale cleanly at any zoom level in the PDF, and not require external file management. The Visualization Agent must translate abstract topology metadata from the Orchestrator into rendered output using only tools available in a standard LaTeX distribution.

### Alternatives Considered

| Alternative | Assessment |
|-------------|-----------|
| **External raster images (PNG/JPEG)** | Pre-rendered images embedded via `\includegraphics`. Simple to include but requires managing external file dependencies. The system would need to invoke an external rendering tool (matplotlib, draw.io export, etc.), introducing a non-LaTeX toolchain dependency and breaking the single-file design. Resolution fixed at render time — pixelates under PDF zoom. |
| **SVG with `svg` LaTeX package** | Vector format; scalable. Requires `inkscape` as a system dependency for LaTeX compilation. Not available in all TeX Live installations; breaks the single-dependency design constraint. |
| **Matplotlib (Python, embedded via `matplotlib2tikz`)** | Python-generated charts exported to TikZ. Adds Python as a compile-time dependency; matplotlib must be installed; the export step requires a separate pipeline stage. Over-engineered for six static conceptual diagrams. |
| **ASCII art / Unicode box-drawing** | No dependencies; plain text. Not publication-quality; cannot represent flowchart topology with directional arrowheads or data chart axes. |
| **TikZ + pgfplots (chosen)** | Programmatic vector graphics compiled directly by LuaLaTeX. No external tools. Part of every full TeX Live / MiKTeX installation. Scales perfectly. Diagrams are reproducible from source parameters alone. |

### Advantages

- **Zero external dependencies:** TikZ and pgfplots are bundled with the LaTeX distribution. No external rendering tools are required for compilation.
- **Single-file coherence:** All figure source code lives inside `untitled-1.tex`. Distribution and reproduction require only the `.tex` file.
- **Vector quality at all scales:** PDF viewers render TikZ/pgfplots figures as native vector graphics — no pixelation at any zoom level, producing publication-quality output.
- **Parametric topology:** The Visualization Agent generates TikZ node and path commands from abstract topology metadata. Changing a node label or adding an edge requires only changing input parameters, not re-rendering an external asset.
- **Consistent styling:** All figures share node styles (`box`, `specialbox`, `cloud`), colour schemes, and `Stealth` arrowheads defined once in the figure preamble. Visual consistency across six figures is guaranteed structurally, not editorially.
- **`pgfplots compat=1.18`:** The class file enforces `\pgfplotsset{compat=1.18}`, ensuring that both charts render consistently regardless of the installed pgfplots version.

### Trade-offs

- **Compilation time:** LuaLaTeX processes TikZ and pgfplots figures from source on every compilation pass. Six figures add meaningful compilation time. The `tikzexternalize` caching library addresses this (noted in DEPLOYMENT_GUIDE.md §5.6) but is not enabled by default.
- **TikZ coordinate verbosity:** Complex flowcharts (Figure 1: 8 nodes; Figure 5: chunking pipeline) require explicit `node distance`, `xshift`, and `yshift` tuning to achieve clean layouts. This is iterative work — Figure 1 required `xshift` adjustments to prevent node overlap (PROCESS_LOG.md Milestone 2.2).
- **pgfplots data charts are static:** The bar chart (Figure 3) and line chart (Figure 6) use hardcoded coordinate values. Updating the data requires editing the source. In a production system, a data pipeline would generate the plot commands dynamically.

### Final Choice

TikZ/pgfplots was chosen for the complete absence of external dependencies, the single-file design preservation, and the vector-quality output requirement. The compilation time trade-off is acceptable for a document compiled in a development workflow rather than a high-frequency production pipeline.

---

## ADR-008: Closed Autonomous Self-Healing QA Loop

**Status:** Accepted  
**Date:** June 2026  
**Paper reference:** §5.2 — *Hierarchical QA and Environment-Aware Repair*; §5.4 — *The Multi-Agent Self-Healing Loop*; §7.1 — *Practical Development Experience*

### Decision

Implement a **closed autonomous feedback loop** in which the QA Agent intercepts LuaLaTeX compilation logs, classifies errors into four canonical classes, dispatches targeted repairs to the source `.tex` file, and triggers re-compilation — without human intervention and without modifying the compiled PDF directly.

### Context

Automated LaTeX generation is inherently error-prone. Even when prose content is semantically correct, structural defects introduced by any agent — overfull table columns, unmatched mathematical delimiters, unescaped special characters, bidirectional text drift — cause the LaTeX compiler to produce warnings, degraded output, or outright compilation failures. Without automated repair, every structural error would require a human developer to read the `.log` file, locate the source line, and manually apply a fix. At the scale of a 58-page document with seven tables, six figures, and 14+ equations, manual error correction is incompatible with the system's autonomy objective.

As §7.1 of the paper states: "The most important lesson learned is that autonomous document generation requires strong quality assurance mechanisms. A generated academic report may appear coherent at the textual level while still failing structurally due to broken references, malformed tables, or compiler errors. Therefore, the QA Agent plays a central role in validating the document before final PDF generation."

### Alternatives Considered

| Alternative | Assessment |
|-------------|-----------|
| **Human-in-the-loop review** | A developer inspects the `.log` after every compilation and manually applies fixes. Highest accuracy; zero false-positive repairs. Completely incompatible with the autonomy design goal and unscalable beyond proof-of-concept. |
| **Pre-generation static analysis only** | The QA Agent validates agent outputs before assembly but does not react to compilation errors. Catches some issues (unescaped characters, delimiter balance) but cannot detect errors that only manifest at integration time (cross-reference failures, figure float overflows). |
| **PDF post-processing** | Modify the compiled PDF directly to correct visual errors. Structurally wrong: the repaired PDF would diverge from the source `.tex`, breaking reproducibility. Any subsequent recompilation would regenerate the unrepaired output. Explicitly ruled out by the design (§5.2: "instead of modifying the compiled PDF directly — which would break structural repeatability"). |
| **Deterministic code generation (no LLM repair)** | Use rule-based templates that guarantee compilation-safe output without needing a repair loop. Eliminates repair complexity but severely constrains the range of content the system can generate — rule-based templates cannot express the semantic variety required for literary analysis across four distinct genres. |
| **Closed autonomous loop (chosen)** | QA Agent intercepts the `.log`, classifies errors, dispatches targeted repairs to `.tex`, triggers recompilation. The same input error always produces the same repair (deterministic), preserving reproducibility. |

### Advantages

- **Full autonomy:** The pipeline produces a validated PDF without human intervention across all four case studies.
- **Targeted repair:** Each of the four error classes maps to a specific remediation protocol (column-width recalculation, delimiter injection, directional containment, re-compilation). Repairs are surgical — they affect only the offending line or environment, not the entire document.
- **Determinism:** The same error always triggers the same repair protocol (§F-19 in PRD). This makes the system's behaviour predictable and auditable.
- **Non-invasive:** Repairs are applied exclusively to the `.tex` source. The PDF is always a fresh compilation of the repaired source. Reproducibility is preserved.
- **RPN-guided prioritization:** Errors are evaluated by Risk Priority Number (Severity × Probability × Detection, §5.3) before repair, ensuring that high-impact errors are addressed before low-severity warnings.

### Trade-offs

- **Repair loop ceiling:** The system's autonomous repair efficiency is 76.3% at the Advanced Thesis Matrix tier (45–55 pages, Table 7). The remaining 23.7% of errors are not self-healed and require human validation. The system does not gracefully communicate which errors were not repaired — it simply stops looping after N iterations.
- **Repair introduces new errors:** A repair that corrects a column width may inadvertently alter a caption line, introducing a new warning. The state machine does not implement rollback to a pre-repair snapshot (listed as a failure mode in AGENTS.md §6 but not implemented).
- **Log parsing brittleness:** The QA Agent classifies errors by regex patterns against the `.log` file. Novel error messages (package updates, new LaTeX warnings) that do not match the four canonical patterns are flagged as anomalies but cannot be auto-repaired. The four classes were selected because they cover the errors observed during development, not all possible LaTeX errors.

### Final Choice

The closed autonomous QA loop is adopted as the system's primary quality assurance mechanism because human-in-the-loop review is incompatible with the autonomy objective and PDF post-processing breaks reproducibility. The 76.3% autonomous repair rate at the relevant complexity tier is accepted; the 23.7% residual requiring human validation is documented as a known system boundary.

---

## ADR-009: Two-Pass Compilation with Automated PDF Validation

**Status:** Accepted  
**Date:** June 2026  
**Paper reference:** §5.1 — *The Deterministic Compilation Pipeline*; `untitled-1.aux` (line 1: `\gdef \@abspage@last{55}`)

### Decision

Invoke LuaLaTeX **exactly twice** per compilation cycle using `--interaction=nonstopmode`, and validate the resulting PDF by inspecting the `.aux` file page count and scanning the `.log` for fatal errors, rather than using a single pass or relying on visual inspection alone.

### Context

A LaTeX document with cross-references (`\ref`, `\pageref`, `\cite`) requires at minimum two compilation passes: the first writes the auxiliary index (`.aux`, `.toc`); the second reads it to resolve forward references and populate the table of contents with correct page numbers. This is a fixed technical requirement of the LaTeX compilation model, not a design choice. The design choice is: how many passes to run, when to stop, and how to verify that the output is correct.

The Listing 1 bash code in §5.1 of the source paper specifies exactly two passes (note: Listing 1 uses the generic filename `academic_book_report.tex`; the actual source file is `untitled-1.tex`):

```bash
lualatex --interaction=nonstopmode untitled-1.tex
lualatex --interaction=nonstopmode untitled-1.tex
```

### Alternatives Considered

| Alternative | Assessment |
|-------------|-----------|
| **Single pass** | Insufficient for any document with cross-references. All `\ref{}` and `\cite{}` values would appear as `??` in the PDF. Not viable for this document. |
| **Three or more passes** | Occasionally necessary when bibliography tools (BibTeX, Biber) are part of the pipeline. Since no `.bib` toolchain is used, two passes fully resolve all auxiliary data. A third pass would re-compile identical `.aux` and `.toc` files, consuming time with no benefit. |
| **`latexmk` automation** | Automatically determines the correct number of passes by monitoring whether auxiliary files change between runs. Removes the need to hardcode pass count. Adds an external dependency; also over-abstracts the pipeline in a way that makes QA log interception harder (the QA Agent must intercept individual LuaLaTeX invocations to inspect their specific `.log` output). |
| **Manual visual inspection only** | Compile once, open the PDF, and check visually. Non-reproducible; cannot be automated; does not catch warnings-without-visual-impact (e.g., an `Overfull \hbox` that slightly exceeds the margin). |
| **Two passes + `.aux` validation (chosen)** | Pass 1 writes auxiliary files; Pass 2 resolves all references. After Pass 2, verify: page count matches expected value (55, confirmed via `\gdef \@abspage@last{55}` in `.aux`); no fatal errors in `.log`; expected non-fatal warnings are within the accepted set. |

### Advantages

- **Complete cross-reference resolution:** All `\ref{}`, `\pageref{}`, table of contents entries (94 entries), and figure/table numbers resolve correctly after Pass 2.
- **`filecontents*` class bootstrap:** The `filecontents*[overwrite]{custom-academic-report.cls}` block in the source writes the class file to disk during Pass 1. Pass 2 then loads the freshly written class. This guarantees that even if the class file is missing from the file system (e.g., after a clean build), the two-pass sequence is self-healing without any external bootstrap step.
- **Deterministic verification:** Checking `\gdef \@abspage@last{55}` in `untitled-1.aux` provides a machine-readable, deterministic pass/fail signal that the QA Agent can evaluate without opening the PDF. Checking the `.log` for fatal errors and comparing against the expected non-fatal warning set (three citation warnings, minor underfull hbox) provides a complete automated validation signal.
- **Alignment with QA loop:** The two-pass structure aligns cleanly with the QA state machine: Pass 1 populates state (S1→S2→S3/S4 cycle), QA repairs are applied, Pass 2 finalises the validated document.

### Trade-offs

- **Cannot detect all errors programmatically:** A page count of 55 and a clean `.log` do not guarantee visual correctness. A figure that renders off-screen, a table that is cropped by a float boundary, or a section heading that lands on the last line of a page would all pass automated validation. Visual inspection remains the final validation step.
- **Two passes always required:** Even a trivial one-line change to the source requires two full LuaLaTeX compilation passes to produce a correctly resolved PDF. For a document with 6 TikZ figures, each pass is slow (see ADR-007 trade-offs).

### Final Choice

Two-pass LuaLaTeX with `.aux`-based validation is the standard, well-supported approach for LaTeX documents with cross-references. It is the minimum necessary for correct output and the maximum necessary given that no BibTeX/BibLaTeX pass is in the pipeline. The automated page-count and log-scan validation provides sufficient signal for the QA Agent to confirm compilation success without opening the PDF.

---

## ADR-010: Modular Section-by-Section Content Generation

**Status:** Accepted  
**Date:** June 2026  
**Paper reference:** §7.3 — *Advanced Document Splitting Frameworks*; §9 — *Practical Implementation*; PROCESS_LOG.md Phase 2

### Decision

Generate the document's content **incrementally by section**, compiling and validating after each section before proceeding to the next, rather than generating the entire document in a single large-context generation pass.

### Context

The complete document spans 10 numbered sections, 16 appendix subsections, and a references section — totalling 1,064 lines of LaTeX source across approximately 58 pages. Generating the entire document in a single generation pass would require holding the full document structure, all in-progress section content, all active cross-reference constraints, and all table/figure layouts simultaneously in one context window. The token density data in §4.4 (μ_text = 1,933.3 tokens/chapter, σ = 924.1) confirms that individual chapters have significant token footprints; the full document would substantially exceed any single practical context window.

Additionally, LaTeX errors introduced early in the document (e.g., a broken table environment in §3) would be invisible until the entire document is attempted. Detecting errors section-by-section shortens the feedback cycle from one error per full-document attempt to one error per section attempt.

### Alternatives Considered

| Alternative | Assessment |
|-------------|-----------|
| **Single full-document generation** | Lowest number of generation calls. Risks context window exhaustion mid-generation, producing truncated or semantically drifted output beyond the saturation point. Error detection is delayed until compilation of the entire document. |
| **Chapter-level batching (3–4 sections per pass)** | Intermediate approach: generate related sections together. Partially preserves cross-section context (e.g., §2 and §3 share MCDA terminology). Still risks context saturation for dense sections; complicates error attribution when a compilation error spans two adjacent sections. |
| **Subsection-level generation** | Each subsection generated independently. Maximum context isolation; minimum drift risk. Potentially loses coherence between subsections within the same section (e.g., §2.5–§2.9 form a connected mathematical argument). |
| **Section-level generation (chosen)** | Each numbered section generated as one unit. Preserves intra-section coherence while keeping the generation context bounded. Each section is compiled in isolation before being integrated into the main source. |

### Advantages

- **Early error detection:** Compilation errors introduced in §2 are caught before §3 generation begins. The feedback cycle is short, reducing the total rework cost.
- **Context window management:** Each section generation is bounded to the section's own content plus relevant RAG-retrieved context — the growing document below is not loaded into the generation context, eliminating accumulative context dilution.
- **Incremental checkpointing:** A successfully compiled section constitutes a checkpoint. If generation fails at §6, §1–§5 are already verified and do not need regeneration.
- **Parallel isolation testing:** Individual TikZ diagrams and booktabs tables were tested in isolation before integration (PROCESS_LOG.md Milestone 2.2, 2.3). Section-level generation naturally supports this practice.
- **Separation of concerns at the source level:** Sections are self-contained structural units in the LaTeX document. Cross-section references (`\ref{fig:...}`, `\ref{tab:...}`) are resolved by the compiler — they do not need to be tracked at the generation layer. The generating agent only needs to know a label exists; the compiler resolves its page and number.

### Trade-offs

- **Cross-section narrative coherence requires explicit RAG management:** Vocabulary and thematic threads established in §1 must be available to §8's case study generators. Without explicit RAG injection of prior section summaries, later sections may drift in terminology. The Text Agent's RAG context loading (loading style vectors before each chapter, §6.1) mitigates this but does not fully substitute for having prior sections in the active context.
- **Delayed integration errors:** Some LaTeX errors only manifest when sections are combined — for example, a `\label` name collision between a figure in §2 and a figure in §8 compiled independently would not be caught at section-level testing. Only the full-document compilation exposes them.
- **Manual cross-reference management during generation:** The generator must track which labels have been defined in prior sections to ensure `\ref{...}` commands are applied to existing labels. This bookkeeping responsibility sits in the Orchestrator's state ledger and is a source of potential correctness failures.

### Final Choice

Section-level incremental generation was adopted because the token density of individual sections already approaches the practical context window ceiling, making full-document generation unreliable. The early error detection and incremental checkpointing benefits directly support the iterative Gemini CLI development workflow described in §9 and documented in PROCESS_LOG.md Phase 2. Cross-section coherence is maintained through the RAG memory layer rather than through a shared generation context.

---

*This ADR document was produced as part of the engineering documentation suite for the LATECH project. Records are based on decisions evident in `untitled-1.tex`, the build artifacts, and the explicit development narrative in §7.1 and §9 of the paper.*
