# Jarvis — Agent Guide

## Dev Environment

Activate before any command:
```bash
eval "$(micromamba.exe shell hook --shell bash)" && micromamba activate ".mamba_env"
```

Run the daemon: `bash scripts/run_linux.sh` (sets `PYTHONPATH=src`)

## Running Tests

```bash
pytest                          # unit tests only (CI default)
pytest -m integration           # integration tests
pytest evals/                    # LLM quality evals (manual only)
pytest tests/performance/ -v    # performance tests (needs Ollama)
```

Evals: `bash scripts/run_evals.sh` (supports `--no-live`, `--no-judge`, `--no-report`, `--single`)

## Key Architecture

- **`src/desktop_app/`** is a separate PyQt6 app with no knowledge of the core `jarvis` module. All communication goes through the config file.
- **Spec files** (`*.spec.md`) next to the code define correct behaviour. Changes must propagate to specs.
- **`docs/llm_contexts.md`** tracks every LLM call. Update it in the same PR when you add/remove/alter an LLM context.
- Tools return **raw data**. Profiles handle formatting. Never LLM-process inside a tool.

## Style

- British English everywhere (behaviour, colour, initialise).
- No em dashes in user-facing text.
- Emoji in CLI output (start each logical line with one).
- Use `debug_log` from `src/jarvis/debug.py` for important logical flow points.
- No hardcoded language patterns.

## Git

- Default branch: `develop` (PRs target it, not `main`).
- Conventional commits: `feat:`, `fix:`, `docs:`, `test:`, `chore:`.
- PR title/body cover the whole changeset; squash-merged commits carry only `(#NNN)` in the title.
- Commit body carries `Closes #NNN` for auto-close on release.
- Run `/review-pr` skill after creating a PR.

## Skills

- `/review-pr` — adversarial multi-agent PR review.
- `/triage` — issue and discussion triaging.