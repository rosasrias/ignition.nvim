# Ignition.nvim Changelog

This changelog records meaningful project changes.

Architectural reasoning belongs in `DECISIONS.md`.

Current development is pre-v1.0.

______________________________________________________________________

## Unreleased

### Identity

- Renamed the plugin to **Ignition.nvim** (former working name `code-runner`).
  Module namespace `code-runner` → `ignition`; entry file
  `plugin/code-runner.lua` → `plugin/ignition.lua`; commands `:CodeRun*` →
  `:IgnitionRun*`; highlight groups/autocmds `CodeRunner*` → `Ignition*`;
  buffer variables `code_runner_*` → `ignition_*`; data directory
  `.../code-runner/` → `.../ignition/`; project dotfile `.code-runner.lua` →
  `.ignition.lua`. No compatibility aliases (pre-v1.0, breaking permitted).
  Architecture and behavior are unchanged; module paths and documentation were
  updated to the new location. See `DECISIONS.md` ADR-019.

### Architecture

- Established Task / Execution / Command / Context / Runner as the target domain model.
- Established Hexagonal/Clean-inspired dependency boundaries.
- Established a single Execution Engine as the target execution model.
- Established Runner-based language extensibility.
- Established zero-config as a core product constraint.

### OpenCode

- Introduced persistent architecture documentation.
- Added explicit architectural contracts.
- Added dependency boundary documentation.
- Added architectural decision records.
- Added persistent development state.
- Reorganized roadmap around architectural maturity.

### Terminal

- El fondo de la ventana de la terminal (`IgnitionTermBg`) va a `NONE` cuando
  la transparencia de base46/NvChad está activa: deja ver el fondo del editor en
  vez del bg oscuro propio. El texto no se toca.

______________________________________________________________________

## Pre-v1.0

Development history prior to the architecture foundation is preserved through repository commits.

Do not use this file as the source of truth for architectural decisions.

For architectural history, see:

```text
DECISIONS.md
```
