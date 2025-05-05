USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Transacción B iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Paso 1: Adquirir bloqueo exclusivo en st_payments
UPDATE dbo.st_payments
SET amount = amount
WHERE paymentID = 1;

-- Simular procesamiento con espera
WAITFOR DELAY '00:00:06';

-- Paso 2: Intentar UPDATE en st_transactions
UPDATE dbo.st_transactions
SET transactionAmount = transactionAmount + 10.00
WHERE transactionID = 1;

COMMIT TRANSACTION;

PRINT 'Transacción B completada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO