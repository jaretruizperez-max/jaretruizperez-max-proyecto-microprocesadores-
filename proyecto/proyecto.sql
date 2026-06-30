CREATE DATABASE VeterinariaDB;
GO




USE VeterinariaDB;
GO
select*from usuarios
select * from duenos
SELECT * FROM Mascotas
SELECT * FROM Consultas
SELECT * FROM Tratamientos
SELECT * FROM Facturas
SELECT * FROM Veterinarios


CREATE TABLE Usuarios (
    usuario_id INT PRIMARY KEY,
    correo NVARCHAR(100) UNIQUE,
    contrasena VARBINARY(MAX),
    tipo  NVARCHAR(20), 
    estado NVARCHAR(20)
);

OPEN SYMMETRIC KEY ClaveSimetricaVet
DECRYPTION BY CERTIFICATE CertificadoVeterinaria;

INSERT INTO Usuarios VALUES 
(1,
'admin@test.com',
EncryptByKey(Key_GUID('ClaveSimetricaVet'),'123456'),
'Admin','Activo'),

(2,
'doc@test.com',
EncryptByKey(Key_GUID('ClaveSimetricaVet'),'123456'),
'Doctor','Activo'),

(3,
'recep@test.com',
EncryptByKey(Key_GUID('ClaveSimetricaVet'),'123456'),
'Recepcionista','Activo'),

(4,
'cliente@test.com',
EncryptByKey(Key_GUID('ClaveSimetricaVet'),'123456'),
'Cliente','Activo');

CLOSE SYMMETRIC KEY ClaveSimetricaVet;

--datos

OPEN SYMMETRIC KEY ClaveSimetricaVet
DECRYPTION BY CERTIFICATE CertificadoVeterinaria;
-- Insertar Dueños (Usuarios 3 y 4 según tu script anterior)
INSERT INTO Duenos (dueno_id, usuario_id, nombre_completo, telefono, direccion, numero_documento, fecha_registro)
VALUES 
(201, 3, 'JUAN PÉREZ', '+52 5512345678', 'CDMX, Col. Roma', EncryptByKey(Key_GUID('ClaveSimetricaVet'), 'DOC12345'), '2023-01-15'),
(202, 4, 'MARÍA GARCÍA', '+52 5587654321', 'CDMX, Polanco', EncryptByKey(Key_GUID('ClaveSimetricaVet'), 'DOC67890'), '2023-02-20');

-- Insertar Veterinarios (Usuario 2)
INSERT INTO Veterinarios (veterinario_id, usuario_id, nombre_completo, especialidad, cedula_profesional)
VALUES 
(301, 2, 'ALEJANDRO GÓMEZ', 'General / Cirugía', EncryptByKey(Key_GUID('ClaveSimetricaVet'), 'CED-998877'));

-- Insertar Recepcionistas
INSERT INTO Recepcionistas (recepcionista_id, usuario_id, nombre)
VALUES 
(401, 3, 'LAURA MARTÍNEZ');

INSERT INTO Mascotas (mascota_id, nombre, especie, raza, edad, peso, dueno_id)
VALUES 
(101, 'MAX', 'Canino', 'Golden Retriever', 3, 28.50, 201),  -- Mascota de Juan
(102, 'LUNA', 'Felino', 'Siamés', 2, 4.20, 201),           -- Segunda mascota de Juan
(103, 'ROCKY', 'Canino', 'Bulldog Francés', 4, 12.10, 202),-- Mascota de María
(104, 'COCO', 'Ave', 'Loro', 1, 0.85, 202);               -- Segunda mascota de María

-- Una consulta pendiente para hoy
INSERT INTO Consultas (consulta_id, mascota_id, veterinario_id, fecha_consulta, motivo, estado, creado_por)
VALUES 
(501, 101, 301, GETDATE(), 'Chequeo Semestral', 'Pendiente', 3);

-- Una consulta ya finalizada con su tratamiento cifrado
INSERT INTO Consultas (consulta_id, mascota_id, veterinario_id, fecha_consulta, motivo, estado, creado_por)
VALUES 
(500, 103, 301, '2023-10-25', 'Infección de oído', 'Atendida', 3);

INSERT INTO Tratamientos (tratamiento_id, consulta_id, diagnostico, tratamiento, observaciones)
VALUES 
(601, 500, 
 EncryptByKey(Key_GUID('ClaveSimetricaVet'), 'Otitis Externa Ligera'), 
 EncryptByKey(Key_GUID('ClaveSimetricaVet'), 'Limpieza y Gotas (OtoVet) cada 12h'), 
 EncryptByKey(Key_GUID('ClaveSimetricaVet'), 'Regresar en 7 días'));

 INSERT INTO Facturas (factura_id, consulta_id, fecha, total)
VALUES 
(701, 500, '2023-10-25', 500.00);

CLOSE SYMMETRIC KEY ClaveSimetricaVet;


CREATE TABLE Duenos (
    dueno_id INT PRIMARY KEY,
    usuario_id INT,
    nombre_completo NVARCHAR(100),
    telefono NVARCHAR(20),
    direccion NVARCHAR(150),
    numero_documento VARBINARY(MAX), 
    fecha_registro DATE,

    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id)
);

CREATE TABLE Veterinarios (
    veterinario_id INT PRIMARY KEY,
    usuario_id INT,
    nombre_completo NVARCHAR(100),
    especialidad NVARCHAR(50),
    cedula_profesional VARBINARY(MAX), 

    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id)
);

CREATE TABLE Recepcionistas (
    recepcionista_id INT PRIMARY KEY,
    usuario_id INT,
    nombre NVARCHAR(100),

    FOREIGN KEY (usuario_id) REFERENCES Usuarios(usuario_id)
);

CREATE TABLE Mascotas (
    mascota_id INT PRIMARY KEY,
    nombre NVARCHAR(50),
    especie NVARCHAR(50),
    raza NVARCHAR(50),
    edad INT,
    peso DECIMAL(5,2),
    dueno_id INT,

    FOREIGN KEY (dueno_id) REFERENCES Duenos(dueno_id)
);

CREATE TABLE Consultas (
    consulta_id INT PRIMARY KEY,
    mascota_id INT,
    veterinario_id INT,
    fecha_consulta DATETIME,
    motivo NVARCHAR(150),
    estado NVARCHAR(20), 
    creado_por INT, 

    FOREIGN KEY (mascota_id) REFERENCES Mascotas(mascota_id),
    FOREIGN KEY (veterinario_id) REFERENCES Veterinarios(veterinario_id),
    FOREIGN KEY (creado_por) REFERENCES Usuarios(usuario_id)
);

CREATE TABLE Tratamientos (
    tratamiento_id INT PRIMARY KEY,
    consulta_id INT,
    diagnostico VARBINARY(MAX),
    tratamiento VARBINARY(MAX), 
    observaciones VARBINARY(MAX),

    FOREIGN KEY (consulta_id) REFERENCES Consultas(consulta_id)
);

CREATE TABLE Facturas (
    factura_id INT PRIMARY KEY,
    consulta_id INT,
    fecha DATE,
    total DECIMAL(10,2),

    FOREIGN KEY (consulta_id) REFERENCES Consultas(consulta_id)
);

select * from Auditoria_Consultas
select * from Auditoria_Tratamientos
select * from Auditoria_Facturas
CREATE TABLE Auditoria_Consultas (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    consulta_id INT,
    accion NVARCHAR(20),
    fecha DATETIME,
    usuario NVARCHAR(100),
    datos NVARCHAR(MAX)
);


CREATE TABLE Auditoria_Tratamientos (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    tratamiento_id INT,
    accion NVARCHAR(20),
    fecha DATETIME,
    usuario NVARCHAR(100),
    datos NVARCHAR(MAX)
);

CREATE TABLE Auditoria_Facturas (
    audit_id INT IDENTITY(1,1) PRIMARY KEY,
    factura_id INT,
    accion NVARCHAR(20),
    fecha DATETIME,
    usuario NVARCHAR(100),
    datos NVARCHAR(MAX)
);

CREATE TRIGGER AuditoriaConsultas
ON Consultas
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO Auditoria_Consultas
    SELECT 
        ISNULL(i.consulta_id, d.consulta_id),
        CASE 
            WHEN i.consulta_id IS NOT NULL AND d.consulta_id IS NULL THEN 'INSERT'
            WHEN i.consulta_id IS NOT NULL AND d.consulta_id IS NOT NULL THEN 'UPDATE'
            WHEN i.consulta_id IS NULL THEN 'DELETE'
        END,
        GETDATE(),
        SYSTEM_USER,
        'Cambio en consulta'
    FROM inserted i
    FULL JOIN deleted d ON i.consulta_id = d.consulta_id;
END;


CREATE TRIGGER EstadoConsulta
ON Tratamientos
AFTER INSERT
AS
BEGIN
    UPDATE c
    SET estado = 'Atendida'
    FROM Consultas c
    JOIN inserted i ON c.consulta_id = i.consulta_id;
END;

CREATE SEQUENCE seq_factura
START WITH 1
INCREMENT BY 1;

INSERT INTO Facturas (factura_id, consulta_id, fecha, total)
VALUES (NEXT VALUE FOR seq_factura, 1, GETDATE(), 500);


BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO Consultas VALUES (1,1,1,GETDATE(),'Chequeo','Pendiente',1);

    INSERT INTO Tratamientos VALUES (1,1,
    EncryptByKey(Key_GUID('ClaveSimetricaVet'),'Diagnostico'),
    EncryptByKey(Key_GUID('ClaveSimetricaVet'),'Tratamiento'),
    EncryptByKey(Key_GUID('ClaveSimetricaVet'),'Observaciones'));

    INSERT INTO Facturas VALUES (NEXT VALUE FOR seq_factura,1,GETDATE(),500);

    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;

    PRINT 'Error en la transacción';
END CATCH;


--PROCEDIMIENTO (REGISTRAR DUEÑO)_
CREATE PROCEDURE sp_InsertarDueno
@id INT,
@nombre NVARCHAR(100),
@correo NVARCHAR(100),
@telefono NVARCHAR(20),
@doc VARCHAR(20)
AS
BEGIN

OPEN SYMMETRIC KEY ClaveSimetricaVet
DECRYPTION BY CERTIFICATE CertificadoVeterinaria;

INSERT INTO Duenos VALUES(
@id,
NULL,
@nombre,
@telefono,
'CDMX',
EncryptByKey(Key_GUID('ClaveSimetricaVet'),@doc),
GETDATE()
);

CLOSE SYMMETRIC KEY ClaveSimetricaVet;

END;

--CONSULTA PIVOT
SELECT *
FROM (
    SELECT MONTH(fecha_consulta) AS Mes, consulta_id
    FROM Consultas
) AS SourceTable
PIVOT (
    COUNT(consulta_id)
    FOR Mes IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12])
) AS PivotTable;

--clientes frecuentes 
SELECT 
dueno_id,
COUNT(*) AS total_consultas,
CASE 
    WHEN COUNT(*) >= 5 THEN 'Frecuente'
    ELSE 'Normal'
END AS tipo_cliente
FROM Mascotas m
JOIN Consultas c ON m.mascota_id = c.mascota_id
GROUP BY dueno_id;

--rank veterinarios 

SELECT 
v.nombre_completo,
COUNT(*) AS total_consultas,
RANK() OVER (ORDER BY COUNT(*) DESC) AS ranking
FROM Veterinarios v
JOIN Consultas c ON v.veterinario_id = c.veterinario_id
GROUP BY v.nombre_completo;

--indices

CREATE INDEX idx_email ON Usuarios(correo);

CREATE INDEX idx_fecha ON Consultas(fecha_consulta);

CREATE INDEX idx_estado ON Consultas(estado);

--tabla de errores 

CREATE TABLE Errores (
    error_id INT IDENTITY(1,1),
    mensaje NVARCHAR(200),
    fecha DATETIME
);



CREATE MASTER KEY
ENCRYPTION BY PASSWORD = 'VETLIFES15.';
GO

CREATE CERTIFICATE CertificadoVeterinaria
WITH SUBJECT = 'Cifrado veterinaria';
GO

CREATE SYMMETRIC KEY ClaveSimetricaVet
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CertificadoVeterinaria;
GO