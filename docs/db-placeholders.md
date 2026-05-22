# Читать когда: пишешь SQL через db_query/db_get_*
# НЕ читать когда: задача не использует БД

## Назначение
Стандартизировать безопасные SQL-запросы через placeholders.

## Основные placeholders

### `?i` integer
```php
db_get_row('SELECT * FROM ?:orders WHERE order_id = ?i', $order_id);
```

### `?s` string
```php
db_get_field('SELECT status FROM ?:orders WHERE order_id = ?i AND lang_code = ?s', $order_id, $lang_code);
```

### `?a` list of strings for `IN (...)`
```php
db_get_array('SELECT * FROM ?:products WHERE product_code IN (?a)', $product_codes);
```

### `?n` list of integers for `IN (...)`
```php
db_get_array('SELECT * FROM ?:products WHERE product_id IN (?n)', $product_ids);
```

### `?u` update set from array
```php
db_query('UPDATE ?:orders SET ?u WHERE order_id = ?i', $data, $order_id);
```

### `?e` insert values from array
```php
db_query('INSERT INTO ?:my_table ?e', $data);
```

### `?w` where builder from array
```php
db_get_array('SELECT * FROM ?:products WHERE ?w', $conditions);
```

## Banned SQL patterns
- `REPLACE INTO`
- `INSERT ... ON DUPLICATE KEY UPDATE`
- `SQL_CALC_FOUND_ROWS`
- `ORDER BY FIELD()`
- SQL с конкатенацией пользовательского ввода

## Правила
1. Всегда использовать placeholders.
2. Не писать vendor-specific SQL без крайней необходимости.
3. Проверять DB изменения регрессионным сценарием задачи.
4. Для install/uninstall SQL в `addon.xml` следовать тем же ограничениям.
