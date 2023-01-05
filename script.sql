-- Active: 1672920260782@@bve2dwhmmyq8qnjk3imc-mysql.services.clever-cloud.com@3306@bve2dwhmmyq8qnjk3imc

--- Drop des Table
DROP TABLE IF EXISTS Salle CASCADE;
DROP TABLE IF EXISTS ELP CASCADE;
DROP TABLE IF EXISTS Groupes CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;

--- Drop des Fonctions


--- Drope des Procedires


--- Creation des TABLE
CREATE TABLE Salle (
    NoSalle VARCHAR(8) PRIMARY KEY,
    Categorie VARCHAR(16) NOT NULL,
    NbPlaces SMALLINT NOT NULL
);

CREATE TABLE Groupes (
    Groupe VARCHAR(16) NOT NULL,
    Formation VARCHAR(16) NOT NULL,
    Effectif SMALLINT UNSIGNED,
    PRIMARY KEY (Groupe, Formation)
);

CREATE TABLE ELP (
    CodeELP SMALLINT PRIMARY KEY,
    NomELP VARCHAR(32) NOT NULL, 
    Formation VARCHAR(16) REFERENCES Groupes(Formation),
    HC SMALLINT  NOT NULL CHECK (HC >= 0),
    HTD SMALLINT  NOT NULL CHECK (HTD >= 0),
    HTP SMALLINT  NOT NULL CHECK (HTP >= 0),
    HCRes SMALLINT DEFAULT 0 NOT NULL CHECK (HCRes >= 0),
    HTDRes SMALLINT DEFAULT 0 NOT NULL CHECK (HTDRes >= 0),
    HTPRes SMALLINT DEFAULT 0 NOT NULL CHECK (HTPRes >= 0)
);

CREATE TABLE Reservation (
    NoReservation INT AUTO_INCREMENT PRIMARY KEY,
    NoSalle SMALLINT REFERENCES Salle(NoSalle),
    CodeELP SMALLINT REFERENCES ELP(CodeELP),
    Groupe VARCHAR(16) NOT NULL REFERENCES Groupes(Groupe),
    Formation VARCHAR(16) NOT NULL REFERENCES Groupes(Formation),
    Nature VARCHAR(16) NOT NULL,
    Debut DATETIME NOT NULL,
    Duree SMALLINT NOT NULL CHECK (Duree >= 0) 
);

--- Creation des Procedure
DELIMITER //
CREATE PROCEDURE MajSalle(Salle VARCHAR(8), Cat VARCHAR(16), Nb SMALLINT) 
BEGIN


END;