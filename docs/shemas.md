# Схемы (Schemes)

- Схема — файл, описывающий структуру объекта; хранится в `app/schemas`.
- Примеры: блоки, настройки, промо-акции. Схемы могут расширяться аддонами.
- Типы схем: `data array`, `XML-structure` (устаревший), `set of functions`.

```php
// app/schemas/menu/menu.php
$schema = [
    'max_nesting' => 1,
];
return $schema;
```

- Расширение через аддон: файл с суффиксом `.post.php` в аналогичном пути, например `app/addons/seo/schemas/permissions/admin.post.php`.
- Получение схемы: `fn_get_schema($schema_dir, $name, $type = 'php', $force_addon_init = false)`.
- Для схем типа функций используется имя вида `actions.functions`.

```php
$schema = fn_get_schema('menu', 'menu', 'php');
$schema = fn_get_schema('settings', 'actions.functions', 'php');
```
