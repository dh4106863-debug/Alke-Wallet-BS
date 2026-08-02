--Creacion de la base de datos
CREATE DATABASE IF NOT EXISTS AlkeWallet;
USE AlkeWallet;
SHOW DATABASES;
SHOW TABLES;

DESCRIBE usuario;
DESCRIBE moneda;
DESCRIBE transaccion;

--Eliminación previa para reseteo limpio
DROP TABLE IF EXISTS transaccion;
DROP TABLE IF EXISTS moneda;
DROP TABLE IF EXISTS usuario;


--Creacion de la tabla de Usuarios
CREATE TABLE IF NOT EXISTS Usuario (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo electronico VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    saldo DECIMAL(12, 2) DEFAULT 0.00,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--Creacion de la tabla de Monedas
CREATE TABLE IF NOT EXISTS Moneda (
    currency_id INT AUTO_INCREMENT PRIMARY KEY,
    currency_name VARCHAR(50) NOT NULL,
    currency_symbol VARCHAR(10) NOT NULL
);

--Creacion de la tabla de Transacciones
CREATE TABLE IF NOT EXISTS Transaccion (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_user_id INT NOT NULL,
    receiver_user_id INT NOT NULL,
    importe DECIMAL(12, 2) NOT NULL,
    currency_id INT NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (sender_user_id) REFERENCES Usuario(user_id),
    FOREIGN KEY (receiver_user_id) REFERENCES Usuario(user_id),
    FOREIGN KEY (currency_id) REFERENCES Moneda(currency_id)
);

--Indices compuestos para optimizar búsquedas por usuario y fecha
CREATE INDEX idx_transaccion_sender_date ON transaccion(sender_user_id, transaction_date);
CREATE INDEX idx_transaccion_receiver_date ON transaccion(receiver_user_id, transaction_date);

--Insertar datos de prueba
INSERT INTO Moneda (currency_name, currency_symbol) VALUES 
('Peso Chileno', 'CLP'),
('Dolar Estadounidense', 'USD'),
('Euro', 'EUR');

INSERT INTO Usuario (nombre, correo, contrasena, saldo) VALUES 
('Dayana Seguel', 'dayana.seguel@gmail.com', 'days123', 10000.00),
('Krishna Hernandez', 'krishna.hernandez@gmail.com', 'kris235', 20000.00);
('Carlos López', 'carlos.lopez@email.com', 'pass789', 2300.00),
('Ana Martínez', 'ana.martinez@email.com', 'passabc', 50.00),
('Pedro Soto', 'pedro.soto@email.com', 'passxyz', 5000.00);

INSERT INTO transaccion (sender_user_id, receiver_user_id, currency_id, importe, transaction_date) VALUES 
(1, 2, 1, 1000.00, '2026-03-10 10:30:00'),
(2, 3, 1, 500.00, '2026-03-11 14:15:00'),
(3, 4, 1, 100.00, '2026-03-12 09:00:00'),
(5, 1, 1, 2000.00, '2026-03-13 18:45:00'),
(1, 4, 1, 50.00, '2026-03-14 11:20:00');

SELECT * FROM Usuarios;
SELECT * FROM Transaccion;

--Transferencia de 1000.00 desde Dayana (user_id = 1) a Krishna (user_id = 2)
START TRANSACTION;

UPDATE Usuario SET saldo = saldo - 1000.00 WHERE user_id = 1;
UPDATE Usuario SET saldo = saldo + 1000.00 WHERE user_id = 2;

INSERT INTO Transaccion (sender_user_id, receiver_user_id, currency_id, importe) 
VALUES (1, 2, 1, 1000.00);

COMMIT;

--Ejemplo 2: Simulación de error de integridad referencial y ROLLBACK
--Intento de transferencia a un usuario inexistente (user_id = 9999)
START TRANSACTION;

INSERT INTO Transaccion (sender_user_id, receiver_user_id, currency_id, importe) 
VALUES (1, 9999, 1, 500.00); 

--Si ocurre un error o falla la FK, se ejecutan las siguientes líneas:
ROLLBACK;


--Consulta para obtener el nombre de la moneda elegida por un usuario específico (ej: user_id = 1)
SELECT DISTINCT m.currency_name, m.currency_symbol 
FROM Moneda m
JOIN transaccion t ON m.currency_id = t.currency_id
WHERE t.sender_user_id = 1 OR t.receiver_user_id = 1;

--Consulta para obtener todas las transacciones registradas
SELECT * FROM transaccion;

--Consulta para obtener todas las transacciones realizadas por un usuario específico (ej: user_id = 1)
SELECT * FROM transaccion 
WHERE sender_user_id = 1 OR receiver_user_id = 1;

--Sentencia DML para modificar el campo correo de un usuario específico
UPDATE Usuario 
SET correo = 'dayana.seguel.nueva@gmail.com' 
WHERE user_id = 1;

--Sentencia para eliminar los datos de una transacción específica (ej: transaction_id = 1)
DELETE FROM transaccion 
WHERE transaction_id = 1;


--SELECT básica sobre la tabla usuario
SELECT user_id, nombre, correo_electronico, saldo FROM usuario;

--Filtros dinámicos con WHERE y operadores lógicos
SELECT * FROM usuario 
WHERE saldo > 500.00 AND correo_electronico LIKE '%@email.com';

--Unir las tablas transaccion y usuario mediante INNER JOIN
SELECT 
    t.transaction_id,
    u_sender.nombre AS emisor,
    u_receiver.nombre AS receptor,
    t.importe,
    t.transaction_date
FROM transaccion t
INNER JOIN usuario u_sender ON t.sender_user_id = u_sender.user_id
INNER JOIN usuario u_receiver ON t.receiver_user_id = u_receiver.user_id;

--Sub-consulta para obtener el total de transacciones por usuario
SELECT 
    u.user_id,
    u.nombre,
    (SELECT COUNT(*) 
     FROM transaccion t 
     WHERE t.sender_user_id = u.user_id OR t.receiver_user_id = u.user_id) AS total_transacciones
FROM usuario u;

--Tarea Plus (Lección 2): Crear una vista que muestre el top-5 de usuarios con mayor saldo
CREATE VIEW top_5_usuarios_saldo AS
SELECT user_id, nombre, correo_electronico, saldo
FROM usuario
ORDER BY saldo DESC
LIMIT 5;

--Consulta a la vista creada
SELECT * FROM top_5_usuarios_saldo;

