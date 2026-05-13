USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = N'Formula1')
BEGIN
    ALTER DATABASE Formula1 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE IF EXISTS Formula1;
END;
GO

CREATE DATABASE Formula1;
GO

USE Formula1;
GO

-- 1. Создание таблиц узлов (графовых)

CREATE TABLE Drivers (
    driver_id INT PRIMARY KEY,
    name NVARCHAR(100),
    nationality NVARCHAR(50),
    birth_year INT
) AS NODE;
GO

CREATE TABLE Teams (
    team_id INT PRIMARY KEY,
    name NVARCHAR(100),
    country NVARCHAR(50),
    founded_year INT
) AS NODE;
GO

CREATE TABLE Cars (
    car_id INT PRIMARY KEY,
    model NVARCHAR(100),
    engine NVARCHAR(50)
) AS NODE;
GO

CREATE TABLE Tracks (
    track_id INT PRIMARY KEY,
    name NVARCHAR(100),
    country NVARCHAR(50),
    length_km DECIMAL(5,2)
) AS NODE;
GO


-- 2. Создание таблиц рёбер с ограничениями

CREATE TABLE member_of (
    season_start INT,
    season_end INT,
    role NVARCHAR(50) DEFAULT 'Driver',
    CONSTRAINT EC_member_of CONNECTION (Drivers TO Teams)
) AS EDGE;
GO

CREATE TABLE drives (
    year_from INT,
    year_to INT,
    wins_on_this_car INT,
    CONSTRAINT EC_drives CONNECTION (Drivers TO Cars)
) AS EDGE;
GO

CREATE TABLE wins_on (
    win_date DATE,
    position INT CHECK (position = 1),
    race_name NVARCHAR(100),
    CONSTRAINT EC_wins_on CONNECTION (Drivers TO Tracks)
) AS EDGE;
GO

CREATE TABLE uses (
    season INT,
    status NVARCHAR(50),
    CONSTRAINT EC_uses CONNECTION (Teams TO Cars)
) AS EDGE;
GO

-- 3. Заполнение узлов (минимум 10 строк в каждой)

INSERT INTO Drivers (driver_id, name, nationality, birth_year) VALUES
(1, 'Lewis Hamilton', 'British', 1985),
(2, 'Max Verstappen', 'Dutch', 1997),
(3, 'Charles Leclerc', 'Monegasque', 1997),
(4, 'Fernando Alonso', 'Spanish', 1981),
(5, 'Lando Norris', 'British', 1999),
(6, 'Carlos Sainz', 'Spanish', 1994),
(7, 'Sergio Perez', 'Mexican', 1990),
(8, 'George Russell', 'British', 1998),
(9, 'Valtteri Bottas', 'Finnish', 1989),
(10, 'Daniel Ricciardo', 'Australian', 1989);
GO

INSERT INTO Teams (team_id, name, country, founded_year) VALUES
(1, 'Mercedes-AMG Petronas', 'Germany', 2010),
(2, 'Red Bull Racing', 'Austria', 2005),
(3, 'Scuderia Ferrari', 'Italy', 1950),
(4, 'McLaren F1 Team', 'UK', 1963),
(5, 'Aston Martin', 'UK', 2021),
(6, 'Alpine', 'France', 2021),
(7, 'AlphaTauri', 'Italy', 2006),
(8, 'Alfa Romeo', 'Switzerland', 2019),
(9, 'Haas F1 Team', 'USA', 2016),
(10, 'Williams Racing', 'UK', 1977);
GO

INSERT INTO Cars (car_id, model, engine) VALUES
(1, 'W14', 'Mercedes'),
(2, 'RB19', 'Honda RBPT'),
(3, 'SF-23', 'Ferrari'),
(4, 'MCL60', 'Mercedes'),
(5, 'AMR23', 'Mercedes'),
(6, 'A523', 'Renault'),
(7, 'AT04', 'Honda RBPT'),
(8, 'C43', 'Ferrari'),
(9, 'VF-23', 'Ferrari'),
(10, 'FW45', 'Mercedes');
GO

INSERT INTO Tracks (track_id, name, country, length_km) VALUES
(1, 'Bahrain International Circuit', 'Bahrain', 5.412),
(2, 'Jeddah Corniche Circuit', 'Saudi Arabia', 6.174),
(3, 'Albert Park Circuit', 'Australia', 5.278),
(4, 'Imola Circuit', 'Italy', 4.909),
(5, 'Circuit de Monaco', 'Monaco', 3.337),
(6, 'Circuit Gilles Villeneuve', 'Canada', 4.361),
(7, 'Silverstone Circuit', 'UK', 5.891),
(8, 'Red Bull Ring', 'Austria', 4.318),
(9, 'Monza Circuit', 'Italy', 5.793),
(10, 'Suzuka International Circuit', 'Japan', 5.807);
GO

-- 4. Заполнение рёбер (установление связей)

INSERT INTO member_of ($from_id, $to_id, season_start, season_end, role)
VALUES
((SELECT $node_id FROM Drivers WHERE driver_id=1), (SELECT $node_id FROM Teams WHERE team_id=1), 2013, 2024, 'Driver'),
((SELECT $node_id FROM Drivers WHERE driver_id=2), (SELECT $node_id FROM Teams WHERE team_id=2), 2016, 2024, 'Driver'),
((SELECT $node_id FROM Drivers WHERE driver_id=3), (SELECT $node_id FROM Teams WHERE team_id=3), 2019, 2024, 'Driver'),
((SELECT $node_id FROM Drivers WHERE driver_id=4), (SELECT $node_id FROM Teams WHERE team_id=5), 2023, 2024, 'Driver'),
((SELECT $node_id FROM Drivers WHERE driver_id=5), (SELECT $node_id FROM Teams WHERE team_id=4), 2019, 2024, 'Driver'),
((SELECT $node_id FROM Drivers WHERE driver_id=6), (SELECT $node_id FROM Teams WHERE team_id=3), 2021, 2024, 'Driver'),
((SELECT $node_id FROM Drivers WHERE driver_id=7), (SELECT $node_id FROM Teams WHERE team_id=2), 2021, 2024, 'Driver'),
((SELECT $node_id FROM Drivers WHERE driver_id=8), (SELECT $node_id FROM Teams WHERE team_id=1), 2022, 2024, 'Driver'),
((SELECT $node_id FROM Drivers WHERE driver_id=9), (SELECT $node_id FROM Teams WHERE team_id=8), 2022, 2024, 'Driver'),
((SELECT $node_id FROM Drivers WHERE driver_id=10),(SELECT $node_id FROM Teams WHERE team_id=7), 2023, 2024, 'Driver');
GO

INSERT INTO drives ($from_id, $to_id, year_from, year_to, wins_on_this_car)
VALUES
((SELECT $node_id FROM Drivers WHERE driver_id=1), (SELECT $node_id FROM Cars WHERE car_id=1), 2022, 2024, 1),
((SELECT $node_id FROM Drivers WHERE driver_id=2), (SELECT $node_id FROM Cars WHERE car_id=2), 2022, 2024, 15),
((SELECT $node_id FROM Drivers WHERE driver_id=3), (SELECT $node_id FROM Cars WHERE car_id=3), 2022, 2024, 3),
((SELECT $node_id FROM Drivers WHERE driver_id=4), (SELECT $node_id FROM Cars WHERE car_id=5), 2023, 2024, 0),
((SELECT $node_id FROM Drivers WHERE driver_id=5), (SELECT $node_id FROM Cars WHERE car_id=4), 2023, 2024, 1),
((SELECT $node_id FROM Drivers WHERE driver_id=6), (SELECT $node_id FROM Cars WHERE car_id=3), 2023, 2024, 0),
((SELECT $node_id FROM Drivers WHERE driver_id=7), (SELECT $node_id FROM Cars WHERE car_id=2), 2022, 2024, 2),
((SELECT $node_id FROM Drivers WHERE driver_id=8), (SELECT $node_id FROM Cars WHERE car_id=1), 2022, 2024, 0),
((SELECT $node_id FROM Drivers WHERE driver_id=9), (SELECT $node_id FROM Cars WHERE car_id=8), 2022, 2024, 0),
((SELECT $node_id FROM Drivers WHERE driver_id=10),(SELECT $node_id FROM Cars WHERE car_id=7), 2023, 2024, 0);
GO

INSERT INTO wins_on ($from_id, $to_id, win_date, position, race_name)
VALUES
((SELECT $node_id FROM Drivers WHERE driver_id=1), (SELECT $node_id FROM Tracks WHERE track_id=7), '2023-07-09', 1, 'British GP'),
((SELECT $node_id FROM Drivers WHERE driver_id=2), (SELECT $node_id FROM Tracks WHERE track_id=1), '2023-03-05', 1, 'Bahrain GP'),
((SELECT $node_id FROM Drivers WHERE driver_id=2), (SELECT $node_id FROM Tracks WHERE track_id=8), '2023-07-02', 1, 'Austrian GP'),
((SELECT $node_id FROM Drivers WHERE driver_id=3), (SELECT $node_id FROM Tracks WHERE track_id=5), '2023-05-28', 1, 'Monaco GP'),
((SELECT $node_id FROM Drivers WHERE driver_id=4), (SELECT $node_id FROM Tracks WHERE track_id=9), '2023-09-03', 1, 'Italian GP'),
((SELECT $node_id FROM Drivers WHERE driver_id=5), (SELECT $node_id FROM Tracks WHERE track_id=6), '2023-06-18', 1, 'Canadian GP'),
((SELECT $node_id FROM Drivers WHERE driver_id=6), (SELECT $node_id FROM Tracks WHERE track_id=4), '2023-05-21', 1, 'Emilia Romagna GP'),
((SELECT $node_id FROM Drivers WHERE driver_id=7), (SELECT $node_id FROM Tracks WHERE track_id=2), '2023-03-19', 1, 'Saudi Arabian GP'),
((SELECT $node_id FROM Drivers WHERE driver_id=8), (SELECT $node_id FROM Tracks WHERE track_id=3), '2023-04-02', 1, 'Australian GP'),
((SELECT $node_id FROM Drivers WHERE driver_id=9), (SELECT $node_id FROM Tracks WHERE track_id=10), '2023-10-08', 1, 'Japanese GP');
GO

INSERT INTO uses ($from_id, $to_id, season, status)
VALUES
((SELECT $node_id FROM Teams WHERE team_id=1), (SELECT $node_id FROM Cars WHERE car_id=1), 2023, 'main'),
((SELECT $node_id FROM Teams WHERE team_id=2), (SELECT $node_id FROM Cars WHERE car_id=2), 2023, 'main'),
((SELECT $node_id FROM Teams WHERE team_id=3), (SELECT $node_id FROM Cars WHERE car_id=3), 2023, 'main'),
((SELECT $node_id FROM Teams WHERE team_id=4), (SELECT $node_id FROM Cars WHERE car_id=4), 2023, 'main'),
((SELECT $node_id FROM Teams WHERE team_id=5), (SELECT $node_id FROM Cars WHERE car_id=5), 2023, 'main'),
((SELECT $node_id FROM Teams WHERE team_id=6), (SELECT $node_id FROM Cars WHERE car_id=6), 2023, 'main'),
((SELECT $node_id FROM Teams WHERE team_id=7), (SELECT $node_id FROM Cars WHERE car_id=7), 2023, 'main'),
((SELECT $node_id FROM Teams WHERE team_id=8), (SELECT $node_id FROM Cars WHERE car_id=8), 2023, 'main'),
((SELECT $node_id FROM Teams WHERE team_id=9), (SELECT $node_id FROM Cars WHERE car_id=9), 2023, 'main'),
((SELECT $node_id FROM Teams WHERE team_id=10),(SELECT $node_id FROM Cars WHERE car_id=10),2023, 'main');
GO


-- 5. Запросы с MATCH (цепочки из 3+ узлов)

SELECT 
    c.model AS CarModel,
    t.name AS TrackName
FROM Drivers d, drives dr, Cars c, wins_on wo, Tracks t
WHERE MATCH(d-(dr)->c AND d-(wo)->t)
  AND d.name = 'Lewis Hamilton';
GO

SELECT d.name AS DriverName
FROM Drivers d, member_of mo, Teams tm, wins_on wo, Tracks tr
WHERE MATCH(d-(mo)->tm AND d-(wo)->tr)
  AND tm.name = 'Scuderia Ferrari'
  AND tr.name = 'Circuit de Monaco'
  AND YEAR(wo.win_date) BETWEEN mo.season_start AND mo.season_end;
GO

SELECT DISTINCT tm.name AS TeamName
FROM Teams tm, member_of mo, Drivers d, wins_on wo, Tracks tr
WHERE MATCH(tm<-(mo)-d-(wo)->tr)
  AND tr.country = 'Italy';
GO

SELECT DISTINCT tr.name AS TrackName
FROM Cars c, drives dr, Drivers d, wins_on wo, Tracks tr
WHERE MATCH(c<-(dr)-d-(wo)->tr)
  AND c.model = 'RB19';
GO

SELECT d.name AS DriverName
FROM Drivers d, member_of mo, Teams t, drives dr, Cars c
WHERE MATCH(d-(mo)->t AND d-(dr)->c)
  AND t.name = 'Mercedes-AMG Petronas'
  AND c.model = 'W14'
  AND 2023 BETWEEN mo.season_start AND mo.season_end
  AND 2023 BETWEEN dr.year_from AND dr.year_to;
GO


-- 6. Запросы SHORTEST_PATH 


-- 6.1 Кратчайший путь от Max Verstappen до любой трассы
SELECT
    STRING_AGG(CAST(t.name AS NVARCHAR(100)), ' -> ') WITHIN GROUP (GRAPH PATH) AS PathString,
    LAST_VALUE(CAST(t.name AS NVARCHAR(100))) WITHIN GROUP (GRAPH PATH) AS DestinationTrack
FROM Drivers d,
     wins_on FOR PATH AS wo,
     Tracks FOR PATH AS t
WHERE MATCH(SHORTEST_PATH(d(-(wo)->t)+))
  AND d.name = 'Max Verstappen';
GO

-- 6.2 Кратчайший путь от Red Bull Racing до болида W14 (длина 1..3)
-- ВНИМАНИЕ: Фильтрация целевого узла (W14) вынесена во внешний запрос через CTE,
-- т.к. SQL Server запрещает условия по FOR PATH-узлам в блоке WHERE MATCH(...)
WITH PathResults AS (
    SELECT
        tm.name AS StartNode,
        STRING_AGG(CAST(c.model AS NVARCHAR(100)), ' -> ') WITHIN GROUP (GRAPH PATH) AS PathString,
        LAST_VALUE(CAST(c.model AS NVARCHAR(100))) WITHIN GROUP (GRAPH PATH) AS DestinationCar
    FROM Teams tm,
         uses FOR PATH AS u,
         Cars FOR PATH AS c
    WHERE MATCH(SHORTEST_PATH(tm(-(u)->c){1,3}))
      AND tm.name = 'Red Bull Racing'
)
SELECT StartNode, PathString, DestinationCar
FROM PathResults
WHERE DestinationCar = 'W14';
GO

