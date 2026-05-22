# Нотификации событий (Event Notifications)

- Схема событий: `notifications/events.php`, доступна через `Tygh::$app['event.events_schema']`.
- Диспетчер событий: `Tygh::$app['event.dispatcher']`.
- Элемент схемы события содержит: `EventId`, `GroupId`, `TemplateLanguageVariable`, `DataProvider`, `ReceiverId`, `TransportId`, `BaseMessageSchema`, `DataValue`.
- `DataProvider` реализует `\Tygh\Notifications\DataProviders\IDataProvider` и готовит данные для сообщений.
- Сообщения формируются на основе схем; для почты — `\Tygh\Notifications\Transports\Mail\MailMessageSchema`, для Notification Center — `\Tygh\Notifications\Transports\Internal\InternalMessageSchema`.
- Email-сообщение описывает `to`, `from`, `reply_to`, `template_code`, `legacy_template`, `language_code`, `company_id`, `area` и данные подстановки.
- Транспорты регистрируются в `event.transports_schema` и как сервисы `Tygh::$app['event.transports.{TransportId}']`, реализуют `ITransport`.
- Получатели регистрируются в `event.receivers_schema` и через хук `get_notification_rules`; нужна языковая переменная `event.receiver.ReceiverId`.
- Настройки уведомлений задают, кому и каким транспортом отправлять события (Administration → Notifications).
- Для отправки уведомлений использовать `Tygh::$app['event.dispatcher']`. Не использовать deprecated `fn_order_notification()`; для заказов отправлять события вроде `order.updated` или `order.status_changed.<status>` через Event Notifications.

```php
Tygh::$app['event.dispatcher']->dispatch(
    'order.updated',
    $order_info,
    $notification_rules
);
```
