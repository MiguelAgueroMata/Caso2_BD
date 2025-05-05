-- 1. READ UNCOMMITTED
-- Caso: Obtener un reporte general hist�rico de alguna operaci�n
-- Tabla: st_transactions
-- Problema: Dirty reads.

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesi�n 1 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Modificar una transacci�n sin hacer COMMIT
UPDATE dbo.st_transactions
SET transactionAmount = 9999.00
WHERE transactionID = 1;

PRINT 'Transacci�n modificada, esperando COMMIT...';
WAITFOR DELAY '00:00:10';

-- Descomenta para hacer COMMIT o ROLLBACK
-- COMMIT TRANSACTION;
ROLLBACK TRANSACTION;

PRINT 'Sesi�n 1 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO