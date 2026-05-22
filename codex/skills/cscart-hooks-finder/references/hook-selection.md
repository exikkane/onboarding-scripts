# Hook Selection

Prioritize hooks in this order:

1. Exact domain match in hook name.
2. Stable core hook with clear parameters.
3. Hook with minimal side effects.
4. TPL hook only when UI insertion is required.

Prefer `pre`/`post` before `override`.
