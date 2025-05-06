-- Script para procedimiento transaccional.

USE [Caso2DB]
GO

CREATE OR ALTER PROCEDURE [dbo].[UpdateProviderContract]
    @providerName VARCHAR(45),
    @providerDescription VARCHAR(200),
    @contractType VARCHAR(45),
    @contractDescription VARCHAR(200),
    @startDate DATE,
    @endDate DATE,
    @authorizedSignatory VARBINARY(250),
    @contractDetails [dbo].[ContractDetailsType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @providerID INT;
    DECLARE @providerContractID INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Verificar si el proveedor existe
        SELECT @providerID = providerID
        FROM [dbo].[st_providers]
        WHERE name = @providerName;

        IF @providerID IS NULL
        BEGIN
            -- Insertar nuevo proveedor
            INSERT INTO [dbo].[st_providers] (
                name, providerDescription, status
            )
            VALUES (
                @providerName,
                @providerDescription,
                1
            );
            SET @providerID = SCOPE_IDENTITY();
            PRINT 'Proveedor insertado: ' + @providerName;
        END
        ELSE
        BEGIN
            PRINT 'Proveedor existente encontrado: ' + @providerName;
        END;

        -- 2. Verificar si el proveedor tiene un contrato activo
        SELECT @providerContractID = providerContractID
        FROM [dbo].[st_providersContract]
        WHERE providerID = @providerID
        AND status = 1
        AND endDate >= GETDATE();

        IF @providerContractID IS NULL
        BEGIN
            -- Insertar nuevo contrato
            INSERT INTO [dbo].[st_providersContract] (
                startDate, endDate, contractType, contractDescription,
                status, authorizedSignatory, providerID
            )
            VALUES (
                @startDate,
                @endDate,
                @contractType,
                @contractDescription,
                1,
                @authorizedSignatory,
                @providerID
            );
            SET @providerContractID = SCOPE_IDENTITY();
            PRINT 'Contrato insertado: providerContractID = ' + CAST(@providerContractID AS VARCHAR(10));
        END
        ELSE
        BEGIN
            -- Actualizar contrato existente
            UPDATE [dbo].[st_providersContract]
            SET startDate = @startDate,
                endDate = @endDate,
                contractType = @contractType,
                contractDescription = @contractDescription,
                authorizedSignatory = @authorizedSignatory
            WHERE providerContractID = @providerContractID;
            PRINT 'Contrato actualizado: providerContractID = ' + CAST(@providerContractID AS VARCHAR(10));
        END;

        -- 3. Procesar las condiciones del contrato (TVP) usando MERGE
        MERGE INTO [dbo].[st_contractDetails] AS target
        USING (
            SELECT 
                CASE 
                    WHEN providerContractID IS NULL THEN @providerContractID 
                    ELSE providerContractID 
                END AS providerContractID,
                serviceBasePrice,
                discount,
                includesIVA,
                contractPrice,
                finalPrice,
                IVA,
                providerProfit,
                solturaProfit,
                profit,
                solturaFee,
                enabled,
                providerServicesID,
                serviceAvailabilityID,
                discountTypeID,
                isMembership,
                validFrom,
                validTo,
                usageUnitTypeID,
                usageValue,
                maxUses,
                bundleQuantity,
                bundlePrice
            FROM @contractDetails
        ) AS source
        ON target.providerContractID = source.providerContractID
        AND target.providerServicesID = source.providerServicesID
        AND target.serviceAvailabilityID = source.serviceAvailabilityID
        WHEN MATCHED THEN
            UPDATE SET
                serviceBasePrice = source.serviceBasePrice,
                discount = source.discount,
                includesIVA = source.includesIVA,
                contractPrice = source.contractPrice,
                finalPrice = source.finalPrice,
                IVA = source.IVA,
                providerProfit = source.providerProfit,
                solturaProfit = source.solturaProfit,
                profit = source.profit,
                solturaFee = source.solturaFee,
                enabled = source.enabled,
                serviceAvailabilityID = source.serviceAvailabilityID,
                discountTypeID = source.discountTypeID,
                isMembership = source.isMembership,
                validFrom = source.validFrom,
                validTo = source.validTo,
                usageUnitTypeID = source.usageUnitTypeID,
                usageValue = source.usageValue,
                maxUses = source.maxUses,
                bundleQuantity = source.bundleQuantity,
                bundlePrice = source.bundlePrice,
                lastUpdated = GETDATE()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (
                providerContractID, serviceBasePrice, lastUpdated, createdAt,
                discount, includesIVA, contractPrice, finalPrice, IVA,
                providerProfit, solturaProfit, profit, solturaFee, enabled,
                providerServicesID, serviceAvailabilityID, discountTypeID,
                isMembership, validFrom, validTo, usageUnitTypeID, usageValue,
                maxUses, bundleQuantity, bundlePrice
            )
            VALUES (
                source.providerContractID,
                source.serviceBasePrice,
                GETDATE(),
                GETDATE(),
                source.discount,
                source.includesIVA,
                source.contractPrice,
                source.finalPrice,
                source.IVA,
                source.providerProfit,
                source.solturaProfit,
                source.profit,
                source.solturaFee,
                source.enabled,
                source.providerServicesID,
                source.serviceAvailabilityID,
                source.discountTypeID,
                source.isMembership,
                source.validFrom,
                source.validTo,
                source.usageUnitTypeID,
                source.usageValue,
                source.maxUses,
                source.bundleQuantity,
                source.bundlePrice
            );

        -- Imprimir cuántas filas fueron afectadas
        PRINT 'Filas insertadas/actualizadas en st_contractDetails: ' + CAST(@@ROWCOUNT AS VARCHAR(10));

        COMMIT TRANSACTION;
        PRINT 'UpdateProviderContract ejecutado exitosamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO