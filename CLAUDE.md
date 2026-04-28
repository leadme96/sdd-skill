# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**sdd-skill** is a Spec-Driven Development skill set that integrates OpenSpec (spec-driven change management) with Superpowers (AI execution discipline) through a "thin orchestration" architecture. Version: `0.1.0`.

**Core principle**: SDD skills only orchestrate — core work is delegated to underlying skills (OpenSpec for spec management, Superpowers for quality execution).

**Entry point**: `sdd-init` is always the first action for a new project. It runs `openspec init`, detects the tech stack, and generates project-specific context and rules.

## Architecture

### Three Layers

```
SDD Action Skills (orchestration layer) — 12 skills, user-facing entry point
    │
    ├── invoke → Superpowers (discipline layer) — brainstorming, TDD, debugging, review, verification
    └── invoke → OpenSpec (spec layer) — init, continue-change, ff-change, verify-change, archive, sync-specs
```

### Skill Directory Structure

```
sdd-skill/
├── README.md                     # Main user documentation
├── CLAUDE.md                     # This file
├── sdd-init/                     # Project initialization + tech stack detection
├── sdd-doctor/                   # Environment diagnosis
├── sdd-brainstorm/               # Design exploration + brainstorm-reviewer-prompt.md
├── sdd-propose/                  # Proposal creation
├── sdd-continue/                 # Incremental artifact generation
├── sdd-ff/                       # Fast-forward all planning docs
├── sdd-plan/                     # Implementation plan + plan-reviewer-prompt.md
├── sdd-apply/                     # TDD implementation
├── sdd-review-spec/              # Spec review + spec-reviewer-prompt.md
├── sdd-review-code/              # Code review (2-phase) + spec-compliance + code-quality reviewer prompts
├── sdd-verify/                   # Comprehensive verification
├── sdd-ship/                     # Archive and merge
└── openspec/
    └── schemas/sdd/
        ├── schema.yaml           # Artifact definitions and dependency chain
        ├── templates/            # 7 templates (brainstorm, proposal, spec, design, tasks, plan, review)
        └── tech-rules/           # Tech-stack rules (nodejs, go, python, java, rust, typescript)
```

### Target Project Structure (generated at runtime)

```
<project>/
├── openspec/
│   ├── config.yaml               # Project config (schema: sdd, context, rules, code patterns)
│   ├── specs/                    # Global specs (merged after archiving)
│   ├── changes/                  # Active changes
│   └── schemas/sdd/              # SDD schema + templates (installed copy)
└── CLAUDE.md                     # Project-level AI workflow guide
```

## Key Design Principles

1. **Action Not Phases**: Each skill is an independent action. Dependencies are enablers, not gates.
2. **Artifact Relay**: Each action's output is the next action's input. All state persisted to files.
3. **Three-part Skill Structure**: Each skill follows Pre-logic (SDD) → Core execution (invoke underlying) → Post-logic (SDD).
4. **Override Mechanism**: Explicit overrides for Superpowers skills that auto-transition (brainstorming → writing-plans, etc.).
5. **Decision Traceability**: proposal.md and design.md must explicitly reference brainstorm.md decisions.
6. **Two-phase Code Review**: Phase 1 (spec compliance) must pass before Phase 2 (code quality).
7. **Schema only constrains content, not orchestration**: Schema defines what artifacts should contain; SDD skills control the flow.
8. **Tech Stack Boundaries**: `sdd-init` generates `config.yaml` rules with language-specific constraints, giving AI clear boundaries and guidance for the target project.

## Context Hygiene

Each action completes with: "Artifacts persisted to <path>. Safe to `/clear`."
- `/clear` after each action is a core habit, not optional
- Three actions are interactive and not suitable for mid-action clear: `sdd-brainstorm`, `sdd-plan`, `sdd-apply`

## Development Workflow

This is a documentation/prompt-based skill set — no build system or runtime.

When modifying this skill set:
- New skills follow the three-part structure (pre-logic → invoke → post-logic)
- Each skill needs: SKILL.md + optional reviewer prompt
- Schema and templates are the interface between Schema layer and Action layer
- `config.yaml` default schema is `sdd`
- Tech rules in `tech-rules/` define per-language constraints that `sdd-init` injects into `config.yaml`
