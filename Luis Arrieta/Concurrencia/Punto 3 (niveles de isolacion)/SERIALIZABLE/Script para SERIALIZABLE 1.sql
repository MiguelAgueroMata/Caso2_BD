-- 4. SERIALIZABLE
-- Caso: Adquisición de planes cuando se están actualizando
-- Tabla: st_plans
-- Problema: Riesgo de deadlocks.
-- Sesion 1

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

PRINT 'Adquisición de plan iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Verificar el precio del plan
SELECT planID, planPrice
FROM dbo.st_plans
WHERE planID = 1;

-- Simular procesamiento
WAITFOR DELAY '00:00:05';

-- Confirmar adquisición (simulada)
UPDATE dbo.st_plans
SET planPrice = planPrice
WHERE planID = 1;

COMMIT TRANSACTION;

PRINT 'Adquisición de plan finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
