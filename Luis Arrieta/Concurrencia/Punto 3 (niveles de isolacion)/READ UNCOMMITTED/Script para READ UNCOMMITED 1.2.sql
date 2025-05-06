-- 1. READ UNCOMMITTED
-- Caso: Obtener un reporte general histórico de alguna operación
-- Problema: Dirty reads (lectura de datos no confirmados).
-- Demostración:
-- Sesión 2: Genera un reporte con READ UNCOMMITTED y lee datos no confirmados.

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

PRINT 'Reporte iniciado at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Generar un reporte histórico
SELECT SUM(transactionAmount) AS TotalAmount
FROM dbo.st_transactions;

COMMIT TRANSACTION;

PRINT 'Reporte finalizado at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO