# Переводы (Language variables)

- Переводы обязательны: в PHP и TPL нельзя писать строки напрямую, использовать только `__()`.
- В коде имя переменной указывается без префикса; в PO-файлах префиксы обязательны.
- Для пользовательских строк использовать `Languages::`.
- Название и описание аддона — `Addons::name::<addon_id>` и `Addons::description::<addon_id>`.
- PO-файлы лежат в `var/langs/[lang_code]/`.
- Переводы аддонов: `var/langs/[lang_code]/addons/[addon_id].po` (имя файла = `<id>` из `addon.xml`).
- Для текущего проекта переводы аддонов хранить именно в `var/langs/[lang_code]/addons/[addon_id].po` (не в `app/addons/[addon_id]/po`).
- Имя файла перевода и все `msgctxt` с префиксом аддона должны строго соответствовать `id` из `addon.xml`.
- Переводы темы: `design/themes/[theme]/langs/[language_code].po`, язык по умолчанию задается `default_language` в `manifest.json`.
- Структура записи: `msgctxt` (имя переменной), `msgid` (оригинал, обычно EN), `msgstr` (перевод). `msgid` одинаков для всех языков.
- Плейсхолдеры оформлять в квадратных скобках и передавать значениями при вызове `__()`.
- Формы множественного числа задаются через `|` и `[n]`, число передается во 2-м параметре.
- При установке аддона значения из PO попадают в `language_values` и кэшируются; при обновлении добавляются только новые переменные.
- Структура заголовка `.po` должна соответствовать рабочим файлам проекта (`var/langs/[lang_code]/addons/*.po`) и содержать как минимум:
  `Project-Id-Version`, `Content-Type`, `Content-Transfer-Encoding`, `Language-Team`, `Language`, `Plural-Forms`, `PO-Revision-Date`.
- Рекомендуемые коды языка в заголовке: `ru_RU` для русского и `en_US` для английского.

```po
msgctxt "Languages::email_marketing.subscription_confirmed"
msgid "Thank you for subscribing to our newsletter"
msgstr "Thank you for subscribing to our newsletter"
```

```po
msgctxt "Addons::name::sample_addon_3_0"
msgid "3.0 scheme addon sample"
msgstr "3.0 scheme addon sample"
```

```php
$confirmed_text = __('email_marketing.subscription_confirmed');
```

```smarty
{__("admin_text_letter_footer", ["[company_name]" => $settings.Company.company_name])}
```

```php
$return[$service_code]['delivery_time'] = __("n_days", array($shipment->GuaranteedDaysToDelivery));
```
