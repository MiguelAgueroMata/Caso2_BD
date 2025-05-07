-- 4. SERIALIZABLE
-- Caso: Adquisición de planes cuando se están actualizando
-- Tabla: st_plans
-- Problema: Riesgo de deadlocks.
-- Sesion 2

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Actualizar el precio del plan
UPDATE dbo.st_plans
SET planPrice = 157980
WHERE planID = 1;

COMMIT TRANSACTION;

PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO