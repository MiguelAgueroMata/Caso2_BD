-- 2. READ COMMITTED
-- Caso: Obtener un reporte general hist�rico
-- Tabla: st_transactions
-- Problema: Non-repeatable read
-- Sesion 2

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesi�n 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Modificar la transacci�n
UPDATE dbo.st_transactions
SET transactionAmount = 2000.00
WHERE transactionID = 1;

COMMIT TRANSACTION;

PRINT 'Sesi�n 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO