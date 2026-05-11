# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**sdd-skill** is a Spec-Driven Development skill set that integrates OpenSpec (spec-driven change management) with Superpowers (AI execution discipline) through a dual-track architecture. Version: `2.0.0`.

**Core principle**: SDD skills only orchestrate — core work is delegated to underlying skills (OpenSpec for spec management, Superpowers for quality execution).

**Entry point**: `sdd` orchestrator auto-detects path. `sdd-init` is always the first action for a new project.

## Architecture

### Dual-Track

```
sdd (orchestrator) — unified entry, auto-detects standard path vs shortest path
    │
    ├── sdd-init          → openspec init + tech detection
    ├── sdd-doctor        → environment diagnosis
    ├── sdd-brainstorm    → superpowers:brainstorming
    ├── sdd-propose       → openspec:continue-change
    ├── sdd-continue      → openspec:continue-change
    ├── sdd-ff            → openspec:ff-change
    ├── sdd-plan          → superpowers:writing-plans
    ├── sdd-apply         → superpowers:tdd
    ├── sdd-review-spec   → subagent (spec compliance)
    ├── sdd-review-code   → superpowers:requesting-code-review
    ├── sdd-verify        → superpowers:verification + openspec:verify
    └── sdd-ship          → openspec:archive + superpowers:finish-branch
```

### Skill Directory Structure

```
sdd-skill/
├── README.md
├── CLAUDE.md
├── install.sh
├── .agents/skills/sdd/              # Orchestrator
│   ├── SKILL.md
│   └── prompts/session-context.md
├── sdd-init/                        # Project initialization
├── sdd-doctor/                      # Environment diagnosis
├── sdd-brainstorm/                  # Design exploration
├── sdd-propose/                     # Proposal creation
├── sdd-continue/                    # Incremental artifact generation
├── sdd-ff/                          # Fast-forward all planning docs
├── sdd-plan/                        # Implementation plan
├── sdd-apply/                       # TDD implementation
├── sdd-review-spec/                 # Spec review
├── sdd-review-code/                 # Code review (2-phase)
├── sdd-verify/                      # Comprehensive verification
├── sdd-ship/                        # Archive and merge
└── openspec/
    └── schemas/sdd/
        ├── schema.yaml              # Artifact definitions and dependency chain
        ├── templates/               # 7 templates
        ├── tech-rules/              # Tech-stack rules
        ├── errors.md                # Centralized error catalog (E001-E010)
        ├── prompts/                 # 5 reviewer prompts
        └── skill-dispatch-defaults.yaml
```

### Target Project Structure (generated at runtime)

```
<project>/
├── openspec/
│   ├── config.yaml
│   ├── specs/
│   ├── changes/
│   └── schemas/sdd/
└── CLAUDE.md
```

## Dependencies

| Dependency | Type | Version | Purpose |
|------------|------|---------|---------|
| superpowers:brainstorming | skill | latest | Socratic design exploration |
| superpowers:writing-plans | skill | latest | Implementation plan generation |
| superpowers:tdd | skill | latest | Test-driven development |
| superpowers:requesting-code-review | skill | latest | Two-phase code review |
| superpowers:verification | skill | latest | Pre-completion verification |
| superpowers:finishing-a-development-branch | skill | latest | Branch completion |
| openspec | CLI | latest | Spec management |

## Key Design Principles

1. **Action Not Phases**: Each skill is an independent action. Dependencies are enablers, not gates.
2. **Artifact Relay**: Each action's output is the next action's input. All state persisted to files.
3. **Three-part Skill Structure**: Pre-logic (SDD) → Core execution (invoke underlying) → Post-logic (SDD).
4. **Override Mechanism**: Explicit overrides for Superpowers skills that auto-transition.
5. **Decision Traceability**: proposal.md and design.md must explicitly reference brainstorm.md decisions.
6. **Two-phase Code Review**: Phase 1 (spec compliance) must pass before Phase 2 (code quality).
7. **Centralized Error Handling**: All error codes in `openspec/schemas/sdd/errors.md`, skills reference by code.
8. **Orchestrator Handles Complexity**: Team agent parallelism, path detection, batch orchestration live in the `sdd` orchestrator, not in individual skills.

## Context Hygiene

Each action completes with: "Artifacts persisted to <path>. Safe to `/clear`."
- `/clear` after each action is a core habit, not optional
- Three actions are interactive and not suitable for mid-action clear: `sdd-brainstorm`, `sdd-plan`, `sdd-apply`

## Development Workflow

This is a documentation/prompt-based skill set — no build system or runtime.

When modifying this skill set:
- New skills follow the three-part structure (pre-logic → invoke → post-logic)
- Error codes go in `openspec/schemas/sdd/errors.md`, reference by code in skill SKILL.md
- Reviewer prompts go in `openspec/schemas/sdd/prompts/`
- Skill dispatch rules go in `openspec/schemas/sdd/skill-dispatch-defaults.yaml`
- Schema and templates are the interface between Schema layer and Action layer