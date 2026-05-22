# Add-on Checklist

Использовать для каждой задачи, где создаётся новый модуль или меняется существующий add-on.

## Обязательная pre-flight проверка
- [ ] Прочитан `docs/workflow.md`
- [ ] Прочитан `docs/addons.md`
- [ ] Для PHP-логики прочитаны `docs/hooks-php-syntax.md`, `docs/php-coding-standards.md`, `docs/db-placeholders.md`
- [ ] Для TPL-изменений прочитаны `docs/hooks-tpl-pre-post.md`, `docs/tpl-coding-standards.md`
- [ ] Выписаны локальные правила проекта в рабочий чеклист до начала реализации
- [ ] Зафиксированы deliverables задачи и ожидаемая доказательная база для существенных выводов

## Архитектура и scope
- [ ] Реализация идёт через add-on, а не через правки core
- [ ] Выбраны hooks / schemas / controllers / templates с минимальным diff
- [ ] Решается причина, а не симптомы
- [ ] Scope файлов зафиксирован в `plan.md`

## Обязательные артефакты нового add-on
- [ ] Создан `app/addons/<addon_id>/addon.xml`
- [ ] Создан `app/addons/<addon_id>/init.php`
- [ ] Создан `app/addons/<addon_id>/func.php` при наличии hook-логики
- [ ] Все новые PHP-файлы имеют обязательную шапку Larionov.tech
- [ ] Все hook handlers зарегистрированы в `init.php`
- [ ] Название add-on в переводах начинается с `Larionov.tech: ...`
- [ ] Добавлена backend icon по пути `design/backend/media/images/addons/<addon_id>/icon.png`
- [ ] В `addon.xml` корректно отражён `has_icon`
- [ ] Добавлены переводы в `var/langs/en/addons/<addon_id>.po`
- [ ] Добавлены переводы в `var/langs/ru/addons/<addon_id>.po`

## Код и документация
- [ ] Код соответствует текущему code style проекта
- [ ] В новых PHP-файлах есть PHPDoc для функций / методов
- [ ] Добавлены короткие английские comments там, где логика неочевидна
- [ ] Не используются функции, классы, хуки или сервисы, помеченные как `@deprecated`; при наличии deprecated вызовов в затронутом участке они заменены актуальным API
- [ ] Нет лишнего рефакторинга вне задачи
- [ ] Нет raw SQL без placeholders
- [ ] Нет N+1 там, где можно избежать batch-логикой

## Grounding и completion
- [ ] Существенные выводы опираются на код / docs / БД / tool output, а `inference` явно помечены
- [ ] При пустых `search`/`grep`/`query` выполнены fallback-попытки и это зафиксировано
- [ ] Все deliverables покрыты или явно помечены `[blocked]`; для рискованных действий зафиксированы pre-flight / post-flight; verification loop выполнен

## Перед завершением
- [ ] `plan.md` обновлён по факту выполнения
- [ ] Создан или обновлён `execution-report.md`
- [ ] Выполнен cache clear, если менялись hooks / schemas / addon.xml / langs / templates
- [ ] Сделан финальный compliance-pass по этому чеклисту перед ответом пользователю
