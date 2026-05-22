# Читать когда: добавляешь PHP hook логику
# НЕ читать когда: задача только про TPL hooks

## Назначение
Правила подключения аддона к PHP hook точкам CS-Cart.

## Базовый синтаксис

### Точка вызова hook
```php
fn_set_hook('get_product_data_pre', $product_id, $field_list, $auth, $lang_code);
```

### Регистрация в аддоне
`app/addons/[addon_id]/init.php`:
```php
fn_register_hooks(
    'get_product_data_pre'
);
```

### Обработчик
`app/addons/[addon_id]/func.php`:
```php
function fn_my_addon_get_product_data_pre(&$product_id, &$field_list, &$auth, &$lang_code)
{
    // custom logic
}
```

## Правила
1. Имя обработчика: `fn_[addon_id]_[hook_name]`.
2. Сигнатура должна повторять параметры hook точки.
3. Если параметр должен изменяться, использовать передачу по ссылке.
4. Не добавлять тяжёлую логику в `init.php`, только wiring.
5. Не использовать PHP hooks, функции, классы или сервисы, помеченные как `@deprecated`; перед подключением hook/API проверить актуальный core PHPDoc и примеры использования.

## Проверка после изменений
- После добавления новых hook точек выполнить cache clear.

## Ошибки, которые запрещены
- Регистрация hook без обработчика.
- Обработчик с неверной сигнатурой.
- Изменение чужих данных без проверки контекста (`AREA`, `auth`, `company_id`).
