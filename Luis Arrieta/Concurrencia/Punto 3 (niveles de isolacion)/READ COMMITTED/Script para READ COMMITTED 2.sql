-- 2. READ COMMITTED
-- Caso: Agotamiento de existencias
-- Tabla: st_usageTokens (usando maxUses como inventario)
-- Problema: Non-repeatable read (ajustado para tu estructura).
-- Sesion 1

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

PRINT 'Verificación de stock iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Primera verificación: Ver el valor específico de maxUses
PRINT 'Primera verificación:';
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

-- Esperar para que Sesión 2 modifique
WAITFOR DELAY '00:00:05';

-- Segunda verificación: Ver el mismo registro
PRINT 'Segunda verificación:';
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

-- Verificar si el registro sigue siendo elegible para inventario
PRINT 'Verificación de elegibilidad para inventario:';
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE maxUses > 0;

COMMIT TRANSACTION;

PRINT 'Verificación de stock finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO