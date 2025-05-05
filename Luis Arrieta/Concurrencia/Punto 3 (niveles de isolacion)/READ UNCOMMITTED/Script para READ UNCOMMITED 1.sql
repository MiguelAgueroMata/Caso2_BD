-- 1. READ UNCOMMITTED
-- Caso: Obtener un reporte general histórico de alguna operación
-- Tabla: st_transactions
-- Problema: Dirty reads.

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 1 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Modificar una transacción sin hacer COMMIT
UPDATE dbo.st_transactions
SET transactionAmount = 9999.00
WHERE transactionID = 1;

PRINT 'Transacción modificada, esperando COMMIT...';
WAITFOR DELAY '00:00:10';

-- Descomenta para hacer COMMIT o ROLLBACK
-- COMMIT TRANSACTION;
ROLLBACK TRANSACTION;

PRINT 'Sesión 1 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO