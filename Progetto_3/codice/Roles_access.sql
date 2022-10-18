/*CREATE ROLE impiegato; --ruolo impiegato
CREATE ROLE direttore; --ruolo direttore
GRANT impiegato TO direttore; --assegno i privilegi di impiegato a direttore

CREATE ROLE capoufficio; --ruolo capoufficio
GRANT impiegato TO capoufficio WITH ADMIN OPTION; --assegno i privilegi di impiegato a capoufficio, con la possibilità di amministrare impiegato

CREATE ROLE prof; --ruolo prof
CREATE ROLE studente; --ruolo studente 
GRANT prof, studente TO direttore WITH ADMIN OPTION; --assegno i privilegi di prof e studente a direttore, con la possibilità di amministrare prof, studente

GRANT studente TO prof; --assegno i privilegi di studente a prof

ALTER ROLE direttore WITH CREATEDB; -- aggiungo a direttore il privilegio di creare nuovi database
ALTER ROLE capoufficio WITH CREATEDB; -- aggiungo a prof il privilegio di creare nuovi database
*/
------------------------------------------------------------------------
------------------------------------------------------------------------

/*CREATE USER alice;
GRANT studente TO alice;
--
CREATE USER bianca;
GRANT studente TO bianca;
--
CREATE USER carlo;
GRANT studente TO carlo;

CREATE USER marta;
GRANT impiegato TO marta;
--
CREATE USER luca;
GRANT capoufficio TO luca;
--
CREATE USER nino;
GRANT direttore TO nino WITH ADMIN OPTION; 

CREATE USER donatella;
CREATE USER elena;
CREATE USER fabio; 
CREATE USER olga;*/

SET ROLE nino;	
  GRANT prof TO donatella,elena,fabio; --nino ora delega (se possibile) il ruolo prof a donatella, elena, fabio.
  GRANT nino TO olga; /* nino delaga tutti i suoi ruoli a olga.*/ 
RESET ROLE;

/*PUNTO 4: ASSEGNAZIONE PRIVILEGI AI RUOLI*/
 --CREATE ROLE admin LOGIN
  --SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;
  
SET ROLE admin;

--admin assegna privilegi a capoufficio
GRANT insert, delete, update, select ON TABLE Personale TO capoufficio WITH GRANT OPTION;

--admin assegna privilegi a direttore
GRANT insert, update, select, delete ON TABLE Corso TO direttore WITH GRANT OPTION;

--admin assegna privilegi a studente, impiegato, prof
GRANT select ON TABLE Studente, Corso, Esame  TO studente;
GRANT select ON TABLE Personale TO impiegato;
GRANT select ON TABLE Studente, Corso, Esame, Personale TO prof;

--admin assegna privilegio a impiegati
CREATE OR REPLACE FUNCTION aggiornamento_media()
RETURNS VOID AS
$$
declare
m DECIMAL;
stud INTEGER;
valCr CURSOR FOR SELECT studente, avg(voto) 
		FROM Esame join Studente on studente = matricola
		   join Corso on esame.corso = corso.codice
	group by Esame.studente;	
BEGIN
open valCr;
FETCH valCr INTO stud, m;
WHILE FOUND LOOP
	BEGIN 
	   UPDATE Studente
	   Set media = m
	   WHERE Studente.matricola = stud;
	   FETCH valCr INTO stud, m;
	END;
END LOOP;
close valCr;
END$$
LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION aggiornamento_media() TO impiegato;

--admin assegna privilegi a tutti
CREATE OR REPLACE FUNCTION interroga_esame(id_corso INTEGER)
RETURNS TABLE(iscrizioni BIGINT,
	      voto_medio DECIMAL)
AS $$
BEGIN
    RETURN QUERY SELECT COUNT(distinct studente), AVG(voto)FROM Esame
		WHERE corso = id_corso;
END$$
LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION interroga_esame() TO impiegato, direttore, capoufficio, prof, studente;

--imposto ruolo nino 
SET ROLE nino;
--fallisce per non violare vincolo di chiave
--GRANT insert(corso,studente), delete(corso,studente) ON TABLE Esame TO studente;

--nino assegna privilegi a prof
GRANT insert, update ON TABLE Esame TO prof;

--set olga, che assegna privilegi a studenti
SET ROLE olga;
GRANT update(indirizzo) ON TABLE Studente TO studente;

RESET ROLE;

/*PUNTO 4: ASSEGNAZIONE PRIVILEGI BASATI SUL CONTENUTO*/
--a
/*CREATE OR REPLACE FUNCTION filtro_stipendio() 
RETURNS TABLE(id INTEGER,
	      nome VARCHAR,
	      stipendio DECIMAL)
AS
$$
BEGIN
   RETURN QUERY SELECT *
   FROM Personale
   WHERE Personale.stipendio < 1800;
END   
$$
LANGUAGE plpgsql;*/

GRANT EXECUTE ON FUNCTION filtro_stipendio() TO impiegato;

--b
/*CREATE OR REPLACE FUNCTION filtro_esami()
RETURNS TABLE(id_corso INTEGER,
	      matricola INTEGER,
	      data DATE, 
	      voto INTEGER)
AS
$$
BEGIN
   RETURN QUERY SELECT *
   FROM Esame
   WHERE Esame.voto IS NULL OR Esame.voto >= 18;
END
$$
LANGUAGE plpgsql;*/

GRANT EXECUTE ON FUNCTION filtro_esami() TO studente;

--c
/*CREATE OR REPLACE FUNCTION filtro_voto()
RETURNS TABLE(matr INTEGER,
	      nome VARCHAR,
	      indirizzo VARCHAR,
	      media DECIMAL)
AS
$$
BEGIN
RETURN QUERY SELECT *
   FROM Studente
   WHERE Studente.media >= 18;
END
$$
LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION filtro_voto() TO studente;

--d
ALTER TABLE Studente ENABLE ROW LEVEL SECURITY;
CREATE POLICY account_studenti ON Studente to studente USING(nome = current_user);

ALTER TABLE Personale ENABLE ROW LEVEL SECURITY;
CREATE POLICY account_personale ON Personale to impiegato USING(nome = current_user);

ALTER TABLE Esame ENABLE ROW LEVEL SECURITY;
CREATE POLICY corso_prof ON Esame to prof USING(corso = (SELECT codice FROM Corso,Personale WHERE Personale.id = Corso.prof AND Personale.nome = current_user));

/*PUNTO 5: REVOCA DEI PRIVILEGI*/
REVOKE direttore
FROM nino
RESTRICT;

REVOKE direttore
FROM nino
CASCADE;

REVOKE ALL
ON Corso
FROM nino
RESTRICT;

REVOKE ALL
ON Corso
FROM nino
CASCADE;
