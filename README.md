# Lily Market — README проекта

## 1. Назначение проекта

**Lily Market** — учебный backend-проект для индивидуального задания по дисциплине «Серверное программирование».

Проект реализует серверную часть кампусного маркетплейса-аукциона. Пользователи регистрируются по университетской почте, входят в систему через JWT, создают аукционы, делают ставки, получают уведомления и видят live-обновления аукциона через SignalR.

Главный принцип проекта: **сервер является единственным источником истины**. Frontend отображает состояние, но не принимает бизнес-решения. Именно backend проверяет ставки, защищает аукцион от конкурентных запросов, завершает торги, выбирает победителя, создаёт уведомления и сохраняет историю в базе данных.

---

## 2. Краткое соответствие требованиям

| Требование | Статус | Основные файлы |
|---|---:|---|
| Регистрация по университетской почте | Выполнено | `AuthController.cs`, `JwtTokenService.cs`, `PasswordHasher.cs` |
| JWT-аутентификация | Выполнено | `Program.cs`, `JwtTokenService.cs`, `[Authorize]` в контроллерах |
| Создание аукционов | Выполнено | `AuctionsController.cs`, `CreateAuctionRequest.cs` |
| Редактирование аукциона до первой ставки | Выполнено | `AuctionsController.cs` |
| Отмена аукциона до первой ставки | Выполнено | `AuctionsController.cs` |
| Ставки | Выполнено | `AuctionBidService.cs`, `AuctionsController.cs`, `AuctionHub.cs` |
| Buy Now | Выполнено | `AuctionBidService.cs` |
| Автоматическое завершение по времени | Выполнено | `AuctionClosingBackgroundService.cs`, `AuctionClosingService.cs` |
| Победитель по истечении времени | Выполнено | `AuctionClosingService.cs` |
| Завершение без ставок | Выполнено | `AuctionClosingService.cs`, `AuctionNotificationService.cs` |
| Уведомления | Выполнено | `AuctionNotificationService.cs`, `NotificationsController.cs`, `Notification.cs` |
| SignalR / WebSocket | Выполнено | `AuctionHub.cs`, `Program.cs`, `auction-notifications.js` |
| Reconnect SignalR-клиента | Выполнено | `auctions-detail.html`, `auction-notifications.js` |
| История ставок в реальном времени | Выполнено | `AuctionNotificationService.cs`, `AuctionHub.cs`, `auction-notifications.js`, `auctions-detail.html` |
| Состояния `Active`, `Ended`, `Sold`, `Canceled` | Выполнено | `AuctionStatus.cs`, `AuctionSaleService.cs`, `AuctionsController.cs` |
| Подтверждение сделки `Ended -> Sold` | Выполнено | `AuctionSaleService.cs`, endpoint `POST /api/auctions/{id}/confirm-sale` |
| PostgreSQL через EF Core | Выполнено | `AppDbContext.cs`, `Migrations`, `appsettings.json` |
| Docker | Выполнено | `Dockerfile`, `docker-compose.yml`, `.dockerignore` |
| Работа с файлами пользователя | Выполнено | `FilesController.cs`, `FileStorageService.cs` |
| Тесты | Выполнено | `AuctionBidTests.cs`, `AuctionSaleTests.cs` |
| Документация API | Выполнено | Swagger, этот README |

---

## 3. Используемые технологии

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
- LocalStorage для хранения JWT и пользователя.

Тесты:

- xUnit;
- EF Core InMemory;
- стандартные `Assert`.

---

## 4. Архитектурное решение

В проекте выбран **гибридный подход: REST + SignalR**.

REST API используется для команд и стандартных операций: регистрация, вход, получение списка аукционов, получение деталей, создание, редактирование, отмена, подача ставки, подтверждение сделки, работа с уведомлениями и загрузка файлов. Такой подход упрощает тестирование, документирование через Swagger и интеграцию с frontend-клиентом.

SignalR используется для realtime-слоя: пользователи подключаются к группе конкретного аукциона, получают актуальное состояние, live-обновления цены, победителя, статуса, истории ставок и уведомлений. От чистого REST с polling отказались, потому что для аукционов это хуже по задержке, трафику и батарее мобильного устройства. От чистого SignalR отказались, потому что REST проще проверять, документировать и использовать для обычных CRUD-операций.

JWT используется как единая система идентификации и для REST, и для SignalR. Для REST токен передаётся через заголовок `Authorization: Bearer <token>`. Для SignalR токен передаётся через `access_token`, а backend извлекает его в `Program.cs` для пути `/hubs/auction`.

---

## 5. Структура проекта

```text
greenswamp/
├── README.md
├── LILY_MARKET_FULL_README.md
├── LilyMarket.sln
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── .gitignore
├── register.html
├── login.html
├── profile.html
├── index.html
├── indiv/
│   └── auction/
│       ├── auctions.html
│       ├── auctions-create.html
│       ├── auctions-detail.html
│       ├── auction-notifications.js
│       └── README.md
├── LilyMarket.Api/
│   ├── Controllers/
│   │   ├── AuctionsController.cs
│   │   ├── AuthController.cs
│   │   ├── FilesController.cs
│   │   └── NotificationsController.cs
│   ├── Data/
│   │   └── AppDbContext.cs
│   ├── Dtos/
│   │   ├── Auctions/
│   │   ├── Auth/
│   │   ├── Bids/
│   │   ├── Files/
│   │   └── Notifications/
│   ├── Entities/
│   │   ├── AppUser.cs
│   │   ├── Auction.cs
│   │   ├── Bid.cs
│   │   └── Notification.cs
│   ├── Enums/
│   │   ├── AuctionStatus.cs
│   │   └── NotificationType.cs
│   ├── Hubs/
│   │   └── AuctionHub.cs
│   ├── Migrations/
│   ├── Services/
│   │   ├── AuctionBidService.cs
│   │   ├── AuctionBidServiceResult.cs
│   │   ├── AuctionClosingBackgroundService.cs
│   │   ├── AuctionClosingService.cs
│   │   ├── AuctionLockProvider.cs
│   │   ├── AuctionNotificationService.cs
│   │   ├── AuctionSaleService.cs
│   │   ├── AuctionSaleServiceResult.cs
│   │   ├── FileStorageService.cs
│   │   ├── JwtTokenService.cs
│   │   └── PasswordHasher.cs
│   ├── wwwroot/
│   │   └── uploads/
│   │       └── auction-covers/
│   ├── Program.cs
│   ├── appsettings.json
│   └── appsettings.Development.json
└── LilyMarket.Tests/
    ├── AuctionBidTests.cs
    ├── AuctionSaleTests.cs
    └── LilyMarket.Tests.csproj
```

Папки `bin` и `obj` не нужны для сдачи. Это результаты сборки, они должны игнорироваться через `.gitignore`.

---

## 6. Основные backend-файлы

### `Program.cs`

Главный файл запуска backend.

В нём настроены:

- `Controllers`;
- `SignalR`;
- `Swagger`;
- `CORS`;
- `EF Core + PostgreSQL`;
- `JWT Bearer Authentication`;
- извлечение JWT для SignalR из `access_token`;
- регистрация сервисов;
- `AuctionClosingBackgroundService`;
- `UseStaticFiles()` для раздачи загруженных изображений;
- endpoint `/`;
- endpoint Hub `/hubs/auction`;
- автоматическое применение миграций при Docker-запуске, если включён параметр `App__ApplyMigrationsOnStartup=true`.

---

### `AppDbContext.cs`

EF Core контекст базы данных.

Таблицы:

- `Users`;
- `Auctions`;
- `Bids`;
- `Notifications`.

Также задаёт связи между сущностями, индексы, ограничения длины строк, точность денежных decimal-полей и хранение enum-значений.

---

### `AuthController.cs`

Контроллер авторизации.

Endpoint-ы:

```text
POST /api/auth/register
POST /api/auth/login
GET  /api/auth/me
```

Реализует:

- регистрацию пользователя;
- проверку университетской почты;
- проверку уникальности email;
- хэширование пароля;
- вход пользователя;
- выдачу JWT;
- получение текущего пользователя по JWT.

---

### `AuctionsController.cs`

Главный REST-контроллер аукционов.

Endpoint-ы:

```text
GET    /api/auctions
GET    /api/auctions/{id}
POST   /api/auctions
PUT    /api/auctions/{id}
DELETE /api/auctions/{id}
POST   /api/auctions/{id}/bids
POST   /api/auctions/{id}/confirm-sale
```

Реализует:

- список аукционов;
- поиск;
- фильтрацию;
- сортировку;
- пагинацию;
- получение деталей аукциона;
- создание аукциона;
- редактирование до первой ставки;
- отмену до первой ставки;
- ставку через REST;
- подтверждение сделки и переход `Ended -> Sold`.

---

### `AuctionBidService.cs`

Сервис бизнес-логики ставок.

Проверяет:

- аукцион существует;
- пользователь существует;
- аукцион активен;
- время аукциона ещё не истекло;
- продавец не ставит на свой аукцион;
- сумма ставки не ниже минимально допустимой;
- первая ставка не ниже `StartingBid`;
- последующие ставки не ниже `CurrentBid + MinimumIncrement`;
- Buy Now завершает аукцион немедленно.

Также сервис:

- сохраняет ставку;
- обновляет `CurrentBid`;
- обновляет `CurrentWinnerId`;
- обновляет `BidCount`;
- создаёт уведомления;
- вызывает realtime-обновления через `AuctionNotificationService`;
- возвращает компактный результат для REST и SignalR.

---

### `AuctionLockProvider.cs`

Сервис защиты от конкурентных ставок.

Использует `SemaphoreSlim` по каждому `auctionId`. Если два пользователя одновременно отправляют ставку на один аукцион, backend обрабатывает их последовательно. Это защищает состояние аукциона от повреждения.

Для учебного проекта с одним экземпляром API этого достаточно. Для production-сценария с несколькими экземплярами backend потребовалась бы блокировка на уровне базы данных или распределённый lock.

---

### `AuctionClosingBackgroundService.cs`

Фоновый сервис, который регулярно запускает проверку аукционов.

Он не зависит от клиента. Это важно, потому что завершение аукциона должно происходить по серверному времени, а не по таймеру в браузере.

---

### `AuctionClosingService.cs`

Сервис завершения аукционов.

Реализует:

- отправку уведомления о скором завершении;
- закрытие аукционов, у которых наступил `EndTimeUtc`;
- выбор победителя по максимальной валидной ставке;
- обработку аукциона без ставок;
- уведомления продавцу, победителю и участникам;
- broadcast обновлённого состояния через SignalR.

---

### `AuctionSaleService.cs`

Сервис подтверждения сделки.

Реализует переход:

```text
Ended -> Sold
```

Проверяет:

- пользователь существует;
- аукцион существует;
- аукцион ещё не `Sold`;
- аукцион находится в статусе `Ended`;
- у аукциона есть победитель;
- подтверждает сделку именно победитель.

После подтверждения создаётся уведомление `SaleConfirmed`, а участники получают live-обновление статуса.

---

### `AuctionNotificationService.cs`

Центральный сервис уведомлений.

Отвечает за:

- создание уведомления о принятой ставке;
- уведомление предыдущего лидера о перебитой ставке;
- уведомление участников и продавца об активности в аукционе;
- уведомление о скором завершении;
- уведомление победителя;
- уведомление продавца о завершении;
- уведомление о завершении без ставок;
- уведомление о подтверждении сделки;
- SignalR broadcast обновления аукциона;
- SignalR alert пользователям.

Этот сервис связывает БД-уведомления и live-события, чтобы уведомления можно было получить как через REST, так и в реальном времени.

---

### `AuctionHub.cs`

SignalR Hub.

Endpoint:

```text
/hubs/auction
```

Основные методы:

```text
JoinAuction
LeaveAuction
PlaceBid
```

Основные события клиенту:

```text
AuctionSnapshot
AuctionUpdated
BidAccepted
BidRejected
AuctionRealtimeError
NotificationAlert
Outbid
AuctionActivity
AuctionEndingSoon
AuctionEnded
SaleConfirmed
```

Пользователи подключаются к группам:

```text
auction-{auctionId}
user-{userId}
```

Группа `auction-{auctionId}` нужна для обновления всех клиентов на странице одного аукциона.  
Группа `user-{userId}` нужна для персональных уведомлений конкретному пользователю.

---

### `NotificationsController.cs`

REST-контроллер уведомлений.

Endpoint-ы:

```text
GET  /api/notifications
POST /api/notifications/{id}/read
POST /api/notifications/read-all
```

Позволяет получить уведомления из БД, количество непрочитанных уведомлений и отметить уведомления прочитанными.

---

### `FilesController.cs` и `FileStorageService.cs`

Отвечают за загрузку обложек аукционов.

Endpoint:

```text
POST /api/files/auction-cover
```

Проверяется:

- файл существует;
- файл не пустой;
- размер не больше 5 MB;
- тип файла разрешён;
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

Пользователь.

Основные поля:

- `Id`;
- `FullName`;
- `Email`;
- `PasswordHash`;
- `CreatedAtUtc`.

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
AuctionActivity
AuctionEndingSoon
EndingSoon
AuctionWon
AuctionEndedNoBids
AuctionEnded
SaleConfirmed
```

---

## 8. Как запустить проект локально без Docker

### 8.1. Проверить .NET

```powershell
dotnet --version
```

Проект рассчитан на .NET 9, что подходит под требование `.NET 8–10`.

---

### 8.2. Проверить PostgreSQL

Нужно, чтобы PostgreSQL был установлен и запущен.

Пример локальной базы:

```text
Database: lily_market
User: postgres
Password: 1234567890
Port: 5432
```

---

### 8.3. Проверить строку подключения

Файл:

```text
LilyMarket.Api/appsettings.json
```

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

Если `dotnet ef` не установлен:

```powershell
dotnet tool install --global dotnet-ef
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
Сводка теста: всего: 18; сбой: 0; успешно: 18; пропущено: 0
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

Проверка API:

```text
http://localhost:5157/
```

---

## 9. Как запустить проект через Docker

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

После запуска должны подняться:

```text
lilymarket-api
lilymarket-postgres
```

API:

```text
http://localhost:5157
```

Swagger:

```text
http://localhost:5157/swagger/index.html
```

---

### 9.3. Почему PostgreSQL проброшен на 5433

В `docker-compose.yml` внешний порт PostgreSQL обычно настроен так:

```yaml
ports:
  - "5433:5432"
```

Внутри контейнера PostgreSQL работает на `5432`, а на компьютере доступен через `5433`. Это сделано, чтобы Docker PostgreSQL не конфликтовал с локальным PostgreSQL на `5432`.

---

### 9.4. Остановить Docker

```powershell
docker compose down
```

Если нужно удалить Docker-базу полностью:

```powershell
docker compose down -v
```

---

## 10. Как открыть frontend

Frontend можно открыть через Live Server в VS Code.

Основные страницы:

```text
register.html
login.html
profile.html
indiv/auction/auctions.html
indiv/auction/auctions-create.html
indiv/auction/auctions-detail.html
```

Примеры адресов:

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
  "expiresAtUtc": "2026-05-23T19:00:00Z",
  "user": {
    "id": "...",
    "fullName": "Seller Frog",
    "email": "seller@greens.edu"
  }
}
```

---

### 11.2. Как использовать JWT в Swagger

1. Открыть:

```text
http://localhost:5157/swagger/index.html
```

2. Нажать **Authorize**.
3. Вставить JWT.

Обычно достаточно вставить сам токен. Если Swagger ожидает полный формат, вставить:

```text
Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6...
```

---

### 11.3. Как использовать JWT в HTTP-запросах

Добавить header:

```http
Authorization: Bearer <JWT_TOKEN>
```

---

### 11.4. Где frontend хранит JWT

Frontend сохраняет данные в LocalStorage:

```text
lilyToken
lilyUser
```

`lilyToken` используется для защищённых REST-запросов и SignalR-подключения.

---

### 11.5. Как JWT используется в SignalR

Frontend передаёт JWT через `accessTokenFactory`.

Backend в `Program.cs` извлекает токен из query-параметра `access_token` для пути:

```text
/hubs/auction
```

Так REST и SignalR используют одну систему идентификации.

---

## 12. Основные API endpoint-ы

### 12.1. Регистрация

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

---

### 12.2. Вход

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

---

### 12.3. Текущий пользователь

```text
GET /api/auth/me
```

Требует JWT.

---

### 12.4. Список аукционов

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

---

### 12.5. Детали аукциона

```text
GET /api/auctions/{id}
```

Возвращает полную информацию по аукциону, включая историю ставок.

---

### 12.6. Создание аукциона

```text
POST /api/auctions
```

Требует JWT.

Пример тела:

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

Успешный ответ:

```text
HTTP 201
```

---

### 12.7. Редактирование аукциона

```text
PUT /api/auctions/{id}
```

Требует JWT продавца.

Разрешено только если:

- аукцион активен;
- пользователь является продавцом;
- ставок ещё нет.

---

### 12.8. Отмена аукциона

```text
DELETE /api/auctions/{id}
```

Требует JWT продавца.

Разрешено только если:

- аукцион активен;
- пользователь является продавцом;
- ставок ещё нет.

После успешной отмены статус становится:

```text
Canceled
```

---

### 12.9. Ставка через REST

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

Успешный ответ:

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

### 12.10. Некорректная ставка ниже шага

Если текущая ставка `500`, а `minimumIncrement = 20`, ставка `510` будет отклонена.

Пример ответа:

```json
{
  "message": "Bid must be at least 520.",
  "minimumAllowedBid": 520
}
```

---

### 12.11. Buy Now

Если `buyNowPrice = 850`, ставка `850` завершает аукцион сразу.

Пример ответа:

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

### 12.12. Подтверждение сделки

```text
POST /api/auctions/{id}/confirm-sale
```

Требует JWT победителя.

Условия:

- аукцион должен быть в статусе `Ended`;
- у аукциона должен быть победитель;
- подтверждать должен победитель;
- аукцион не должен быть уже `Sold`.

После успешного подтверждения статус становится:

```text
Sold
```

---

### 12.13. Уведомления

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

Отметить одно уведомление прочитанным:

```text
POST /api/notifications/{id}/read
```

Отметить все уведомления прочитанными:

```text
POST /api/notifications/read-all
```

---

### 12.14. Загрузка обложки аукциона

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

Ответ содержит URL файла, который можно использовать как `coverImageUrl` при создании аукциона.

---

## 13. SignalR

Hub endpoint:

```text
/hubs/auction
```

Подключение:

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

Сервер добавляет пользователя в группу:

```text
auction-{auctionId}
```

И отправляет актуальное состояние через:

```text
AuctionSnapshot
```

---

### 13.2. Сделать ставку через SignalR

```javascript
await connection.invoke('PlaceBid', auctionId, 520);
```

Если ставка принята:

```text
BidAccepted
AuctionUpdated
```

Если ставка отклонена:

```text
BidRejected
```

---

### 13.3. Live-обновление аукциона

Событие:

```text
AuctionUpdated
```

Оно отправляется всем клиентам в группе аукциона. На frontend после этого обновляется цена, текущий победитель, статус и история ставок.

---

### 13.4. Live-уведомления

События:

```text
NotificationAlert
Outbid
AuctionActivity
AuctionEndingSoon
AuctionEnded
SaleConfirmed
```

Они используются для всплывающих alert/toast-сообщений и синхронизации состояния у участников.

---

### 13.5. Reconnect

Frontend использует:

```javascript
.withAutomaticReconnect([0, 2000, 5000, 10000])
```

После переподключения клиент снова вызывает `JoinAuction`, а сервер отправляет свежий `AuctionSnapshot`. Это позволяет восстановить актуальное состояние после временного обрыва соединения.

---

## 14. Уведомления в проекте

Обязательные уведомления из задания реализованы:

| Событие | Тип уведомления |
|---|---|
| Принятая ставка | `BidAccepted` |
| Ставка перебита | `Outbid` |
| Кто-то взаимодействует с аукционом | `AuctionActivity` |
| Скорое завершение за 5 минут | `AuctionEndingSoon` / `EndingSoon` |
| Победа | `AuctionWon` |
| Завершение с победителем | `AuctionEnded` |
| Завершение без ставок | `AuctionEndedNoBids` |
| Подтверждение сделки | `SaleConfirmed` |

Уведомления сохраняются в БД, поэтому пользователь может увидеть их после перезагрузки страницы через `GET /api/notifications`.

Для live-режима уведомления также отправляются через SignalR пользователям и участникам аукциона.

---

## 15. Полный end-to-end сценарий проверки

### 15.1. Подготовка

Запустить backend:

```powershell
dotnet run --project LilyMarket.Api
```

Открыть Swagger:

```text
http://localhost:5157/swagger/index.html
```

---

### 15.2. Продавец

1. Зарегистрировать продавца через `POST /api/auth/register`.
2. Получить JWT.
3. Авторизоваться в Swagger.
4. Создать аукцион через `POST /api/auctions`.
5. Сохранить `id` аукциона.

---

### 15.3. Покупатель

1. Зарегистрировать покупателя через `POST /api/auth/register`.
2. Получить JWT покупателя.
3. Авторизоваться как покупатель.
4. Сделать ставку через `POST /api/auctions/{id}/bids`.
5. Проверить, что ставка принята.
6. Сделать ставку ниже шага и проверить ошибку.
7. Сделать ставку на `buyNowPrice` и проверить завершение аукциона.

---

### 15.4. Подтверждение сделки

1. После завершения аукциона победитель вызывает:

```text
POST /api/auctions/{id}/confirm-sale
```

2. Проверить, что статус стал:

```text
Sold
```

---

### 15.5. Уведомления

Проверить уведомления продавца и покупателя:

```text
GET /api/notifications
```

Ожидаемые типы:

```text
BidAccepted
Outbid
AuctionWon
AuctionEnded
AuctionEndedNoBids
AuctionEndingSoon
SaleConfirmed
```

---

### 15.6. Frontend

Через Live Server открыть:

```text
http://127.0.0.1:5500/register.html
```

Проверить сценарий:

```text
register.html -> login.html -> auctions.html -> auctions-create.html -> auctions-detail.html
```

Для проверки live-режима открыть страницу деталей одного аукциона в двух разных браузерах или профилях, войти под разными пользователями и сделать ставку. Цена, статус и история ставок должны обновляться у всех участников без ручной перезагрузки.

---

## 16. Тесты проекта

Тесты находятся здесь:

```text
LilyMarket.Tests/AuctionBidTests.cs
LilyMarket.Tests/AuctionSaleTests.cs
```

Запуск:

```powershell
dotnet test
```

Ожидаемый результат:

```text
Сводка теста: всего: 18; сбой: 0; успешно: 18; пропущено: 0
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
| `ConfirmSale_WinnerConfirmsEndedAuction_ShouldMarkAuctionAsSold` | победитель подтверждает сделку |
| `ConfirmSale_NotWinner_ShouldBeForbidden` | посторонний пользователь не может подтвердить сделку |
| `ConfirmSale_ActiveAuction_ShouldBeRejected` | активный аукцион нельзя перевести в Sold |
| `ConfirmSale_EndedAuctionWithoutWinner_ShouldBeRejected` | нельзя подтвердить аукцион без победителя |
| `ConfirmSale_AlreadySoldAuction_ShouldBeRejected` | нельзя повторно подтвердить уже проданный аукцион |

Обязательные требования к тестам закрыты:

- валидная ставка;
- ставка ниже минимального шага;
- ставка на завершённый аукцион;
- ставка продавца на собственный аукцион;
- Buy Now;
- завершение по времени с победителем;
- завершение без ставок;
- конкурентность;
- подтверждение сделки.

---

## 17. Проверка по критериям оценки

### 17.1. Полный цикл аукциона end-to-end

Выполнено.

Цикл:

```text
регистрация -> JWT -> создание аукциона -> ставка -> live-обновление -> Buy Now / завершение по времени -> победитель -> уведомления -> Sold
```

---

### 17.2. Правила ставок и конкурентный доступ

Выполнено.

Реализовано в:

```text
AuctionBidService.cs
AuctionLockProvider.cs
AuctionBidTests.cs
```

---

### 17.3. Архитектура

Выполнено.

Код разделён по слоям:

```text
Controllers
Services
Dtos
Entities
Data
Hubs
Tests
```

Бизнес-логика ставок, завершения и подтверждения сделки вынесена из контроллеров в сервисы.

---

### 17.4. Отключение и переподключение клиента

Выполнено на frontend-уровне через SignalR automatic reconnect.

После reconnect клиент снова подключается к группе аукциона и получает актуальное состояние.

---

### 17.5. Тесты

Выполнено.

Тесты запускаются командой:

```powershell
dotnet test
```

Без дополнительной настройки.

---

### 17.6. API-документация

Выполнено.

Есть:

- Swagger;
- этот README;
- описание endpoint-ов;
- описание JWT;
- описание Docker;
- описание SignalR;
- описание тестов.

---

### 17.7. Качество кода

Выполнено.

Сильные стороны:

- контроллеры не содержат всю бизнес-логику;
- ставки вынесены в `AuctionBidService`;
- завершение вынесено в `AuctionClosingService`;
- подтверждение сделки вынесено в `AuctionSaleService`;
- уведомления вынесены в `AuctionNotificationService`;
- работа с файлами вынесена в `FileStorageService`;
- JWT вынесен в `JwtTokenService`;
- хэширование паролей вынесено в `PasswordHasher`;
- конкурентность вынесена в `AuctionLockProvider`.

---

## 18. Что удалить перед сдачей

Перед сдачей не нужно отправлять временные папки сборки:

```text
LilyMarket.Api/bin
LilyMarket.Api/obj
LilyMarket.Tests/bin
LilyMarket.Tests/obj
```

Также не нужно отправлять пользовательские загруженные файлы:

```text
LilyMarket.Api/wwwroot/uploads/*
```

Но можно оставить структуру папок:

```text
LilyMarket.Api/wwwroot/uploads/auction-covers
```

Если Git не сохраняет пустую папку, можно добавить `.gitkeep`.

---

## 19. Что обязательно оставить

```text
README.md
LILY_MARKET_FULL_README.md
LilyMarket.sln
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

Обязательно оставить:

```text
LilyMarket.Api/Migrations
LilyMarket.Api/appsettings.json
LilyMarket.Api/appsettings.Development.json
LilyMarket.Api/Program.cs
```

---

## 20. Быстрый чек-лист перед сдачей

Выполнить:

```powershell
dotnet build
dotnet test
```

Запустить backend:

```powershell
dotnet run --project LilyMarket.Api
```

Открыть:

```text
http://localhost:5157/swagger/index.html
```

Проверить Docker:

```powershell
docker compose up --build
```

Проверить frontend через Live Server:

```text
http://127.0.0.1:5500/register.html
```

Проверить сценарий:

```text
продавец -> создание аукциона -> покупатель -> ставка -> live-обновление -> Buy Now -> уведомления -> confirm-sale -> Sold
```

---

## 21. Академическая честность и использование ИИ-инструмента

Проектные решения и итоговая реализация адаптированы под данное индивидуальное задание и структуру проекта Lily Market.

В процессе разработки использовался ИИ-инструмент ChatGPT как помощник для:

- объяснения ошибок компиляции и тестов;
- планирования архитектуры REST + SignalR;
- подготовки вариантов DTO, сервисов и контроллеров;
- написания и расширения тестовых сценариев;
- улучшения README-документации;
- проверки соответствия проекта критериям задания.

ИИ-инструмент использовался как справочный и учебный помощник. Итоговые решения, структура проекта, проверка работоспособности, запуск `dotnet build`, `dotnet test`, Docker и интеграция с frontend выполнялись и адаптировались в рамках данного проекта.

---

## 22. Итог

Проект реализует backend аукционного приложения Lily Market с полным циклом:

```text
регистрация -> JWT -> создание аукциона -> ставка -> realtime-обновление -> Buy Now / завершение по времени -> уведомления -> подтверждение сделки Sold -> frontend-интеграция -> тесты -> Docker
```

Основные критерии индивидуального задания закрыты:

- WebSocket / SignalR;
- архитектура API;
- авторизация;
- тесты;
- файлы пользователя;
- Docker;
- интеграция с frontend;
- realtime-обновления;
- уведомления;
- конкурентность;
- серверное завершение аукционов.
