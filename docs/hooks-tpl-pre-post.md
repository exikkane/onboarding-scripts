# Читать когда: добавляешь вывод в шаблоны через hooks
# НЕ читать когда: задача только про PHP hooks

## Назначение
Безопасно внедрять HTML/Smarty без правки core шаблонов.

## Точка hook в шаблоне
```smarty
{hook name="products:view_main_info"}
  ...
{/hook}
```

## Добавление кода аддоном
Пример файла:
- `design/themes/[theme]/templates/addons/[addon_id]/hooks/products/view_main_info.post.tpl`

Суффиксы:
- `.pre.tpl` — до контента hook.
- `.post.tpl` — после контента hook.

## Override
Полный override только когда pre/post недостаточно:
- `design/backend/templates/addons/[addon_id]/overrides/...`
- `design/themes/[theme]/templates/addons/[addon_id]/overrides/...`

## Правила
1. Сначала использовать `pre/post`, потом `override`.
2. Соблюдать структуру hook section/path.
3. Не переносить бизнес-логику в TPL.
4. Все строки выводить через language vars.
