-- Script de cursor concurrente
-- Caso 1: Nivel de aislamiento READ COMMITTED
-- Caso 2
-- Caso 3

USE [Caso2DB]
GO

SET NOCOUNT ON;

-- Caso 1: READ COMMITTED
PRINT '=== Caso 1: READ COMMITTED ==='
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;

-- Intentar leer el registro (debería poder leer si no está bloqueado)
PRINT 'Intentando leer usageTokenID = 1...'
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

-- Intentar modificar (esperará si el cursor tiene un bloqueo exclusivo)
PRINT 'Intentando modificar usageTokenID = 1...'
UPDATE dbo.st_usageTokens
SET maxUses = 10
WHERE usageTokenID = 1;

-- Intentar insertar un nuevo registro
PRINT 'Intentando insertar un nuevo registro...'
INSERT INTO dbo.st_usageTokens (userID, tokenType, tokenCode, createdAt, expirationDate, status, failedAttempts, contractDetailsID, maxUses)
SELECT TOP 1 userID, 'ServiceAccess', CONVERT(VARBINARY(250), 'TOKEN_NEW'), GETDATE(), DATEADD(MONTH, 1, GETDATE()), 'Active', 0, contractDetailsID, 5
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

COMMIT TRANSACTION;
PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO

-- Caso 2: REPEATABLE READ
PRINT '=== Caso 2: REPEATABLE READ ==='
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;

-- Intentar leer el registro
PRINT 'Intentando leer usageTokenID = 1...'
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

-- Intentar modificar
PRINT 'Intentando modificar usageTokenID = 1...'
UPDATE dbo.st_usageTokens
SET maxUses = 10
WHERE usageTokenID = 1;

-- Intentar insertar un nuevo registro
PRINT 'Intentando insertar un nuevo registro...'
INSERT INTO dbo.st_usageTokens (userID, tokenType, tokenCode, createdAt, expirationDate, status, failedAttempts, contractDetailsID, maxUses)
SELECT TOP 1 userID, 'ServiceAccess', CONVERT(VARBINARY(250), 'TOKEN_NEW'), GETDATE(), DATEADD(MONTH, 1, GETDATE()), 'Active', 0, contractDetailsID, 5
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

COMMIT TRANSACTION;
PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO

-- Caso 3: SERIALIZABLE
PRINT '=== Caso 3: SERIALIZABLE ==='
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

-- Intentar leer el registro
PRINT 'Intentando leer usageTokenID = 1...'
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

-- Intentar modificar
PRINT 'Intentando modificar usageTokenID = 1...'
UPDATE dbo.st_usageTokens
SET maxUses = 10
WHERE usageTokenID = 1;

-- Intentar insertar un nuevo registro
PRINT 'Intentando insertar un nuevo registro...'
INSERT INTO dbo.st_usageTokens (userID, tokenType, tokenCode, createdAt, expirationDate, status, failedAttempts, contractDetailsID, maxUses)
SELECT TOP 1 userID, 'ServiceAccess', CONVERT(VARBINARY(250), 'TOKEN_NEW'), GETDATE(), DATEADD(MONTH, 1, GETDATE()), 'Active', 0, contractDetailsID, 5
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

COMMIT TRANSACTION;
PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO