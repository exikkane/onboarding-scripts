# Разработка модулей (Add-ons)

## Общие положения
- Все расширения делаются через add-ons; точки расширения — PHP hooks и TPL hooks.
- PHP hook объявляется `fn_set_hook(...)` в ядре; модуль подписывается в `init.php` через `fn_register_hooks(...)`, логика — в `func.php` с именем `fn_<addon>_<hook>()`.
- Любой реализованный в модуле PHP hook-handler (включая `settings_variants_*`) должен быть явно зарегистрирован в `app/addons/<addon_id>/init.php` через `fn_register_hooks(...)`.
- В add-on коде нельзя добавлять вызовы функций, классов, хуков или сервисов, помеченных как `@deprecated`; при работе с затронутым участком deprecated API нужно заменить актуальным core API минимальным диффом.
- TPL hook — блок `{hook name="section:hook_name"}...{/hook}`; добавление/переопределение через hook-шаблоны.
- Новые PHP-файлы должны иметь шапку Larionov.tech; точный шаблон см. в `docs/php-coding-standards.md`.
- Новый модуль должен иметь `addon.xml`, `init.php`, backend icon и переводы; контрольный список — `docs/flow-templates/addon-checklist.md`.
- все новые модули начинаются с префикса lt_
- наименования (перевод) модуля начинается с Larionov.tech: [название модуля]

## Пути и структура
- Обязательная папка модуля: `app/addons/<addon_name>`.
- В ней обычно находятся `addon.xml`, `func.php`, `init.php`, `config.php`, а также `controllers/` и `schemas/`.
- Дополнительные шаблоны:
`var/themes_repository/responsive/templates/addons/<addon_name>`,
`design/backend/templates/addons/<addon_name>`,
`var/themes_repository/responsive/mail/templates/addons/<addon_name>`.

## Слои модуля (глобальный стандарт)
- Для новых модулей используется разделение на слои:
`Delivery -> Application -> Domain -> Infrastructure`.
- Delivery: `init.php`, `func.php`, `controllers/*` (вход в модуль, валидация, делегирование в сервисы).
- Application: `Tygh/Addons/<Module>/Service/*` (сценарии и оркестрация вызовов).
- Domain: `Tygh/Addons/<Module>/Dto/*`, `Tygh/Enum/Addons/<Module>/*`, `Tygh/Addons/<Module>/Interfaces/*`.
- Infrastructure: `Tygh/Addons/<Module>/Repository/*`, `Tygh/Addons/<Module>/Storage/*`, `Tygh/Addons/<Module>/Helpers/*`, API/SDK adapters.
- Прямые `db_*` вызовы в Delivery/Application слое запрещены; доступ к БД только через `Repository`.
- Не допускать "god-service": один сервис отвечает за один бизнес-контекст.
- Пустые директории не создавать: структура формируется по мере появления кода.

## addon.xml и схемы
- `addon.xml` обязателен: `app/addons/[addon_name]/addon.xml`.
- При открытии «Add-ons → Manage add-ons» система сканирует `app/addons/` и читает `addon.xml` для неустановленных модулей.
- При установке данные из `addon.xml` сохраняются в БД, а структура настроек читается из файла каждый раз.
- Схемы: 2.0 (устарела с 4.2.x) и 3.0 (актуальная; переводы и lang vars в `.po`).

```xml
<addon scheme="3.0">
    <id>sample_addon_3_0</id>
    <version>1.0</version>
</addon>
```

## TPL hooks и override
- Подключение hook-шаблона:
`design/backend/templates/addons/[addon_id]/hooks/[template]/[hook].[pre|post|override].tpl`
или `design/themes/[theme]/templates/addons/[addon_id]/hooks/...`.
- Полный override: `design/.../templates/addons/[addon_id]/overrides/...` с тем же относительным путем, что и у оригинального шаблона.
