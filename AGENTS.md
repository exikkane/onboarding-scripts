## Workflow — читать всегда

Основное:
1. Прочитать `docs/workflow.md`.
2. Открывать только профильные документы по карте ниже, если задача реально затрагивает область.
3. Не меняй код-стиль проекта; предпочитай минимальные диффы.
4. Если задача затрагивает add-on: пройти `docs/flow-templates/addon-checklist.md` до реализации и сделать compliance-pass перед финальным ответом.
5. Все изменения внутри проекта кратко документировать в `project_changes.md` в корне проекта.
6. При debugging/bugfix решать причину, а не симптомы.

## Карта документов

### Работа с модулями и проектом в целом
Читать:
- `docs/addons.md`

### PHP-логика через хуки
Читать:
- `docs/hooks-php-syntax.md`
- `docs/php-coding-standards.md`
- `docs/db-placeholders.md`

### TPL/HTML изменения через хуки
Читать:
- `docs/hooks-tpl-pre-post.md`
- `docs/tpl-coding-standards.md`

Шаблоны:
- `docs/flow-templates/plan.template.md` — только когда нужен `plan.md`
- `docs/flow-templates/execution-report.template.md` — только когда нужен `execution-report.md`
- `docs/flow-templates/addon-checklist.md` — только для add-on задач

Детальные DOs and DON'Ts: `docs/dos-and-donts.md`.

### Уведомления
Читать:
- `docs/notifications.md`

### Schemas
Читать:
- `docs/shemas.md`

### Работа с переводами
Читать:
- `docs/translations.md`
