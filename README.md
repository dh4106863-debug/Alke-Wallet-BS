<img width="1366" height="676" alt="image" src="https://github.com/user-attachments/assets/80a8d9d4-df3d-40d6-9c05-461f1a653763" />RESUMEN # Alke-Wallet-BS
<img width="694" height="475" alt="image" src="https://github.com/user-attachments/assets/6a995855-d906-44ef-8c5e-28dae1e95f82" />
CÓDIGO SQL COMPLETO
--Crear la base de datos
CREATE DATABASE IF NOT EXISTS AlkeWallet;
<img width="1365" height="657" alt="image" src="https://github.com/user-attachments/assets/29fb5922-5052-4c39-96e7-3b71f562d387" />

USE AlkeWallet; 

--Eliminar previa para reseteo limpio (respetando orden de FK)
DROP TABLE IF EXISTS transaccion;
DROP TABLE IF EXISTS moneda;
DROP TABLE IF EXISTS usuario;


--Crear la tabla de Usuarios
CREATE TABLE IF NOT EXISTS Usuario (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    saldo DECIMAL(12, 2) DEFAULT 0.00,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

--Crear la tabla de Monedas
CREATE TABLE IF NOT EXISTS Moneda (
    currency_id INT AUTO_INCREMENT PRIMARY KEY,
    currency_name VARCHAR(50) NOT NULL,
    currency_symbol VARCHAR(10) NOT NULL
);
<img width="1366" height="676" alt="image" src="https://github.com/user-attachments/assets/eee0673e-1730-4e76-b894-ba3aa5928b35" />

--Crear la tabla de Transacciones
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

--Indices para optimizar búsquedas
CREATE INDEX idx_transaccion_sender_date ON Transaccion(sender_user_id, transaction_date);
CREATE INDEX idx_transaccion_receiver_date ON Transaccion(receiver_user_id, transaction_date);

--Comprobar las tablas creadas
SHOW DATABASES;
SHOW TABLES;
DESCRIBE Usuario;
DESCRIBE Moneda;
DESCRIBE Transaccion;

--INSERTAR DE DATOS DE PRUEBA 
INSERT INTO Moneda (currency_name, currency_symbol) VALUES 
('Peso Chileno', 'CLP'),
('Dolar Estadounidense', 'USD'),
('Euro', 'EUR');

INSERT INTO Usuario (nombre, correo, contrasena, saldo) VALUES 
('Dayana Seguel', 'dayana.seguel@gmail.com', 'days123', 10000.00),
('Krishna Hernandez', 'krishna.hernandez@gmail.com', 'kris235', 20000.00),
('Carlos López', 'carlos.lopez@email.com', 'pass789', 2300.00),
('Ana Martínez', 'ana.martinez@email.com', 'passabc', 50.00),
('Pedro Soto', 'pedro.soto@email.com', 'passxyz', 5000.00);

INSERT INTO Transaccion (sender_user_id, receiver_user_id, currency_id, importe, transaction_date) VALUES 
(1, 2, 1, 1000.00, '2026-03-10 10:30:00'),
(2, 3, 1, 500.00, '2026-03-11 14:15:00'),
(3, 4, 1, 100.00, '2026-03-12 09:00:00'),
(5, 1, 1, 2000.00, '2026-03-13 18:45:00'),
(1, 4, 1, 50.00, '2026-03-14 11:20:00');

--Comprobar datos ingresados
SELECT * FROM Usuario;
SELECT * FROM Transaccion;

--MANIPULACIÓN DE DATOS Y TRANSACCIONES

--Ejemplo 1: Transferencia exitosa entre usuarios con actualización de saldo
START TRANSACTION;

UPDATE Usuario SET saldo = saldo - 1000.00 WHERE user_id = 1;
UPDATE Usuario SET saldo = saldo + 1000.00 WHERE user_id = 2;

INSERT INTO Transaccion (sender_user_id, receiver_user_id, currency_id, importe) 
VALUES (1, 2, 1, 1000.00);

COMMIT;

--Ejemplo 2: Simulación de error de integridad referencial y ROLLBACK
START TRANSACTION;

--Intento de transferencia a un usuario inexistente (user_id = 9999)
--(Si se ejecuta en un entorno real, la FK fallará y se debe revertir)
INSERT INTO Transaccion (sender_user_id, receiver_user_id, currency_id, importe) 
VALUES (1, 9999, 1, 500.00); 

ROLLBACK; 

--Sentencia DML para modificar el campo correo de un usuario específico
UPDATE Usuario 
SET correo = 'dayana.seguel.nueva@gmail.com' 
WHERE user_id = 1;

--Sentencia DML para eliminar una transacción específica
DELETE FROM Transaccion 
WHERE transaction_id = 1;

--Consulta básica sobre la tabla Usuario
SELECT user_id, nombre, correo, saldo FROM Usuario;

--Filtros dinámicos con WHERE y operadores lógicos
SELECT * FROM Usuario 
WHERE saldo > 500.00 AND correo LIKE '%@gmail.com';

--Monedas utilizadas por un usuario específico (ej: user_id = 1)
SELECT DISTINCT m.currency_name, m.currency_symbol 
FROM Moneda m
JOIN Transaccion t ON m.currency_id = t.currency_id
WHERE t.sender_user_id = 1 OR t.receiver_user_id = 1;

--Obtener todas las transacciones realizadas por un usuario específico
SELECT * FROM Transaccion 
WHERE sender_user_id = 1 OR receiver_user_id = 1;

--Unir las tablas Transaccion y Usuario mediante INNER JOIN
SELECT 
    t.transaction_id,
    u_sender.nombre AS emisor,
    u_receiver.nombre AS receptor,
    t.importe,
    t.transaction_date
FROM Transaccion t
INNER JOIN Usuario u_sender ON t.sender_user_id = u_sender.user_id
INNER JOIN Usuario u_receiver ON t.receiver_user_id = u_receiver.user_id;

--Subconsulta para obtener el total de transacciones por usuario
SELECT 
    u.user_id,
    u.nombre,
    (SELECT COUNT(*) 
     FROM Transaccion t 
     WHERE t.sender_user_id = u.user_id OR t.receiver_user_id = u.user_id) AS total_transacciones
FROM Usuario u;

--Vista con el top-5 de usuarios con mayor saldo
CREATE OR REPLACE VIEW top_5_usuarios_saldo AS
SELECT user_id, nombre, correo, saldo
FROM Usuario
ORDER BY saldo DESC
LIMIT 5;

--Consultar a la vista
SELECT * FROM top_5_usuarios_saldo;
