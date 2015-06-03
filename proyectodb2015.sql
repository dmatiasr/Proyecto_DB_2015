/*	Proyecto BASE DE DATOS 2015 : 
	INTEGRANTES : Delle Vedove Mauricio,
				  Roig Francisco,
				  Rondeau Matias

	Modela la Base de datos del Juego
	"Cuatro En Linea"

	CAMBIOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO !!!

 */

DROP TABLE IF EXISTS tiene;
DROP TABLE IF EXISTS celda;
DROP TABLE IF EXISTS auditoria_Eliminados;
DROP TABLE IF EXISTS partida;
DROP TABLE IF EXISTS jugador;
DROP TRIGGER IF EXISTS chequeo_solapamiento;
DROP TRIGGER IF EXISTS eliminar_jugador;
DROP TRIGGER IF EXISTS cheq_tamceld;

/*Tabla de jugadores*/
CREATE TABLE jugador(
	id int NOT NULL AUTO_INCREMENT,
	nick VARCHAR(20),
	email VARCHAR(20),
	nombreAPellido VARCHAR(30),
	fechaNac DATE,
	edad int, /* calculado */
	UNIQUE (nick,email),
	CONSTRAINT jugador_pk PRIMARY KEY (id)
)ENGINE=InnoDB;


CREATE TABLE partida(
	idpartida INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
	resultado ENUM("Ganador","Empate","Perdedor"),
	estado bool,
	fecha  DATE,
	fila INT,
	columna INT,
	horaInicio VARCHAR (10),
	horaFin VARCHAR (10),
	id1 int,
	id2 int,
	CONSTRAINT fk_id1 FOREIGN KEY (id1) REFERENCES  jugador(id) ON DELETE CASCADE, /**/
	CONSTRAINT fk_id2	FOREIGN KEY (id2) REFERENCES jugador(id) ON DELETE CASCADE
)ENGINE=InnoDB;


CREATE TABLE celda(
	filx INT,
	coly INT,
	PRIMARY KEY (filx,coly)
)ENGINE=InnoDB;


CREATE TABLE tiene(
	numMov INT NOT NULL PRIMARY KEY  , /*numero de movimientos */ 
	idpartida INT, 
	idx INT,
	idy INT,
	CONSTRAINT fk_id_partida FOREIGN KEY (idpartida) REFERENCES partida (idpartida) ON DELETE CASCADE,
	CONSTRAINT fk_idx FOREIGN KEY (idx, idy) REFERENCES celda (filx, coly) ON DELETE CASCADE
)ENGINE=InnoDB;


/*Tabla de jugadores eliminados*/
CREATE TABLE auditoria_Eliminados(
	id_jugador_eliminado int PRIMARY KEY,
	nickElim VARCHAR(20), 
	fechaElim datetime,
	eliminadoPor VARCHAR(50) /*Quien elimino el jugador*/
)ENGINE=InnoDB;


/*TRIGGER que genera la tabla de Auditoria de jugadores Eliminados*/
delimiter $$

CREATE TRIGGER eliminar_jugador BEFORE DELETE on jugador 
FOR EACH ROW
BEGIN
	INSERT INTO auditoria_Eliminados (id_jugador_eliminado,nickElim,fechaElim,eliminadoPor) VALUES (Old.id,Old.nick,SYSDATE(),CURRENT_USER());
END$$
delimiter ;



/*TRIGGER que controla que no se solapen las partidas*/
delimiter $$
CREATE TRIGGER chequeo_solapamiento BEFORE INSERT ON partida
FOR EACH ROW
BEGIN 
	IF EXISTS ( SELECT fecha,horaInicio,horaFin,id1,id2 FROM partida 
		WHERE fecha=NEW.fecha AND (estado=false) AND ( (new.id1=id1 or new.id1=id2 ) 
		OR (new.id2=id1 or new.id2=id2) ) /*Para igual fecha, ver las horas disponibles que tiene para jugar*/
		AND (horaInicio<=NEW.horaInicio AND NEW.horaInicio<=horaFin  /*primer caso que la hora nueva este dentro de las hs q ya tiene*/
		AND NEW.horaFin>=horaInicio AND NEW.horaFin<=horaFin) 
		OR (NEW.horaInicio<horaInicio AND NEW.horaFin<horaFin AND NEW.horaFin>=horaInicio ) /*2:Q la hora inicio menor pero la mayor dentro */
		OR (NEW.horaFin>horaFin AND  NEW.horaInicio>horaInicio AND NEW.horaInicio<horaFin )/*3:q la hora inicio dentro, la mayor fuera*/
		OR (NEW.horaInicio<horaInicio AND NEW.horaFin>horaFin)  ) /*que ambas inicio y fin este fuera newhoraInicio[horaIniciojugadahoraFin] newHoraFin  */
	THEN
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "UD NO PUEDE JUGAR : DEBE FINALIZAR SU PARTIDA ANTERIOR. " ;

	END IF;
END$$
delimiter ;


/*TRIGGER que controla que el movimiento insertado este dentro del tablero*/
delimiter $$
CREATE TRIGGER cheq_tamceld BEFORE INSERT ON tiene 
FOR EACH ROW
BEGIN
	DECLARE f INT;
	DECLARE c INT; 
	SET f =  (SELECT SUM(fila) FROM partida WHERE idpartida=NEW.idpartida); 
	SET c =  (SELECT SUM(columna) FROM partida WHERE idpartida=NEW.idpartida); 
	IF (((NEW.idx>0) AND (NEW.idx<=f)) AND ((NEW.idy>0) AND (NEW.idy<=c))) THEN	
		INSERT INTO celda (filx,coly)VALUES(NEW.idx,NEW.idy);
	ELSE 
		 SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = " POSICION INCORRECTA " ;

	END IF;	
	END$$
delimiter ;


/*Inserta en la tabla jugadores*/
INSERT INTO jugador (id,nick,email,nombreAPellido,fechaNac,edad) VALUES
(1,'Mauri','Mauri@gmail.com','Mauricio Delle Vedove','1986-05-05',28),
(2,'Fran','fran@gmail.com','Francisco Roig','1993-03-03',22),
(3,'Matias','matu_dmr@hotmail.com','Matias Rondeau','1986-09-01',28),
(4,'j1','j1@gmail.com','j1','1993-03-06',21),
(5,'j2','j2@gmail.com','j2','1970-03-04',45);


/*Inserta en la tabla partida*/
INSERT INTO partida(idpartida,resultado,estado,fecha,fila,columna,horaInicio,horaFin,id1,id2) VALUES
(3,'Empate',true,'2015-02-02',8,8,'15:00','16:00',1,2),
(4,'Perder',true,'2015-02-02',8,8,'15:00','16:00',3,4),
(5,'Ganador',true,'2015-02-03',8,7,'14:00','14:15',1,5);


/*Inserta en la tabla tiene*/
INSERT INTO tiene (numMov,idpartida,idx,idy) VALUES
(1,3,1,2);
