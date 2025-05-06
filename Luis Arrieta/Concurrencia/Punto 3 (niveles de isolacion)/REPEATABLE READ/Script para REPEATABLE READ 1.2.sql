-- 3. REPEATABLE READ
-- Caso: Cambios de precio durante suscripciones
-- Tabla: st_plans (usando planPrice a trav�s de st_subcriptions)
-- Problema: Phantom read.
-- Sesion 2

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesi�n 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Insertar una nueva suscripci�n para el planTypeID = 1
INSERT INTO dbo.st_subcriptions (description, logoURL, enabled, planTypeID, userID)
VALUES ('Nueva suscripci�n', 'http://logo.com', 1, 1, 10);

COMMIT TRANSACTION;

PRINT 'Sesi�n 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO