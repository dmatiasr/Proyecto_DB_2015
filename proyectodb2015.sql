DROP TABLE IF EXISTS jugador;
CREATE TABLE jugador(
	id int,
	nick VARCHAR(20),
	email VARCHAR(20),
	nombreAPellido VARCHAR(30),
	fechaNac DATE,
	edad int, /* calculado */
	CONSTRAINT jugador_pk PRIMARY KEY (id)
	);

INSERT INTO jugador (id,nick,email,nombreAPellido,fechaNac,edad) VALUES
(1,'plomero','plomero@gmail.com','Raul Perez','1986-05-05',28),
(2,'elmaury','maury@gmail.com','Mauricio Delle','1993-03-03',22);


DROP TABLE IF EXISTS partida;
CREATE TABLE partida(
	idpartida INT PRIMARY KEY,
	resultado ENUM("Ganador","Empate","Perdedor"),
	estado bool,
	fecha  DATE,
	fila INT,
	columna INT,
	horaInicio VARCHAR (10),
	horaFin VARCHAR (10),
	id1 int,
	id2 int,
	CONSTRAINT fk_id1 FOREIGN KEY (id1) REFERENCES  jugador(id) ON DELETE SET NULL,
	CONSTRAINT fk_id2	FOREIGN KEY (id2) REFERENCES jugador(id) ON DELETE SET NULL,
	UNIQUE u_jugador1(id1,fecha,horaInicio,horaFin), /*Para evitar solapamiento de fecha,dia y hora de un jugador*/
	UNIQUE u_jugador2(id2,fecha,horaInicio,horaFin)

	);
INSERT INTO partida(idpartida,resultado,estado,fecha,fila,columna,horaInicio,horaFin,id1,id2) VALUES
(3,'Empate',true,'2015-02-02',8,8,'15:00','16:00',1,2);


DROP TABLE IF EXISTS celda;
CREATE TABLE celda(
	filx INT,  /* fila x*/
	coly INT, /* columna y*/
	PRIMARY KEY (filx,coly),
	CONSTRAINT check_x CHECK (filx<=partida.fila AND 0<=filx),
	CONSTRAINT check_y CHECK (coly<=partida.columna AND 0<=coly)
);

INSERT INTO celda (filx,coly) VALUES
(1,2),
(9,9);

DROP TABLE IF EXISTS tiene;
CREATE TABLE tiene(
	num_mov INT PRIMARY KEY, /*numero de movimientos */ 
	idpartida INT, 
	idx INT,
	idy INT,
	CONSTRAINT fk_id_partida FOREIGN KEY (idpartida) REFERENCES partida (idpartida) ON DELETE CASCADE,
	CONSTRAINT fk_idx FOREIGN KEY (idx, idy) REFERENCES celda (filx, coly) ON DELETE CASCADE
);

INSERT INTO tiene (num_mov,idpartida,idx,idy) VALUES
(1,3,1,2),
(2,3,9,9);

DROP TABLE IF EXISTS eliminados;
CREATE TABLE eliminados(
	id int PRIMARY KEY,
	fechaElim datetime,
	idElim VARCHAR(10)
);



/*TRIGGER que genera la tabla de Auditoria de usuarios Eliminados*/


delimiter $$
DROP TRIGGER IF EXISTS borrar_datos;
CREATE TRIGGER borrar_datos BEFORE DELETE on jugador 
FOR EACH ROW
BEGIN
	DELETE from partida where (partida.id1 IS NULL) and (partida.id2 IS NULL);
	INSERT INTO eliminados (id,fechaElim,idElim) VALUES (Old.id,SYSDATE(),CURRENT_USER());
END$$
delimiter ;


/*

delimiter $$
DROP TRIGGER IF EXISTS chequea_celda;
CREATE TRIGGER control_partida AFTER INSERT ON celda;  
FOR EACH ROW
BEGIN 
	IF (partida.fila >= filx) AND (partida.columna >= coly)
	THEN
	INSERT INTO celda (filx,coly) VALUES 
END$$
delimiter ;
*/