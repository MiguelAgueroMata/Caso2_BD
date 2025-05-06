-- Caso: Calcular el tipo de cambio
-- Tabla: st_exchangeRate
-- Problema: Dirty read.
-- Sesion2

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

PRINT 'Cálculo iniciado at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Calcular usando el tipo de cambio
SELECT exhangeRate
FROM dbo.st_exchangeRate
WHERE exchangeRateID = 1;

COMMIT TRANSACTION;

PRINT 'Cálculo finalizado at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO