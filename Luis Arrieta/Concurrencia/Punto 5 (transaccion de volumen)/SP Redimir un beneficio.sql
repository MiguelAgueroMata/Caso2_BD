-- Stored Procedure que reflejea la transacción de volumen se la base de datos, en nuestro seria "Redimir un beneficio"
-- Esto refleja la interacción más común de los usuarios con la app Soltura al consumir beneficios como gimnasio, combustible o comidas.

USE [Caso2DB]
GO

CREATE PROCEDURE dbo.RedeemBenefit
    @usageTokenID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Verificar y actualizar el token
        UPDATE dbo.st_usageTokens
        SET maxUses = maxUses - 1
        WHERE usageTokenID = @usageTokenID
        AND maxUses > 0;

        IF @@ROWCOUNT = 0
            THROW 50001, 'Beneficio no disponible o ya redimido.', 1;

        -- Verificar existencia de valores necesarios para st_transactions
        DECLARE @TransactionTypeID INT;
        DECLARE @TransactionSubTypeID INT;
        DECLARE @CurrencyID INT;
        DECLARE @ExchangeRateID INT;
        DECLARE @PaymentID INT;

        -- Obtener transactionTypeID
        SELECT TOP 1 @TransactionTypeID = transactionTypeID
        FROM dbo.st_transactionType
        WHERE name = 'Compra'; -- Usar 'Compra' en lugar de 'Redemption'

        IF @TransactionTypeID IS NULL
            THROW 50002, 'No se encontró un tipo de transacción "Compra" en st_transactionType.', 1;

        -- Obtener transactionSubTypeID
        SELECT TOP 1 @TransactionSubTypeID = transactionSubTypesID
        FROM dbo.st_transactionSubTypes;

        IF @TransactionSubTypeID IS NULL
            THROW 50003, 'No se encontró un subtipo de transacción en st_transactionSubTypes.', 1;

        -- Obtener currencyID
        SELECT TOP 1 @CurrencyID = currencyID
        FROM dbo.st_currencies;

        IF @CurrencyID IS NULL
            THROW 50004, 'No se encontró una moneda en st_currencies.', 1;

        -- Obtener exchangeRateID
        SELECT TOP 1 @ExchangeRateID = exchangeRateID
        FROM dbo.st_exchangeRate;

        IF @ExchangeRateID IS NULL
            THROW 50005, 'No se encontró una tasa de cambio en st_exchangeRate.', 1;

        -- Obtener paymentID
        SELECT TOP 1 @PaymentID = paymentID
        FROM dbo.st_payments;

        IF @PaymentID IS NULL
            THROW 50006, 'No se encontró un pago en st_payments.', 1;

        -- Registrar la transacción en st_transactions
        INSERT INTO dbo.st_transactions 
        (
            transactionAmount, 
            description, 
            transactionDate, 
            postTime, 
            referenceNumber, 
            convertedAmount, 
            checksum, 
            currencyID, 
            exchangeRateID, 
            paymentID, 
            userID, 
            transactionTypeID, 
            transactionSubTypeID
        )
        SELECT 
            0, -- transactionAmount
            'Redemption of benefit', -- description
            GETDATE(), -- transactionDate
            GETDATE(), -- postTime
            CAST(@usageTokenID AS VARCHAR(10)), -- referenceNumber
            0, -- convertedAmount
            0x0, -- checksum (valor dummy, ajusta según necesidades)
            @CurrencyID, -- currencyID
            @ExchangeRateID, -- exchangeRateID
            @PaymentID, -- paymentID
            userID, -- userID
            @TransactionTypeID, -- transactionTypeID
            @TransactionSubTypeID -- transactionSubTypeID
        FROM dbo.st_usageTokens
        WHERE usageTokenID = @usageTokenID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
GO

EXEC dbo.RedeemBenefit @usageTokenID = 1;

SELECT * FROM dbo.st_usageTokens WHERE usageTokenID = 1;

SELECT * FROM dbo.st_transactions WHERE referenceNumber = '1';