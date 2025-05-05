-- 3. REPEATABLE READ
-- Caso: Cambios de precio durante suscripciones
-- Tabla: st_plans (usando planPrice a trav�s de st_subcriptions)
-- Problema: Phantom read.
-- Sesion 1

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

PRINT 'Verificaci�n de precio iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Primera verificaci�n: Ver el precio del plan asociado a las suscripciones
PRINT 'Primera verificaci�n:';
SELECT s.subcriptionID, p.planPrice
FROM dbo.st_subcriptions s
JOIN dbo.st_plans p ON s.planTypeID = p.planTypeID
WHERE s.planTypeID = 1;

-- Esperar para que Sesi�n 2 inserte
WAITFOR DELAY '00:00:05';

-- Segunda verificaci�n
PRINT 'Segunda verificaci�n:';
SELECT s.subcriptionID, p.planPrice
FROM dbo.st_subcriptions s
JOIN dbo.st_plans p ON s.planTypeID = p.planTypeID
WHERE s.planTypeID = 1;

COMMIT TRANSACTION;

PRINT 'Verificaci�n de precio finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO