## Workflow

Перед реализацией добираем недостающий контекст через код, локальную документацию, БД и tool output. Уточняющие вопросы задаем только если критичный контекст нельзя извлечь автоматически.

### 1. Research
- Определить затронутые hooks/controllers/schemas/templates/data/UI.
- Для аналитики использовать `sub-questions -> retrieval -> synthesis`.
- При изменении PHP/API проверить, не помечены ли используемые функции/классы/хуки как `@deprecated`.
- Существенные факты подтверждать кодом, docs, БД или tool output; интерпретации явно помечать как `inference`.
- Если поиск/grep/query дал пустой или слишком узкий результат, сделать 1-2 fallback-попытки.
- Для простых задач после research можно сразу переходить к реализации; `plan.md` нужен для сложных, рискованных и add-on задач.
- Если задача затрагивает add-on, до реализации пройти `docs/flow-templates/addon-checklist.md`.

### 2. Plan
Только для сложных, рискованных и add-on задач.

- Использовать `docs/flow-templates/plan.template.md`.
- Зафиксировать scope файлов, deliverables, assumptions/blockers, TODO, cache clear и regression/verification plan.
- При изменении задачи обновить scope и явно отделить новый объём от прежнего.

### 3. Execute
- Работать минимальным diff и в стиле проекта.
- Если есть `plan.md`, идти по TODO и отмечать выполненные пункты по ходу.
- Перед рискованным действием кратко фиксировать intended action; после выполнения фиксировать outcome и проверку.
- Если deliverable нельзя закрыть, пометить его `[blocked]` с причиной.

### 4. Cache Clear
Обязателен после изменений hooks, schemas, `addon.xml`, templates/layout, language vars или settings. Процедура: `docs/debugging-cache.md`.

### 5. Verification
- Проверить покрытие требований пользователя, grounding, side effects и отсутствие незакрытых deliverables.
- Для UI/HTML/storefront/admin/canonical/meta/robots сценариев использовать `playwright`; если в проекте есть `scripts/pwcli.sh`, запускать через него из корня проекта.
- Если создается `execution-report.md`, фиксировать в нём проверенные URL/сценарии, assertions и screenshots/traces при наличии.

### 6. Final
- Обновить `project_changes.md` в корне проекта.
- Если был `plan.md` или `execution-report.md`, привести их к фактическому состоянию.
- Для add-on задач перед ответом сделать compliance-pass по `docs/flow-templates/addon-checklist.md`.
