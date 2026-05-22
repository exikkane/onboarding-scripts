# Читать когда: изменения не применяются или закрываешь задачу с cache-sensitive правками
# НЕ читать когда: задача не затрагивает hooks/schemas/templates/layout/langs/settings

## Назначение
Формализовать обязательную очистку кеша и фиксацию доказательств.

## Когда cache clear обязателен
- Добавлен/изменён PHP hook wiring.
- Добавлен/изменён TPL hook/override.
- Изменены `schemas/**`.
- Изменён `addon.xml`.
- Изменены language файлы (`var/langs/*/addons/*.po`).
- Изменены layout/template точки, где возможна кешированная компиляция.

## Способы очистки

### Через URL
- `http://<admin-host>/admin.php?cc`
- `http://<admin-host>/admin.php?dispatch=...&cc`

### Через файловую систему
```bash
cd /path/to/store/var
rm -rf cache
```

## Диагностика

### PHP
```php
fn_print_r($variable);
fn_print_die($variable);
```

### TPL
```smarty
{$variable|@fn_print_r}
```
