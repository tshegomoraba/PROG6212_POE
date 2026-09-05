# RaceDay Database & API

## 1. Project Overview

RaceDay is an event and race-management system designed to manage users, organisers, participants, events, event categories, routes, enrolments, and race results.

The project consists of:
- A SQL Server database named `RaceDayDB`.
- A relational database structure represented by the RaceDay ERD.
- A planned REST API for authentication, user profiles, events, categories, routes, enrolments, and results.

The database script creates the database, creates the required tables, inserts sample data, and runs sample queries.

---

## 2. Database Tables

### 2.1 Roles

**Primary Key:** `RoleID`

| Field | Key | Description |
|---|---|---|
| RoleID | PK | Unique role identifier |
| RoleName | — | Name of the role |

Sample roles:
- Admin
- Organiser
- Participant

---

### 2.2 Users

**Primary Key:** `UserID`  
**Foreign Key:** `RoleID` → `Roles(RoleID)`

| Field | Key | Description |
|---|---|---|
| UserID | PK | Unique user identifier |
| RoleID | FK | User's assigned role |
| FullName | — | User's full name |
| Email | — | Unique email address |
| PasswordHash | — | Hashed user password |
| PhoneNumber | — | User's phone number |
| RegisteredDate | — | Date/time the user registered |

---

### 2.3 Events

**Primary Key:** `EventID`  
**Foreign Key:** `OrganiserID` → `Users(UserID)`

| Field | Key | Description |
|---|---|---|
| EventID | PK | Unique event identifier |
| OrganiserID | FK | User responsible for organising the event |
| EventName | — | Name of the event |
| EventType | — | Running, Cycling, or Walking |
| EventDate | — | Date of the event |
| Location | — | Event location |
| Latitude | — | Geographic latitude |
| Longitude | — | Geographic longitude |
| Description | — | Event description |
| CreatedDate | — | Date/time the event was created |

---

### 2.4 Categories

**Primary Key:** `CategoryID`  
**Foreign Key:** `EventID` → `Events(EventID)`

| Field | Key | Description |
|---|---|---|
| CategoryID | PK | Unique category identifier |
| EventID | FK | Event to which the category belongs |
| CategoryName | — | Name of the race/category |
| DistanceKM | — | Category distance in kilometres |
| MinAge | — | Minimum participant age |
| EntryFee | — | Entry fee |

---

### 2.5 Routes

**Primary Key:** `RouteID`  
**Foreign Key:** `CategoryID` → `Categories(CategoryID)`

| Field | Key | Description |
|---|---|---|
| RouteID | PK | Unique route identifier |
| CategoryID | FK | Category associated with the route |
| RouteName | — | Name of the route |
| StartPoint | — | Route starting point |
| EndPoint | — | Route ending point |
| ElevationGainM | — | Elevation gain in metres |
| MapUrl | — | Link to the route map |
| RouteNotes | — | Additional route information |

`CategoryID` is marked `UNIQUE` in the SQL database, meaning a category can have at most one route.

---

### 2.6 Enrolments

**Primary Key:** `EnrolmentID`  
**Foreign Keys:**
- `ParticipantID` → `Users(UserID)`
- `CategoryID` → `Categories(CategoryID)`

| Field | Key | Description |
|---|---|---|
| EnrolmentID | PK | Unique enrolment identifier |
| ParticipantID | FK | Participant who enrolled |
| CategoryID | FK | Category entered |
| EnrolmentDate | — | Date/time of enrolment |
| BibNumber | — | Unique race bib number |
| PaymentStatus | — | Pending, Paid, or Refunded |

---

### 2.7 Results

**Primary Key:** `ResultID`  
**Foreign Key:** `EnrolmentID` → `Enrolments(EnrolmentID)`

| Field | Key | Description |
|---|---|---|
| ResultID | PK | Unique result identifier |
| EnrolmentID | FK | Enrolment associated with the result |
| FinishTime | — | Participant's finish time |
| Position | — | Finishing position |
| Status | — | Registered, Finished, DNF, or DQ |

`EnrolmentID` is marked `UNIQUE`, so each enrolment can have at most one result record.

---

## 3. ERD Relationships

The supplied ERD shows the following relationships:

1. **Roles → Users**
   - One Role can be associated with many Users.
   - Each User belongs to one Role.
   - Cardinality: `Roles 1 : * Users`

2. **Users → Events**
   - One User/Organiser can organise many Events.
   - Each Event has one Organiser.
   - Cardinality: `Users 1 : * Events`

3. **Events → Categories**
   - One Event can contain many Categories.
   - Each Category belongs to one Event.
   - Cardinality: `Events 1 : * Categories`

4. **Categories → Routes**
   - The supplied ERD displays a `1 : *` relationship.
   - However, the SQL script makes `Routes.CategoryID` UNIQUE, which implements a maximum of one Route per Category.
   - Therefore, the SQL implementation represents this as one Category to zero-or-one Route (`1 : 0..1`).

5. **Users → Enrolments**
   - Enrolments contain `ParticipantID`, which references Users.
   - One participant can have many enrolments.
   - Each enrolment belongs to one participant.

6. **Categories → Enrolments**
   - One Category can have many Enrolments.
   - Each Enrolment belongs to one Category.
   - Cardinality: `Categories 1 : * Enrolments`

7. **Enrolments → Results**
   - The ERD displays a one-to-one relationship.
   - The SQL implementation also enforces this using `UNIQUE (EnrolmentID)`.
   - Cardinality: `Enrolments 1 : 0..1 Results` in practical database terms because an enrolment may exist before a result is recorded.

---

## 4. ERD Field Transcription

The supplied ERD contains these entities and attributes:

### Roles
- PK `RoleID`
- `RoleName`

### Users
- PK `UserID`
- FK `RoleID`
- `FullName`
- `Email`
- `PhoneNumber`
- `RegisteredDate`

### Events
- PK `EventID`
- FK `OrganiserID`
- `EventName`
- `EventDate`
- `Location`
- `Latitude`
- `Longitude`
- `Description`
- `CreatedDate`

### Categories
- PK `CategoryID`
- FK `EventID`
- `CategoryName`
- `DistanceKM`
- `MinAge`
- `EntryFee`

### Routes
- PK `RouteID`
- FK `CategoryID`
- `RouteName`
- `StartPoint`
- `EndPoint`
- `ElevationGainM`
- `MapURL`
- `RouteNotes`

### Enrolment
- PK `EnrolmentID`
- FK `ParticipationID` (as displayed in the supplied ERD)
- FK `CategoryID`
- `EnrolmentDate`
- `BibNumber`
- `PaymentStatus`

### Results
- PK `ResultsID`
- FK `EnrolmentID`
- `FinishTime`
- `Position`
- `Status`

**Important:** The SQL database uses `ParticipantID`, while the supplied ERD displays `ParticipationID`. The SQL field should be treated as the implemented field name.

---

## 5. SQL Database Setup

### Requirements

You need:
- Microsoft SQL Server
- SQL Server Management Studio (SSMS) or another SQL Server-compatible client

### Installation Steps

1. Open SQL Server Management Studio.
2. Connect to your SQL Server instance.
3. Open `RaceDay.sql`.
4. Execute the complete script.
5. The script creates the `RaceDayDB` database if it does not already exist.
6. It then creates the tables in dependency order.
7. Sample records are inserted into the database.
8. Sample `SELECT` statements are executed at the end.

The script creates these tables:

```text
Roles
Users
Events
Categories
Routes
Enrolments
Results
```

---

## 6. Database Constraints

The database uses primary keys, foreign keys, unique constraints, default values, and check constraints.

### Primary Keys

Each table has an identity-based primary key.

### Foreign Keys

```text
Users.RoleID          → Roles.RoleID
Events.OrganiserID    → Users.UserID
Categories.EventID    → Events.EventID
Routes.CategoryID     → Categories.CategoryID
Enrolments.ParticipantID → Users.UserID
Enrolments.CategoryID → Categories.CategoryID
Results.EnrolmentID   → Enrolments.EnrolmentID
```

### Check Constraints

`Events.EventType` is restricted to:

```text
Running
Cycling
Walking
```

`Enrolments.PaymentStatus` is restricted to:

```text
Pending
Paid
Refunded
```

`Results.Status` is restricted to:

```text
Registered
Finished
DNF
DQ
```

---

## 7. Sample Data

The SQL script includes sample users, events, categories, routes, enrolments, and results.

Example events include:
- Durban Beachfront Marathon
- Comrades Training Cycle Challenge
- Cape Town Fun Walk

The sample data demonstrates how users, events, categories, routes, enrolments, and results are connected.

---

## 8. API Overview

The API plan provides endpoints for authentication, users, events, categories, routes, enrolments, and results.

### Authentication

| Method | Endpoint | Purpose | Access |
|---|---|---|---|
| POST | `/api/auth/register` | Registers a new user | Public |
| POST | `/api/auth/login` | Authenticates a user and returns an access token | Public |

The registration endpoint accepts full name, email, password, phone number, and role. Login accepts email and password. fileciteturn0file0L5-L6

### Users

| Method | Endpoint | Purpose | Access |
|---|---|---|---|
| GET | `/api/users/me` | Retrieves the logged-in user's profile | Logged-in user |
| PUT | `/api/users/me` | Updates the logged-in user's profile | Logged-in user |

fileciteturn0file0L7-L8

### Events

| Method | Endpoint | Purpose | Access |
|---|---|---|---|
| GET | `/api/events` | Lists upcoming events | Public |
| GET | `/api/events/{id}` | Retrieves event details | Public |
| POST | `/api/events` | Creates an event | Organiser |
| PUT | `/api/events/{id}` | Updates an owned event | Organiser |
| DELETE | `/api/events/{id}` | Deletes an owned event | Organiser |
| GET | `/api/events/{id}/weather` | Retrieves event weather forecast | Public |

The API plan also specifies ownership checks for organiser updates and deletions. fileciteturn0file0L9-L14

### Categories and Routes

| Method | Endpoint | Purpose | Access |
|---|---|---|---|
| GET | `/api/events/{id}/categories` | Lists event categories | Public |
| POST | `/api/events/{id}/categories` | Adds a category | Organiser |
| PUT | `/api/categories/{id}` | Updates a category | Organiser |
| DELETE | `/api/categories/{id}` | Deletes a category | Organiser |
| GET | `/api/categories/{id}/route` | Retrieves route details | Public |
| POST | `/api/categories/{id}/route` | Creates/replaces route information | Organiser |

fileciteturn0file0L15-L20

### Enrolments and Results

| Method | Endpoint | Purpose | Access |
|---|---|---|---|
| POST | `/api/categories/{id}/enrol` | Enrols a participant and generates a bib number | Participant |
| GET | `/api/users/me/enrolments` | Lists the participant's enrolments | Participant |
| DELETE | `/api/enrolments/{id}` | Cancels an enrolment | Participant |
| GET | `/api/users/me/history` | Retrieves personal performance history | Participant |
| GET | `/api/categories/{id}/results` | Retrieves category leaderboard | Public |
| POST | `/api/enrolments/{id}/results` | Records or updates a result | Organiser |

These endpoints and their expected responses are defined in the API endpoint plan. fileciteturn0file0L21-L26

---

## 9. API Access Roles

The system uses three database roles:

```text
Admin
Organiser
Participant
```

The API plan specifically uses:
- **Public** — no login required.
- **Any (logged in)** — authenticated user.
- **Organiser** — organiser access required.
- **Participant** — participant access required.

The database initially inserts Admin, Organiser, and Participant roles. fileciteturn0file1L101-L108

---

## 10. Example API Workflow

A typical participant workflow is:

```text
1. Register
   POST /api/auth/register

2. Login
   POST /api/auth/login

3. View upcoming events
   GET /api/events

4. View an event
   GET /api/events/{id}

5. View categories
   GET /api/events/{id}/categories

6. View the route
   GET /api/categories/{id}/route

7. Enrol
   POST /api/categories/{id}/enrol

8. View enrolments
   GET /api/users/me/enrolments

9. View personal history
   GET /api/users/me/history
```

---

## 11. Example Organiser Workflow

```text
1. Login
   POST /api/auth/login

2. Create an event
   POST /api/events

3. Add categories
   POST /api/events/{id}/categories

4. Add a route
   POST /api/categories/{id}/route

5. Capture participant results
   POST /api/enrolments/{id}/results

6. Update or delete owned events/categories when required
```

---

## 12. Sample SQL Query

The SQL script includes a query that retrieves a participant's performance history by joining:

```text
Results
    ↓
Enrolments
    ↓
Categories
    ↓
Events
```

The query returns:

```text
EventName
CategoryName
FinishTime
Position
Status
```

for participant ID `3`. fileciteturn0file1L159-L164

---

## 13. Project Structure

A suggested project structure is:

```text
RaceDay/
│
├── README.md
├── RaceDay.sql
├── ERD.png
├── api-endpoints.md
│
└── src/
    └── [API application source code]
```

---

## 14. Important Implementation Notes

### ERD and SQL naming

The ERD shows `ParticipationID` in the Enrolment table, while the SQL script implements `ParticipantID`. Keep the database/API implementation consistent by using:

```text
ParticipantID
```

### Route relationship

The ERD visually shows Categories to Routes as `1 : *`, but the SQL script defines:

```sql
CategoryID INT NOT NULL UNIQUE
```

Therefore, the implemented database permits only one Route for each Category.

### Result relationship

The Results table defines:

```sql
EnrolmentID INT NOT NULL UNIQUE
```

Therefore, an enrolment can have only one result record. An enrolment can exist before a result is recorded because `FinishTime` and `Position` can be NULL and the default result status is `Registered`.

---

## 15. Source Files

This README was prepared from the supplied RaceDay materials:
- RaceDay ERD
- `RaceDay.sql`
- `api-endpoints.md`

The SQL script defines the database structure and sample data, while the API endpoint plan defines the proposed application endpoints and access requirements. fileciteturn0file1L19-L32 fileciteturn0file0L3-L8

---

## 16. Status

**Database:** SQL schema and sample data provided.

**ERD:** Provided.

**API:** Endpoint plan provided; implementation is dependent on the selected backend technology.

**README:** Complete.
