-- 2. READ COMMITTED
-- Caso: Agotamiento de existencias
-- Tabla: st_usageTokens (usando maxUses como inventario)
-- Problema: Non-repeatable read (ajustado para tu estructura).
-- Sesion 2

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Reducir el stock
UPDATE dbo.st_usageTokens
SET maxUses = 0
WHERE usageTokenID = 1;

COMMIT TRANSACTION;

PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO