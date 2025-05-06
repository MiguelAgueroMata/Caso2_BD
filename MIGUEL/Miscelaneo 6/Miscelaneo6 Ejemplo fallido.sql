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

-- Verificar que las variables tengan valores v�lidos
IF @planID IS NULL OR @subscriptionID IS NULL OR @userID IS NULL OR @usageTokenID IS NULL
BEGIN
    PRINT 'Error: No se encontraron datos suficientes en las tablas para la prueba.';
    RETURN;
END;

-- Guardar el estado inicial para comparaci�n
SELECT * INTO #st_plans_before FROM [dbo].[st_plans] WHERE planID = @planID;
SELECT * INTO #st_subcriptions_before FROM [dbo].[st_subcriptions] WHERE subcriptionID = @subscriptionID;
SELECT * INTO #st_payments_before FROM [dbo].[st_payments] WHERE description LIKE '%MiddleTransactionSP%';
SELECT * INTO #st_transactions_before FROM [dbo].[st_transactions] WHERE description LIKE '%MiddleTransactionSP%';
SELECT * INTO #st_usageTokens_before FROM [dbo].[st_usageTokens] WHERE usageTokenID = @usageTokenID;
SELECT * INTO #st_usageTransactions_before FROM [dbo].[st_usageTransactions] WHERE usageNotes LIKE '%InnerTransactionSP%';

-- Ejecutar el SP externo (con error simulado)
EXEC [dbo].[OuterTransactionSP] 
    @planID = @planID, 
    @subscriptionID = @subscriptionID, 
    @userID = @userID, 
    @usageTokenID = @usageTokenID, 
    @shouldFail = 1;

-- Verificar resultados (ninguna tabla deber�a haber cambiado)
SELECT 'st_plans (despu�s)' AS table_name, * FROM [dbo].[st_plans] WHERE planID = @planID;
SELECT 'st_subcriptions (despu�s)' AS table_name, * FROM [dbo].[st_subcriptions] WHERE subcriptionID = @subscriptionID;
SELECT 'st_payments (despu�s)' AS table_name, * FROM [dbo].[st_payments] WHERE description LIKE '%MiddleTransactionSP%';
SELECT 'st_transactions (despu�s)' AS table_name, * FROM [dbo].[st_transactions] WHERE description LIKE '%MiddleTransactionSP%';
SELECT 'st_usageTokens (despu�s)' AS table_name, * FROM [dbo].[st_usageTokens] WHERE usageTokenID = @usageTokenID;
SELECT 'st_usageTransactions (despu�s)' AS table_name, * FROM [dbo].[st_usageTransactions] WHERE usageNotes LIKE '%InnerTransactionSP%';

-- Comparar para confirmar que no hubo cambios
SELECT 'st_plans (comparaci�n)' AS table_name, * FROM #st_plans_before;
SELECT 'st_subcriptions (comparaci�n)' AS table_name, * FROM #st_subcriptions_before;
SELECT 'st_payments (comparaci�n)' AS table_name, * FROM #st_payments_before;
SELECT 'st_transactions (comparaci�n)' AS table_name, * FROM #st_transactions_before;
SELECT 'st_usageTokens (comparaci�n)' AS table_name, * FROM #st_usageTokens_before;
SELECT 'st_usageTransactions (comparaci�n)' AS table_name, * FROM #st_usageTransactions_before;

-- Limpiar tablas temporales
DROP TABLE #st_plans_before;
DROP TABLE #st_subcriptions_before;
DROP TABLE #st_payments_before;
DROP TABLE #st_transactions_before;
DROP TABLE #st_usageTokens_before;
DROP TABLE #st_usageTransactions_before;
GO