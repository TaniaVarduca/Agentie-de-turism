--Relatie 1-M
--Hoteluri si sejururi (Un hotel poate gazdui mai multe sejururi, dar un sejur se poate desfasura la un singur hotel)

--Relatie M-N
--Clienti si sejururi (Un client poate cumpara mai multe sejururi si un sejur poate fi cumparat de mai multi clienti)
CREATE DATABASE [Agentie de turism]

CREATE TABLE Clienti
(cod_client INT PRIMARY KEY IDENTITY,
nume VARCHAR(100) NOT NULL,
prenume VARCHAR(100) NOT NULL,
CNP VARCHAR(13) UNIQUE NOT NULL,
nr_tel VARCHAR(10) NOT NULL,
email VARCHAR(100) NOT NULL,
);

CREATE TABLE BileteAvion
(cod_bilet INT PRIMARY KEY IDENTITY,
oras_plecare VARCHAR(100) NOT NULL,
destinatie VARCHAR(100) NOT NULL,
data_ora_plecare DATETIME NOT NULL,
data_ora_sosire DATETIME NOT NULL,
pret FLOAT NOT NULL,
cod_client INT FOREIGN KEY REFERENCES Clienti(cod_client),
);

CREATE TABLE Hoteluri
(cod_hotel INT PRIMARY KEY IDENTITY,
nume VARCHAR(100) NOT NULL,
nr_stele INT CHECK(nr_stele>0),
localitate VARCHAR(100) NOT NULL,
nr_telefon VARCHAR(100) NOT NULL,
);

CREATE TABLE Sejururi
(cod_sejur INT PRIMARY KEY IDENTITY,
destinatie VARCHAR(100) NOT NULL,
nr_nopti INT,
cod_hotel INT FOREIGN KEY REFERENCES Hoteluri(cod_hotel),
);

--Tabel de legatura
CREATE TABLE Rezervari
(cod_client INT FOREIGN KEY REFERENCES Clienti(cod_client),
cod_sejur INT FOREIGN KEY REFERENCES Sejururi(cod_sejur),
nr_persoane INT NOT NULL,
tip_camera VARCHAR(100),
pret FLOAT NOT NULL,
data_rezervare DATE DEFAULT GETDATE()
CONSTRAINT pk_Rezervari PRIMARY KEY (cod_client, cod_sejur)
);
ALTER TABLE Rezervari
ADD data_check_in DATE, data_check_out DATE;


--LAB 2

INSERT INTO Clienti
VALUES ('Pepescu','Dan','5990412482910','0743728430','pepescu@gmail.com'),
	   ('Ionescu','Adrian','5981016452311','0723744365','ionescu@gmail.com'),
	   ('Cistelecan','Ioan','5791114482413','0783421420','cistelecan@gmail.com'),
	   ('Mihaila','Andrei','5910511442419','0744738233','mihaila@gmail.com'),
	   ('Pop','Andrei','5890422479114','0723118446','popandrei@gmail.com'),
	   ('Stan','Anda','6940411426916','0753426428','andastan@gmail.com');
SELECT * FROM Clienti;

INSERT INTO BileteAvion
VALUES ('Bucuresti','Roma','20210118 09:15 AM','20210118 10:35 AM',350,4),
	   ('Cluj-Napoca','Paris','20211218 08:30 AM','20201218 10:55 AM',280,1),	   
	   ('Sibiu','Amsterdam','20210818 07:10 AM','20210818 09:20 AM',580,2),
	   ('Iasi','Madrid','20210629 11:25 AM','20210629 14:05 PM',285,5),
	   ('Cluj-Napoca','Copenhaga','20210208 05:20 AM','20210208 09:00 AM',450,5),
	   ('Oradea','Milano','20210411 12:30 PM','20210411 13:50 PM',190,3);
SELECT * FROM BileteAvion;

INSERT INTO Hoteluri
VALUES ('Novotel',4,'Paris',33640002166),
	   ('Corallo',3,'Roma',3634758231),
	   ('Rembrandtplein',5,'Amsterdam',2423817274),
	   ('EasyHotel',2,'Madrid',436876957545),
	   ('Nimb',5,'Copenhaga',54578149432),
	   ('Ibis',4,'Milano',47567348658),
	   ('City Hotel',NULL,'Budapesta',33640032466);
SELECT * FROM Hoteluri;

INSERT INTO Sejururi
VALUES ('Roma',5,2),
	   ('Paris',3,1),
	   ('Milano',4,6),
	   ('Copenhaga',2,5),
	   ('Amsterdam',5,3),
	   ('Madrid',4,4);
SELECT * FROM Sejururi;

INSERT INTO Rezervari
VALUES (2,5,3,'tripla',6980,'20201101','20210818','20210823'),
       (5,6,2,'dubla',3250,'20200902','20210629','20210703'),
	   (5,4,2,'dubla',4050,'20200813','20210802','20210804'),
	   (3,3,2,'dubla',3250,'20200902','20210411','20210415'),
	   (1,2,2,'dubla',3500,'20201108','20211218','20211221'),
	   (4,1,2,'dubla',4890,'20200712','20210118','20210423');	    
SELECT * FROM Rezervari;


--update cu operator relational >= si =
UPDATE Rezervari
SET tip_camera = 'tripla'
WHERE pret >= 4000;
UPDATE Rezervari
SET nr_persoane = 3
WHERE tip_camera = 'tripla';

--update cu op '<='
UPDATE BileteAvion
SET pret = pret + 10
WHERE pret <= 290;

--update cu operatorul logic OR, relational '>' si '<':
UPDATE Rezervari 
SET pret = pret + 200
WHERE nr_persoane = 3 OR data_check_in > '20210801' OR data_check_out < '20210501'; 

--update cu op NOT
UPDATE Clienti 
SET prenume = 'Ion'
WHERE prenume NOT IN ('Dan','Andrei','Anda','Adrian')

INSERT INTO Hoteluri
VALUES ('City Hotel',NULL,'Budapesta',33640032466),
	   ('Confort',3,'Viena',52463462);


--stergere IS NULL
DELETE FROM Hoteluri
WHERE nr_stele IS NULL;

--stergere cu operator logic AND si op relational <>
DELETE FROM Hoteluri
WHERE nr_stele <> 4 AND localitate = 'Viena';

SELECT * FROM Hoteluri;


--LAB 3

--UNION
SELECT localitate FROM Hoteluri
UNION 
SELECT destinatie FROM Sejururi;

--INNER JOIN (relatie many-to-many), DISTINCT
SELECT DISTINCT C.nume, C.prenume, S.destinatie, R.pret 
FROM Rezervari R 
INNER JOIN Clienti C ON C.cod_client=R.cod_client
INNER JOIN Sejururi S ON S.cod_sejur=R.cod_sejur;

--LEFT JOIN
SELECT C.nume, C.prenume, B.destinatie FROM Clienti C 
LEFT OUTER JOIN BileteAvion B ON C.cod_client = B.cod_client

--GROUP BY, MIN
SELECT cod_client, 
MIN(pret) AS PretMinim
FROM Rezervari 
GROUP BY cod_client;

--GROUP BY, COUNT
SELECT cod_client,
COUNT(cod_sejur) AS [nr sejururi]
FROM Rezervari 
GROUP BY cod_client;

--GROUP BY, SUM, HAVING, WHERE, OR, AND, NOT
SELECT cod_client, 
SUM(pret) AS PretTotal
FROM Rezervari 
WHERE (cod_client=2 OR cod_client=3) AND (NOT cod_client=4)
GROUP BY cod_client 
HAVING SUM(pret) < 4000;


--LAB 4

--FUNCTII VALIDARE

--1 --> Clienti
GO
CREATE FUNCTION ValidareCNP(@cnp VARCHAR(13))
RETURNS BIT AS
BEGIN
DECLARE @ok BIT;
SET @ok = 0;
IF (((substring(@cnp,1,1) = '2' OR substring(@cnp,1,1) = '6') OR 
   (substring(@cnp,1,1) = '1' OR substring(@cnp,1,1) = '5')) AND
   (len(@cnp)=13))
SET @ok=1;
ELSE SET @ok=0;
RETURN @ok;
END

--2 -->Sejururi
GO
CREATE FUNCTION ValidareNrNopti(@nr_nopti INT)
RETURNS BIT AS
BEGIN
DECLARE @ok BIT;
SET @ok = 0;
IF (@nr_nopti>0)
	SET @ok=1;
ELSE SET @ok=0;
RETURN @ok;
END

--3 -->Rezervari
GO
CREATE FUNCTION ValidareRezervari(@tip_camera VARCHAR(100), @nr_persoane INT, @pret FLOAT)
RETURNS BIT AS
BEGIN
DECLARE @ok BIT;
SET @ok = 0;
IF (@nr_persoane>0 AND @pret>0 AND 
   (@tip_camera='dubla' OR @tip_camera='twin' OR @tip_camera='tripla' OR @tip_camera='premium' OR @tip_camera='single'))
SET @ok=1;
ELSE SET @ok=0;
RETURN @ok;
END

--PROCEDURI STOCATE
--1
GO
CREATE PROCEDURE adaugaClienti @nume VARCHAR(100), @prenume VARCHAR(300), @CNP VARCHAR(13), @nr_tel VARCHAR(10), @email VARCHAR(100)
AS
BEGIN
IF (dbo.ValidareCNP(@CNP)=1)
	BEGIN
	INSERT INTO Clienti(nume, prenume, CNP, nr_tel, email) VALUES (@nume, @prenume, @CNP, @nr_tel, @email);
	PRINT 'S-a inserat ' + @nume + ' in tabelul Clienti';
	END
ELSE PRINT 'Dati un CNP valid';
END

EXEC adaugaClienti 'Andreescu', 'Adrian', '5981024424783', '0724654000', 'adi@yahoo.com';
EXEC adaugaClienti 'Cristescu', 'Maria', '6881222154764', '0754632830', 'maria@gmail.com';
EXEC adaugaClienti 'Paunescu', 'Ion', '5741112655748', '0751463874', 'ionpaun@gmail.com';
EXEC adaugaClienti 'Georgescu', 'Ion', '5741112655740', '0751456774', 'ionn@gmail.com';
EXEC adaugaClienti 'Paunescu', 'Andrei', '5001226985732', '0751456774', 'ionn@gmail.com';

SELECT * FROM Clienti;

--2
GO
CREATE PROCEDURE adaugaSejururi @destinatie VARCHAR(100), @nr_nopti INT, @cod_hotel INT
AS
BEGIN
IF (dbo.ValidareNrNopti(@nr_nopti)=1)
BEGIN
	INSERT INTO Sejururi(destinatie, nr_nopti, cod_hotel) VALUES (@destinatie, @nr_nopti, @cod_hotel);
	PRINT 'S-a inserat ' + @destinatie + ' in tabelul Sejururi';
END
ELSE PRINT 'Dati nr_nopti>0';
END

EXEC adaugaSejururi 'Viena', 5, 12;
EXEC adaugaSejururi 'Roma', 3, 2;
EXEC adaugaSejururi 'Milano', 3, 2;

SELECT * FROM Sejururi;

--3 (tabel de legatura)
GO
CREATE PROCEDURE adaugaRezervari @cod_client INT, @cod_sejur INT, @nr_persoane INT, @tip_camera VARCHAR(100), @pret FLOAT, @data_rezervare DATE, @data_check_in DATE, @data_check_out DATE
AS
BEGIN
IF (dbo.ValidareRezervari(@tip_camera, @nr_persoane, @pret)=1)
INSERT INTO Rezervari(cod_client, cod_sejur, nr_persoane, tip_camera, pret, data_rezervare, data_check_in, data_check_out) VALUES (@cod_client, @cod_sejur, @nr_persoane, @tip_camera, @pret, @data_rezervare, @data_check_in, @data_check_out);
ELSE PRINT 'Date incorecte'
END

EXEC adaugaRezervari 158, 232, 2, 'dubla', 3460, '20200810', '20210103', '20210108';
EXEC adaugaRezervari 221, 232, 3, 'tripla', 4120, '20200810', '20210413', '20210415';
EXEC adaugaRezervari 6, 232, 3, 'tripla', 4120, '20200810', '20210413', '20210415';

SELECT * FROM Rezervari;


--LAB 5

--View

CREATE VIEW vw_Clienti AS 
SELECT C.nume, C.prenume, 
B.destinatie AS destinatie,
B.data_ora_plecare AS data_ora_plecare
FROM Clienti AS C
INNER JOIN BileteAvion
AS B ON C.cod_client = B.cod_client;

SELECT * FROM vw_Clienti;

--Trigger

--adaugare hotel
CREATE TRIGGER [dbo].[La_introducere_hotel]
ON [dbo].[Hoteluri]
AFTER INSERT   
AS 
PRINT (CONVERT( VARCHAR(24), GETDATE(), 121) + '  Insert in Hoteluri');

--stergere hotel
CREATE TRIGGER [dbo].[La_stergere_hotel]
ON [dbo].[Hoteluri]
AFTER DELETE   
AS 
PRINT (CONVERT( VARCHAR(24), GETDATE(), 121) + '  Delete in Hoteluri');


INSERT INTO Hoteluri
VALUES ('Carol', 4, 'Dubai', 546768795);

DELETE FROM Hoteluri
WHERE nume = 'Carol';

SELECT * FROM Hoteluri; 
