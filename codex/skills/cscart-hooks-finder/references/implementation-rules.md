# Hook Implementation Rules

- Register hooks in `app/addons/<addon>/init.php` via `fn_register_hooks(...)`.
- Implement handlers in `app/addons/<addon>/func.php` as `fn_<addon>_<hook>()`.
- Add hook-focused PHPDoc with source function in `@see`.
- Keep logic in services if handler grows too large.
