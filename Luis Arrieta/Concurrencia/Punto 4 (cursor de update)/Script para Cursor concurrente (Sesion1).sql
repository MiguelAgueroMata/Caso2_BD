-- Script que usa un cursor para actualizar st_transactions y simular concurrencia con WAITFOR DELAY.

USE [Caso2DB]
GO

SET NOCOUNT ON;

-- Caso 1: READ COMMITTED
PRINT '=== Caso 1: READ COMMITTED ==='
PRINT 'Sesión 1 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;

DECLARE update_cursor CURSOR FOR
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE maxUses > 0;

DECLARE @usageTokenID INT;
DECLARE @currentMaxUses INT;
DECLARE @newMaxUses INT;

OPEN update_cursor;
FETCH NEXT FROM update_cursor INTO @usageTokenID, @currentMaxUses;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @newMaxUses = @currentMaxUses - 1;
    UPDATE dbo.st_usageTokens
    SET maxUses = @newMaxUses
    WHERE CURRENT OF update_cursor;

    PRINT 'Actualizado usageTokenID = ' + CAST(@usageTokenID AS VARCHAR) + ' a maxUses = ' + CAST(@newMaxUses AS VARCHAR) + ' at ' + CONVERT(VARCHAR, GETDATE(), 121);

    WAITFOR DELAY '00:00:03'; -- Pausa para permitir concurrencia

    FETCH NEXT FROM update_cursor INTO @usageTokenID, @currentMaxUses;
END;

CLOSE update_cursor;
DEALLOCATE update_cursor;

COMMIT TRANSACTION;
PRINT 'Sesión 1 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO

-- Caso 2: REPEATABLE READ
PRINT '=== Caso 2: REPEATABLE READ ==='
PRINT 'Sesión 1 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;

DECLARE update_cursor CURSOR FOR
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE maxUses > 0;

DECLARE @usageTokenID INT;
DECLARE @currentMaxUses INT;
DECLARE @newMaxUses INT;


OPEN update_cursor;
FETCH NEXT FROM update_cursor INTO @usageTokenID, @currentMaxUses;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @newMaxUses = @currentMaxUses - 1;
    UPDATE dbo.st_usageTokens
    SET maxUses = @newMaxUses
    WHERE CURRENT OF update_cursor;

    PRINT 'Actualizado usageTokenID = ' + CAST(@usageTokenID AS VARCHAR) + ' a maxUses = ' + CAST(@newMaxUses AS VARCHAR) + ' at ' + CONVERT(VARCHAR, GETDATE(), 121);

    WAITFOR DELAY '00:00:03';

    FETCH NEXT FROM update_cursor INTO @usageTokenID, @currentMaxUses;
END;

CLOSE update_cursor;
DEALLOCATE update_cursor;

COMMIT TRANSACTION;
PRINT 'Sesión 1 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO

-- Caso 3: SERIALIZABLE
PRINT '=== Caso 3: SERIALIZABLE ==='
PRINT 'Sesión 1 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

DECLARE update_cursor CURSOR FOR
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE maxUses > 0;

DECLARE @usageTokenID INT;
DECLARE @currentMaxUses INT;
DECLARE @newMaxUses INT;


OPEN update_cursor;
FETCH NEXT FROM update_cursor INTO @usageTokenID, @currentMaxUses;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @newMaxUses = @currentMaxUses - 1;
    UPDATE dbo.st_usageTokens
    SET maxUses = @newMaxUses
    WHERE CURRENT OF update_cursor;

    PRINT 'Actualizado usageTokenID = ' + CAST(@usageTokenID AS VARCHAR) + ' a maxUses = ' + CAST(@newMaxUses AS VARCHAR) + ' at ' + CONVERT(VARCHAR, GETDATE(), 121);

    WAITFOR DELAY '00:00:03';

    FETCH NEXT FROM update_cursor INTO @usageTokenID, @currentMaxUses;
END;

CLOSE update_cursor;
DEALLOCATE update_cursor;

COMMIT TRANSACTION;
PRINT 'Sesión 1 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
