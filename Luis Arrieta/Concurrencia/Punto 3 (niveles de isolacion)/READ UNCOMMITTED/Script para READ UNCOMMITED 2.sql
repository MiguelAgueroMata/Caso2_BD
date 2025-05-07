-- Caso: Calcular el tipo de cambio
-- Tabla: st_exchangeRate
-- Problema: Dirty read.
-- Sesion 1


USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 1 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Modificar el tipo de cambio sin hacer COMMIT
UPDATE dbo.st_exchangeRate
SET exchangeRate = 0.0930
WHERE exchangeRateID = 1;

PRINT 'Tipo de cambio modificado, esperando COMMIT...';
WAITFOR DELAY '00:00:10';

-- ROLLBACK para simular un error
ROLLBACK TRANSACTION;

PRINT 'Sesión 1 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO