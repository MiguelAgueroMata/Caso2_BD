-- 4. SERIALIZABLE
-- Caso: Adquisici�n de planes cuando se est�n actualizando
-- Tabla: st_plans
-- Problema: Riesgo de deadlocks.
-- Sesion 1

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

PRINT 'Adquisici�n de plan iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Verificar el precio del plan
SELECT planID, planPrice
FROM dbo.st_plans
WHERE planID = 1;

-- Simular procesamiento
WAITFOR DELAY '00:00:05';

-- Confirmar adquisici�n (simulada)
UPDATE dbo.st_plans
SET planPrice = planPrice
WHERE planID = 1;

COMMIT TRANSACTION;

PRINT 'Adquisici�n de plan finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
