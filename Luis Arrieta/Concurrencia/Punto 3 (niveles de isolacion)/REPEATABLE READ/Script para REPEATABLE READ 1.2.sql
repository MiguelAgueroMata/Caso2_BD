-- 3. REPEATABLE READ
-- Caso: Cambios de precio durante suscripciones
-- Tabla: st_plans (usando planPrice a través de st_subcriptions)
-- Problema: Phantom read.
-- Sesion 2

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Insertar una nueva suscripción para el planTypeID = 1
INSERT INTO dbo.st_subcriptions (description, logoURL, enabled, planTypeID, userID)
VALUES ('Nueva suscripción', 'http://logo.com', 1, 1, 10);

COMMIT TRANSACTION;

PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO