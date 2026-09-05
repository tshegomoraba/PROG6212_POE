IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'RaceDayDB')
BEGIN
    CREATE DATABASE RaceDayDB;
END
GO

USE RaceDayDB;
GO

IF OBJECT_ID('dbo.Results', 'U') IS NOT NULL DROP TABLE dbo.Results;
IF OBJECT_ID('dbo.Enrolments', 'U') IS NOT NULL DROP TABLE dbo.Enrolments;
IF OBJECT_ID('dbo.Routes', 'U') IS NOT NULL DROP TABLE dbo.Routes;
IF OBJECT_ID('dbo.Categories', 'U') IS NOT NULL DROP TABLE dbo.Categories;
IF OBJECT_ID('dbo.Events', 'U') IS NOT NULL DROP TABLE dbo.Events;
IF OBJECT_ID('dbo.Users', 'U') IS NOT NULL DROP TABLE dbo.Users;
IF OBJECT_ID('dbo.Roles', 'U') IS NOT NULL DROP TABLE dbo.Roles;
GO

CREATE TABLE Roles (
    RoleID      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    VARCHAR(20) NOT NULL UNIQUE
);
GO

CREATE TABLE Users (
    UserID          INT IDENTITY(1,1) PRIMARY KEY,
    RoleID          INT NOT NULL,
    FullName        VARCHAR(100) NOT NULL,
    Email           VARCHAR(100) NOT NULL UNIQUE,
    PasswordHash    VARCHAR(255) NOT NULL,
    PhoneNumber     VARCHAR(20) NULL,
    RegisteredDate  DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO

CREATE TABLE Events (
    EventID         INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID     INT NOT NULL,
    EventName       VARCHAR(150) NOT NULL,
    EventType       VARCHAR(20) NOT NULL,
    EventDate       DATE NOT NULL,
    Location        VARCHAR(150) NOT NULL,
    Latitude        DECIMAL(9,6) NULL,
    Longitude       DECIMAL(9,6) NULL,
    Description     VARCHAR(500) NULL,
    CreatedDate     DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserID) REFERENCES Users(UserID),
    CONSTRAINT CK_Events_Type CHECK (EventType IN ('Running','Cycling','Walking'))
);
GO

CREATE TABLE Categories (
    CategoryID      INT IDENTITY(1,1) PRIMARY KEY,
    EventID         INT NOT NULL,
    CategoryName    VARCHAR(100) NOT NULL,
    DistanceKM      DECIMAL(5,2) NOT NULL,
    MinAge          INT NOT NULL DEFAULT 0,
    EntryFee        DECIMAL(8,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID) REFERENCES Events(EventID)
);
GO

CREATE TABLE Routes (
    RouteID         INT IDENTITY(1,1) PRIMARY KEY,
    CategoryID      INT NOT NULL UNIQUE,
    RouteName       VARCHAR(100) NOT NULL,
    StartPoint      VARCHAR(150) NOT NULL,
    EndPoint        VARCHAR(150) NOT NULL,
    ElevationGainM  INT NOT NULL DEFAULT 0,
    MapUrl          VARCHAR(255) NULL,
    RouteNotes      VARCHAR(500) NULL,
    CONSTRAINT FK_Routes_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

CREATE TABLE Enrolments (
    EnrolmentID     INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID   INT NOT NULL,
    CategoryID      INT NOT NULL,
    EnrolmentDate   DATETIME NOT NULL DEFAULT GETDATE(),
    BibNumber       VARCHAR(10) NOT NULL UNIQUE,
    PaymentStatus   VARCHAR(20) NOT NULL DEFAULT 'Pending',
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantID) REFERENCES Users(UserID),
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    CONSTRAINT CK_Enrolments_Payment CHECK (PaymentStatus IN ('Pending','Paid','Refunded'))
);
GO

CREATE TABLE Results (
    ResultID        INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID     INT NOT NULL UNIQUE,
    FinishTime      TIME NULL,
    Position        INT NULL,
    Status          VARCHAR(20) NOT NULL DEFAULT 'Registered',
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentID) REFERENCES Enrolments(EnrolmentID),
    CONSTRAINT CK_Results_Status CHECK (Status IN ('Registered','Finished','DNF','DQ'))
);
GO

INSERT INTO Roles (RoleName) VALUES ('Admin'), ('Organiser'), ('Participant');
GO

INSERT INTO Users (RoleID, FullName, Email, PasswordHash, PhoneNumber) VALUES
(2, 'Sipho Nkosi',            'sipho.nkosi@raceday.co.za',      'hashed_pw_1', '0821234567'),
(2, 'Amanda van der Merwe',   'amanda.vdm@raceday.co.za',       'hashed_pw_2', '0827654321'),
(3, 'Thabo Mokoena',          'thabo.mokoena@example.com',      'hashed_pw_3', '0731112222'),
(3, 'Lerato Dlamini',         'lerato.dlamini@example.com',     'hashed_pw_4', '0739998888');
GO

INSERT INTO Events (OrganiserID, EventName, EventType, EventDate, Location, Latitude, Longitude, Description) VALUES
(1, 'Durban Beachfront Marathon',       'Running', '2026-11-15', 'Durban, KZN',         -29.858680, 31.028090, 'Annual road running event along the Durban beachfront.'),
(1, 'Comrades Training Cycle Challenge','Cycling', '2026-10-03', 'Pietermaritzburg, KZN', -29.600300, 30.379400, 'Cycling event to help runners prepare for Comrades season.'),
(2, 'Cape Town Fun Walk',               'Walking', '2026-09-20', 'Cape Town, WC',        -33.924900, 18.424100, 'Family-friendly fun walk in support of local charities.');
GO

INSERT INTO Categories (EventID, CategoryName, DistanceKM, MinAge, EntryFee) VALUES
(1, '10km Fun Run',      10,    12, 150.00),
(1, 'Half Marathon',     21.1,  16, 250.00),
(1, 'Full Marathon',     42.2,  18, 350.00),
(2, '40km Road Ride',    40,    16, 200.00),
(2, '80km Road Ride',    80,    18, 300.00),
(2, '120km Road Ride',   120,   18, 400.00),
(3, '5km Walk',          5,     0,  50.00),
(3, '10km Walk',         10,    10, 80.00),
(3, 'Kids 2km Fun Walk', 2,     0,  30.00);
GO

INSERT INTO Routes (CategoryID, RouteName, StartPoint, EndPoint, ElevationGainM, MapUrl, RouteNotes) VALUES
(2, 'Beachfront Half Marathon Route', 'North Beach, Durban',        'uShaka Marine World, Durban', 85,  'https://maps.example.com/route/half-marathon', 'Flat coastal route, watch for wind on the return leg.'),
(3, 'Beachfront Full Marathon Route', 'North Beach, Durban',        'Moses Mabhida Stadium, Durban', 140, 'https://maps.example.com/route/full-marathon', 'Two-loop course, water tables every 5km.'),
(5, '80km Midlands Cycle Route',      'Pietermaritzburg City Hall', 'Howick Falls',                  650, 'https://maps.example.com/route/80km-cycle',    'Rolling hills, one steep climb at the 45km mark.'),
(7, '5km Fun Walk Route',             'V&A Waterfront',             'Green Point Park',              20,  'https://maps.example.com/route/5km-walk',      'Flat, stroller and wheelchair friendly.'),
(9, 'Kids Fun Walk Route',            'Green Point Park entrance',  'Green Point Park amphitheatre', 5,   'https://maps.example.com/route/kids-walk',     'Closed to traffic, marshals every 200m.');
GO

INSERT INTO Enrolments (ParticipantID, CategoryID, BibNumber, PaymentStatus) VALUES
(3, 2, 'B1001', 'Paid'),
(3, 5, 'B1002', 'Paid'),
(4, 1, 'B1003', 'Pending'),
(4, 7, 'B1004', 'Paid');
GO

INSERT INTO Results (EnrolmentID, FinishTime, Position, Status) VALUES
(1, '01:45:32', 12,   'Finished'),
(2, '02:15:10', 8,    'Finished'),
(3, NULL,       NULL, 'Registered'),
(4, '00:28:45', 3,    'Finished');
GO

SELECT * FROM Roles;
SELECT * FROM Users;
SELECT * FROM Events;
SELECT * FROM Categories;
SELECT * FROM Routes;
SELECT * FROM Enrolments;
SELECT * FROM Results;

SELECT e.EventName, c.CategoryName, r.FinishTime, r.Position, r.Status
FROM Results r
JOIN Enrolments en ON r.EnrolmentID = en.EnrolmentID
JOIN Categories c ON en.CategoryID = c.CategoryID
JOIN Events e ON c.EventID = e.EventID
WHERE en.ParticipantID = 3;