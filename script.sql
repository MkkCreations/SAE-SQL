-- Active: 1672920260782@@bve2dwhmmyq8qnjk3imc-mysql.services.clever-cloud.com@3306@bve2dwhmmyq8qnjk3imc

/* 
    Host: bve2dwhmmyq8qnjk3imc-mysql.services.clever-cloud.com
    User: ut8vvlox26eetjoz
    Password: DUnKkSJLggjJ0vorUaGg
    Port: 3306
 */
--- Drop des Table
DROP TABLE IF EXISTS Salle CASCADE;
DROP TABLE IF EXISTS ELP CASCADE;
DROP TABLE IF EXISTS Groupes CASCADE;
DROP TABLE IF EXISTS Reservation CASCADE;
DROP PROCEDURE IF EXISTS Reserver;
DROP PROCEDURE IF EXISTS ReservationsSalle;
DROP FUNCTION IF EXISTS TauxOccupationSalle;


DELIMITER //
--- Creation des TABLE
CREATE TABLE Salle (
    NoSalle VARCHAR(8) PRIMARY KEY,
    Categorie VARCHAR(16) NOT NULL CHECK (Categorie IN ("Amphi", "Salle", "Salle TP")),
    NbPlaces SMALLINT NOT NULL
);

CREATE TABLE Groupes (
    Groupe VARCHAR(16) NOT NULL,
    Formation VARCHAR(16) NOT NULL,
    Effectif SMALLINT UNSIGNED,
    PRIMARY KEY (Groupe, Formation),
    CHECK (Groupe LIKE 'Promo' OR Groupe LIKE 'TD%' OR Groupe LIKE 'TP%')
);

CREATE TABLE ELP (
    CodeELP INT(16) PRIMARY KEY,
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
    NoSalle VARCHAR(8) REFERENCES Salle(NoSalle),
    CodeELP VARCHAR(16) REFERENCES ELP(CodeELP),
    Groupe VARCHAR(16)  NOT NULL REFERENCES Groupes(Groupe),
    Formation VARCHAR(16) NOT NULL REFERENCES Groupes(Formation),
    Nature VARCHAR(16) NOT NULL CHECK (Nature IN ("Cours", "TD", "TP", "Epreuve")),
    Debut DATETIME NOT NULL ,
    Duree SMALLINT NOT NULL CHECK (Duree >= 0) 
);

DELIMITER //
--- Insertion des donees

INSERT INTO Salle (NoSalle, Categorie, NbPlaces) VALUES ("101", "Amphi", 100);
INSERT INTO Salle (NoSalle, Categorie, NbPlaces) VALUES ("102", "Salle", 30);
INSERT INTO Salle (NoSalle, Categorie, NbPlaces) VALUES ("103", "Salle TP", 30);
INSERT INTO Groupes (Groupe, Formation, Effectif) VALUES ("Promo","BUT inf 2", 30);
INSERT INTO Groupes (Groupe, Formation, Effectif) VALUES ("TD4","BUT inf 2", 300);
INSERT INTO Groupes (Groupe, Formation, Effectif) VALUES ("TD3","BUT inf 1", 20);
INSERT INTO Groupes (Groupe, Formation, Effectif) VALUES ("TP3","BUT inf P", 32);
INSERT INTO ELP (CodeELP, NomELP, Formation, HC, HTD, HTP) VALUES (0238,"Math","BUT inf 2",240, 240, 240);
INSERT INTO ELP (CodeELP, NomELP, Formation, HC, HTD, HTP) VALUES (2638,"Stat","BUT inf 1",240, 240, 240);
INSERT INTO ELP (CodeELP, NomELP, Formation, HC, HTD, HTP) VALUES (0142,"Dev Web","BUT inf P",240, 240, 240);

--- Creation des Procedure
DELIMITER //
---- Projet 4
CREATE PROCEDURE Reserver(SalleNum VARCHAR(8), Code VARCHAR(16), Gpe VARCHAR(16), Forma VARCHAR(16), Nat VARCHAR(16), Deb DATETIME, Dur SMALLINT) 
BEGIN
    DECLARE nbEffectif SMALLINT;
    DECLARE nbPlace SMALLINT;
    DECLARE nbHore SMALLINT;
    DECLARE nbSalle INT(8);
    DECLARE EXIT HANDLER FOR NOT FOUND SELECT 'INEXISTANTE' message;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION BEGIN ROLLBACK; SELECT 'ERREUR: OPERATION ANNULÉE' message; END;
    SELECT Effectif INTO nbEffectif FROM Groupes WHERE Groupe = Gpe;
    SELECT NbPlaces INTO nbPlace FROM Salle WHERE NoSalle = SalleNum;
    SELECT COUNT(*) INTO nbSalle FROM Reservation r WHERE NoSalle = SalleNum AND Deb BETWEEN Debut  AND DATE_ADD(Debut, INTERVAL Dur MINUTE);
    IF nbEffectif > nbPlace THEN
        SELECT "L'effectif saisie est superieur au nombre de places" message;
    ELSEIF Dur > 240 OR Dur < 0 THEN
        SELECT "La durée doit etre positive et inferieure à 241" message;
    ELSEIF nbSalle != 0   THEN
        SELECT NbPlaces FROM Salle WHERE NoSalle = SalleNum;
        SELECT "La Salle est déjà reservé" message;
    ELSE
        INSERT INTO Reservation (NoSalle, CodeELP, Groupe, Formation, Nature, Debut, Duree) VALUES (SalleNum, Code, Gpe, Forma, Nat, Deb, Dur);

        IF Nat = "Cours" THEN
            UPDATE ELP SET HCRes = HCRes + (Dur/60) WHERE CodeELP = Code;
        ELSEIF Nat = "TD" THEN
            UPDATE ELP SET HTDRes = HTDRes + (Dur/60) WHERE CodeELP = Code;
        ELSEIF Nat = "TP" THEN
            UPDATE ELP SET HTPRes = HTPRes + (Dur/60) WHERE CodeELP = Code;
        END IF;
    END IF;
END;

DELIMITER //
CREATE PROCEDURE ReservationsSalle(Salle VARCHAR(8))
BEGIN
    DECLARE debut, fin DATETIME;
    DECLARE code, nat, grp, forma VARCHAR(16);
    DECLARE nom VARCHAR(32);
    SELECT CONCAT('Debut: ',r.Debut,' Fin: ', DATE_ADD(r.Debut, INTERVAL r.Duree MINUTE),' CodeELP: ',r.CodeELP,' NomELP: ',ELP.NomELP,' Nature: ',Nature,' Groupe: ',Groupe,' Formation: ',r.Formation )
    FROM Reservation r, ELP
    WHERE r.NoSalle = Salle 
    AND r.CodeELP = ELP.CodeELP
    ORDER BY Debut ASC;
END;


CALL Reserver('102','238', 'TD4','BUT Info 2','TD',STR_TO_DATE('14/12/2022 0830','%d/%m/%Y %H%i'),120);
CALL Reserver('101','142', 'TD3','BUT Info 3','TD',STR_TO_DATE('12/12/2022 0830','%d/%m/%Y %H%i'),60);
CALL Reserver('102','2638', 'TD3','BUT Info 1','TD',STR_TO_DATE('12/12/2022 0830','%d/%m/%Y %H%i'),120);

CALL ReservationsSalle('101');

--- Create des Fonctions

DELIMITER //
CREATE  FUNCTION TauxOccupationSalle(SalleNum VARCHAR(8), Deb DATETIME, Fin DATETIME) RETURNS INT
    READS SQL DATA
    DETERMINISTIC
BEGIN
    DECLARE taux INT(8) DEFAULT 0;
    DECLARE jours INT(8);
    DECLARE res INT(8);
    DECLARE exis INT(8);
	SELECT COUNT(NoSalle) INTO exis FROM Salle WHERE NoSalle = SalleNum;
    IF exis = 0 THEN 
		RETURN (SELECT "La Salle n'existe pas" message);
	ELSE 
		SELECT SUM(Duree/60) INTO res FROM Reservation WHERE (Debut BETWEEN Deb AND DATE_ADD(Fin, INTERVAL 1 DAY)) AND NoSalle = SalleNum;
		SET jours = TIMESTAMPDIFF(DAY, Deb, DATE_ADD(Fin, INTERVAL 1 DAY));
		SET taux = (res * 100)/(6 * jours); 
        IF taux is NULL THEN
			RETURN 0;
		ELSE
			RETURN taux;
		END IF;
	END IF;
END

SELECT TauxOccupationSalle(101, STR_TO_DATE('12/12/2022','%d/%m/%Y'),STR_TO_DATE('14/12/2022 ','%d/%m/%Y'));
SELECT TauxOccupationSalle(101, STR_TO_DATE('12/12/2022','%d/%m/%Y'),STR_TO_DATE('17/12/2022 ','%d/%m/%Y'));
SELECT TauxOccupationSalle(101, STR_TO_DATE('16/12/2022','%d/%m/%Y'),STR_TO_DATE('20/12/2022 ','%d/%m/%Y'));
SELECT TauxOccupationSalle(103, STR_TO_DATE('12/12/2022','%d/%m/%Y'),STR_TO_DATE('14/12/2022 ','%d/%m/%Y'));
