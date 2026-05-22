---
name: cscart-hooks-finder
description: Find and rank relevant CS-Cart PHP and TPL hooks for module implementation. Always use before writing logic in module creation tasks.
---

# CS-Cart Hooks Finder

Discover extension points for add-on features with priority suggestions.

## Mandatory Trigger

Use this skill in every module creation task before coding handlers.

## Workflow

1. Run hook search.
- Execute `scripts/find_hooks.py --project-root <root> --query "<feature description>"`.

2. Review ranked hooks.
- Inspect PHP hooks (`fn_set_hook`).
- Inspect TPL hooks (`{hook name="..."}`).

3. Generate implementation plan.
- Pick pre/post/override strategy.
- Register selected hooks in `init.php` and implement handlers in `func.php`.

## References

- `references/hook-selection.md` for ranking logic.
- `references/implementation-rules.md` for handler naming and registration.

## Scripts

- `scripts/find_hooks.py`
  Search core and add-ons for hook definitions and rank by keyword match.
