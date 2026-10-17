# RaceDay

A full-stack web-based event management system for South African road running, walking and cycling events. Event Organisers create and manage events, categories, routes and results. Participants browse events, enter a category, track their personal performance history, and prepare for race day with route and live weather information.

This is an individual project built across three parts:

| Part | What | Where |
|---|---|---|
| 1 | System planning and database (ERD, API endpoint plan, SQL script) | [`/docs`](./docs) |
| 2 | RESTful API (ASP.NET Core, Entity Framework Core, session authentication, Swagger, unit tests, CI) | [`/Part2`](./Part2) |
| 3 | MVC front end | _coming later_ |

---

## Part 2 - RESTful API

### Technology
- ASP.NET Core Web API (C#, .NET 8)
- Entity Framework Core 8 with the **Code-First** approach, on SQL Server
- Session-based authentication (server-side session) with **BCrypt** password hashing
- Swagger / OpenAPI (Swashbuckle) with XML documentation on every endpoint
- xUnit tests using `WebApplicationFactory` and an in-memory database
- GitHub Actions: builds the solution and runs all tests on every push

### Prerequisites
- Visual Studio 2022 (or newer) with the **ASP.NET and web development** workload
- .NET 8 SDK
- SQL Server Express (or LocalDB) and SQL Server Management Studio (optional, to inspect the data)
- Git

### Setup and run instructions
1. **Clone the repository** and open `Part2/RaceDay.sln` in Visual Studio.
2. **Check the connection string** in `Part2/RaceDay.Api/appsettings.json`. It defaults to `Server=.\SQLEXPRESS;Database=RaceDayApiDb;Trusted_Connection=True;TrustServerCertificate=True;`. Change the server name if yours is different (for example `(localdb)\MSSQLLocalDB`).
3. **Create the database.** Open **Tools > NuGet Package Manager > Package Manager Console**, set *Default project* to `RaceDay.Api`, then run:
   ```
   Add-Migration InitialCreate
   Update-Database
   ```
   This builds the `RaceDayApiDb` database from the C# model (Code-First) and seeds the three roles (Admin, Organiser, Participant).
4. **Run the API.** Set `RaceDay.Api` as the startup project and press **F5**. Swagger opens automatically (for example `http://localhost:5080/swagger`).
5. **Try it in Swagger:** register an Organiser (`POST /api/auth/register`), log in (`POST /api/auth/login`), then create an event. Swagger keeps the session cookie for you, so later calls are already logged in. Use `POST /api/auth/logout` and log in as a Participant to see the role rules in action.

### Running the unit tests
- In Visual Studio: **Test > Run All Tests** (Test Explorer).
- Or from a terminal in the `Part2` folder: `dotnet test`

The tests use an in-memory database, so they never touch SQL Server and also run in GitHub Actions.

### The two roles
| Role | Can do |
|---|---|
| **Organiser** | Create, update and delete their own events; add, update and delete categories; set a route for a category; view all enrolments for their events; record finish times and positions |
| **Participant** | Browse events, categories, routes, weather and leaderboards; enrol in an event by choosing a category; cancel their own enrolment; view their own enrolments and personal performance history |
| Both | Register, log in/out, view and update their own profile |

Registration only allows the roles **Organiser** and **Participant**. Nobody can register themselves as Admin.

### How authentication works
1. `POST /api/auth/register` stores the user with a **BCrypt hash** of the password. The original password is never saved or returned.
2. `POST /api/auth/login` checks the password and stores the user's ID and role in the **server-side session**. The browser holds only a session cookie.
3. Protected endpoints use a `[SessionAuthorize]` attribute. Not logged in gives **401 Unauthorized**; logged in with the wrong role gives **403 Forbidden**.
4. Organisers can only change their **own** events (ownership is checked, not only the role).

### Endpoints
Everything from the Part 1 plan is implemented; open Swagger to see each endpoint with its purpose, request body and responses.

| Area | Endpoints |
|---|---|
| Authentication | `POST /api/auth/register`, `POST /api/auth/login`, `POST /api/auth/logout` |
| User profile | `GET/PUT /api/users/me`, `GET /api/users/me/enrolments`, `GET /api/users/me/history` |
| Events | `GET /api/events`, `GET /api/events/{id}`, `POST /api/events`, `PUT/DELETE /api/events/{id}`, `GET /api/events/{id}/weather` |
| Categories and routes | `GET/POST /api/events/{id}/categories`, `PUT/DELETE /api/categories/{id}`, `GET/POST /api/categories/{id}/route` |
| Enrolments | `POST /api/categories/{id}/enrol`, `GET /api/events/{id}/enrolments`, `DELETE /api/enrolments/{id}` |
| Results | `POST /api/enrolments/{id}/results`, `GET /api/categories/{id}/results` |

### Differences from the Part 1 plan and schema
Each deviation below is deliberate and explained.

| Change | Reason |
|---|---|
| `Events` has a new `DistanceKM` column | The Part 2 brief says every event must capture a distance. In Part 1 distance was only stored on categories. |
| New endpoint `GET /api/events/{id}/enrolments` (Organiser) | The Part 2 brief requires organisers to view all enrolments for their events; it was missing from the Part 1 plan. |
| New endpoint `POST /api/auth/logout` | Needed to end a session. |
| `POST /api/auth/login` returns the user's details and sets a session cookie instead of returning a token | The Part 2 brief requires session management rather than tokens. |
| Extra status codes: `409` when deleting an event or category that has enrolments, or cancelling an enrolment that has a result; `400` for weather on an event without coordinates | Prevents data being orphaned or lost. |
| Enrolment conflict (`409`) means "already enrolled in this event", not just this category | A participant cannot run two categories of the same event. |
| The Part 1 ERD image omitted `Users.PasswordHash` and `Events.EventType` | Both are in the Part 1 SQL script and in the Part 2 model. |
| Part 2 uses a separate database named `RaceDayApiDb` | Keeps the Code-First database apart from the Part 1 `RaceDayDB`. |

### CI/CD
A GitHub Actions workflow ([`.github/workflows/dotnet-ci.yml`](./.github/workflows/dotnet-ci.yml)) restores, builds and runs all unit tests on every push. The Part 1 workflow (`validate-structure.yml`) still checks the `/docs` folder.

**Successful green build:**

<!-- Replace this comment with your screenshot once the workflow is green:
![Green build](docs/part2-green-build.png) -->

### Video demonstration
**YouTube (unlisted):** _paste your link here_

### Project structure
```
RaceDay/
├── docs/                       Part 1 planning documents
├── Part2/
│   ├── RaceDay.sln
│   ├── RaceDay.Api/
│   │   ├── Controllers/        Auth, Users, Events, Categories, Enrolments
│   │   ├── Data/               RaceDayDbContext (EF Core model and constraints)
│   │   ├── Dtos/               Request and response shapes
│   │   ├── Models/             Entity classes (one per table)
│   │   ├── Security/           [SessionAuthorize] attribute
│   │   ├── Services/           Weather service
│   │   └── Program.cs          Wiring: database, session, Swagger
│   └── RaceDay.Tests/          xUnit tests
├── .github/workflows/          CI workflows
└── README.md
```
