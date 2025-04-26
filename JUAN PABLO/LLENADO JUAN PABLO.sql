USE [Caso2DB]
GO

-- Monedas (CRC y USD)
INSERT INTO [dbo].[st_currencies] ([name], [acronym], [symbol], [country])
VALUES 
    ('Colón Costarricense', 'CRC', '₡', 'Costa Rica'),
    ('Dólar Estadounidense', 'USD', '$', 'Estados Unidos');
GO

-- Tipos de contacto
INSERT INTO [dbo].[st_contactType] ([name])
VALUES 
    ('Email'),
    ('Teléfono'),
    ('Dirección');
GO

-- Tipos de descuento
INSERT INTO [dbo].[st_discountType] ([name])
VALUES 
    ('Porcentaje'),
    ('Monto fijo'),
    ('Sin descuento');
GO

-- Tipos de disponibilidad de servicio
INSERT INTO [dbo].[st_serviceAvailability] ([name])
VALUES 
    ('Siempre disponible'),
    ('Horario limitado'),
    ('Por cita');
GO

-- Tipos de unidades de uso
INSERT INTO [dbo].[st_usageUnitType] ([name])
VALUES 
    ('Sesiones'),
    ('Horas'),
    ('Días'),
    ('Meses');
GO

-- Tipos de medios
INSERT INTO [dbo].[st_mediaTypes] ([name], [mediaExtension])
VALUES 
    ('Imagen', 'jpg'),
    ('Documento', 'pdf'),
    ('Video', 'mp4');
GO

-- Métodos de pago
INSERT INTO [dbo].[st_paymentMethod] ([name], [secretKey], [key], [apiURL], [logoURL], [configJSON], [lastUpdated], [enabled])
VALUES 
    ('Tarjeta de crédito', 0x1234, 0x5678, 'https://api.payment.com', 'https://logo.com/tc.jpg', '{"type":"credit"}', GETDATE(), 1),
    ('Transferencia bancaria', 0x9012, 0x3456, 'https://api.bank.com', 'https://logo.com/tb.jpg', '{"type":"bank"}', GETDATE(), 1);
GO

-- Tipos de transacción
INSERT INTO [dbo].[st_transactionType] ([name])
VALUES 
    ('Compra'),
    ('Reembolso');
GO

-- Subtipos de transacción
INSERT INTO [dbo].[st_transactionSubTypes] ([name])
VALUES 
    ('Suscripción'),
    ('Pago único');
GO

-- Llenado de st_serviceType (incluye todos los servicios de la imagen y las instrucciones)
INSERT INTO [dbo].[st_serviceType] ([name], [description])
VALUES 
    ('Gimnasio', 'Acceso a instalaciones de gimnasio y clases'),
    ('Salud', 'Servicios médicos y chequeos'),
    ('Parqueo', 'Espacios de parqueo reservados'),
    ('Entretenimiento', 'Acceso a eventos y actividades recreativas'),
    ('Lavandería', 'Servicios de lavandería y planchado'),
    ('Limpieza', 'Servicios de limpieza básica de hogar'),
    ('Combustible', 'Suministro de combustible (gasolina o diésel)'),
    ('Belleza', 'Servicios de belleza como corte de pelo'),
    ('Alimentación', 'Cenas y almuerzos seleccionados'),
    ('Telefonía', 'Planes móviles y servicios de comunicación');
GO
-- Llenado de st_planType (Premium, Familiar, Personalizado)
INSERT INTO [dbo].[st_planType] ([name], [description], [enabled], [createdAt], [lastUpdated])
VALUES 
    ('Premium', 'Plan con beneficios exclusivos y múltiples servicios', 1, GETDATE(), GETDATE()),
    ('Familiar', 'Plan diseñado para grupos o familias', 1, GETDATE(), GETDATE()),
    ('Personalizado', 'Plan adaptable a las necesidades del usuario', 1, GETDATE(), GETDATE());
GO

-- Llenado de Tasas de Cambio
INSERT INTO [dbo].[st_exchangeRate] (
    [currencyIdSource], [currencyIdDestiny], [startDate], [endDate], 
    [exchangeRate], [currentExchangeRate], [currencyID]
)
VALUES 
(1, 2, '2025-01-01', '2025-12-31', 0.0020, 1, 1),
(2, 1, '2025-01-01', '2025-12-31', 505.85, 1, 2);



USE [Caso2DB]
GO


--------------------------------------------------------------------------
-- Ver monedas
SELECT * FROM [dbo].[st_currencies];
GO

-- Ver tipos de contacto
SELECT * FROM [dbo].[st_contactType];
GO

-- Ver tipos de descuento
SELECT * FROM [dbo].[st_discountType];
GO

-- Ver tipos de disponibilidad de servicio
SELECT * FROM [dbo].[st_serviceAvailability];
GO

-- Ver tipos de unidades de uso
SELECT * FROM [dbo].[st_usageUnitType];
GO

-- Ver tipos de medios
SELECT * FROM [dbo].[st_mediaTypes];
GO

-- Ver métodos de pago
SELECT * FROM [dbo].[st_paymentMethod];
GO

-- Ver tipos de transacción
SELECT * FROM [dbo].[st_transactionType];
GO

-- Ver subtipos de transacción
SELECT * FROM [dbo].[st_transactionSubTypes];
GO

-- Ver tipos de servicio
SELECT * FROM [dbo].[st_serviceType];
GO

-- Ver tipos de plan
SELECT * FROM [dbo].[st_planType];
GO

----------------------------

USE [Caso2DB]
GO


-- Procedure para llenar proveedores Contratos y Servicios

CREATE PROCEDURE [dbo].[llenarProveedoresContratosYServicios]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT;
    DECLARE @providerID INT;
    DECLARE @serviceID INT;
    DECLARE @contractID INT;
    DECLARE @planID INT;
    DECLARE @providerServicesID INT;
    DECLARE @randomPrice DECIMAL(10, 2);
    DECLARE @randomQuantity INT;
    DECLARE @randomServiceTypeID INT;
    DECLARE @randomCurrencyID INT;

    -- 1. Llenar st_providers (7 proveedores)
    SET @i = 1;
    WHILE @i <= 7
    BEGIN
        INSERT INTO [dbo].[st_providers] ([name], [providerDescription], [status])
        VALUES (
            'Provider_' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR) + '_Inc',
            'Proveedor de servicios #' + CAST(@i AS VARCHAR),
            1
        );
        SET @i = @i + 1;
    END;

    -- 2. Llenar st_services (2-4 servicios por proveedor)
    DECLARE provider_cursor CURSOR FOR
    SELECT providerID FROM [dbo].[st_providers];
    OPEN provider_cursor;
    FETCH NEXT FROM provider_cursor INTO @providerID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @i = 1;
        SET @randomQuantity = 2 + ABS(CHECKSUM(NEWID())) % 3; -- Entre 2 y 4 servicios
        WHILE @i <= @randomQuantity
        BEGIN
            SET @randomServiceTypeID = 1 + ABS(CHECKSUM(NEWID())) % 10; -- Entre 1 y 10 (según st_serviceType)
            INSERT INTO [dbo].[st_services] ([enabled], [lastUpdated], [providersID], [serviceName], [logoURL], [Description], [serviceTypeID])
            VALUES (
                1,
                GETDATE(),
                @providerID,
                (SELECT [name] FROM [dbo].[st_serviceType] WHERE serviceTypeID = @randomServiceTypeID) + '_' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR),
                'https://logo.com/service_' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR) + '.jpg',
                'Servicio #' + CAST(@i AS VARCHAR) + ' del proveedor #' + CAST(@providerID AS VARCHAR),
                @randomServiceTypeID
            );
            SET @i = @i + 1;
        END;
        FETCH NEXT FROM provider_cursor INTO @providerID;
    END;
    CLOSE provider_cursor;
    DEALLOCATE provider_cursor;

    -- 3. Llenar st_providerServices (asociar servicios a proveedores)
    DECLARE service_cursor CURSOR FOR
    SELECT serviceID, providersID FROM [dbo].[st_services];
    OPEN service_cursor;
    FETCH NEXT FROM service_cursor INTO @serviceID, @providerID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO [dbo].[st_providerServices] ([providerID], [serviceID])
        VALUES (@providerID, @serviceID);
        FETCH NEXT FROM service_cursor INTO @serviceID, @providerID;
    END;
    CLOSE service_cursor;
    DEALLOCATE service_cursor;

    -- 4. Llenar st_providersContract (un contrato por proveedor)
    DECLARE contract_cursor CURSOR FOR
    SELECT providerID FROM [dbo].[st_providers];
    OPEN contract_cursor;
    FETCH NEXT FROM contract_cursor INTO @providerID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO [dbo].[st_providersContract] ([startDate], [endDate], [contractType], [contractDescription], [status], [authorizedSignatory], [providerID])
        VALUES (
            '2025-01-01',
            '2025-12-31',
            'Anual',
            'Contrato para proveedor #' + CAST(@providerID AS VARCHAR),
            1,
            0x1234,
            @providerID
        );
        FETCH NEXT FROM contract_cursor INTO @providerID;
    END;
    CLOSE contract_cursor;
    DEALLOCATE contract_cursor;

    -- 5. Llenar st_contractDetails (detalles de contratos)
    DECLARE contract_details_cursor CURSOR FOR
    SELECT providerContractID, providerID FROM [dbo].[st_providersContract];
    OPEN contract_details_cursor;
    FETCH NEXT FROM contract_details_cursor INTO @contractID, @providerID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE service_cursor_inner CURSOR FOR
        SELECT serviceID FROM [dbo].[st_services] WHERE providersID = @providerID;
        OPEN service_cursor_inner;
        FETCH NEXT FROM service_cursor_inner INTO @serviceID;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO [dbo].[st_providerServices] ([providerID], [serviceID])
            VALUES (@providerID, @serviceID);

            SET @providerServicesID = SCOPE_IDENTITY();
            SET @randomPrice = 1000 + (RAND() * 49000); -- Precio entre 1000 y 50000
            SET @randomQuantity = 1 + ABS(CHECKSUM(NEWID())) % 10; -- Cantidad entre 1 y 10
            INSERT INTO [dbo].[st_contractDetails] (
                [providerContractID], [serviceBasePrice], [lastUpdated], [createdAt], [discount], [includesIVA],
                [contractPrice], [finalPrice], [IVA], [providerProfit], [solturaProfit], [profit], [solturaFee],
                [enabled], [providerServicesID], [serviceAvailabilityID], [discountTypeID], [isMembership],
                [validFrom], [validTo], [usageUnitTypeID], [usageValue], [maxUses], [bundleQuantity], [bundlePrice]
            )
            VALUES (
                @contractID,
                @randomPrice,
                GETDATE(),
                GETDATE(),
                0.0,
                1,
                @randomPrice,
                @randomPrice,
                0.13,
                @randomPrice * 0.7,
                @randomPrice * 0.3,
                @randomPrice,
                @randomPrice * 0.1,
                1,
                @providerServicesID,
                1, -- Siempre disponible
                3, -- Sin descuento
                CASE WHEN RAND() > 0.5 THEN 1 ELSE 0 END,
                '2025-01-01',
                '2025-12-31',
                1 + ABS(CHECKSUM(NEWID())) % 4, -- Unidad de uso aleatoria
                @randomQuantity,
                @randomQuantity,
                NULL,
                NULL
            );
            FETCH NEXT FROM service_cursor_inner INTO @serviceID;
        END;
        CLOSE service_cursor_inner;
        DEALLOCATE service_cursor_inner;
        FETCH NEXT FROM contract_details_cursor INTO @contractID, @providerID;
    END;
    CLOSE contract_details_cursor;
    DEALLOCATE contract_details_cursor;

    -- 6. Llenar st_plans (7-9 planes)
    SET @i = 1;
    SET @randomQuantity = 7 + ABS(CHECKSUM(NEWID())) % 3; -- Entre 7 y 9 planes
    WHILE @i <= @randomQuantity
    BEGIN
        SET @randomPrice = 10000 + (RAND() * 50000); -- Precio entre 10000 y 60000
        SET @randomCurrencyID = 1 + ABS(CHECKSUM(NEWID())) % 2; -- CRC o USD
        INSERT INTO [dbo].[st_plans] ([planPrice], [postTime], [planName], [planTypeID], [currencyID], [description], [imageURL], [lastUpdated], [solturaPrice])
        VALUES (
            @randomPrice,
            GETDATE(),
            'Plan_' + CAST(@i AS VARCHAR) + '_' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR),
            1 + ABS(CHECKSUM(NEWID())) % 3, -- Premium, Familiar, Personalizado
            @randomCurrencyID,
            'Descripción del plan #' + CAST(@i AS VARCHAR),
            'https://logo.com/plan_' + CAST(@i AS VARCHAR) + '.jpg',
            GETDATE(),
            @randomPrice * 0.15
        );
        SET @i = @i + 1;
    END;

    -- 7. Llenar st_planServices (asociar servicios a planes)
    DECLARE plan_cursor CURSOR FOR
    SELECT planID FROM [dbo].[st_plans];
    OPEN plan_cursor;
    FETCH NEXT FROM plan_cursor INTO @planID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @i = 1;
        SET @randomQuantity = 2 + ABS(CHECKSUM(NEWID())) % 3; -- Entre 2 y 4 servicios por plan
        WHILE @i <= @randomQuantity
        BEGIN
            SET @serviceID = (SELECT TOP 1 serviceID FROM [dbo].[st_services] ORDER BY NEWID());
            SET @randomPrice = 1000 + (RAND() * 49000);
            SET @randomQuantity = 1 + ABS(CHECKSUM(NEWID())) % 10;
            INSERT INTO [dbo].[st_planServices] (
                [serviceID], [planID], [discountTypeID], [bundleQuantity], [bundlePrice],
                [originalPrice], [solturaPrice], [usageValue], [maxUses], [isMembership],
                [serviceAvailabilityTypeID], [validFrom], [validTo], [usageUnitTypeID]
            )
            VALUES (
                @serviceID,
                @planID,
                3, -- Sin descuento
                NULL,
                NULL,
                @randomPrice,
                @randomPrice * 0.1,
                @randomQuantity,
                @randomQuantity,
                CASE WHEN RAND() > 0.5 THEN 1 ELSE 0 END,
                1,
                '2025-01-01',
                '2025-12-31',
                1 + ABS(CHECKSUM(NEWID())) % 4
            );
            SET @i = @i + 1;
        END;
        FETCH NEXT FROM plan_cursor INTO @planID;
    END;
    CLOSE plan_cursor;
    DEALLOCATE plan_cursor;
END;
GO

EXEC llenarProveedoresContratosYServicios;

-----------------------------------------------------------------------------

-- Ver subtipos de transacción
SELECT * FROM [dbo].[st_transactionSubTypes];
GO

-- Ver tipos de servicio
SELECT * FROM [dbo].[st_serviceType];
GO

-- Ver tipos de plan
SELECT * FROM [dbo].[st_planType];
GO

-- Ver proveedores
SELECT * FROM [dbo].[st_providers];
GO

-- Ver servicios
SELECT * FROM [dbo].[st_services];
GO

-- Ver relación proveedores-servicios
SELECT * FROM [dbo].[st_providerServices];
GO

-- Ver contratos de proveedores
SELECT * FROM [dbo].[st_providersContract];
GO

-- Ver detalles de contratos
SELECT * FROM [dbo].[st_contractDetails];
GO

-- Ver planes
SELECT * FROM [dbo].[st_plans];
GO

-- Ver relación planes-servicios
SELECT * FROM [dbo].[st_planServices];
GO

-------------------------------------------------------------------------------


   