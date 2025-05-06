-- 2. READ COMMITTED
-- Caso: Obtener un reporte general histórico
-- Tabla: st_transactions
-- Problema: Non-repeatable read
-- Sesion 2

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Modificar la transacción
UPDATE dbo.st_transactions
SET transactionAmount = 2000.00
WHERE transactionID = 1;

COMMIT TRANSACTION;

PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO