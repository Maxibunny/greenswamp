# Lily Market — полный README по проекту

## 1. Назначение проекта

**Lily Market** — учебный backend для индивидуального задания по дисциплине «Серверное программирование».

Проект реализует серверную часть кампусного маркетплейса-аукциона: пользователи регистрируются по университетской почте, создают аукционы, делают ставки, получают уведомления и видят обновления аукциона в реальном времени через SignalR.

Основная идея проекта: сервер является единственным источником истины. Именно backend проверяет ставки, назначает победителя, завершает аукционы, создаёт уведомления и хранит данные в PostgreSQL.

---

## 2. Краткий вывод по соответствию требованиям

По предоставленной структуре и исходному коду проект закрывает основные критерии индивидуального задания:

| Критерий | Статус | Где реализовано |
|---|---:|---|
| Работа с WebSocket / SignalR | Выполнено | `LilyMarket.Api/Hubs/AuctionHub.cs`, `Program.cs`, `auctions-detail.html` |
| Архитектура API сервера | Выполнено | `Controllers`, `Services`, `Dtos`, `Entities`, `Data`, `Hubs` |
| Авторизация пользователя | Выполнено | `AuthController.cs`, `JwtTokenService.cs`, `PasswordHasher.cs` |
| Покрытие тестами | Выполнено | `LilyMarket.Tests/AuctionBidTests.cs` |
| Работа с файлами пользователя | Выполнено | `FilesController.cs`, `FileStorageService.cs`, `wwwroot/uploads/auction-covers` |
| Работа с Docker | Выполнено | `Dockerfile`, `docker-compose.yml`, `.dockerignore` |
| Интеграция в приложение | Выполнено | `register.html`, `login.html`, `auctions.html`, `auctions-create.html`, `auctions-detail.html`, `profile.html` |
| Полный цикл аукциона end-to-end | Выполнено | REST API + frontend + notifications + SignalR |
| Защита от конкурентных ставок | Выполнено | `AuctionLockProvider.cs`, тесты конкурентности |
| Автоматическое завершение по времени | Выполнено | `AuctionClosingBackgroundService.cs`, `AuctionClosingService.cs` |

Важное замечание: в проекте есть состояние `Sold` в enum `AuctionStatus`, но в предоставленном коде я не нашёл отдельный endpoint подтверждения сделки, который переводит аукцион из `Ended` в `Sold`. В тексте задания состояние `Sold` описано как часть жизненного цикла, но в минимальном списке обязательной реализации отдельно требуется создание, ставки, завершение и уведомления. Если преподаватель строго потребует именно переход `Ended -> Sold`, стоит добавить отдельный endpoint вида `POST /api/auctions/{id}/confirm-sale`. В остальном обязательная логика аукциона реализована.

Ещё одно замечание перед сдачей: в архиве присутствуют папки `bin` и `obj`. Они не нужны для сдачи, потому что это результаты сборки. Их лучше удалить перед отправкой проекта.

---

## 3. Технологии проекта

Backend:

- .NET 9;
- ASP.NET Core Web API;
- Entity Framework Core;
- PostgreSQL;
- JWT Bearer Authentication;
- SignalR;
- BackgroundService;
- Swagger / OpenAPI;
- Docker Compose.

Frontend:

- HTML;
- JavaScript;
- Tailwind CDN;
- Fetch API;
- SignalR JavaScript Client;
- LocalStorage для хранения JWT.

Тесты:

- xUnit;
- EF Core InMemory;
- FluentAssertions указан в проекте тестов, но основные проверки сделаны через `Assert`.

---

## 4. Архитектурное решение

В проекте выбран **гибридный подход**.

Команды, которые хорошо ложатся на стандартную HTTP-семантику, реализованы через REST API: регистрация, вход, создание аукциона, получение списка, получение деталей, редактирование, отмена, ставки, уведомления и загрузка файлов. Это упрощает тестирование, позволяет проверять API через Swagger и делает backend понятным для мобильного клиента.

SignalR используется для realtime-слоя: клиент подключается к группе конкретного аукциона, получает snapshot текущего состояния, отправляет ставки через Hub и получает live-обновления `AuctionUpdated`. Такой подход подходит для мобильного приложения: основные операции надёжно доступны через REST, а живые изменения приходят без постоянного polling. От чистого REST с polling отказались, потому что для аукциона это хуже по задержке, трафику и батарее мобильного устройства. От чистого SignalR отказались, потому что REST проще документировать, тестировать и использовать через Swagger.

JWT используется как единая система идентификации и для REST, и для SignalR. Для SignalR токен передаётся через `access_token`, а `Program.cs` извлекает его в `OnMessageReceived` для пути `/hubs/auction`.

---

## 5. Структура проекта

Основная структура без временных папок сборки:

```text
LilyMarket.sln
README.md
REPORT.md
TESTING.md
Dockerfile
docker-compose.yml
.dockerignore
.gitignore

LilyMarket.Api/
├── Controllers/
│   ├── AuctionsController.cs
│   ├── AuthController.cs
│   ├── FilesController.cs
│   └── NotificationsController.cs
├── Data/
│   └── AppDbContext.cs
├── Dtos/
│   ├── Auctions/
│   ├── Auth/
│   ├── Bids/
│   ├── Files/
│   └── Notifications/
├── Entities/
│   ├── AppUser.cs
│   ├── Auction.cs
│   ├── Bid.cs
│   └── Notification.cs
├── Enums/
│   ├── AuctionStatus.cs
│   └── NotificationType.cs
├── Hubs/
│   └── AuctionHub.cs
├── Migrations/
├── Services/
│   ├── AuctionBidService.cs
│   ├── AuctionBidServiceResult.cs
│   ├── AuctionClosingBackgroundService.cs
│   ├── AuctionClosingService.cs
│   ├── AuctionLockProvider.cs
│   ├── FileStorageService.cs
│   ├── JwtTokenService.cs
│   └── PasswordHasher.cs
├── wwwroot/
│   └── uploads/
│       └── auction-covers/
├── Program.cs
├── appsettings.json
└── appsettings.Development.json

LilyMarket.Tests/
├── AuctionBidTests.cs
└── LilyMarket.Tests.csproj

indiv/auction/
├── auctions.html
├── auctions-create.html
├── auctions-detail.html
└── README.md

register.html
login.html
profile.html
index.html
```

---

## 6. Для чего нужны основные backend-файлы

### `Program.cs`

Главный файл запуска backend.

В нём настроены:

- Controllers;
- SignalR;
- Swagger;
- CORS;
- EF Core + PostgreSQL;
- JWT Bearer Authentication;
- извлечение JWT для SignalR из `access_token`;
- сервисы приложения;
- `AuctionClosingBackgroundService`;
- `UseStaticFiles()` для раздачи загруженных изображений;
- endpoint `/` для проверки статуса API;
- endpoint Hub `/hubs/auction`.

Также в нём есть автоматическое применение миграций при Docker-запуске, если включён параметр:

```text
App__ApplyMigrationsOnStartup=true
```

---

### `AppDbContext.cs`

EF Core контекст базы данных.

Содержит таблицы:

- `Users`;
- `Auctions`;
- `Bids`;
- `Notifications`.

Также задаёт связи, индексы, ограничения длины строк, точность decimal-полей и хранение enum-ов как строк.

---

### `AuthController.cs`

Контроллер авторизации.

Реализует:

- регистрацию пользователя;
- вход пользователя;
- получение текущего пользователя по JWT.

Проверяет:

- имя пользователя;
- email;
- университетский email;
- минимальную длину пароля;
- уникальность email.

Endpoint-ы:

```text
POST /api/auth/register
POST /api/auth/login
GET  /api/auth/me
```

---

### `AuctionsController.cs`

Главный REST-контроллер аукционов.

Реализует:

- список активных аукционов;
- фильтрацию по категории;
- поиск;
- сортировку;
- пагинацию;
- получение деталей;
- создание аукциона;
- редактирование аукциона;
- отмену аукциона;
- ставку через REST.

Endpoint-ы:

```text
GET    /api/auctions
GET    /api/auctions/{id}
POST   /api/auctions
PUT    /api/auctions/{id}
DELETE /api/auctions/{id}
POST   /api/auctions/{id}/bids
```

---

### `AuctionBidService.cs`

Сервис бизнес-логики ставок.

Именно здесь выполняются основные правила аукциона:

- аукцион должен существовать;
- аукцион должен быть активным;
- серверное время не должно быть позже `EndTimeUtc`;
- продавец не может делать ставку на свой аукцион;
- пользователь должен существовать;
- первая ставка должна быть не ниже `StartingBid`;
- последующие ставки должны быть не ниже `CurrentBid + MinimumIncrement`;
- предыдущий лидер получает уведомление `Outbid`;
- текущий участник получает `BidAccepted`;
- если ставка достигла `BuyNowPrice`, аукцион завершается сразу;
- создаются уведомления победителю и продавцу.

В контроллере логика ставок не размазана — он вызывает сервис. Это улучшает архитектуру и делает тесты проще.

---

### `AuctionLockProvider.cs`

Сервис защиты от конкурентных ставок.

Использует:

```csharp
ConcurrentDictionary<Guid, SemaphoreSlim>
```

Для каждого аукциона создаётся отдельный `SemaphoreSlim`. Если две ставки приходят одновременно на один аукцион, они обрабатываются последовательно. Это защищает поля:

- `CurrentBid`;
- `CurrentWinnerId`;
- `BidCount`;
- список ставок.

---

### `AuctionClosingBackgroundService.cs`

Фоновый сервис.

Он работает на сервере и регулярно вызывает обработку аукционов. Клиент не отвечает за завершение аукционов. Это соответствует требованию: серверные часы являются источником истины.

---

### `AuctionClosingService.cs`

Сервис завершения аукционов.

Реализует:

- уведомления о скором завершении;
- завершение истёкших аукционов;
- завершение без ставок;
- завершение с победителем;
- уведомления продавцу и победителю.

---

### `AuctionHub.cs`

SignalR Hub.

Адрес:

```text
/hubs/auction
```

Методы:

```text
JoinAuction
LeaveAuction
PlaceBid
```

События клиенту:

```text
AuctionSnapshot
AuctionUpdated
BidAccepted
BidRejected
AuctionRealtimeError
```

Зачем нужен:

- чтобы две открытые вкладки аукциона видели обновления без перезагрузки;
- чтобы мобильный клиент мог получать изменения в реальном времени;
- чтобы пользователь сразу видел новую цену, победителя и статус аукциона.

---

### `NotificationsController.cs`

Контроллер уведомлений.

Endpoint-ы:

```text
GET  /api/notifications
POST /api/notifications/{id}/read
POST /api/notifications/read-all
```

Возвращает уведомления текущего пользователя и количество непрочитанных.

---

### `FilesController.cs` и `FileStorageService.cs`

Отвечают за загрузку картинок аукциона.

Endpoint:

```text
POST /api/files/auction-cover
```

Принимает `multipart/form-data`, поле `file`.

Проверяет:

- файл есть;
- файл не пустой;
- размер не больше 5 MB;
- content-type разрешён;
- расширение разрешено.

Разрешённые форматы:

```text
.jpg
.jpeg
.png
.webp
```

Файлы сохраняются в:

```text
LilyMarket.Api/wwwroot/uploads/auction-covers
```

---

## 7. Сущности базы данных

### `AppUser`

Пользователь системы.

Основные поля:

- `Id`;
- `FullName`;
- `Email`;
- `PasswordHash`;
- `CreatedAtUtc`.

Связи:

- пользователь может создать много аукционов;
- пользователь может сделать много ставок;
- пользователь может получить много уведомлений.

---

### `Auction`

Аукцион.

Основные поля:

- `Id`;
- `SellerId`;
- `Title`;
- `Description`;
- `Category`;
- `Condition`;
- `CoverImageUrl`;
- `Location`;
- `StartingBid`;
- `MinimumIncrement`;
- `BuyNowPrice`;
- `CurrentBid`;
- `CurrentWinnerId`;
- `BidCount`;
- `EndTimeUtc`;
- `CreatedAtUtc`;
- `UpdatedAtUtc`;
- `EndedAtUtc`;
- `Status`.

Статусы:

```text
Active
Ended
Sold
Canceled
```

---

### `Bid`

Ставка.

Основные поля:

- `Id`;
- `AuctionId`;
- `BidderId`;
- `Amount`;
- `CreatedAtUtc`.

---

### `Notification`

Уведомление.

Основные поля:

- `Id`;
- `UserId`;
- `AuctionId`;
- `Type`;
- `Message`;
- `IsRead`;
- `CreatedAtUtc`.

Типы уведомлений:

```text
BidAccepted
Outbid
AuctionWon
AuctionEnded
AuctionEndedNoBids
EndingSoon
```

---

## 8. Как запустить проект локально без Docker

### 8.1. Проверить .NET

```powershell
dotnet --version
```

Проект рассчитан на `.NET 9`, что подходит под требование `.NET 8–10`.

---

### 8.2. Проверить PostgreSQL

Локальная база:

```text
lily_market
```

Пользователь:

```text
postgres
```

Пароль в учебной конфигурации:

```text
1234567890
```

---

### 8.3. Проверить строку подключения

Файл:

```text
LilyMarket.Api/appsettings.json
```

Там должна быть строка подключения к PostgreSQL.

Пример:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=lily_market;Username=postgres;Password=1234567890"
  }
}
```

---

### 8.4. Применить миграции

Из корня проекта:

```powershell
dotnet ef database update --project LilyMarket.Api --startup-project LilyMarket.Api
```

---

### 8.5. Собрать проект

```powershell
dotnet build
```

---

### 8.6. Запустить тесты

```powershell
dotnet test
```

Ожидаемый результат:

```text
Сводка теста: сбой: 0
```

---

### 8.7. Запустить backend

```powershell
dotnet run --project LilyMarket.Api
```

Ожидаемый адрес:

```text
http://localhost:5157
```

Swagger:

```text
http://localhost:5157/swagger/index.html
```

Проверка статуса API:

```text
http://localhost:5157/
```

---

## 9. Как запустить проект через Docker

Docker нужен для проверки критерия «Работа с Docker».

### 9.1. Проверить Docker

```powershell
docker --version
docker compose version
```

---

### 9.2. Запустить backend + PostgreSQL

Из корня проекта:

```powershell
docker compose up --build
```

После запуска должны подняться контейнеры:

```text
lilymarket-api
lilymarket-postgres
```

API будет доступно:

```text
http://localhost:5157/swagger/index.html
```

Проверка:

```text
http://localhost:5157/
```

В Docker-режиме ответ должен содержать:

```json
{
  "service": "Lily Market API",
  "status": "Running",
  "environment": "Docker",
  "timeUtc": "..."
}
```

---

### 9.3. Почему PostgreSQL проброшен на 5433

В `docker-compose.yml` указано:

```yaml
ports:
  - "5433:5432"
```

Внутри контейнера PostgreSQL работает на `5432`, а на компьютере доступен через `5433`. Это сделано, чтобы Docker PostgreSQL не конфликтовал с локальным PostgreSQL.

---

### 9.4. Остановить Docker

В терминале с `docker compose up --build` нажать:

```text
Ctrl + C
```

Потом выполнить:

```powershell
docker compose down
```

Если нужно удалить Docker-базу полностью:

```powershell
docker compose down -v
```

---

## 10. Как открыть frontend

Frontend — это HTML-файлы. Удобнее всего запускать через **Live Server** в VS Code.

Основные страницы:

```text
register.html
login.html
profile.html
indiv/auction/auctions.html
indiv/auction/auctions-create.html
indiv/auction/auctions-detail.html
```

Пример адресов через Live Server:

```text
http://127.0.0.1:5500/register.html
http://127.0.0.1:5500/login.html
http://127.0.0.1:5500/profile.html
http://127.0.0.1:5500/indiv/auction/auctions.html
http://127.0.0.1:5500/indiv/auction/auctions-create.html
```

Backend должен быть запущен на:

```text
http://localhost:5157
```

---

## 11. Как работает JWT

### 11.1. Где получается JWT

JWT возвращается после регистрации или входа.

Endpoint-ы:

```text
POST /api/auth/register
POST /api/auth/login
```

Пример ответа:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6...",
  "expiresAtUtc": "2026-05-21T19:00:00Z",
  "user": {
    "id": "...",
    "fullName": "Seller Frog",
    "email": "seller@greens.edu"
  }
}
```

---

### 11.2. Как использовать JWT в Swagger

1. Открыть Swagger:

```text
http://localhost:5157/swagger/index.html
```

2. Нажать кнопку **Authorize**.
3. Вставить token.

В текущей настройке Swagger схема называется `Bearer`, поэтому обычно достаточно вставить сам JWT без слова `Bearer`. Если Swagger не принимает, можно попробовать формат:

```text
Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...
```

---

### 11.3. Как использовать JWT в обычном HTTP-запросе

Нужно добавить header:

```http
Authorization: Bearer <JWT_TOKEN>
```

Пример:

```http
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...
```

---

### 11.4. Где frontend хранит JWT

Frontend сохраняет данные в LocalStorage:

```text
lilyToken
lilyUser
```

`lilyToken` используется при запросах к защищённым endpoint-ам.

---

### 11.5. Как JWT используется в SignalR

На frontend в `auctions-detail.html` SignalR подключается так, что JWT отдаётся через `accessTokenFactory`.

На backend в `Program.cs` настроено извлечение токена из query-параметра `access_token` для пути:

```text
/hubs/auction
```

Это позволяет использовать одного и того же пользователя и для REST, и для realtime-соединения.

---

## 12. Все основные endpoint-ы и как ими пользоваться

## 12.1. Регистрация

```text
POST /api/auth/register
```

Тело:

```json
{
  "fullName": "Seller Frog",
  "email": "seller@greens.edu",
  "password": "123456"
}
```

Что делает:

- проверяет email;
- проверяет пароль;
- создаёт пользователя;
- хэширует пароль;
- возвращает JWT.

Ожидаемый ответ:

```text
HTTP 200
```

---

## 12.2. Вход

```text
POST /api/auth/login
```

Тело:

```json
{
  "email": "seller@greens.edu",
  "password": "123456"
}
```

Что делает:

- ищет пользователя;
- проверяет пароль;
- возвращает JWT.

---

## 12.3. Текущий пользователь

```text
GET /api/auth/me
```

Требует JWT.

Ответ:

```json
{
  "id": "...",
  "fullName": "Seller Frog",
  "email": "seller@greens.edu"
}
```

---

## 12.4. Список аукционов

```text
GET /api/auctions
```

Параметры:

```text
sort
category
search
page
pageSize
```

Пример:

```text
GET /api/auctions?sort=ending_soon&page=1&pageSize=12
```

Ответ компактный и подходит для мобильного списка:

```json
{
  "total": 1,
  "page": 1,
  "pageSize": 12,
  "items": [
    {
      "id": "...",
      "title": "MacBook Pro 13 2021 M1",
      "category": "Tech",
      "condition": "Good",
      "coverImageUrl": "...",
      "currentBid": 0,
      "startingBid": 500,
      "buyNowPrice": 850,
      "bidCount": 0,
      "endTime": "...",
      "status": "Active"
    }
  ]
}
```

---

## 12.5. Детали аукциона

```text
GET /api/auctions/{id}
```

Возвращает полную информацию:

- продавец;
- текущий победитель;
- описание;
- цены;
- статус;
- история ставок.

---

## 12.6. Создание аукциона

```text
POST /api/auctions
```

Требует JWT.

Тело:

```json
{
  "title": "MacBook Pro 13 2021 M1",
  "description": "Selling my M1 MacBook Pro. Battery cycle count under 100. Comes with original charger.",
  "category": "Tech",
  "condition": "Good",
  "coverImageUrl": "https://picsum.photos/seed/macbook21/600/400",
  "location": "Main Library entrance",
  "startingBid": 500,
  "minimumIncrement": 20,
  "buyNowPrice": 850,
  "endTime": "2026-05-25T18:00:00"
}
```

Ожидаемый ответ:

```text
HTTP 201
```

---

## 12.7. Редактирование аукциона

```text
PUT /api/auctions/{id}
```

Требует JWT продавца.

Разрешено только если:

- аукцион активен;
- пользователь является продавцом;
- ставок ещё нет.

Если ставка уже есть, сервер вернёт ошибку.

---

## 12.8. Отмена аукциона

```text
DELETE /api/auctions/{id}
```

Требует JWT продавца.

Разрешено только если:

- аукцион активен;
- пользователь является продавцом;
- ставок ещё нет.

При успешной отмене:

```text
HTTP 204
```

Статус аукциона становится:

```text
Canceled
```

---

## 12.9. Ставка через REST

```text
POST /api/auctions/{id}/bids
```

Требует JWT покупателя.

Тело:

```json
{
  "amount": 500
}
```

Ожидаемый успешный ответ:

```json
{
  "message": "Bid accepted.",
  "auctionEnded": false,
  "auction": {
    "id": "...",
    "currentBid": 500,
    "bidCount": 1,
    "status": "Active"
  }
}
```

---

## 12.10. Некорректная ставка ниже шага

Если текущая ставка 500, а `minimumIncrement = 20`, ставка 510 будет отклонена.

Запрос:

```json
{
  "amount": 510
}
```

Ответ:

```json
{
  "message": "Bid must be at least 520.",
  "minimumAllowedBid": 520
}
```

---

## 12.11. Buy Now

Если `buyNowPrice = 850`, ставка 850 завершает аукцион сразу.

Запрос:

```json
{
  "amount": 850
}
```

Ожидаемый ответ:

```json
{
  "message": "Bid accepted. Buy Now price reached. Auction ended.",
  "auctionEnded": true,
  "auction": {
    "currentBid": 850,
    "status": "Ended",
    "endedAtUtc": "..."
  }
}
```

---

## 12.12. Уведомления

Получить уведомления:

```text
GET /api/notifications
```

Параметры:

```text
unreadOnly
take
```

Пример:

```text
GET /api/notifications?unreadOnly=false&take=50
```

Ответ:

```json
{
  "total": 2,
  "unreadCount": 2,
  "items": [
    {
      "id": "...",
      "auctionId": "...",
      "auctionTitle": "MacBook Pro 13 2021 M1",
      "type": "BidAccepted",
      "message": "Your bid of $500 was accepted for MacBook Pro 13 2021 M1.",
      "isRead": false,
      "createdAtUtc": "..."
    }
  ]
}
```

Отметить одно уведомление прочитанным:

```text
POST /api/notifications/{id}/read
```

Отметить все уведомления прочитанными:

```text
POST /api/notifications/read-all
```

---

## 12.13. Загрузка обложки аукциона

```text
POST /api/files/auction-cover
```

Требует JWT.

Тип запроса:

```text
multipart/form-data
```

Поле:

```text
file
```

Ответ:

```json
{
  "url": "http://localhost:5157/uploads/auction-covers/filename.jpg",
  "fileName": "filename.jpg",
  "sizeBytes": 12345,
  "contentType": "image/jpeg"
}
```

После этого `url` можно использовать как `coverImageUrl` при создании аукциона.

---

## 13. SignalR: как работать

Hub endpoint:

```text
/hubs/auction
```

Клиент подключается с JWT:

```javascript
const connection = new signalR.HubConnectionBuilder()
  .withUrl('http://localhost:5157/hubs/auction', {
    accessTokenFactory: () => token
  })
  .withAutomaticReconnect([0, 2000, 5000, 10000])
  .build();
```

---

### 13.1. Подключиться к аукциону

```javascript
await connection.invoke('JoinAuction', auctionId);
```

Сервер добавляет соединение в группу:

```text
auction-{auctionId}
```

И отправляет событие:

```text
AuctionSnapshot
```

---

### 13.2. Получить snapshot

```javascript
connection.on('AuctionSnapshot', auction => {
  console.log('Current auction state:', auction);
});
```

---

### 13.3. Сделать ставку через SignalR

```javascript
await connection.invoke('PlaceBid', auctionId, 520);
```

Если ставка принята, клиент получает:

```text
BidAccepted
AuctionUpdated
```

Если ставка отклонена:

```text
BidRejected
```

---

### 13.4. Получить live-обновление

```javascript
connection.on('AuctionUpdated', auction => {
  console.log('Auction updated:', auction);
});
```

Это событие отправляется всем клиентам, которые находятся в группе этого аукциона.

---

### 13.5. Отключиться от группы

```javascript
await connection.invoke('LeaveAuction', auctionId);
```

---

### 13.6. Проверка SignalR вручную

1. Запустить backend.
2. Создать аукцион.
3. Открыть `auctions-detail.html?id={auctionId}` в двух вкладках.
4. В одной вкладке сделать ставку.
5. Во второй вкладке цена и история ставок должны обновиться без перезагрузки.
6. Остановить backend и снова запустить.
7. Frontend должен переподключиться через `withAutomaticReconnect` и снова получить актуальный snapshot.

---

## 14. Полный end-to-end сценарий проверки

### 14.1. Подготовка

Запустить backend:

```powershell
dotnet run --project LilyMarket.Api
```

Открыть Swagger:

```text
http://localhost:5157/swagger/index.html
```

---

### 14.2. Продавец

1. Выполнить `POST /api/auth/register`.
2. Зарегистрировать продавца:

```json
{
  "fullName": "Seller Frog",
  "email": "seller@greens.edu",
  "password": "123456"
}
```

3. Скопировать JWT.
4. Нажать `Authorize` в Swagger.
5. Вставить JWT.
6. Выполнить `POST /api/auctions`.
7. Сохранить `id` аукциона.

---

### 14.3. Покупатель

1. Выполнить `POST /api/auth/register`.
2. Зарегистрировать покупателя:

```json
{
  "fullName": "Buyer Frog",
  "email": "buyer@greens.edu",
  "password": "123456"
}
```

3. Скопировать JWT покупателя.
4. Заменить токен в Swagger.
5. Выполнить ставку:

```text
POST /api/auctions/{id}/bids
```

```json
{
  "amount": 500
}
```

6. Проверить, что ставка принята.
7. Выполнить некорректную ставку:

```json
{
  "amount": 510
}
```

8. Проверить, что сервер вернул ошибку и `minimumAllowedBid = 520`.
9. Выполнить Buy Now:

```json
{
  "amount": 850
}
```

10. Проверить, что `auctionEnded = true`, а статус стал `Ended`.

---

### 14.4. Уведомления

С токеном покупателя:

```text
GET /api/notifications
```

Ожидаются:

```text
BidAccepted
AuctionWon
```

С токеном продавца:

```text
GET /api/notifications
```

Ожидается:

```text
AuctionEnded
```

---

### 14.5. Frontend

Через Live Server открыть:

```text
http://127.0.0.1:5500/register.html
```

Проверить сценарий:

```text
register.html -> auctions.html -> auctions-create.html -> auctions-detail.html
```

---

## 15. Тесты проекта

Тесты находятся здесь:

```text
LilyMarket.Tests/AuctionBidTests.cs
```

Запуск:

```powershell
dotnet test
```

Покрытые сценарии:

| Тест | Что проверяет |
|---|---|
| `PlaceBid_ValidFirstBid_ShouldBeAccepted` | корректная первая ставка принимается |
| `PlaceBid_BelowMinimumStep_ShouldBeRejected` | ставка ниже минимального шага отклоняется |
| `PlaceBid_OnEndedAuction_ShouldBeRejected` | нельзя ставить на завершённый аукцион |
| `PlaceBid_SellerBidsOnOwnAuction_ShouldBeRejected` | продавец не может ставить на свой аукцион |
| `PlaceBid_BuyNowPriceReached_ShouldCloseAuctionImmediately` | Buy Now завершает аукцион |
| `CloseExpiredAuction_WithBids_ShouldKeepHighestBidderAsWinner` | завершение по времени выбирает победителя |
| `CloseExpiredAuction_WithoutBids_ShouldEndWithoutWinner` | завершение без ставок не назначает победителя |
| `PlaceBid_TwoSimultaneousSameAmountBids_ShouldNotCorruptAuctionState` | конкурентные одинаковые ставки не ломают состояние |
| `PlaceBid_TwoSimultaneousBuyNowBids_ShouldAcceptOnlyOneWinner` | конкурентный Buy Now не создаёт двух победителей |
| `PlaceBid_WhenPreviousWinnerIsOutbid_ShouldCreateOutbidNotification` | предыдущий лидер получает `Outbid` |
| `PlaceBid_UnknownUser_ShouldReturnUnauthorized` | несуществующий пользователь не может ставить |
| `PlaceBid_UnknownAuction_ShouldReturnNotFound` | ставка на несуществующий аукцион возвращает 404 |
| `PlaceBid_WhenAuctionTimeAlreadyPassed_ShouldCloseAuctionAndRejectBid` | серверное время блокирует позднюю ставку |

Обязательные требования к тестам закрыты:

- валидная ставка;
- ставка ниже минимального шага;
- ставка на завершённый аукцион;
- ставка продавца на собственный аукцион;
- Buy Now;
- завершение по времени с победителем;
- завершение без ставок;
- асинхронность и конкурентность.

---

## 16. Проверка по критериям задания

### 16.1. Полный цикл аукциона end-to-end

Выполнено.

Есть:

- регистрация продавца;
- создание аукциона;
- регистрация покупателя;
- ставка;
- Buy Now;
- завершение;
- победитель;
- уведомления;
- отображение во frontend.

---

### 16.2. Правила ставок и конкурентный доступ

Выполнено.

Есть:

- `AuctionBidService`;
- `AuctionLockProvider`;
- проверки minimumIncrement;
- запрет продавцу ставить на свой аукцион;
- запрет ставки после завершения;
- тесты конкурентности.

---

### 16.3. Архитектура

Выполнено.

Логика разделена:

- `Controllers` — HTTP-слой;
- `Services` — бизнес-логика;
- `Dtos` — входные и выходные модели;
- `Entities` — модели БД;
- `Data` — EF Core;
- `Hubs` — realtime;
- `Tests` — проверка бизнес-логики.

---

### 16.4. Отключение и переподключение мобильного клиента

Выполнено на frontend-уровне через SignalR:

```javascript
.withAutomaticReconnect([0, 2000, 5000, 10000])
```

После reconnect вызывается повторный `JoinAuction`, и сервер отправляет актуальный `AuctionSnapshot`.

---

### 16.5. Тесты

Выполнено.

Тесты содержательные и покрывают обязательные области.

---

### 16.6. API-документация

Выполнено.

Есть:

- Swagger;
- README;
- TESTING;
- REPORT;
- этот полный README.

---

### 16.7. Качество кода

Выполнено на хорошем уровне:

- ставки вынесены в сервис;
- завершение вынесено в сервис;
- файлы вынесены в сервис;
- JWT вынесен в сервис;
- хэширование паролей вынесено в сервис;
- конкурентность вынесена в provider;
- контроллеры не содержат всю бизнес-логику ставок.

---

## 17. Что удалить перед сдачей

В твоём архиве сейчас есть временные папки сборки:

```text
LilyMarket.Api/bin
LilyMarket.Api/obj
LilyMarket.Tests/bin
LilyMarket.Tests/obj
```

Перед сдачей их лучше удалить. Они не нужны, потому что проект собирается командой:

```powershell
dotnet build
```

Также не нужно сдавать загруженные пользователем картинки:

```text
LilyMarket.Api/wwwroot/uploads/*
```

Но можно оставить пустую структуру папок:

```text
LilyMarket.Api/wwwroot/uploads/auction-covers
```

Если Git не хранит пустые папки, можно положить туда файл `.gitkeep`.

---

## 18. Что обязательно оставить в сдаче

Оставить:

```text
LilyMarket.sln
README.md
REPORT.md
TESTING.md
Dockerfile
docker-compose.yml
.dockerignore
.gitignore
LilyMarket.Api/
LilyMarket.Tests/
indiv/auction/
register.html
login.html
profile.html
index.html
green-toad-logo.svg
green-toad-sad.svg
green-toad-wink.svg
```

Не удалять:

```text
LilyMarket.Api/Migrations
LilyMarket.Api/appsettings.json
LilyMarket.Api/appsettings.Development.json
LilyMarket.Api/Program.cs
```

---

## 19. Быстрый чек-лист перед сдачей

Перед отправкой проекта выполнить:

```powershell
dotnet build
dotnet test
```

Потом проверить локальный запуск:

```powershell
dotnet run --project LilyMarket.Api
```

Открыть:

```text
http://localhost:5157/swagger/index.html
```

Потом проверить Docker:

```powershell
docker compose up --build
```

Открыть:

```text
http://localhost:5157/swagger/index.html
```

Потом проверить frontend через Live Server:

```text
http://127.0.0.1:5500/register.html
```

---

## 20. Академическая честность

При разработке можно указать, что использовался ИИ-инструмент как помощник для:

- объяснения ошибок;
- планирования структуры;
- подготовки DTO, сервисов и контроллеров;
- написания тестовых сценариев;
- подготовки документации.

Итоговый код был адаптирован под проект, проверен локально и через Docker.

---

## 21. Итог

Проект реализует backend аукционного приложения Lily Market с полным циклом:

```text
регистрация -> JWT -> создание аукциона -> ставка -> realtime-обновление -> Buy Now / завершение по времени -> уведомления -> frontend-интеграция -> тесты -> Docker
```

Основные критерии индивидуального задания закрыты. Единственное место, которое можно усилить при строгой проверке жизненного цикла, — отдельный endpoint подтверждения сделки и перевод `Ended -> Sold`. Сейчас enum `Sold` есть, но отдельного endpoint-а подтверждения сделки в предоставленном коде не обнаружено.
