USE Caso2DB;
GO

CREATE OR ALTER PROCEDURE [dbo].[SP_GestionarSuscripcionPremium]
    @UserID INT,
    @PlanID INT,
    @PaymentMethodID INT = 1,  -- Default: Tarjeta de crédito
    @MonthsToAdd INT = 1       -- Default: 1 mes
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ErrorNumber INT, @ErrorSeverity INT, @ErrorState INT, @CustomError INT
    DECLARE @Message VARCHAR(200)
    DECLARE @InicieTransaccion BIT = 0
    
    -- Variables para el proceso
    DECLARE @SubscriptionID INT
    DECLARE @MontoPago DECIMAL(10,2)
    DECLARE @CurrencyID INT
    DECLARE @NuevoPaymentID INT
    DECLARE @NuevaTransaccionID INT
    DECLARE @FechaInicio DATE = GETDATE()
    DECLARE @FechaFin DATE = DATEADD(MONTH, @MonthsToAdd, @FechaInicio)
    
    -- Validaciones iniciales
    IF NOT EXISTS (SELECT 1 FROM [dbo].[st_users] WHERE userID = @UserID)
    BEGIN
        SET @Message = 'Usuario no encontrado'
        GOTO ErrorHandler
    END
    
    IF NOT EXISTS (SELECT 1 FROM [dbo].[st_plans] WHERE planID = @PlanID)
    BEGIN
        SET @Message = 'Plan no encontrado'
        GOTO ErrorHandler
    END
    
    -- Obtener información del plan
    SELECT 
        @MontoPago = planPrice,
        @CurrencyID = currencyID
    FROM [dbo].[st_plans]
    WHERE planID = @PlanID;
    
    -- Iniciar transacción
    SET @InicieTransaccion = 1
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED
    BEGIN TRANSACTION
    
    BEGIN TRY
        SET @CustomError = 2001
        
        -- 1. Crear o actualizar suscripción (versión simplificada sin lastUpdated)
        IF EXISTS (SELECT 1 FROM [dbo].[st_subcriptions] WHERE userID = @UserID AND planTypeID = @PlanID)
        BEGIN
            -- Actualizar suscripción existente (solo cambiamos el estado a habilitado)
            UPDATE [dbo].[st_subcriptions]
            SET enabled = 1
            WHERE userID = @UserID AND planTypeID = @PlanID;
            
            SELECT @SubscriptionID = subcriptionID 
            FROM [dbo].[st_subcriptions]
            WHERE userID = @UserID AND planTypeID = @PlanID;
        END
        ELSE
        BEGIN
            -- Crear nueva suscripción (versión sin paymentID)
            INSERT INTO [dbo].[st_subcriptions] (
                [description], [logoURL], [enabled], [planTypeID], [userID]
            )
            VALUES (
                'Suscripción al plan ' + CAST(@PlanID AS VARCHAR),
                'https://soltura.com/planes/' + CAST(@PlanID AS VARCHAR) + '.jpg',
                1,
                @PlanID,
                @UserID
            );
            
            SET @SubscriptionID = SCOPE_IDENTITY();
        END
        
        -- 2. Registrar el pago (se mantiene igual)
        INSERT INTO [dbo].[st_payments] (
            [paymentMethodID], [amount], [actualAmount], [result],
            [authentication], [reference], [chargedToken], [description],
            [error], [paymentDate], [checksum], [currencyID]
        )
        VALUES (
            @PaymentMethodID,
            @MontoPago,
            @MontoPago,
            'Success',
            'AUTH_' + CAST(@SubscriptionID AS VARCHAR),
            'PAY_' + FORMAT(GETDATE(), 'yyyyMMddHHmmss'),
            0x0,
            'Pago suscripción ' + CAST(@SubscriptionID AS VARCHAR),
            NULL,
            GETDATE(),
            0x0,
            @CurrencyID
        );
        
        SET @NuevoPaymentID = SCOPE_IDENTITY();
        
        -- 3. NO actualizamos paymentID en subcriptions ya que no existe el campo
        
        -- 4. Registrar transacción financiera (se mantiene igual)
        INSERT INTO [dbo].[st_transactions] (
            [transactionAmount], [description], [transactionDate], [postTime],
            [referenceNumber], [convertedAmount], [checksum], [currencyID],
            [exchangeRateId], [paymentId], [userID], [transactionTypeID],
            [transactionSubTypeID]
        )
        VALUES (
            @MontoPago,
            'Pago suscripción ' + CAST(@SubscriptionID AS VARCHAR),
            GETDATE(),
            GETDATE(),
            'TXN_' + CAST(@SubscriptionID AS VARCHAR),
            @MontoPago,
            0x0,
            @CurrencyID,
            1,  -- Tasa de cambio default
            @NuevoPaymentID,
            @UserID,
            1,  -- Tipo: Compra
            1   -- Subtipo: Suscripción
        );
        
        SET @NuevaTransaccionID = SCOPE_IDENTITY();
        
        -- 5. Crear programación de renovación automática (se mantiene igual)
        INSERT INTO [dbo].[st_schedules] (
            [name], [recurrencyType], [repeat], [endDate], [subcriptionID]
        )
        VALUES (
            'Renovación automática suscripción ' + CAST(@SubscriptionID AS VARCHAR),
            2,  -- Mensual
            'Every 1 month',
            @FechaFin,
            @SubscriptionID
        );
        
        DECLARE @ScheduleID INT = SCOPE_IDENTITY();
        
        -- 6. Detalles de programación (se mantiene igual)
        INSERT INTO [dbo].[st_scheduleDetails] (
            [deleted], [baseDate], [datePart], [lastExecution], [nextExecution], [scheduleID]
        )
        VALUES (
            0,
            @FechaInicio,
            'First day of month',
            NULL,
            DATEADD(MONTH, 1, @FechaInicio),
            @ScheduleID
        );
        
        -- Confirmar transacción si todo fue bien
        IF @InicieTransaccion = 1
            COMMIT TRANSACTION;
        
        -- Retornar información del proceso
        SELECT 
            @SubscriptionID AS SubscriptionID,
            @UserID AS UserID,
            @PlanID AS PlanID,
            @MontoPago AS Amount,
            @NuevoPaymentID AS PaymentID,
            @NuevaTransaccionID AS TransactionID,
            @FechaInicio AS StartDate,
            @FechaFin AS EndDate,
            'Proceso completado exitosamente' AS Status;
        
        RETURN 0;
    END TRY
    BEGIN CATCH
        SET @ErrorNumber = ERROR_NUMBER()
        SET @ErrorSeverity = ERROR_SEVERITY()
        SET @ErrorState = ERROR_STATE()
        SET @Message = ERROR_MESSAGE()
        
        IF @InicieTransaccion = 1
            ROLLBACK TRANSACTION;
        
        -- Registrar error
        INSERT INTO [dbo].[st_errorLogs] (
            [errorNumber], [errorSeverity], [errorState], [errorMessage],
            [errorProcedure], [errorLine], [errorTime]
        )
        VALUES (
            @ErrorNumber, @ErrorSeverity, @ErrorState, @Message,
            'SP_GestionarSuscripcionPremium', ERROR_LINE(), GETDATE()
        );
        
        -- Retornar error
        SELECT 
            NULL AS SubscriptionID,
            @UserID AS UserID,
            @PlanID AS PlanID,
            NULL AS Amount,
            NULL AS PaymentID,
            NULL AS TransactionID,
            NULL AS StartDate,
            NULL AS EndDate,
            'Error: ' + @Message AS Status;
        
        RETURN -99;
    END CATCH;

ErrorHandler:
    -- Registrar error de validación
    INSERT INTO [dbo].[st_errorLogs] (
        [errorNumber], [errorSeverity], [errorState], [errorMessage],
        [errorProcedure], [errorLine], [errorTime]
    )
    VALUES (
        50000, 16, 1, @Message,
        'SP_GestionarSuscripcionPremium', ERROR_LINE(), GETDATE()
    );
    
    -- Retornar error de validación
    SELECT 
        NULL AS SubscriptionID,
        @UserID AS UserID,
        @PlanID AS PlanID,
        NULL AS Amount,
        NULL AS PaymentID,
        NULL AS TransactionID,
        NULL AS StartDate,
        NULL AS EndDate,
        'Error: ' + @Message AS Status;
    
    RETURN -1;
END;


DECLARE @Result INT
EXEC @Result = [dbo].[SP_GestionarSuscripcionPremium] 
    @UserID = 1, 
    @PlanID = 1,
    @PaymentMethodID = 1,
    @MonthsToAdd = 4
    
SELECT 'Resultado' = CASE @Result 
    WHEN 0 THEN 'Éxito' 
    WHEN -1 THEN 'Error de validación' 
    WHEN -99 THEN 'Error en ejecución' 
    ELSE 'Código desconocido: ' + CAST(@Result AS VARCHAR) 
END


DECLARE @Result INT
EXEC @Result = [dbo].[SP_GestionarSuscripcionPremium] 
    @UserID = 999,  -- ID que no existe
    @PlanID = 1
    
SELECT 'Resultado' = CASE @Result 
    WHEN 0 THEN 'Éxito' 
    WHEN -1 THEN 'Error de validación' 
    WHEN -99 THEN 'Error en ejecución' 
    ELSE 'Código desconocido: ' + CAST(@Result AS VARCHAR) 
END


DECLARE @Result INT
EXEC @Result = [dbo].[SP_GestionarSuscripcionPremium] 
    @UserID = 1, 
    @PlanID = 999  -- ID de plan que no existe
    
SELECT 'Resultado' = CASE @Result 
    WHEN 0 THEN 'Éxito' 
    WHEN -1 THEN 'Error de validación' 
    WHEN -99 THEN 'Error en ejecución' 
    ELSE 'Código desconocido: ' + CAST(@Result AS VARCHAR) 
END

SELECT p.* 
FROM [dbo].[st_payments] p
JOIN [dbo].[st_subcriptions] s ON p.description LIKE '%' + CAST(s.subcriptionID AS VARCHAR) + '%'
WHERE s.userID = 1

SELECT* FROM [dbo].[st_payments]
SELECT* FROM [dbo].[st_transactions]


