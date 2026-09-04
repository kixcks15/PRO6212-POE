-- ============================================
-- Database: RaceDay
-- Description: Event Management System for South African Road Events
-- Author: PROG6212 Student
-- Date: 2026
-- ============================================

-- Drop database if it exists (for clean testing)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'RaceDay')
BEGIN
    ALTER DATABASE RaceDay SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDay;
END
GO

-- Create the database
CREATE DATABASE RaceDay;
GO

USE RaceDay;
GO

-- ============================================
-- Table: Users
-- Stores all users (both Organisers and Participants)
-- ============================================
CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Surname VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Organiser', 'Participant')),
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================
-- Table: Events
-- Stores event details created by Organisers
-- ============================================
CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    Name VARCHAR(200) NOT NULL,
    Description VARCHAR(1000) NULL,
    Location VARCHAR(255) NOT NULL,
    EventDate DATE NOT NULL,
    StartTime TIME NOT NULL,
    Distance DECIMAL(10,2) NOT NULL, -- In kilometres
    Status VARCHAR(20) NOT NULL DEFAULT 'Open' CHECK (Status IN ('Open', 'Closed', 'Cancelled')),
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserID) REFERENCES Users(UserID)
);
GO

-- ============================================
-- Table: EventCategories
-- Categories within each event (e.g., Senior Men, Veteran Women)
-- ============================================
CREATE TABLE EventCategories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    AgeMin INT NULL,
    AgeMax INT NULL,
    Price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Category_Event FOREIGN KEY (EventID) REFERENCES Events(EventID) ON DELETE CASCADE
);
GO

-- ============================================
-- Table: Enrolments
-- Links Participants to Event Categories (Many-to-Many resolution)
-- ============================================
CREATE TABLE Enrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    ParticipantID INT NOT NULL,
    CategoryID INT NOT NULL,
    EnrolmentDate DATETIME NOT NULL DEFAULT GETDATE(),
    Status VARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled')),
    CONSTRAINT FK_Enrolment_Participant FOREIGN KEY (ParticipantID) REFERENCES Users(UserID),
    CONSTRAINT FK_Enrolment_Category FOREIGN KEY (CategoryID) REFERENCES EventCategories(CategoryID),
    CONSTRAINT UQ_Enrolment_Unique UNIQUE (ParticipantID, CategoryID)
);
GO

-- ============================================
-- Table: Results
-- Stores participant results for their enrolments
-- ============================================
CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL UNIQUE, -- One-to-One relationship
    FinishTime TIME NULL,
    PositionOverall INT NULL,
    PositionGender INT NULL,
    IsCompleted BIT NOT NULL DEFAULT 0,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Result_Enrolment FOREIGN KEY (EnrolmentID) REFERENCES Enrolments(EnrolmentID) ON DELETE CASCADE
);
GO

-- ============================================
-- Table: Weather
-- Stores weather data recorded for events
-- ============================================
CREATE TABLE Weather (
    WeatherID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    RecordedDateTime DATETIME NOT NULL DEFAULT GETDATE(),
    Temperature DECIMAL(5,2) NULL, -- In Celsius
    Humidity DECIMAL(5,2) NULL, -- Percentage
    WindSpeed DECIMAL(5,2) NULL, -- In km/h
    Conditions VARCHAR(100) NULL,
    CONSTRAINT FK_Weather_Event FOREIGN KEY (EventID) REFERENCES Events(EventID) ON DELETE CASCADE
);
GO

-- ============================================
-- Seed Data: Insert Users (2 Organisers, 3 Participants)
-- ============================================
-- Password hashes are examples - in production, use bcrypt or similar
INSERT INTO Users (Name, Surname, Email, PasswordHash, Role) VALUES
('Thabo', 'Mbeki', 'thabo.mbeki@raceday.co.za', '$2a$11$K2x5Fp8YKb7H5qM9nL1eSuX3aBcDfGhIjKlMnOpQrStUvWxYz12345', 'Organiser'),
('Nomzamo', 'Mbatha', 'nomzamo.mbatha@raceday.co.za', '$2a$11$K2x5Fp8YKb7H5qM9nL1eSuX3aBcDfGhIjKlMnOpQrStUvWxYz12345', 'Organiser'),
('Sipho', 'Ndlovu', 'sipho.ndlovu@gmail.com', '$2a$11$K2x5Fp8YKb7H5qM9nL1eSuX3aBcDfGhIjKlMnOpQrStUvWxYz12345', 'Participant'),
('Lindiwe', 'Mthembu', 'lindiwe.mthembu@gmail.com', '$2a$11$K2x5Fp8YKb7H5qM9nL1eSuX3aBcDfGhIjKlMnOpQrStUvWxYz12345', 'Participant'),
('Pieter', 'Van der Merwe', 'pieter.vdm@gmail.com', '$2a$11$K2x5Fp8YKb7H5qM9nL1eSuX3aBcDfGhIjKlMnOpQrStUvWxYz12345', 'Participant');
GO

-- ============================================
-- Seed Data: Insert Events (3 Events)
-- ============================================
INSERT INTO Events (OrganiserID, Name, Description, Location, EventDate, StartTime, Distance, Status) VALUES
(1, 'Cape Town Cycle Tour 2026', 'The world''s largest timed cycle race - a scenic 109km route around the Cape Peninsula.', 'Cape Town, Western Cape', '2026-03-08', '06:30:00', 109.00, 'Open'),
(2, 'Soweto Marathon 2026', 'Iconic marathon through the streets of Soweto with an electric atmosphere.', 'Soweto, Gauteng', '2026-11-07', '05:45:00', 42.20, 'Open'),
(1, 'Two Oceans Ultra Marathon 2026', 'The world''s most beautiful marathon - a 56km ultra along the Cape coastline.', 'Cape Town, Western Cape', '2026-04-18', '05:30:00', 56.00, 'Open');
GO

-- ============================================
-- Seed Data: Insert Event Categories (3 categories per event)
-- ============================================
-- Cape Town Cycle Tour Categories
INSERT INTO EventCategories (EventID, Name, AgeMin, AgeMax, Price) VALUES
(1, 'Elite Men', 18, 39, 850.00),
(1, 'Veteran Men', 40, 60, 750.00),
(1, 'Women', 18, 60, 750.00);

-- Soweto Marathon Categories
INSERT INTO EventCategories (EventID, Name, AgeMin, AgeMax, Price) VALUES
(2, 'Senior Men', 20, 39, 450.00),
(2, 'Senior Women', 20, 39, 450.00),
(2, 'Masters', 40, 99, 400.00);

-- Two Oceans Ultra Categories
INSERT INTO EventCategories (EventID, Name, AgeMin, AgeMax, Price) VALUES
(3, 'Open Men', 20, 39, 650.00),
(3, 'Open Women', 20, 39, 650.00),
(3, 'Grand Masters', 50, 99, 550.00);
GO

-- ============================================
-- Seed Data: Insert Enrolments
-- ============================================
INSERT INTO Enrolments (ParticipantID, CategoryID, Status) VALUES
(3, 2, 'Confirmed'), -- Sipho in Cycle Tour Veteran Men
(4, 5, 'Confirmed'), -- Lindiwe in Soweto Senior Women
(5, 1, 'Pending'),   -- Pieter in Cycle Tour Elite Men
(3, 4, 'Confirmed'), -- Sipho in Soweto Senior Men
(4, 8, 'Pending');   -- Lindiwe in Two Oceans Open Women
GO

-- ============================================
-- Seed Data: Insert Results
-- ============================================
INSERT INTO Results (EnrolmentID, FinishTime, PositionOverall, PositionGender, IsCompleted) VALUES
(1, '02:45:30', 45, 18, 1), -- Sipho's Cycle Tour result
(2, '03:52:15', 12, 2, 1),  -- Lindiwe's Soweto result
(4, '04:10:42', 87, 42, 1); -- Sipho's Soweto result
GO

-- ============================================
-- Seed Data: Insert Weather Records
-- ============================================
INSERT INTO Weather (EventID, RecordedDateTime, Temperature, Humidity, WindSpeed, Conditions) VALUES
(1, '2026-03-08 05:30:00', 18.5, 75.0, 15.0, 'Partly cloudy, light breeze'),
(1, '2026-03-08 08:00:00', 22.0, 65.0, 22.0, 'Sunny, moderate wind'),
(2, '2026-11-07 05:00:00', 16.0, 80.0, 5.0, 'Clear skies, calm'),
(3, '2026-04-18 05:00:00', 14.0, 82.0, 20.0, 'Overcast, strong wind'),
(3, '2026-04-18 08:00:00', 17.0, 70.0, 25.0, 'Sunny intervals, windy');
GO

-- ============================================
-- Verify the data
-- ============================================
SELECT 'Users' AS TableName, COUNT(*) AS RecordCount FROM Users
UNION ALL
SELECT 'Events', COUNT(*) FROM Events
UNION ALL
SELECT 'EventCategories', COUNT(*) FROM EventCategories
UNION ALL
SELECT 'Enrolments', COUNT(*) FROM Enrolments
UNION ALL
SELECT 'Results', COUNT(*) FROM Results
UNION ALL
SELECT 'Weather', COUNT(*) FROM Weather;
GO

-- ============================================
-- Sample Queries for Testing
-- ============================================

-- 1. Show all events with their organisers
SELECT 
    e.EventID,
    e.Name AS EventName,
    u.Name + ' ' + u.Surname AS Organiser,
    e.Location,
    e.EventDate,
    e.Status
FROM Events e
INNER JOIN Users u ON e.OrganiserID = u.UserID
ORDER BY e.EventDate;

-- 2. Show event categories with enrolment counts
SELECT 
    ec.CategoryID,
    e.Name AS EventName,
    ec.Name AS CategoryName,
    ec.Price,
    COUNT(en.EnrolmentID) AS EnrolmentCount
FROM EventCategories ec
INNER JOIN Events e ON ec.EventID = e.EventID
LEFT JOIN Enrolments en ON ec.CategoryID = en.CategoryID
GROUP BY ec.CategoryID, e.Name, ec.Name, ec.Price
ORDER BY e.Name, ec.Name;

-- 3. Show participant enrolments with event details
SELECT 
    u.Name + ' ' + u.Surname AS Participant,
    e.Name AS EventName,
    ec.Name AS Category,
    en.EnrolmentDate,
    en.Status,
    r.FinishTime,
    r.PositionOverall,
    r.IsCompleted
FROM Enrolments en
INNER JOIN Users u ON en.ParticipantID = u.UserID
INNER JOIN EventCategories ec ON en.CategoryID = ec.CategoryID
INNER JOIN Events e ON ec.EventID = e.EventID
LEFT JOIN Results r ON en.EnrolmentID = r.EnrolmentID
ORDER BY e.EventDate, u.Surname;

-- 4. Show weather forecast for upcoming events
SELECT 
    e.Name AS EventName,
    e.EventDate,
    w.RecordedDateTime,
    w.Temperature,
    w.Conditions
FROM Events e
INNER JOIN Weather w ON e.EventID = w.EventID
WHERE e.EventDate >= GETDATE()
ORDER BY e.EventDate, w.RecordedDateTime;

-- 5. Dashboard statistics for Organiser
SELECT 
    'Total Events' AS Metric, COUNT(*) AS Value FROM Events
UNION ALL
SELECT 
    'Total Participants', COUNT(DISTINCT ParticipantID) FROM Enrolments
UNION ALL
SELECT 
    'Total Enrolments', COUNT(*) FROM Enrolments
UNION ALL
SELECT 
    'Completed Participants', COUNT(*) FROM Results WHERE IsCompleted = 1;
GO
