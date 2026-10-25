# Workflow ratings

PR 0 copy of Strategy `agentic-workflows-workflow-ratings.md`, cleaned for this repo.

Ratings as of 2026-10-25.

Cost tier is an ESTIMATE per run (S <=20 AIC, M 20-60, L 60-150, XL >150), set from prompt size, outputs and timeout. Each PBI measures real cost in its first 3 runs (B02). 1 AIC = $0.01.

## githubnext/agentics/workflows (62 entries = 61 .md + shared/; 13 are redirects)

| Workflow | What it does | Value for Sven repos | Cost | When | PBI |
|---|---|---|---|---|---|
| accessibility-review | Reviews a site for a11y, files issues | M: Chatmarkt web | M | later | F30 |
| adhoc-qa | Ad hoc QA pass, discussion + PR | M: Chatmarkt, Spellwise | L | later | F31 |
| agentic-wiki-coder | Wiki edits -> code PR | L: no wikis used | L | later | F32 |
| agentic-wiki-writer | Code -> wiki pages | L: docs live in repo | L | later | F33 |
| ai-moderator | Spam/AI-slop labeling on issues and comments | M: public repos get spam | S | later | F34 |
| archie | /archie mermaid map of issue/PR links | M: fits mermaid habit | S | later | F35 |
| ci-coach | Daily Actions efficiency PRs | H: Actions minutes cost money | M | now | F11 |
| ci-doctor | Investigates failed runs, files issue | H: every repo | M | now | F02 |
| code-simplifier | Simplify recent code, PR | H: matches review style | M | later | F12 |
| contribution-check | Batch-checks PRs vs guidelines | L: solo dev | M | later | F36 |
| contribution-guidelines-checker | Per-PR guideline check | M: bot PRs follow CONTRIBUTING | S | later | F37 |
| cost-tracker | Reads firewall token usage after a run, reports cost | H: cost per run proof | S | now | F04 |
| daily-accessibility-review | redirect to accessibility-review | see accessibility-review | | | F30 |
| daily-doc-updater | redirect to doc-updater | see doc-updater | | | F07 |
| daily-efficiency-improver | redirect to efficiency-improver | see efficiency-improver | | | F41 |
| daily-issue-triage | Batch triage once a day | H: cheaper than per-event | M | now | F06 |
| daily-malicious-code-scan | redirect to malicious-code-scan | see malicious-code-scan | | | F05 |
| daily-multi-device-docs-tester | redirect to multi-device-docs-tester | see multi-device-docs-tester | | | F48 |
| daily-perf-improver | redirect to perf-improver | see perf-improver | | | F49 |
| daily-plan | redirect to plan | see plan | | | F50 |
| daily-qa | redirect to adhoc-qa | see adhoc-qa | | | F31 |
| daily-repo-chronicle | redirect to repo-chronicle | see repo-chronicle | | | F53 |
| daily-repo-status | redirect to repo-status | see repo-status | | | F03 |
| daily-team-status | redirect to team-status | see team-status | | | F56 |
| daily-test-improver | redirect to test-improver | see test-improver | | | F18 |
| dictation-prompt | Builds dictation prompt file | L: niche | S | later | F38 |
| discussion-task-miner | Discussions -> issues | L: discussions unused | S | later | F39 |
| doc-updater | Docs follow code changes, PR | H: docs/pbi + READMEs drift | M | now | F07 |
| duplicate-code-detector | Finds duplication, issue | M: MCP C# monorepo | M | later | F40 |
| efficiency-improver | Energy/efficiency PRs | L | L | later | F41 |
| glossary-maintainer | Keeps glossary current | L | S | later | F42 |
| grumpy-reviewer | /grumpy critical review | H: second reviewer voice | M | now | F13 |
| issue-arborist | Links related issues as sub-issues | M: PBI issues tree | S | later | F43 |
| issue-monster | Assigns cookie-labeled issues to Copilot agent | H: PBI to agent pipeline | M | later | F44 |
| issue-triage | Per-issue triage on open | M: low volume, daily batch better | S | later | F45 |
| large-file-simplifier | Largest file -> refactor plan issue | M | S | later | F46 |
| lean-squad | Multi-role squad (plan, build, review) | H: mirrors our room | XL | later | F47 |
| link-checker | Broken doc links -> PR | H: docs heavy repos | S | now | F14 |
| malicious-code-scan | 3-day scan for malicious/agentic threats, code scanning alert | H: security | M | now | F05 |
| markdown-linter | Super Linter markdown -> issue | H: agentPacks is markdown | S | now | F15 |
| multi-device-docs-tester | Playwright responsive test of doc site | M: Chatmarkt pages | L | later | F48 |
| perf-improver | Perf PRs with measurement | M | L | later | F49 |
| plan | Planner: discussion with plan | M: like Strategy | S | later | F50 |
| pr-fix | /pr-fix pushes fix for failing CI | H: Builder relief | M | later | F16 |
| pr-nitpick-reviewer | /nit style review | M | S | later | F51 |
| q | /q optimizes agentic workflows themselves | H: this repo | M | now | F17 |
| repo-ask | /ask answers repo questions | M | S | later | F52 |
| repo-assist | Friendly all-round maintainer | M: overlaps others | L | later | F10 |
| repo-chronicle | Narrative daily activity discussion | L | S | later | F53 |
| repo-status | Daily status issue | H: portfolio view | S | now | F03 |
| repository-quality-improver | Daily quality focus area -> issue | M | M | later | F54 |
| sub-issue-closer | Closes parents when children done | M: PBI trees | S | later | F55 |
| team-status | Team status issue | L: solo, use repo-status | S | later | F56 |
| tech-content-editorial-board | Editorial review of docs | M: Writer-style docs | M | later | F57 |
| test-improver | Adds tests, PR | H: Chatmarkt/MCP tests | L | later | F18 |
| unbloat-docs | Shortens verbose docs | H: caveman/no slop fits | M | later | F19 |
| update-docs | On push, update docs PR | M: overlaps doc-updater (pick one) | M | later | F58 |
| vex-generator | OpenVEX on Dependabot dismissal | L | S | later | F59 |
| weekly-issue-activity | Weekly issue trends discussion | L | S | later | F60 |
| weekly-repo-map | ASCII tree map issue | L | S | later | F61 |
| weekly-research | Weekly research discussion | M: News/Research bots exist | S | later | F62 |
| shared/ (arxiv, ffmpeg, formatting, markitdown, mcp, reporting, sq) | shared imports | formatting + reporting reused | | now | C05 |

## gh-aw gallery (18 pages)

| Page | PBI |
|---|---|
| gallery index | F00 |
| ai-issue-triage | F06 |
| ai-release-notes | F09 |
| automated-pr-review | F01 |
| ci-failure-investigation | F02 |
| code-improvement | F12 |
| daily-report-portfolio | F03 |
| dependency-analysis | F20 |
| docs-automation | F07 |
| linter-factory | F21 |
| maintaining-repos | F10 |
| metrics-analytics | F22 |
| multi-repo/code-quality-monitoring | P03 |
| multi-repo/dependabot-rollout | P02 |
| multi-repo/feature-sync | P06 |
| multi-repo/issue-tracking | P01 |
| multi-repo/triage-from-side-repo | P03 |
| security-review | F05 |

## agent-factory-status (348 rows)

| Workflow | Agent | Decision |
|---|---|---|
| [aw] Failure Investigator (6h) | claude | not ours: gh-aw team internal/experiment (reviewed) |
| /cloclo | codex | not ours: gh-aw team internal/experiment (reviewed) |
| 1. List all Go packages with their doc comments | codex | not ours: language/tool we do not use or gh-aw internal |
| ACE Editor Session | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Actions and AW Linter Factory | copilot | not ours: language/tool we do not use or gh-aw internal |
| Agent Container Smoke Test | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Agent Job Health Monitor | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Agent Performance Analyzer - Meta-Orchestrator | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Agent Persona Explorer | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Agentic Workflow AIC Usage Optimizer | copilot | PICK F23 |
| Agentic Workflow Audit Agent | codex | PICK F24 |
| Agy Conformance Reusable (Experimental) | agy | not ours: gh-aw own engine/smoke test |
| AI Moderator | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Approach Validator | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Archie | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Architecture Guardian | copilot | PICK F64 |
| Archivx - Workflow Visualizer | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Artifacts Usage Report | codex | not ours: gh-aw team internal/experiment (reviewed) |
| arXiv Paper Researcher: GitHub Agentic Workflows | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Auto-Triage Issues | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Avenger | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| AW Essential Issue Clustering | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Basic Research Agent | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Blog Auditor | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Bot Detection | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Breaking Change Checker | copilot | PICK F25 |
| Cache directory setup | opencode | not ours: gh-aw own engine/smoke test |
| Changeset Generator | codex | PICK L06 |
| Chaos PR Bundle Fuzzer | codex | not ours: gh-aw team internal/experiment (reviewed) |
| CI Cleaner | claude | not ours: gh-aw team internal/experiment (reviewed) |
| CI Optimization Coach | copilot | PICK F11 |
| Claude Code User Documentation Review | claude | not ours: gh-aw own engine/smoke test |
| CLI Consistency Checker | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| CLI Version Checker | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Code Refiner | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Code Scanning Fixer | copilot | PICK F26 |
| Code Simplifier | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Codex GitHub Remote MCP Test | codex | not ours: gh-aw own engine/smoke test |
| Commit Changes Analyzer | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Constraint Solving - Problem of the Day | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Contribution Check | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Copilot Agent PR Analysis | claude | later: Copilot usage analytics, revisit after B02 (F71 bucket) |
| Copilot Agent Prompt Clustering Analysis | claude | later: Copilot usage analytics, revisit after B02 (F71 bucket) |
| Copilot Centralization Drilldown | codex | later: Copilot usage analytics, revisit after B02 (F71 bucket) |
| Copilot Centralization Optimizer | codex | later: Copilot usage analytics, revisit after B02 (F71 bucket) |
| Copilot CLI Deep Research Agent | copilot | later: Copilot usage analytics, revisit after B02 (F71 bucket) |
| Copilot Opt | copilot | later: Copilot usage analytics, revisit after B02 (F71 bucket) |
| Copilot PR Conversation NLP Analysis | copilot | later: Copilot usage analytics, revisit after B02 (F71 bucket) |
| Copilot PR Prompt Pattern Analysis | copilot | later: Copilot usage analytics, revisit after B02 (F71 bucket) |
| Copilot Session Insights | claude | later: Copilot usage analytics, revisit after B02 (F71 bucket) |
| Daily A/B Testing Advisor | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily action/setup/* Security Audit | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Agent of the Day Blog Writer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Agentic Workflow AIC Usage Audit | copilot | PICK F04 |
| Daily AgentRx Trace Optimizer | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily AIC Consumption Report (Sentry + Grafana OTel) | goose | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Ambient Context Optimizer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Assign Issue To User | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily AstroStyleLite Markdown Spellcheck | claude | not ours: language/tool we do not use or gh-aw internal |
| Daily AW Cross-Repo Compile Check | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily AWF Spec Compiler Surfacing Review | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily BYOK Ollama Test | copilot | not ours: gh-aw own engine/smoke test |
| Daily Cache Strategy Analyzer | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Caveman Optimizer | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Choice Type Test | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily CLI Performance Agent | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Cli Tools Tester | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Code Debt Cleanup - Aider | aider | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Code Metrics and Trend Tracking Agent | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Community Attribution Updater | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Compiler Quality Check | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Compiler Threat Spec Optimizer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Container Image Security Scan | copilot | PICK F66 |
| Daily Copilot PR Merged Report | copilot | later: Copilot usage analytics, revisit after B02 (F71 bucket) |
| Daily Credit Limit Test | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Discussion Report Dispatcher | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Documentation Diagram | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Documentation Healer | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Documentation Updater | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Ecosystem Explorer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Elixir Credo Snippet Audit | claude | not ours: language/tool we do not use or gh-aw internal |
| Daily Evals Feature Report | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Fact | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily File Diet | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Firewall Logs Collector and Reporter | copilot | PICK B08 |
| Daily Formal Spec Verifier | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily GitHub Docs SEO Optimizer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Go Function Namer | pi | not ours: language/tool we do not use or gh-aw internal |
| Daily Go Test Parallelizer | codex | not ours: language/tool we do not use or gh-aw internal |
| Daily Go Test Stubs - Aider | aider | not ours: language/tool we do not use or gh-aw internal |
| Daily Grader Audit | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Graft Intelligence | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Harness Experiment Proposer | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Hippo Learn | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Issues Report Generator | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Malicious Code Scan Agent | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Max Ai Credits Test | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily MCP Tool Concurrency Analysis | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Model Inventory Checker | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily News | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Observability Report for AWF Firewall and MCP Gateway | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily PR Code Quality Review | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Project Performance Summary Generator (Using MCP Scripts) | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Regression Audit | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Regulatory Report Generator | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Reliability Review | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Rendering Scripts Verifier | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Safe Output Integrator | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Safe Output Tool Optimizer | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Safe Outputs Conformance Checker | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Safe Outputs Git Simulator | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Schema Consistency Audit | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Secrets Analysis Agent | copilot | PICK F27 |
| Daily Security Observability Report | copilot | PICK B08 |
| Daily Semgrep Scan | codex | PICK F70 |
| Daily SPDD Spec Planner | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Spec Coverage Review | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Spending Forecast | codex | PICK B05 |
| Daily Storify | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Sub-Agent Model Resolution Audit | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Syntax Error Quality Check | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Team Evolution Insights | goose | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Testify Uber Super Expert | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Trajectory Grader Implementer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily VulnHunter Scan | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Windows Defender Release Scan | codex | not ours: language/tool we do not use or gh-aw internal |
| Daily Windows Terminal Integration Builder | codex | not ours: language/tool we do not use or gh-aw internal |
| Daily Work Queue Formal Verification | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Work Queues Report | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Workflow Security Model | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Daily Workflow Updater | copilot | PICK L05 |
| Daily yamllint Fixer | claude | not ours: gh-aw team internal/experiment (reviewed) |
| daily-experiment-report | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| DataFlow PR & Discussion Dataset Builder | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Dead Code Removal Agent | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Deep Report | claude | not ours: gh-aw team internal/experiment (reviewed) |
| DeepSec Security Scan | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Delight | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Dependabot Burner | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Dependabot Dependency Checker | codex | PICK F20 |
| Deployment Incident Monitor | copilot | PICK M01 |
| Design Decision Gate | pi | PICK F67 |
| Designer Drift Audit | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Detection Analysis Report | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Dev Auto Model Smoke Test | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Dev Hawk | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Developer Documentation Consolidator | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Dictation Prompt Generator | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Documentation Noob Tester | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Documentation Unbloat | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Draft PR Cleanup | copilot | PICK F28 |
| Duplicate Code Detector | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Engine Conformance Agy (Experimental) | agy | not ours: gh-aw own engine/smoke test |
| Engine Conformance Aider | aider | not ours: gh-aw own engine/smoke test |
| Engine Conformance Claude | claude | not ours: gh-aw own engine/smoke test |
| Engine Conformance Codex | codex | not ours: gh-aw own engine/smoke test |
| Engine Conformance Copilot | copilot | not ours: gh-aw own engine/smoke test |
| Engine Conformance Crush | crush | not ours: gh-aw own engine/smoke test |
| Engine Conformance Cursor | cursor | not ours: gh-aw own engine/smoke test |
| Engine Conformance DeepSeek Harness | copilot | not ours: gh-aw own engine/smoke test |
| Engine Conformance Dispatcher | copilot | not ours: gh-aw own engine/smoke test |
| Engine Conformance Gemini | gemini | not ours: gh-aw own engine/smoke test |
| Engine Conformance Goose | goose | not ours: gh-aw own engine/smoke test |
| Engine Conformance Kiro | kiro | not ours: gh-aw own engine/smoke test |
| Engine Conformance OpenCode | opencode | not ours: gh-aw own engine/smoke test |
| Engine Conformance Pi | pi | not ours: gh-aw own engine/smoke test |
| Engine Conformance Pydantic AI | copilot | not ours: gh-aw own engine/smoke test |
| ESLint Factory Dispatcher | copilot | not ours: language/tool we do not use or gh-aw internal |
| ESLint Miner | copilot | not ours: language/tool we do not use or gh-aw internal |
| ESLint Monster | codex | not ours: language/tool we do not use or gh-aw internal |
| ESLint Refiner | claude | not ours: language/tool we do not use or gh-aw internal |
| EvoSkill Evolver | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Example Failure Category Filter | codex | not ours: gh-aw own engine/smoke test |
| Example: Properly Provisioned Permissions | codex | not ours: gh-aw own engine/smoke test |
| Feature Grower | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Firewall Test Agent | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Front Page Copy Guard | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Functional Pragmatist | codex | not ours: gh-aw team internal/experiment (reviewed) |
| GEO Optimizer Daily Audit | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| GitHub API Consumption Report Agent | codex | not ours: gh-aw team internal/experiment (reviewed) |
| GitHub MCP Remote Server Tools Report Generator | claude | not ours: gh-aw team internal/experiment (reviewed) |
| GitHub MCP Structural Analysis | claude | not ours: gh-aw team internal/experiment (reviewed) |
| GitHub Remote MCP Authentication Test | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Glossary Maintainer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Go Fan | claude | not ours: language/tool we do not use or gh-aw internal |
| Go Logger Enhancement | claude | not ours: language/tool we do not use or gh-aw internal |
| Go Pattern Detector | claude | not ours: language/tool we do not use or gh-aw internal |
| GPL Dependency Cleaner (gpclean) | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Grumpy Code Reviewer | codex | PICK F13 |
| Hippo Embed | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Impeccable Skills Reviewer | copilot | PICK F69 |
| Instructions Janitor | claude | PICK F29 |
| Issue Arborist | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Issue Monster | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Issue Triage Agent | codex | not ours: gh-aw team internal/experiment (reviewed) |
| jsweep - JavaScript Unbloater | copilot | not ours: language/tool we do not use or gh-aw internal |
| Layout Specification Maintainer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Linter Miner | copilot | not ours: language/tool we do not use or gh-aw internal |
| LintMonster | codex | not ours: language/tool we do not use or gh-aw internal |
| Lockfile Statistics Analysis Agent | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Matt Pocock Skills Reviewer | copilot | PICK F69 |
| MCP Inspector Agent | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Mergefest | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Metrics Collector | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Multi-Device Docs Tester | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Necromancer | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Notion Issue Summary | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Objective Impact Report | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| On-Demand Agentic Workflow AIC Trend Audit | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Organization Health Report | copilot | PICK P07 |
| Package Specification Enforcer | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Package Specification Extractor | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Package Specification Librarian | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Plan Command | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Poem Bot - A Creative Agentic Workflow | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Ponytail Reviewer | codex | not ours: gh-aw team internal/experiment (reviewed) |
| PR Code Quality Reviewer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| PR Description Updater | copilot | PICK F63 |
| PR Nitpick Reviewer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| PR Sous Chef | pi | not ours: gh-aw team internal/experiment (reviewed) |
| PR Triage Agent | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| PureLock | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Python Data Visualization Generator | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Q | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Rebuild the documentation after making changes | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Refactoring Cadence | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Release | copilot | PICK F09 |
| Repository Audit & Agentic Workflow Opportunity Analyzer | codex | PICK F68 |
| Repository Quality Improvement Agent | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Repository Tree Map Generator | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Resource Summarizer Agent | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Safe Output Health Monitor | claude | PICK B07 |
| Schema Consistency Checker | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Schema Feature Coverage Checker | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Scout | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Security Compliance Campaign | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Security Review Agent | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Semantic Function Refactoring | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Sergo - Serena Go Expert | claude | not ours: language/tool we do not use or gh-aw internal |
| Sighthound Security Scan | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Skillet | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Slide Deck Maintainer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Smoke Agent: all/merged | claude | not ours: gh-aw own engine/smoke test |
| Smoke Agent: all/none | claude | not ours: gh-aw own engine/smoke test |
| Smoke Agent: public/approved | claude | not ours: gh-aw own engine/smoke test |
| Smoke Agent: public/none | claude | not ours: gh-aw own engine/smoke test |
| Smoke Agent: scoped/approved | claude | not ours: gh-aw own engine/smoke test |
| Smoke Agy (Experimental) | agy | not ours: gh-aw own engine/smoke test |
| Smoke Aider | aider | not ours: gh-aw own engine/smoke test |
| Smoke Azure Codex | codex | not ours: gh-aw own engine/smoke test |
| Smoke Azure PI | pi | not ours: gh-aw own engine/smoke test |
| Smoke Built-in Ledgers | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Call Workflow | codex | not ours: gh-aw own engine/smoke test |
| Smoke Checkout PR Dispatch | copilot | not ours: gh-aw own engine/smoke test |
| Smoke CI | codex | not ours: gh-aw own engine/smoke test |
| Smoke Claude | claude | not ours: gh-aw own engine/smoke test |
| Smoke Claude Auto | claude | not ours: gh-aw own engine/smoke test |
| Smoke Claude Copilot | claude | not ours: gh-aw own engine/smoke test |
| Smoke Claude Copilot Auto | claude | not ours: gh-aw own engine/smoke test |
| Smoke Claude Dynamic Workflow | claude | not ours: gh-aw own engine/smoke test |
| Smoke Claude on Copilot | claude | not ours: gh-aw own engine/smoke test |
| Smoke Claude Routed | claude | not ours: gh-aw own engine/smoke test |
| Smoke Claude Sub Agents | claude | not ours: gh-aw own engine/smoke test |
| Smoke Codex | codex | not ours: gh-aw own engine/smoke test |
| Smoke Codex Auto | codex | not ours: gh-aw own engine/smoke test |
| Smoke Codex Bare Auto | codex | not ours: gh-aw own engine/smoke test |
| Smoke Copilot | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot - AOAI (apikey) | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot - AOAI (Entra) | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot ARM64 | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot Auto | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot Dynamic Workflow | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot MAI | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot Routed | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot Routed Claude | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot Routed Steering | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot SDK | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot SDK Routed | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot SDK Routed Claude | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot Small | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Copilot Sub Agents | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Create Cross-Repo PR | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Crush | crush | not ours: gh-aw own engine/smoke test |
| Smoke Cursor | cursor | not ours: gh-aw own engine/smoke test |
| Smoke DeepSeek Harness | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Drive | codex | not ours: gh-aw own engine/smoke test |
| Smoke Gemini | gemini | not ours: gh-aw own engine/smoke test |
| Smoke GitHub Claude | claude | not ours: gh-aw own engine/smoke test |
| Smoke GitHub Codex | codex | not ours: gh-aw own engine/smoke test |
| Smoke Goose | goose | not ours: gh-aw own engine/smoke test |
| Smoke Issues | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Kiro | kiro | not ours: gh-aw own engine/smoke test |
| Smoke Multi PR | copilot | not ours: gh-aw own engine/smoke test |
| Smoke OpenCode | opencode | not ours: gh-aw own engine/smoke test |
| Smoke OTEL | codex | not ours: gh-aw own engine/smoke test |
| Smoke Pi | pi | not ours: gh-aw own engine/smoke test |
| Smoke Pi Auto | pi | not ours: gh-aw own engine/smoke test |
| Smoke Pi Routed | pi | not ours: gh-aw own engine/smoke test |
| Smoke Pi Routed Claude | pi | not ours: gh-aw own engine/smoke test |
| Smoke Pi Sub Agents | pi | not ours: gh-aw own engine/smoke test |
| Smoke Project | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Pydantic AI | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Repo-Memory Ledger | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Security Alerts | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Service Ports | pi | not ours: gh-aw own engine/smoke test |
| Smoke Temporary ID | pi | not ours: gh-aw own engine/smoke test |
| Smoke Update Cross-Repo PR | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Work Queue | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Work Queue Dispatcher | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Work Queue Worker | copilot | not ours: gh-aw own engine/smoke test |
| Smoke Workflow Call | claude | not ours: gh-aw own engine/smoke test |
| Smoke Workflow Call with Inputs | copilot | not ours: gh-aw own engine/smoke test |
| Squad | copilot | PICK F47 |
| Squad Game Planner | copilot | PICK F47 |
| Squad Implement Worker | copilot | PICK F47 |
| Squad Plan | copilot | PICK F47 |
| Stale PR Cleanup | copilot | PICK F28 |
| Stale Repository Identifier | pi | PICK P07 |
| Static Analysis Report | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Step Name Alignment | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Sub-Issue Closer | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Super Linter Report | pi | not ours: language/tool we do not use or gh-aw internal |
| Team Status | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Terminal Stylist | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Test Quality Sentinel | copilot | PICK F65 |
| The Daily Repository Chronicle | pi | not ours: gh-aw team internal/experiment (reviewed) |
| The Great Escapi | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Tidy | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Typist - Go Type Analysis | claude | not ours: language/tool we do not use or gh-aw internal |
| Ubuntu Actions Image Analyzer | copilot | not ours: language/tool we do not use or gh-aw internal |
| UK AI Operational Resilience | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Update Astro | codex | not ours: language/tool we do not use or gh-aw internal |
| Video Analysis Agent | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Visual Regression Checker | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Weekly Blog Post Writer | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Weekly Editors Health Check | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Weekly Issue Summary | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Weekly Network Domain Set Audit | pi | PICK POL06 |
| Weekly Safe Outputs Specification Review | pi | not ours: gh-aw team internal/experiment (reviewed) |
| Weekly Workflow Analysis | claude | PICK B02 |
| Windows Grower | codex | not ours: language/tool we do not use or gh-aw internal |
| Windows Runner Integration Test | codex | not ours: language/tool we do not use or gh-aw internal |
| Workflow Craft Agent | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Workflow Generator | copilot | not ours: gh-aw team internal/experiment (reviewed) |
| Workflow Health Manager - Meta-Orchestrator | copilot | PICK B07 |
| Workflow Normalizer | codex | not ours: gh-aw team internal/experiment (reviewed) |
| Workflow Portfolio Analyst | claude | not ours: gh-aw team internal/experiment (reviewed) |
| Workflow Skill Extractor | copilot | not ours: gh-aw team internal/experiment (reviewed) |
