USE [Caso2DB]
GO

-- Declarar las variables
DECLARE @planID INT;
DECLARE @subscriptionID INT;
DECLARE @userID INT;
DECLARE @usageTokenID INT;

-- Asegurarnos de que existan datos para la prueba
SELECT TOP 1 @planID = planID FROM [dbo].[st_plans];
SELECT TOP 1 @subscriptionID = subcriptionID, @userID = userID FROM [dbo].[st_subcriptions];
SELECT TOP 1 @usageTokenID = usageTokenID FROM [dbo].[st_usageTokens] WHERE maxUses > 0;

-- Verificar que las variables tengan valores válidos
IF @planID IS NULL OR @subscriptionID IS NULL OR @userID IS NULL OR @usageTokenID IS NULL
BEGIN
    PRINT 'Error: No se encontraron datos suficientes en las tablas para la prueba.';
    RETURN;
END;

-- Ejecutar el SP externo (sin error)
EXEC [dbo].[OuterTransactionSP] 
    @planID = @planID, 
    @subscriptionID = @subscriptionID, 
    @userID = @userID, 
    @usageTokenID = @usageTokenID, 
    @shouldFail = 0;

-- Verificar resultados
SELECT 'st_plans', * FROM [dbo].[st_plans] WHERE planID = @planID;
SELECT 'st_subcriptions', * FROM [dbo].[st_subcriptions] WHERE subcriptionID = @subscriptionID;
SELECT 'st_payments', * FROM [dbo].[st_payments] WHERE description LIKE '%MiddleTransactionSP%';
SELECT 'st_transactions', * FROM [dbo].[st_transactions] WHERE description LIKE '%MiddleTransactionSP%';
SELECT 'st_usageTokens', * FROM [dbo].[st_usageTokens] WHERE usageTokenID = @usageTokenID;
SELECT 'st_usageTransactions', * FROM [dbo].[st_usageTransactions] WHERE usageNotes LIKE '%InnerTransactionSP%';
GO