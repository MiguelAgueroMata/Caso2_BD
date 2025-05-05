USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Transacción A iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Paso 1: Adquirir bloqueo exclusivo en st_usageTokens
UPDATE dbo.st_usageTokens
SET failedAttempts = failedAttempts
WHERE usageTokenID = 1;

-- Simular procesamiento con espera
WAITFOR DELAY '00:00:06';

-- Paso 2: Intentar UPDATE en st_payments
UPDATE dbo.st_payments
SET amount = amount + 1.00
WHERE paymentID = 1;

COMMIT TRANSACTION;

PRINT 'Transacción A completada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO