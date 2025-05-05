-- 2. READ COMMITTED
-- Caso: Obtener un reporte general histórico
-- Tabla: st_transactions
-- Problema: Non-repeatable read
-- Sesion 1

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

PRINT 'Reporte iniciado at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Primera lectura
PRINT 'Primera lectura:';
SELECT transactionID, transactionAmount
FROM dbo.st_transactions
WHERE transactionID = 1;

-- Esperar para que Sesión 2 modifique
WAITFOR DELAY '00:00:05';

-- Segunda lectura
PRINT 'Segunda lectura:';
SELECT transactionID, transactionAmount
FROM dbo.st_transactions
WHERE transactionID = 1;

COMMIT TRANSACTION;

PRINT 'Reporte finalizado at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO