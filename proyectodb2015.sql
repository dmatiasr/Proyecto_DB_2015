

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



DROP TABLE IF EXISTS partida;
CREATE TABLE partida(
	idpartida INT PRIMARY KEY,
	resultado ENUM("Ganador","Empate","Perdedor"),
	estado bool,
	fecha  DATE,
	fila INT,
	columna INT,
	horaFin VARCHAR (10),
	horaInicio VARCHAR (10),
	id1 int,
	id2 int,
	CONSTRAINT fk_id1 FOREIGN KEY (id1) REFERENCES  jugador(id) ON DELETE CASCADE,
	CONSTRAINT fk_id2	FOREIGN KEY (id2) REFERENCES jugador(id) ON DELETE CASCADE,
	UNIQUE u_jugador1(id1,fecha),
	UNIQUE u_jugador2(id2,fecha)
	);


DROP TABLE IF EXISTS celda;
CREATE TABLE celda(
	filx INT,  /* fila x*/
	coly INT, /* columna y*/
	PRIMARY KEY (filx,coly)
);

DROP TABLE IF EXISTS tiene;
CREATE TABLE tiene(
	num_mov INT PRIMARY KEY, /*numero de movimientos */ 
	idpartida INT, 
	idx INT,
	idy INT,
	CONSTRAINT fk_id_partida FOREIGN KEY (idpartida) REFERENCES partida (idpartida),
	CONSTRAINT fk_idx FOREIGN KEY (idx, idy) REFERENCES celda (filx, coly),
	CONSTRAINT check_x CHECK (0 <= idx AND idx <= partida.fila),
	CONSTRAINT check_y CHECK (0 <= idy AND idy <= partida.columna)
);

DROP TABLE IF EXISTS eliminados;
CREATE TABLE eliminados(
	id int PRIMARY KEY,
	fechaElim datetime,
	idElim VARCHAR(10)
	/*CONSTRAINT fk_idElim FOREIGN KEY (idElim) REFERENCES jugador (id) ON DELETE CASCADE*/
);

delimiter $$
DROP TRIGGER IF EXISTS borrar_datos;
CREATE TRIGGER borrar_datos BEFORE DELETE on jugador 
FOR EACH ROW
BEGIN
	DECLARE vID VARCHAR(10);
	SELECT USER() INTO vID;
	INSERT INTO eliminados (id,fechaElim,idElim) VALUES (Old.id,SYSDATE(),CURRENT_USER());
END$$
delimiter ;


