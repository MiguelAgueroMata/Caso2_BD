USE [Caso2DB]
GO

-- Procedimiento interno (SP3): InnerTransactionSP
CREATE OR ALTER PROCEDURE [dbo].[InnerTransactionSP]
    @usageTokenID INT,
    @userID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TranName VARCHAR(20) = 'InnerTran';

    BEGIN TRY
        -- Iniciar transacción interna
        BEGIN TRANSACTION @TranName;

        -- Modificar st_usageTokens: reducir maxUses
        UPDATE [dbo].[st_usageTokens]
        SET maxUses = maxUses - 1
        WHERE usageTokenID = @usageTokenID
        AND maxUses > 0;

        IF @@ROWCOUNT = 0
            THROW 50001, 'No se pudo actualizar el token de uso.', 1;

        -- Modificar st_usageTransactions: registrar un uso
        INSERT INTO [dbo].[st_usageTransactions] (
            usageTokenID, transactionDate, usageNotes, transactionType
        )
        VALUES (
            @usageTokenID,
            GETDATE(),
            'Uso registrado por InnerTransactionSP',
            'ServiceConsumption'
        );

        -- Confirmar transacción interna
        COMMIT TRANSACTION @TranName;
        PRINT 'InnerTransactionSP ejecutado exitosamente.';
    END TRY
    BEGIN CATCH
        -- Si hay error, rollback de la transacción interna
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION @TranName;

        -- Relanzar el error para que el SP llamador lo maneje
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- Procedimiento intermedio (SP2): MiddleTransactionSP
CREATE OR ALTER PROCEDURE [dbo].[MiddleTransactionSP]
    @subscriptionID INT,
    @userID INT,
    @usageTokenID INT,
    @shouldFail BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TranName VARCHAR(20) = 'MiddleTran';

    BEGIN TRY
        -- Iniciar transacción intermedia
        BEGIN TRANSACTION @TranName;

        -- Simular un error primero si shouldFail = 1
        IF @shouldFail = 1
            THROW 50002, 'Error simulado en MiddleTransactionSP.', 1;

        -- Modificar st_payments: registrar un nuevo pago
        INSERT INTO [dbo].[st_payments] (
            paymentMethodID, amount, actualAmount, result, authentication,
            reference, chargedToken, description, error, paymentDate,
            checksum, currencyID
        )
        VALUES (
            1,
            1000.00,
            1000.00,
            'Success',
            'AUTH_' + CAST(@subscriptionID AS VARCHAR),
            'REF_' + CAST(@subscriptionID AS VARCHAR),
            CONVERT(VARBINARY(250), 'TOKEN_' + CAST(@subscriptionID AS VARCHAR)),
            'Pago registrado por MiddleTransactionSP',
            NULL,
            GETDATE(),
            CONVERT(VARBINARY(250), 'CHECKSUM_' + CAST(@subscriptionID AS VARCHAR)),
            1
        );

        DECLARE @paymentID INT = SCOPE_IDENTITY();

        -- Modificar st_transactions: registrar una transacción
        INSERT INTO [dbo].[st_transactions] (
            transactionAmount, description, transactionDate, postTime,
            referenceNumber, convertedAmount, checksum, currencyID,
            exchangeRateId, paymentId, userID, transactionTypeID,
            transactionSubTypeID
        )
        VALUES (
            1000.00,
            'Transacción registrada por MiddleTransactionSP',
            GETDATE(),
            GETDATE(),
            'TX_' + CAST(@subscriptionID AS VARCHAR),
            1000.00,
            CONVERT(VARBINARY(250), 'TX_CHECKSUM_' + CAST(@subscriptionID AS VARCHAR)),
            1,
            1,
            @paymentID,
            @userID,
            1,
            1
        );

        -- Llamar al SP interno
        EXEC [dbo].[InnerTransactionSP] @usageTokenID, @userID;

        -- Confirmar transacción intermedia
        COMMIT TRANSACTION @TranName;
        PRINT 'MiddleTransactionSP ejecutado exitosamente.';
    END TRY
    BEGIN CATCH
        -- Rollback de la transacción intermedia
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION @TranName;

        -- Relanzar el error para que el SP externo lo maneje
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO

-- Procedimiento externo (SP1): OuterTransactionSP
CREATE OR ALTER PROCEDURE [dbo].[OuterTransactionSP]
    @planID INT,
    @subscriptionID INT,
    @userID INT,
    @usageTokenID INT,
    @shouldFail BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TranName VARCHAR(20) = 'OuterTran';

    BEGIN TRY
        -- Iniciar transacción externa
        BEGIN TRANSACTION @TranName;

        -- Modificar st_plans: actualizar el precio del plan
        UPDATE [dbo].[st_plans]
        SET planPrice = planPrice + 500.00
        WHERE planID = @planID;

        IF @@ROWCOUNT = 0
            THROW 50003, 'No se pudo actualizar el plan.', 1;

        -- Modificar st_subcriptions: actualizar la descripción
        UPDATE [dbo].[st_subcriptions]
        SET description = 'Suscripción actualizada por OuterTransactionSP'
        WHERE subcriptionID = @subscriptionID;

        IF @@ROWCOUNT = 0
            THROW 50004, 'No se pudo actualizar la suscripción.', 1;

        -- Llamar al SP intermedio
        EXEC [dbo].[MiddleTransactionSP] @subscriptionID, @userID, @usageTokenID, @shouldFail;

        -- Confirmar transacción externa
        COMMIT TRANSACTION @TranName;
        PRINT 'OuterTransactionSP ejecutado exitosamente.';
    END TRY
    BEGIN CATCH
        -- Rollback de la transacción externa
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION @TranName;

        -- Mostrar el error pero no interrumpir la ejecución
        PRINT 'Error en OuterTransactionSP: ' + ERROR_MESSAGE();
    END CATCH
END;
GO