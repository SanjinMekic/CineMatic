CREATE DATABASE IB210083
GO
USE IB210083

CREATE TABLE Korisnici (
    ID INT PRIMARY KEY IDENTITY,
    Ime NVARCHAR(50),
    Prezime NVARCHAR(50),
    KorisnickoIme NVARCHAR(50),
    Email VARCHAR(100),
    Slika VARBINARY(MAX),
    PasswordSalt NVARCHAR(128),
    PasswordHash NVARCHAR(128),
);

CREATE TABLE Uloge (
    ID INT PRIMARY KEY IDENTITY,
    Naziv NVARCHAR(50)
);

CREATE TABLE KorisniciUloge (
    KorisnikID INT,
    UlogaID INT,
    FOREIGN KEY (KorisnikID) REFERENCES Korisnici(ID) ON DELETE CASCADE,
    FOREIGN KEY (UlogaID) REFERENCES Uloge(ID) ON DELETE CASCADE,
    PRIMARY KEY (KorisnikID, UlogaID)
);

CREATE TABLE DobneRestrikcije (
    ID INT PRIMARY KEY IDENTITY,
    Restrikcija NVARCHAR(10),
	Opis NVARCHAR(MAX)
);

CREATE TABLE Filmovi (
    ID INT PRIMARY KEY IDENTITY,
    Naziv NVARCHAR(100),
    Trajanje INT,
    Opis NVARCHAR(MAX),
    Slika VARBINARY(MAX),
	DobnaRestrikcijaID INT NULL,
    FOREIGN KEY (DobnaRestrikcijaID) REFERENCES DobneRestrikcije(ID) ON DELETE SET NULL
);

CREATE TABLE Žanrovi (
    ID INT PRIMARY KEY IDENTITY,
    Naziv NVARCHAR(50)
);

CREATE TABLE FilmoviŽanrovi (
    FilmID INT,
    ŽanrID INT,
    FOREIGN KEY (FilmID) REFERENCES Filmovi(ID) ON DELETE CASCADE,
    FOREIGN KEY (ŽanrID) REFERENCES Žanrovi(ID) ON DELETE CASCADE,
    PRIMARY KEY (FilmID, ŽanrID)
);

CREATE TABLE Glumci (
    ID INT PRIMARY KEY IDENTITY,
    Ime NVARCHAR(50),
    Prezime NVARCHAR(50),
	DatumRodjenja DATETIME,
	Opis VARCHAR(MAX),
    Slika VARBINARY(MAX)
);

CREATE TABLE FilmoviGlumci (
    FilmID INT,
    GlumacID INT,
    FOREIGN KEY (FilmID) REFERENCES Filmovi(ID) ON DELETE CASCADE,
    FOREIGN KEY (GlumacID) REFERENCES Glumci(ID) ON DELETE CASCADE,
    PRIMARY KEY (FilmID, GlumacID)
);

CREATE TABLE Režiseri (
    ID INT PRIMARY KEY IDENTITY,
    Ime NVARCHAR(50),
    Prezime NVARCHAR(50),
	DatumRodjenja DATETIME,
	Opis NVARCHAR(MAX),
    Slika VARBINARY(MAX)
);

CREATE TABLE FilmoviRežiseri (
    FilmID INT,
    RežiserID INT,
    FOREIGN KEY (FilmID) REFERENCES Filmovi(ID) ON DELETE CASCADE,
    FOREIGN KEY (RežiserID) REFERENCES Režiseri(ID) ON DELETE CASCADE,
    PRIMARY KEY (FilmID, RežiserID)
);

CREATE TABLE Sale (
    ID INT PRIMARY KEY IDENTITY,
    Naziv NVARCHAR(50)
);

CREATE TABLE NačiniPrikazivanja (
    ID INT PRIMARY KEY IDENTITY,
    Naziv NVARCHAR(50)
);

CREATE TABLE Projekcije (
    ID INT PRIMARY KEY IDENTITY,
    FilmID INT,
	SalaID INT,
	NačinProjekcijeID INT,
    DatumIVrijeme DATETIME,
    Cijena DECIMAL(10,2),
    Stanje NVARCHAR(50),
    FOREIGN KEY (FilmID) REFERENCES Filmovi(ID) ON DELETE CASCADE,
	FOREIGN KEY (SalaID) REFERENCES Sale(ID) ON DELETE CASCADE,
    FOREIGN KEY (NačinProjekcijeID) REFERENCES NačiniPrikazivanja(ID) ON DELETE CASCADE
);

CREATE TABLE Sjedišta (
    ID INT PRIMARY KEY IDENTITY,
    Naziv NVARCHAR(10)
);

CREATE TABLE ProjekcijeSjedišta (
    ProjekcijaID INT,
    SjedišteID INT,
    Rezervisano BIT DEFAULT 0,
    FOREIGN KEY (ProjekcijaID) REFERENCES Projekcije(ID) ON DELETE CASCADE,
    FOREIGN KEY (SjedišteID) REFERENCES Sjedišta(ID) ON DELETE CASCADE,
    PRIMARY KEY (ProjekcijaID, SjedišteID)
);

CREATE TABLE Uplate (
    ID INT PRIMARY KEY IDENTITY,
    KorisnikID INT,
    Izdavač VARCHAR(50),
    TransakcijaID VARCHAR(255),
    Iznos DECIMAL(10,2),
    DatumIVrijeme DATETIME,
    FOREIGN KEY (KorisnikID) REFERENCES Korisnici(ID) ON DELETE CASCADE
);

CREATE TABLE Rezervacije (
    ID INT PRIMARY KEY IDENTITY,
    KorisnikID INT,
    ProjekcijaID INT,
	UplataID INT NULL,
    DatumIVrijeme DATETIME,
    BrojUlaznica INT,
    UkupnaCijena DECIMAL(10,2),
	NačinPlaćanja VARCHAR(50) DEFAULT 'Gotovina',
	QRCodeBase64 NVARCHAR(MAX),
	PonistenaKarta BIT DEFAULT 0,
    FOREIGN KEY (KorisnikID) REFERENCES Korisnici(ID) ON DELETE NO ACTION,
    FOREIGN KEY (ProjekcijaID) REFERENCES Projekcije(ID) ON DELETE CASCADE,
	FOREIGN KEY (UplataID) REFERENCES Uplate(ID) ON DELETE SET NULL
);

CREATE TABLE RezervacijeSjedišta (
    RezervacijaID INT,
    SjedišteID INT,
	DatumIVrijeme DATETIME,
    FOREIGN KEY (RezervacijaID) REFERENCES Rezervacije(ID) ON DELETE CASCADE,
    FOREIGN KEY (SjedišteID) REFERENCES Sjedišta(ID) ON DELETE CASCADE,
    PRIMARY KEY (RezervacijaID, SjedišteID)
);

CREATE TABLE KategorijeHraneIPića (
    ID INT PRIMARY KEY IDENTITY,
    Naziv NVARCHAR(100) NOT NULL
);

CREATE TABLE HraneIPića (
    ID INT PRIMARY KEY IDENTITY,
	KategorijaID INT,
    Naziv NVARCHAR(100),
    Cijena DECIMAL(10,2),
    Opis VARCHAR(MAX),
    KoličinaUSkladištu INT,
	Slika VARBINARY(max),
	FOREIGN KEY (KategorijaID) REFERENCES KategorijeHraneIPića(ID)
);

CREATE TABLE RezervacijeHraneIPića (
    RezervacijaID INT,
    HranaIPićeID INT,
	Kolicina INT DEFAULT 1
    FOREIGN KEY (RezervacijaID) REFERENCES Rezervacije(ID) ON DELETE CASCADE,
    FOREIGN KEY (HranaIPićeID) REFERENCES HraneIPića(ID) ON DELETE CASCADE,
    PRIMARY KEY (RezervacijaID, HranaIPićeID)
);

CREATE TABLE Recenzije (
    ID INT PRIMARY KEY IDENTITY,
	KorisnikID INT,
    FilmID INT,
    Ocjena INT,
	DatumIVrijeme DATETIME,
    Komentar NVARCHAR(MAX),
    FOREIGN KEY (KorisnikID) REFERENCES Korisnici(ID) ON DELETE CASCADE,
    FOREIGN KEY (FilmID) REFERENCES Filmovi(ID) ON DELETE CASCADE
);

CREATE TABLE FAQKategorije (
    ID INT PRIMARY KEY IDENTITY,
    Naziv VARCHAR(100) UNIQUE NOT NULL
);

CREATE TABLE FAQs (
    ID INT PRIMARY KEY IDENTITY,
    KategorijaID INT,
    Pitanje NVARCHAR(MAX) NOT NULL,
    Odgovor NVARCHAR(MAX) NOT NULL,
    FOREIGN KEY (KategorijaID) REFERENCES FAQKategorije(ID) ON DELETE CASCADE
);

-- Unos podataka u tabelu Korisnici
INSERT INTO Korisnici (Ime, Prezime, Email, KorisnickoIme, PasswordSalt, PasswordHash, Slika)
VALUES 
('Elma', 'Hajdarević', 'elma@example.com', 'elma01', 'salt1', 'hash1', NULL),
('Adnan', 'Kovačević', 'adnan@example.com', 'adnan123', 'salt2', 'hash2', NULL),
('Amira', 'Dedić', 'amira@example.com', 'amira88', 'salt3', 'hash3', NULL),
('Benjamin', 'Tomić', 'benjamin@example.com', 'benjamin88', 'salt4', 'hash4', NULL),
('Lejla', 'Mujkić', 'lejla@example.com', 'lejla123', 'salt5', 'hash5', NULL),
('Nedim', 'Begović', 'nedim@example.com', 'nedimL', 'salt6', 'hash6', NULL),
('Selma', 'Omerović', 'selma@example.com', 'selma234', 'salt7', 'hash7', NULL),
('Jasmina', 'Šabić', 'jasmina@example.com', 'jasmina01', 'salt8', 'hash8', NULL),
('Dženan', 'Smajlović', 'dzenan@example.com', 'dzenan222', 'salt9', 'hash9', NULL),
('Tarik', 'Hadžić', 'tarik@example.com', 'tarik333', 'salt10', 'hash10', NULL);

-- Unos podataka u tabelu Uloge
INSERT INTO Uloge (Naziv)
VALUES
('Korisnik'),
('Administrator')

-- Unos podataka u tabelu KorisniciUloge
INSERT INTO KorisniciUloge (KorisnikID, UlogaID)
VALUES 
(1, 1),
(2, 1),
(3, 1),
(4, 1),
(5, 1),
(6, 1),
(7, 1),
(8, 1),
(9, 2),
(10, 2);

-- Unos podataka u tabelu DobneRestrikcije
INSERT INTO DobneRestrikcije (Restrikcija, Opis)
VALUES
('0+', 'Filmovi za sve uzraste'),
('3+', 'Filmovi za djecu 3 i više godina'),
('7+', 'Filmovi za djecu 7 i više godina'),
('12+', 'Filmovi za uzrast 12 i više'),
('12+', 'Filmovi koji uključuju lagane nasilne scene i jezike'),
('15+', 'Filmovi sa ozbiljnim temama i akcijama koje su prikladne za mlade'),
('16+', 'Filmovi za uzrast 16 i više'),
('18+', 'Filmovi za odrasle'),
('PG', 'Filmovi sa preporukom za roditelje ili staratelje');

-- Unos podataka u tabelu Filmovi
INSERT INTO Filmovi (Naziv, Trajanje, Opis, Slika, DobnaRestrikcijaID)
VALUES
('The Lion King', 88, 'Priča o mladom lavu Simbi koji mora prihvatiti svoje naslijeđe kao kralj. Uključuje akciju, emocije i izuzetnu muziku.', NULL, 1),
('The Dark Knight', 152, 'Batman mora suočiti sa Jokerom, psihopatom koji želi uništiti Gotham City. Film je prepun akcije i napetosti.', NULL, 2),
('Forrest Gump', 142, 'Priča o Forrestu Gumpu, čovjeku s niskim IQ-om koji postaje ključna figura u mnogim istorijskim događajima u SAD-u.', NULL, 3),
('Joker', 122, 'Priča o životu Arthura Flecka, nezadovoljnog komičara koji postaje zlikovac u Gotham Cityju, izazivajući društvene nemire.', NULL, 4),
('The Matrix', 136, 'Neo je u potrazi za istinom o stvarnosti koja nije onakva kakvom se čini. Sci-fi akcija sa filozofskim temama.', NULL, 1),
('Inception', 148, 'Skupina profesionalaca ulazi u svijet snova kako bi promijenili podsvjesne misli. Film je kompleksan i pun akcije.', NULL, 2),
('The Godfather', 175, 'Priča o obitelji Corleone, mafijaškoj dinastiji koja upravlja kriminalnim carstvom. Klasik koji istražuje teme moći i lojalnosti.', NULL, 3),
('Pulp Fiction', 154, 'Tri međusobno povezane priče o kriminalu i nasilju u Los Angelesu. Film koji je postavio nove standarde u kinematografiji.', NULL, 4),
('Avengers: Endgame', 181, 'Konačni obračun Avengersa protiv Thanos-a kako bi spasili svemir. Akcijski spektakl s velikim brojem likova i epohalnim trenucima.', NULL, 1),
('Gladiator', 155, 'Bivši general Maximus postaje gladijator i traži osvetu protiv carigradskog cara. Film prepun borbenih scena i emocija.', NULL, 2),
('The Shawshank Redemption', 142, 'Priča o prijateljstvu između dva zatvorenika i njihovoj potrazi za slobodom u zatvoru Shawshank. Inspirativni klasik o nadi i istrajnosti.', NULL, 3),
('Interstellar', 169, 'Astronauti putuju kroz crvotočinu u potrazi za novim domom za čovječanstvo. Film koji kombinuje nauku i emocije.', NULL, 2),
('Fight Club', 139, 'Priča o nezadovoljnom muškarcu koji osniva tajni klub za borbu kako bi se oslobodio svoje unutrašnje frustracije. Provokativan film o društvenim normama i identitetu.', NULL, 1),
('Star Wars: A New Hope', 121, 'Luke Skywalker kreće na put borbe protiv Galaktičkog Imperija, postajući ključna figura u borbi za slobodu u galaksiji.', NULL, 4),
('The Silence of the Lambs', 118, 'Mladi agent FBI-a mora surađivati s zatvorenim serijskim ubicom Hannibalom Lecterom kako bi uhvatio drugog ubicu. Napet thriller s psihološkim dubinama.', NULL, 3);

-- Unos podataka u tabelu Žanrovi
INSERT INTO Žanrovi (Naziv)
VALUES
('Akcija'),
('Drama'),
('Komedija'),
('Horor'),
('Triler'),
('Romantika'),
('Fantazija'),
('Animacija'),
('Dokumentarac'),
('Misterija');

-- Unos podataka u tabelu FilmoviŽanrovi
INSERT INTO FilmoviŽanrovi (FilmID, ŽanrID)
VALUES
(1, 8),  -- The Lion King (Animacija)
(1, 7),  -- The Lion King (Fantazija)
(1, 2),  -- The Lion King (Drama)
(1, 3),  -- The Lion King (Komedija)
(1, 5),  -- The Lion King (Triler)
(2, 1),  -- The Dark Knight (Akcija)
(2, 5),  -- The Dark Knight (Triler)
(2, 2),  -- The Dark Knight (Drama)
(2, 4),  -- The Dark Knight (Horor)
(2, 9),  -- The Dark Knight (Kriminalistički)
(3, 2),  -- Forrest Gump (Drama)
(3, 3),  -- Forrest Gump (Komedija)
(3, 8),  -- Forrest Gump (Animacija)
(3, 7),  -- Forrest Gump (Fantazija)
(4, 4),  -- Joker (Horor)
(4, 2),  -- Joker (Drama)
(4, 5),  -- Joker (Triler)
(4, 9),  -- Joker (Kriminalistički)
(5, 1),  -- The Matrix (Akcija)
(5, 5),  -- The Matrix (Triler)
(5, 7),  -- The Matrix (Sci-Fi)
(5, 8),  -- The Matrix (Animacija)
(6, 1),  -- Inception (Akcija)
(6, 5),  -- Inception (Triler)
(6, 7),  -- Inception (Sci-Fi)
(6, 8),  -- Inception (Animacija)
(7, 2),  -- The Godfather (Drama)
(7, 9),  -- The Godfather (Kriminalistički)
(7, 5),  -- The Godfather (Triler)
(7, 4),  -- The Godfather (Horor)
(8, 1),  -- Pulp Fiction (Akcija)
(8, 2),  -- Pulp Fiction (Drama)
(8, 5),  -- Pulp Fiction (Triler)
(8, 4),  -- Pulp Fiction (Horor)
(9, 1),  -- Avengers: Endgame (Akcija)
(9, 7),  -- Avengers: Endgame (Fantazija)
(9, 8),  -- Avengers: Endgame (Animacija)
(9, 2),  -- Avengers: Endgame (Drama)
(10, 1), -- Gladiator (Akcija)
(10, 2), -- Gladiator (Drama)
(10, 5), -- Gladiator (Triler)
(10, 4), -- Gladiator (Horor)
(11, 2), -- The Shawshank Redemption (Drama)
(11, 3), -- The Shawshank Redemption (Komedija)
(11, 5), -- The Shawshank Redemption (Triler)
(12, 2), -- Interstellar (Drama)
(12, 7), -- Interstellar (Sci-Fi)
(12, 8), -- Interstellar (Animacija)
(13, 1), -- Fight Club (Akcija)
(13, 5), -- Fight Club (Triler)
(13, 4), -- Fight Club (Horor)
(13, 9), -- Fight Club (Kriminalistički)
(14, 7), -- Star Wars: A New Hope (Fantazija)
(14, 1), -- Star Wars: A New Hope (Akcija)
(14, 2), -- Star Wars: A New Hope (Drama)
(14, 5), -- Star Wars: A New Hope (Triler)
(15, 3), -- The Silence of the Lambs (Komedija)
(15, 4), -- The Silence of the Lambs (Horor)
(15, 5), -- The Silence of the Lambs (Triler)
(15, 9); -- The Silence of the Lambs (Kriminalistički)

-- Unos podataka u tabelu Glumci
INSERT INTO Glumci (Ime, Prezime, DatumRodjenja, Opis, Slika)
VALUES
('Matthew', 'Broderick', '1962-03-21', 'Američki glumac poznat po ulozi u animiranom filmu The Lion King.', NULL),
('Christian', 'Bale', '1974-01-30', 'Britanski glumac poznat po transformacijama ulogama, posebno kao Batman.', NULL),
('Tom', 'Hanks', '1956-07-09', 'Američki glumac i producent, poznat po širokom spektru uloga i emotivnim izvedbama.', NULL),
('Joaquin', 'Phoenix', '1974-10-28', 'Američki glumac poznat po intenzivnim i emocionalno zahtjevnim ulogama.', NULL),
('Keanu', 'Reeves', '1964-09-02', 'Kanadski glumac poznat po ulozi u Matrix trilogiji i akcijskim filmovima.', NULL),
('Leonardo', 'DiCaprio', '1974-11-11', 'Američki glumac i producent, dobitnik Oscara, poznat po brojnim dramskim ulogama.', NULL),
('Marlon', 'Brando', '1924-04-03', 'Legendarni američki glumac i ikona filmske umjetnosti 20. stoljeća.', NULL),
('John', 'Travolta', '1954-02-18', 'Američki glumac poznat po ulogama u glazbenim i kriminalističkim filmovima.', NULL),
('Chris', 'Hemsworth', '1983-08-11', 'Australski glumac poznat po ulozi Thora u Marvel filmovima.', NULL),
('Russell', 'Crowe', '1964-04-07', 'Novozelandsko-australski glumac, dobitnik Oscara, poznat po ulozi u filmu Gladiator.', NULL),
('Tim', 'Robbins', '1958-10-16', 'Američki glumac, režiser i scenarist, poznat po ulozi u filmu The Shawshank Redemption.', NULL),
('Matthew', 'McConaughey', '1969-11-04', 'Američki glumac poznat po šarmantnim i ozbiljnim ulogama, uključujući film Interstellar.', NULL),
('Brad', 'Pitt', '1963-12-18', 'Američki glumac i producent, poznat po raznovrsnim ulogama i filmskom utjecaju.', NULL),
('Mark', 'Hamill', '1951-09-25', 'Američki glumac najpoznatiji po ulozi Lukea Skywalkera u Star Wars sagama.', NULL),
('Jodie', 'Foster', '1962-11-19', 'Američka glumica i režiserka, poznata po inteligentnim i snažnim ulogama.', NULL);

-- Unos podataka u tabelu FilmoviGlumci
INSERT INTO FilmoviGlumci (FilmID, GlumacID)
VALUES
(1, 1),  -- The Lion King - Matthew Broderick
(2, 2),  -- The Dark Knight - Christian Bale
(3, 3),  -- Forrest Gump - Tom Hanks
(4, 4),  -- Joker - Joaquin Phoenix
(5, 5),  -- The Matrix - Keanu Reeves
(6, 6),  -- Inception - Leonardo DiCaprio
(7, 7),  -- The Godfather - Marlon Brando
(8, 8),  -- Pulp Fiction - John Travolta
(9, 9),  -- Avengers: Endgame - Chris Hemsworth
(10, 10), -- Gladiator - Russell Crowe
(11, 11), -- The Shawshank Redemption - Tim Robbins
(12, 12), -- Interstellar - Matthew McConaughey
(13, 13), -- Fight Club - Brad Pitt
(14, 14), -- Star Wars: A New Hope - Mark Hamill
(15, 15); -- The Silence of the Lambs - Jodie Foster

-- Unos podataka u tabelu Režiseri
INSERT INTO Režiseri (Ime, Prezime, DatumRodjenja, Opis, Slika)
VALUES
('Jon', 'Favreau', '1966-10-19', 'Američki režiser, producent i glumac, poznat po režiranju The Lion King remakea.', NULL),
('Christopher', 'Nolan', '1970-07-30', 'Britanski režiser poznat po složenim narativima i vizualno impresivnim filmovima.', NULL),
('Robert', 'Zemeckis', '1951-05-14', 'Američki režiser i scenarist, poznat po inovacijama u vizualnim efektima.', NULL),
('Todd', 'Phillips', '1970-12-20', 'Američki režiser poznat po komedijama i dramama, uključujući Joker.', NULL),
('Lana', 'Wachowski', '1965-06-21', 'Američka režiserka poznata po režiji kultnog Matrix serijala.', NULL),
('Christopher', 'Nolan', '1970-07-30', 'Britanski režiser poznat po složenim narativima i vizualno impresivnim filmovima.', NULL),
('Francis', 'Ford Coppola', '1939-04-07', 'Američki režiser, jedan od najutjecajnijih filmskih stvaralaca svih vremena.', NULL),
('Quentin', 'Tarantino', '1963-03-27', 'Američki režiser poznat po stiliziranom nasilju i jedinstvenom dijalogu.', NULL),
('Anthony', 'Russo', '1970-02-03', 'Američki režiser koji zajedno s bratom režira Marvelove blockbustere.', NULL),
('Ridley', 'Scott', '1937-11-30', 'Britanski režiser poznat po epskim filmovima i naučno-fantastičnim klasicima.', NULL),
('Frank', 'Darabont', '1959-01-28', 'Američki režiser poznat po adaptacijama djela Stephena Kinga.', NULL),
('Christopher', 'Nolan', '1970-07-30', 'Britanski režiser poznat po složenim narativima i vizualno impresivnim filmovima.', NULL),
('David', 'Fincher', '1962-08-28', 'Američki režiser poznat po mračnim, psihološkim trilerima.', NULL),
('George', 'Lucas', '1944-05-14', 'Američki režiser i producent, tvorac Star Wars i Indiana Jones serijala.', NULL),
('Jonathan', 'Demme', '1944-02-22', 'Američki režiser, poznat po filmu The Silence of the Lambs.', NULL);

-- Unos podataka u tabelu FilmoviRežiseri
INSERT INTO FilmoviRežiseri (FilmID, RežiserID)
VALUES
(1, 1),  -- The Lion King - Jon Favreau
(2, 2),  -- The Dark Knight - Christopher Nolan
(3, 3),  -- Forrest Gump - Robert Zemeckis
(4, 4),  -- Joker - Todd Phillips
(5, 5),  -- The Matrix - Lana Wachowski
(6, 6),  -- Inception - Christopher Nolan
(7, 7),  -- The Godfather - Francis Ford Coppola
(8, 8),  -- Pulp Fiction - Quentin Tarantino
(9, 9),  -- Avengers: Endgame - Anthony Russo
(10, 10), -- Gladiator - Ridley Scott
(11, 11), -- The Shawshank Redemption - Frank Darabont
(12, 12), -- Interstellar - Christopher Nolan
(13, 13), -- Fight Club - David Fincher
(14, 14), -- Star Wars: A New Hope - George Lucas
(15, 15); -- The Silence of the Lambs - Jonathan Demme

-- Unos podataka u tabelu Sale
INSERT INTO Sale (Naziv)
VALUES
('Sala 1'),
('Sala 2'),
('Sala 3'),
('Sala 4'),
('Sala 5'),
('Sala 6'),
('Sala 7'),
('Sala 8'),
('Sala 9'),
('Sala 10');

-- Unos podataka u tabelu NačiniPrikazivanja
INSERT INTO NačiniPrikazivanja (Naziv)
VALUES
('Standardni'),
('3D'),
('IMAX'),
('4DX'),
('Dolby Vision'),
('VIP'),
('DTS'),
('HFR'),
('VR'),
('Kino na otvorenom');

-- Unos podataka u tabelu Projekcije
INSERT INTO Projekcije (FilmID, SalaID, NačinProjekcijeID, DatumIVrijeme, Cijena, Stanje)
VALUES
(1, 1, 1, '2025-04-05 14:00:00', 10.50, 'active'),
(2, 2, 2, '2025-04-05 16:30:00', 13.00, 'draft'),
(3, 3, 3, '2025-04-05 19:00:00', 15.50, 'active'),
(4, 4, 4, '2025-04-06 14:00:00', 18.00, 'active'),
(5, 5, 5, '2025-04-06 16:30:00', 14.50, 'hidden'),
(6, 6, 6, '2025-04-06 19:00:00', 11.00, 'active'),
(7, 7, 7, '2025-04-07 14:00:00', 13.50, 'draft'),
(8, 8, 8, '2025-04-07 16:30:00', 16.00, 'active'),
(9, 9, 9, '2025-04-07 19:00:00', 19.00, 'active'),
(10, 10, 10, '2025-04-08 14:00:00', 15.00, 'hidden'),
(1, 2, 9, '2025-04-08 16:30:00', 14.00, 'active'),
(2, 3, 8, '2025-04-08 19:00:00', 17.50, 'draft'),
(3, 4, 7, '2025-04-09 14:00:00', 16.50, 'active'),
(4, 5, 6, '2025-04-09 16:30:00', 11.50, 'active'),
(5, 6, 5, '2025-04-09 19:00:00', 13.00, 'hidden'),
(11, 1, 4, '2025-04-10 14:00:00', 10.50, 'active'),
(12, 2, 3, '2025-04-10 16:30:00', 13.00, 'active'),
(13, 3, 2, '2025-04-10 19:00:00', 15.50, 'active'),
(14, 4, 1, '2025-04-11 14:00:00', 18.00, 'active'),
(15, 5, 2, '2025-04-11 16:30:00', 14.50, 'active'),
(11, 2, 3, '2025-04-12 14:00:00', 11.50, 'active'),
(12, 3, 4, '2025-04-12 16:30:00', 14.00, 'active'),
(13, 4, 5, '2025-04-12 19:00:00', 17.50, 'active'),
(14, 5, 6, '2025-04-13 14:00:00', 16.00, 'active'),
(15, 6, 7, '2025-04-13 16:30:00', 17.50, 'active');

-- Unos podataka u tabelu Sjedišta
INSERT INTO Sjedišta (Naziv)
VALUES
('A1'), ('A2'), ('A3'), ('A4'), ('A5'),
('B1'), ('B2'), ('B3'), ('B4'), ('B5'),
('C1'), ('C2'), ('C3'), ('C4'), ('C5'),
('D1'), ('D2'), ('D3'), ('D4'), ('D5'),
('E1'), ('E2'), ('E3'), ('E4'), ('E5'),
('F1'), ('F2'), ('F3'), ('F4'), ('F5'),
('G1'), ('G2'), ('G3'), ('G4'), ('G5'),
('H1'), ('H2'), ('H3'), ('H4'), ('H5'),
('I1'), ('I2'), ('I3'), ('I4'), ('I5'),
('J1'), ('J2'), ('J3'), ('J4'), ('J5');

DECLARE @ProjekcijaID INT = 1;
DECLARE @MaxProjekcijaID INT;
SELECT @MaxProjekcijaID = MAX(ID) FROM Projekcije;

-- Petlja koja prolazi kroz sve projekcije
WHILE @ProjekcijaID <= @MaxProjekcijaID
BEGIN
    -- Dodavanje sjedala za svaku projekciju
    INSERT INTO ProjekcijeSjedišta(ProjekcijaID, SjedišteID, Rezervisano)
    SELECT
        @ProjekcijaID,
        Sjedišta.ID,
        0 -- Ovdje '0' znači da sjedalo nije rezervisano
    FROM 
        Sjedišta;

    -- Povećanje ScreeningID za narednu projekciju
    SET @ProjekcijaID = @ProjekcijaID + 1;
END;

-- Unos podataka u tabelu Uplate
INSERT INTO Uplate (KorisnikID, Izdavač, TransakcijaID, Iznos, DatumIVrijeme)
VALUES
(1, 'Stripe', 'txn_1', 21.00, '2025-03-02 14:00:00'),
(2, 'Stripe', 'txn_2', 10.50, '2025-03-02 14:00:00'),
(3, 'Gotovina', NULL, 46.50, '2025-03-03 16:30:00'),
(1, 'Stripe', 'txn_3', 15.50, '2025-03-03 16:30:00'),
(4, 'Gotovina', NULL, 18.00, '2025-03-04 19:00:00'),
(5, 'Stripe', 'txn_4', 44.00, '2025-03-04 19:00:00'),
(6, 'Stripe', 'txn_5', 16.00, '2025-03-06 15:00:00'),
(7, 'Gotovina', NULL, 38.00, '2025-03-06 18:30:00'),
(8, 'Stripe', 'txn_6', 28.00, '2025-03-07 17:00:00'),
(8, 'Gotovina', NULL, 66.00, '2025-03-07 17:00:00');

-- Unos podataka u tabelu Rezervacije
INSERT INTO Rezervacije (KorisnikID, ProjekcijaID, DatumIVrijeme, BrojUlaznica, UkupnaCijena, UplataID, NačinPlaćanja, QRCodeBase64)
VALUES
(1, 1, '2025-04-01 19:00', 2, 20.00, 1, 'Gotovina', NULL),
(2, 2, '2025-04-01 21:00', 3, 36.00, 2, 'Stripe', NULL),
(3, 3, '2025-04-02 18:00', 1, 14.00, NULL, 'Gotovina', NULL),
(4, 4, '2025-04-02 20:00', 2, 32.00, 4, 'Gotovina', NULL),
(5, 5, '2025-04-03 17:00', 2, 36.00, NULL, 'Gotovina', NULL),
(6, 6, '2025-04-03 19:00', 1, 20.00, 6, 'Gotovina', NULL),
(7, 7, '2025-04-04 16:00', 3, 66.00, 7, 'Gotovina', NULL),
(8, 8, '2025-04-04 18:00', 2, 48.00, NULL, 'Stripe', NULL),
(9, 9, '2025-04-05 15:00', 1, 26.00, 9, 'Stripe', NULL),
(10, 10, '2025-04-05 17:00', 2, 56.00, NULL, 'Gotovina', NULL);

-- Unos podataka u tabelu RezervacijeSjedišta
INSERT INTO RezervacijeSjedišta (RezervacijaID, SjedišteID, DatumIVrijeme)
VALUES
(1, 1, GETDATE()), 
(1, 2, GETDATE()),
(2, 3, GETDATE()),
(3, 4, GETDATE()), 
(3, 5, GETDATE()), 
(3, 6, GETDATE()),
(4, 7, GETDATE()),
(5, 8, GETDATE()),
(6, 9, GETDATE()), 
(6, 10, GETDATE()), 
(6, 11, GETDATE()), 
(6, 12, GETDATE()),
(7, 12, GETDATE()),
(8, 12, GETDATE()),
(8, 13, GETDATE()),
(9, 12, GETDATE()),
(9, 13, GETDATE()),
(10, 12, GETDATE()),
(10, 13, GETDATE()),
(10, 14, GETDATE()),
(10, 15, GETDATE());

MERGE ProjekcijeSjedišta AS target
USING (VALUES 
    (1, 1, 1),  
    (1, 2, 1),  
    (1, 3, 1),  
    (3, 4, 1),  
    (3, 5, 1),  
    (3, 6, 1),  
    (3, 7, 1),  
    (4, 8, 1),  
    (6, 9, 1),  
    (6, 10, 1), 
    (6, 11, 1), 
    (6, 12, 1), 
    (8, 12, 1), 
    (9, 12, 1), 
    (9, 13, 1), 
    (11, 12, 1),
    (11, 13, 1),
    (13, 12, 1),
    (13, 13, 1),
    (13, 14, 1),
    (13, 15, 1) 
) AS source (ProjekcijaID, SjedišteID, Rezervisano)
ON (target.ProjekcijaID = source.ProjekcijaID AND target.SjedišteID = source.SjedišteID)
WHEN MATCHED THEN 
    UPDATE SET Rezervisano = source.Rezervisano
WHEN NOT MATCHED THEN 
    INSERT (ProjekcijaID, SjedišteID, Rezervisano) 
    VALUES (source.ProjekcijaID, source.SjedišteID, source.Rezervisano);

-- Unos podataka u tabelu KategorijeHraneIPića
INSERT INTO KategorijeHraneIPića (Naziv)
VALUES
('Pića'),
('Grickalice'),
('Slastice'),
('Zdravlje'),
('Sendviči'),
('Topli napici'),
('Jela'),
('Juhe'),
('Sokovi'),
('Alkoholi');

-- Unos podataka u tabelu HraneIPića
INSERT INTO HraneIPića (KategorijaID, Naziv, Cijena, Opis, KoličinaUSkladištu)
VALUES
(1, 'Coca Cola', 2.50, 'Omiljeni gazirani napitak', 100),
(2, 'Čips', 1.80, 'Krompiri u hrskavoj korici', 50),
(3, 'Čokolada', 3.00, 'Slatka poslastica od čokolade', 30),
(4, 'Voćni jogurt', 2.20, 'Zdrav snack bogat vitaminima', 80),
(5, 'Sendvič sa sirom', 4.00, 'Sendvič sa svježim sirom i povrćem', 60),
(6, 'Kafa', 1.50, 'Kvalitetna kafa iz kafe aparata', 200),
(7, 'Pileća supa', 5.00, 'Ukusna pileća supa sa povrćem', 40),
(8, 'Narandžasti sok', 2.80, 'Svježe iscjeđen sok od narandže', 90),
(9, 'Pivo', 3.50, 'Hladno pivo za uživanje', 100),
(10, 'Vino crno', 7.00, 'Crno vino iz italijanske regije', 25);

-- Unos podataka u tabelu RezervacijeHraneIPića
INSERT INTO RezervacijeHraneIPića (RezervacijaID, HranaIPićeID)
VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(3, 5),
(3, 6),
(4, 7),
(4, 8),
(5, 9),
(5, 10);

-- Unos podataka u tabelu Rezencije
INSERT INTO Recenzije (KorisnikID, FilmID, Ocjena, DatumIVrijeme, Komentar)
VALUES
(1, 1, 5, '2025-04-01 19:00', 'Odličan film!'),
(2, 2, 4, '2025-04-01 21:00', 'Film je bio dobar, ali mogao je biti bolji.'),
(3, 3, 5, '2025-04-02 18:00', 'Vrlo uzbudljiv film!'),
(4, 4, 3, '2025-04-02 20:00', 'Film nije ispunio moja očekivanja.'),
(5, 5, 4, '2025-04-03 17:00', 'Lijep film, ali je kraj mogao biti bolji.'),
(6, 6, 5, '2025-04-03 19:00', 'Sjajan film!'),
(7, 7, 2, '2025-04-04 16:00', 'Nije moj tip filma.'),
(8, 8, 4, '2025-04-04 18:00', 'Dobro je, ali traje predugo.'),
(9, 9, 5, '2025-04-05 15:00', 'Izvanredno!'),
(10, 10, 3, '2025-04-05 17:00', 'Film je bio u redu, ništa posebno.');

-- Unos podataka u tabelu FAQKategorije
INSERT INTO FAQKategorije (Naziv)
VALUES
('Opšte informacije'),
('Kupovina karata'),
('Reklamacije'),
('Projekcije'),
('Promocije'),
('Sigurnost'),
('Zdravlje i sigurnost'),
('Usluge'),
('Posebne ponude'),
('Često postavljana pitanja');

-- Unos podataka u tabelu FAQs
INSERT INTO FAQs (KategorijaID, Pitanje, Odgovor)
VALUES
(1, 'Kako da kupim kartu?', 'Kartu možete kupiti online ili na blagajni kino sale.'),
(2, 'Kada je najbolji trenutak za kupovinu karata?', 'Preporučujemo kupovinu karata unaprijed kako biste osigurali svoje mjesto.'),
(3, 'Kako da zatražim povrat novca?', 'Za povrat novca obratite se našoj službi za korisnike.'),
(4, 'Kada počinju projekcije?', 'Projekcije počinju u unaprijed najavljenim terminima, provjerite naš raspored.'),
(5, 'Imate li popuste?', 'Imamo popuste za studente i starije osobe. Detalje provjerite na našoj web stranici.'),
(6, 'Da li je sigurno u kino dvoranama?', 'Sigurnost naših posjetitelja je naš prioritet, poduzimamo sve mjere zaštite.'),
(7, 'Da li moram nositi masku?', 'Preporučujemo nošenje maske tokom projekcija, ovisno o trenutnim zdravstvenim smjernicama.'),
(8, 'Koje usluge nudi kino?', 'Nudimo usluge poput online rezervacije, VIP sale i dostavu hrane u dvoranu.'),
(9, 'Imate li posebne ponude za firme?', 'Da, nudimo posebne ponude za korporativne događaje, kontaktirajte nas za više informacija.'),
(10, 'Kako da se pretplatim na obavijesti?', 'Pretplatite se na naš newsletter na našoj web stranici.');


