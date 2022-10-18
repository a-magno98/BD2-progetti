
CREATE TABLE Personale 
(
	id	INTEGER PRIMARY KEY,
	nome	VARCHAR,
	stipendio DECIMAL(10,2)
);

CREATE TABLE Studente
(
	matricola	INTEGER PRIMARY KEY,
	nome		VARCHAR,
	indirizzo	VARCHAR,
	media		DECIMAL(10,2)
);

CREATE TABLE Corso
(
	codice		INTEGER PRIMARY KEY,
	titolo		VARCHAR,
	prof		INTEGER,
	FOREIGN KEY(prof) REFERENCES Personale(id)
			  ON DELETE RESTRICT
			  ON UPDATE CASCADE
);

CREATE TABLE Esame
(
	corso		INTEGER,
	studente	INTEGER,
	PRIMARY KEY(corso, studente),
	FOREIGN KEY(corso) REFERENCES Corso(codice)
			  ON DELETE RESTRICT
			  ON UPDATE CASCADE,
	FOREIGN KEY(studente) REFERENCES Studente(matricola)
			  ON DELETE RESTRICT
			  ON UPDATE CASCADE,
	dat		DATE,
	voto		INTEGER
);
	