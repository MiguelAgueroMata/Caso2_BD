-- 2. READ COMMITTED
-- Caso: Agotamiento de existencias
-- Tabla: st_usageTokens (usando maxUses como inventario)
-- Problema: Non-repeatable read (ajustado para tu estructura).
-- Sesion 1

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

PRINT 'Verificaci�n de stock iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Primera verificaci�n: Ver el valor espec�fico de maxUses
PRINT 'Primera verificaci�n:';
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

-- Esperar para que Sesi�n 2 modifique
WAITFOR DELAY '00:00:05';

-- Segunda verificaci�n: Ver el mismo registro
PRINT 'Segunda verificaci�n:';
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

-- Verificar si el registro sigue siendo elegible para inventario
PRINT 'Verificaci�n de elegibilidad para inventario:';
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE maxUses > 0;

COMMIT TRANSACTION;

PRINT 'Verificaci�n de stock finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO