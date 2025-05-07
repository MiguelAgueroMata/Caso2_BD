USE [Caso2DB]
GO

-- Monedas (CRC y USD)
INSERT INTO [dbo].[st_currencies] ([name], [acronym], [symbol], [country])
VALUES 
    ('Colón Costarricense', 'CRC', '₡', 'Costa Rica'),
    ('Dólar Estadounidense', 'USD', '$', 'Estados Unidos'),
    ('Euro', 'EUR', '€', 'Europa'),
    ('Yen Japonés', 'JPY', '¥', 'Japón');
GO

-- Tipos de contacto
INSERT INTO [dbo].[st_contactType] ([name])
VALUES 
    ('Email'),
    ('Teléfono'),
    ('Dirección'),
    ('WhatsApp'),
    ('Telegram');
GO

-- Tipos de descuento
INSERT INTO [dbo].[st_discountType] ([name])
VALUES 
    ('Porcentaje'),
    ('Monto fijo'),
    ('Sin descuento'),
    ('Descuento por volumen'),
    ('Descuento estacional');
GO

-- Tipos de disponibilidad de servicio
INSERT INTO [dbo].[st_serviceAvailability] ([name])
VALUES 
    ('Siempre disponible'),
    ('Horario limitado'),
    ('Por cita'),
    ('Temporada alta'),
    ('Eventos especiales');
GO

-- Tipos de unidades de uso
INSERT INTO [dbo].[st_usageUnitType] ([name])
VALUES 
    ('Sesiones'),
    ('Horas'),
    ('Días'),
    ('Meses'),
    ('Años');
GO

-- Tipos de medios
INSERT INTO [dbo].[st_mediaTypes] ([name], [mediaExtension])
VALUES 
    ('Imagen', 'jpg'),
    ('Documento', 'pdf'),
    ('Video', 'mp4'),
    ('Audio', 'mp3'),
    ('Presentación', 'pptx');
GO


-- Métodos de pago (corregidos con valores binarios válidos)
INSERT INTO [dbo].[st_paymentMethod] ([name], [secretKey], [key], [apiURL], [logoURL], [configJSON], [lastUpdated], [enabled])
VALUES 
    ('Tarjeta de crédito', 0x12345678, 0x87654321, 'https://api.payment.com', 'https://logo.com/tc.jpg', '{"type":"credit"}', GETDATE(), 1),
    ('Transferencia bancaria', 0x90123456, 0x65432109, 'https://api.bank.com', 'https://logo.com/tb.jpg', '{"type":"bank"}', GETDATE(), 1),
    ('PayPal', 0xABCD1234, 0xDCBA4321, 'https://api.paypal.com', 'https://logo.com/pp.jpg', '{"type":"paypal"}', GETDATE(), 1),
    ('Criptomoneda', 0x56781234, 0x43218765, 'https://api.crypto.com', 'https://logo.com/crypto.jpg', '{"type":"crypto"}', GETDATE(), 1);
GO

-- Tipos de transacción
INSERT INTO [dbo].[st_transactionType] ([name])
VALUES 
    ('Compra'),
    ('Reembolso'),
    ('Ajuste'),
    ('Donación'),
    ('Transferencia');
GO

-- Subtipos de transacción
INSERT INTO [dbo].[st_transactionSubTypes] ([name])
VALUES 
    ('Suscripción'),
    ('Pago único'),
    ('Recarga'),
    ('Cancelación'),
    ('Membresía');
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
    ('Telefonía', 'Planes móviles y servicios de comunicación'),
    ('Educación', 'Cursos en línea y talleres'),
    ('Transporte', 'Servicios de traslado privado');
GO

-- Llenado de st_planType (Premium, Familiar, Personalizado)
INSERT INTO [dbo].[st_planType] ([name], [description], [enabled], [createdAt], [lastUpdated])
VALUES 
    ('Premium', 'Plan con beneficios exclusivos y múltiples servicios', 1, GETDATE(), GETDATE()),
    ('Familiar', 'Plan diseñado para grupos o familias', 1, GETDATE(), GETDATE()),
    ('Personalizado', 'Plan adaptable a las necesidades del usuario', 1, GETDATE(), GETDATE()),
    ('Básico', 'Plan con servicios esenciales', 1, GETDATE(), GETDATE()),
    ('Empresarial', 'Plan para empresas y equipos', 1, GETDATE(), GETDATE());
GO

-- Llenado de Tasas de Cambio
INSERT INTO [dbo].[st_exchangeRate] (
    [currecyIdSource], [currencyIdDestiny], [startDate], [endDate], 
    [exhangeRate], [currentExchangeRate], [currencyID]
)
VALUES 
(1, 2, '2025-01-01', '2025-12-31', 0.0020, 1, 1),
(2, 1, '2025-01-01', '2025-12-31', 505.85, 1, 2),
(1, 3, '2025-01-01', '2025-12-31', 0.0018, 1, 1),
(3, 1, '2025-01-01', '2025-12-31', 550.00, 1, 3),
(2, 4, '2025-01-01', '2025-12-31', 0.0075, 1, 2),
(4, 2, '2025-01-01', '2025-12-31', 133.33, 1, 4);

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

-- Ver tipos de cambios
SELECT * FROM [dbo].[st_exchangeRate];
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

    -- 1. Llenar st_providers (15 proveedores)
    SET @i = 1;
    WHILE @i <= 15
    BEGIN
        INSERT INTO [dbo].[st_providers] ([name], [providerDescription], [status])
        VALUES (
            'Provider_' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR) + '_Inc',
            'Proveedor de servicios #' + CAST(@i AS VARCHAR),
            1
        );
        SET @i = @i + 1;
    END;

    -- 2. Llenar st_services (4-6 servicios por proveedor)
    DECLARE provider_cursor CURSOR FOR
    SELECT providerID FROM [dbo].[st_providers];
    OPEN provider_cursor;
    FETCH NEXT FROM provider_cursor INTO @providerID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @i = 1;
        SET @randomQuantity = 4 + ABS(CHECKSUM(NEWID())) % 3; -- Entre 4 y 6 servicios
        WHILE @i <= @randomQuantity
        BEGIN
            SET @randomServiceTypeID = 1 + ABS(CHECKSUM(NEWID())) % 12; -- Entre 1 y 12 (según st_serviceType)
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
            SET @randomPrice = 2000 + (RAND() * 98000); -- Precio entre 2000 y 100000
            SET @randomQuantity = 2 + ABS(CHECKSUM(NEWID())) % 20; -- Cantidad entre 2 y 21
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
                1 + ABS(CHECKSUM(NEWID())) % 5, -- Entre 1 y 5
                1 + ABS(CHECKSUM(NEWID())) % 5, -- Entre 1 y 5
                CASE WHEN RAND() > 0.5 THEN 1 ELSE 0 END,
                '2025-01-01',
                '2025-12-31',
                1 + ABS(CHECKSUM(NEWID())) % 5, -- Entre 1 y 5
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

    -- 6. Llenar st_plans (14-18 planes)
    SET @i = 1;
    SET @randomQuantity = 14 + ABS(CHECKSUM(NEWID())) % 5; -- Entre 14 y 18 planes
    WHILE @i <= @randomQuantity
    BEGIN
        SET @randomPrice = 20000 + (RAND() * 100000); -- Precio entre 20000 y 120000
        SET @randomCurrencyID = 1 + ABS(CHECKSUM(NEWID())) % 4; -- CRC, USD, EUR, JPY
        INSERT INTO [dbo].[st_plans] ([planPrice], [postTime], [planName], [planTypeID], [currencyID], [description], [imageURL], [lastUpdated], [solturaPrice])
        VALUES (
            @randomPrice,
            GETDATE(),
            'Plan_' + CAST(@i AS VARCHAR) + '_' + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS VARCHAR),
            1 + ABS(CHECKSUM(NEWID())) % 5, -- Premium, Familiar, Personalizado, Básico, Empresarial
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
        SET @randomQuantity = 4 + ABS(CHECKSUM(NEWID())) % 5; -- Entre 4 y 8 servicios por plan
        WHILE @i <= @randomQuantity
        BEGIN
            SET @serviceID = (SELECT TOP 1 serviceID FROM [dbo].[st_services] ORDER BY NEWID());
            SET @randomPrice = 2000 + (RAND() * 98000);
            SET @randomQuantity = 2 + ABS(CHECKSUM(NEWID())) % 20;
            INSERT INTO [dbo].[st_planServices] (
                [serviceID], [planID], [discountTypeID], [bundleQuantity], [bundlePrice],
                [originalPrice], [solturaPrice], [usageValue], [maxUses], [isMembership],
                [serviceAvailabilityTypeID], [validFrom], [validTo], [usageUnitTypeID]
            )
            VALUES (
                @serviceID,
                @planID,
                1 + ABS(CHECKSUM(NEWID())) % 5, -- Entre 1 y 5
                NULL,
                NULL,
                @randomPrice,
                @randomPrice * 0.1,
                @randomQuantity,
                @randomQuantity,
                CASE WHEN RAND() > 0.5 THEN 1 ELSE 0 END,
                1 + ABS(CHECKSUM(NEWID())) % 5,
                '2025-01-01',
                '2025-12-31',
                1 + ABS(CHECKSUM(NEWID())) % 5
            );
            SET @i = @i + 1;
        END;
        FETCH NEXT FROM plan_cursor INTO @planID;
    END;
    CLOSE plan_cursor;
    DEALLOCATE plan_cursor;
END;
GO

-- Ejecutar el procedimiento
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

USE [Caso2DB]
GO

                                        --LLENADOS DE LUIS--
                                        --LLENADOS DE LUIS--
                                        --LLENADOS DE LUIS--
                                        --LLENADOS DE LUIS--

-- Insertar permisos básicos para el sistema Soltura
INSERT INTO [dbo].[st_Permissions] ([description], [accessLevel], [createdAt], [lastUpdated], [enabled])
VALUES 
    ('Ver planes y servicios', 1, GETDATE(), GETDATE(), 1),
    ('Realizar pagos', 1, GETDATE(), GETDATE(), 1),
    ('Gestionar suscripciones', 1, GETDATE(), GETDATE(), 1),
    ('Administrar usuarios', 3, GETDATE(), GETDATE(), 1),
    ('Administrar proveedores', 3, GETDATE(), GETDATE(), 1),
    ('Ver reportes financieros', 2, GETDATE(), GETDATE(), 1),
    ('Gestionar inventario', 2, GETDATE(), GETDATE(), 1),
    ('Configurar promociones', 2, GETDATE(), GETDATE(), 1);
GO

-- Insertar 6 roles: Cliente, Administrador, Proveedor, Gerente, Soporte, Marketing
INSERT INTO [dbo].[st_Roles] ([roleName], [description], [createdAt], [lastUpdated], [enabled])
VALUES 
    ('Cliente', 'Usuario con acceso a planes y pagos', GETDATE(), GETDATE(), 1),
    ('Administrador', 'Usuario con acceso completo al sistema', GETDATE(), GETDATE(), 1),
    ('Proveedor', 'Usuario que gestiona servicios de proveedores', GETDATE(), GETDATE(), 1),
    ('Gerente', 'Usuario con acceso a reportes y gestión parcial', GETDATE(), GETDATE(), 1),
    ('Soporte', 'Usuario para asistencia técnica', GETDATE(), GETDATE(), 1),
    ('Marketing', 'Usuario para campañas y promociones', GETDATE(), GETDATE(), 1);
GO

-- Insertar permisos a roles según sus responsabilidades.
INSERT INTO [dbo].[st_roles_has_st_permissions] ([rolesID], [permissionID])
VALUES 
    -- Cliente: permisos básicos
    (1, 1), (1, 2), (1, 3),
    -- Administrador: todos los permisos
    (2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 6), (2, 7), (2, 8),
    -- Proveedor: permisos relacionados con servicios
    (3, 5),
    -- Gerente: permisos de reportes y suscripciones
    (4, 3), (4, 6),
    -- Soporte: permisos de asistencia
    (5, 1), (5, 3),
    -- Marketing: permisos de promociones
    (6, 8);
GO

-- Procedure para llenar usuarios, asignar roles a usuarios, suscripciones, y permisos a usuarios.
CREATE PROCEDURE [dbo].[llenarUsuariosAutenticacionYSuscripciones]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @userID INT;
    DECLARE @planID INT;
    DECLARE @planCount INT;
    DECLARE @subsPerPlan TABLE (planID INT, subsCount INT);
    DECLARE @userNames TABLE (firstName VARCHAR(45), lastName VARCHAR(45));

    -- Lista de nombres y apellidos realistas para Costa Rica
    INSERT INTO @userNames (firstName, lastName)
    VALUES 
        ('Juan', 'Rodríguez'), ('María', 'González'), ('Carlos', 'Mora'), ('Ana', 'Vargas'), 
        ('Luis', 'Jiménez'), ('Sofía', 'Hernández'), ('Diego', 'Soto'), ('Laura', 'López'), 
        ('José', 'Chavarría'), ('Valeria', 'Ramírez'), ('Andrés', 'Araya'), ('Camila', 'Solano'), 
        ('Gabriel', 'Cordero'), ('Isabella', 'Brenes'), ('Miguel', 'Gómez'), ('Emma', 'Pérez'), 
        ('Alejandro', 'Fallas'), ('Lucía', 'Alvarado'), ('Sebastián', 'Castro'), ('Daniela', 'Rojas'), 
        ('Rafael', 'Sánchez'), ('Victoria', 'Madrigal'), ('Pablo', 'Venegas'), ('Clara', 'Ureña'), 
        ('Santiago', 'Barquero'), ('Elena', 'Leitón'), ('Mateo', 'Segura'), ('Natalia', 'Céspedes'), 
        ('Adrián', 'Blanco'), ('Paula', 'Salazar'), ('Ricardo', 'Quesada'), ('Fernanda', 'Guerrero');

    -- 1. Llenar st_users (60 usuarios)
    WHILE @i <= 60
    BEGIN
        DECLARE @firstName VARCHAR(45) = (SELECT firstName FROM @userNames ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY);
        DECLARE @lastName VARCHAR(45) = (SELECT lastName FROM @userNames ORDER BY NEWID() OFFSET 0 ROWS FETCH NEXT 1 ROW ONLY);
        
        INSERT INTO [dbo].[st_users] ([firstName], [lastName], [password], [enabled], [birthDate], [createdAt])
        VALUES (
            @firstName,
            @lastName,
            CONVERT(VARBINARY(250), @firstName + @lastName + CAST(@i AS VARCHAR)), -- Contraseña simulada
            1,
            DATEADD(YEAR, -1 * (20 + ABS(CHECKSUM(NEWID())) % 40), GETDATE()), -- Edad entre 20 y 60
            GETDATE()
        );

        SET @userID = SCOPE_IDENTITY();

        -- 2. Asignar roles en st_roles_has_st_users
        IF @i <= 5 -- Primeros 5 usuarios son Administradores
            INSERT INTO [dbo].[st_roles_has_st_users] ([roleID]) VALUES (2); -- Administrador
        ELSE IF @i <= 10 -- Siguientes 5 usuarios son Proveedores
            INSERT INTO [dbo].[st_roles_has_st_users] ([roleID]) VALUES (3); -- Proveedor
        ELSE IF @i <= 15 -- Siguientes 5 usuarios son Gerentes
            INSERT INTO [dbo].[st_roles_has_st_users] ([roleID]) VALUES (4); -- Gerente
        ELSE IF @i <= 20 -- Siguientes 5 usuarios son Soporte
            INSERT INTO [dbo].[st_roles_has_st_users] ([roleID]) VALUES (5); -- Soporte
        ELSE IF @i <= 25 -- Siguientes 5 usuarios son Marketing
            INSERT INTO [dbo].[st_roles_has_st_users] ([roleID]) VALUES (6); -- Marketing
        ELSE -- Resto son Clientes
            INSERT INTO [dbo].[st_roles_has_st_users] ([roleID]) VALUES (1); -- Cliente

        -- 3. Asignar permisos específicos en st_permissions_has_st_users (ejemplo: permisos adicionales para gerentes)
        IF @i BETWEEN 11 AND 15 -- Gerentes tienen permiso adicional de reportes
            INSERT INTO [dbo].[st_permissions_has_st_users] ([permissionID], [userID]) VALUES (6, @userID); -- Ver reportes financieros
        IF @i BETWEEN 16 AND 20 -- Soporte tiene permiso adicional de suscripciones
            INSERT INTO [dbo].[st_permissions_has_st_users] ([permissionID], [userID]) VALUES (3, @userID); -- Gestionar suscripciones
        IF @i BETWEEN 21 AND 25 -- Marketing tiene permiso adicional de promociones
            INSERT INTO [dbo].[st_permissions_has_st_users] ([permissionID], [userID]) VALUES (8, @userID); -- Configurar promociones

        SET @i = @i + 1;
    END;

    -- 4. Llenar st_subcriptions (50 suscripciones, máximo 10 por plan)
    -- Inicializar contador de suscripciones por plan
    INSERT INTO @subsPerPlan (planID, subsCount)
    SELECT planID, 0 FROM [dbo].[st_plans];

    SET @i = 1; -- Comenzar desde el usuario 1
    WHILE @i <= 50 -- Hasta cubrir 50 suscripciones
    BEGIN
        -- Seleccionar un plan con menos de 10 suscripciones
        SELECT TOP 1 @planID = planID 
        FROM @subsPerPlan 
        WHERE subsCount < 10 
        ORDER BY NEWID(); -- Aleatorio

        IF @planID IS NOT NULL
        BEGIN
            INSERT INTO [dbo].[st_subcriptions] ([description], [logoURL], [enabled], [planTypeID], [userID])
            SELECT 
                'Suscripción al plan ' + p.planName,
                p.imageURL,
                1,
                p.planTypeID,
                u.userID
            FROM [dbo].[st_plans] p
            CROSS JOIN (SELECT TOP 1 userID FROM [dbo].[st_users] WHERE userID >= @i AND userID <= 60 ORDER BY NEWID()) u
            WHERE p.planID = @planID;

            -- Incrementar contador de suscripciones para el plan
            UPDATE @subsPerPlan SET subsCount = subsCount + 1 WHERE planID = @planID;
            SET @i = @i + 1;
        END;
    END;
END;
GO

-- Ejecutar el procedimiento
EXEC [dbo].[llenarUsuariosAutenticacionYSuscripciones];
GO

-----------------------------------------------------------------------------

-- Ver usuarios
SELECT * FROM [dbo].[st_users];
GO

-- Ver permisos
SELECT * FROM [dbo].[st_Permissions];
GO

-- Ver asignación de permisos a usuarios
SELECT * FROM [dbo].[st_permissions_has_st_users];
GO

-- Ver roles
SELECT * FROM [dbo].[st_Roles];
GO

-- Ver asignación de roles a permisos
SELECT * FROM [dbo].[st_roles_has_st_permissions];
GO

-- Ver asignación de roles a usuarios
SELECT * FROM [dbo].[st_roles_has_st_users];
GO

-- Ver suscripciones
SELECT * FROM [dbo].[st_subcriptions];
GO

---------------------------------------------------------------------------

-- Procedure para asignar beneficiarios a planes
CREATE PROCEDURE [dbo].[llenarBeneficiariesPerPlan]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @subscriptionID INT;
    DECLARE @userID INT;
    DECLARE @planTypeID INT;
    DECLARE @beneficiaryCount INT;

    -- Cursor para recorrer suscripciones
    DECLARE sub_cursor CURSOR FOR
    SELECT s.subcriptionID, s.planTypeID, s.userID
    FROM [dbo].[st_subcriptions] s
    JOIN [dbo].[st_plans] p ON s.planTypeID = p.planTypeID
    WHERE p.planTypeID = 2; -- Solo planes familiares

    OPEN sub_cursor;
    FETCH NEXT FROM sub_cursor INTO @subscriptionID, @planTypeID, @userID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar 2-5 beneficiarios por suscripción familiar
        SET @beneficiaryCount = 2 + ABS(CHECKSUM(NEWID())) % 4;
        WHILE @beneficiaryCount > 0
        BEGIN
            -- Seleccionar un usuario diferente al titular como beneficiario
            SELECT TOP 1 @userID = u.userID
            FROM [dbo].[st_users] u
            LEFT JOIN [dbo].[st_beneficiariesPerPlan] b ON u.userID = b.userID AND b.subscriptionID = @subscriptionID
            WHERE u.userID != (SELECT userID FROM [dbo].[st_subcriptions] WHERE subcriptionID = @subscriptionID) AND b.beneficiarieID IS NULL
            ORDER BY NEWID();

            IF @userID IS NOT NULL
            BEGIN
                INSERT INTO [dbo].[st_beneficiariesPerPlan] ([startDate], [endDate], [subscriptionID], [userID], [enabled])
                VALUES (
                    GETDATE(),
                    DATEADD(YEAR, 1, GETDATE()),
                    @subscriptionID,
                    @userID,
                    1
                );
            END;
            SET @beneficiaryCount = @beneficiaryCount - 1;
        END;
        FETCH NEXT FROM sub_cursor INTO @subscriptionID, @planTypeID, @userID;
    END;
    CLOSE sub_cursor;
    DEALLOCATE sub_cursor;

    -- Asignar beneficiarios a planes no familiares (titular como beneficiario)
    DECLARE sub_cursor_all CURSOR FOR
    SELECT s.subcriptionID, s.userID
    FROM [dbo].[st_subcriptions] s;
    OPEN sub_cursor_all;
    FETCH NEXT FROM sub_cursor_all INTO @subscriptionID, @userID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar si el titular ya está como beneficiario
        IF NOT EXISTS (
            SELECT 1 FROM [dbo].[st_beneficiariesPerPlan]
            WHERE subscriptionID = @subscriptionID AND userID = @userID
        )
        BEGIN
            INSERT INTO [dbo].[st_beneficiariesPerPlan] ([startDate], [endDate], [subscriptionID], [userID], [enabled])
            VALUES (
                GETDATE(),
                DATEADD(YEAR, 1, GETDATE()),
                @subscriptionID,
                @userID,
                1
            );
        END;
        FETCH NEXT FROM sub_cursor_all INTO @subscriptionID, @userID;
    END;
    CLOSE sub_cursor_all;
    DEALLOCATE sub_cursor_all;
END;
GO

-- Ejecutar el procedimiento
EXEC [dbo].[llenarBeneficiariesPerPlan];
GO

-- Procedure para llenar pagos y transacciones (corregido)
CREATE PROCEDURE [dbo].[llenarPagosYTransacciones]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @subscriptionID INT;
    DECLARE @userID INT;
    DECLARE @planPrice DECIMAL(10, 2);
    DECLARE @currencyID INT;
    DECLARE @paymentID INT;
    DECLARE @paymentDate DATETIME;
    DECLARE @i INT;
    DECLARE @maxPaymentMethodID INT;

    -- Obtener el máximo paymentMethodID disponible
    SELECT @maxPaymentMethodID = MAX(paymentMethodID) FROM [dbo].[st_paymentMethod];

    -- Cursor para recorrer suscripciones
    DECLARE sub_cursor CURSOR FOR
    SELECT s.subcriptionID, s.userID, p.planPrice, p.currencyID
    FROM [dbo].[st_subcriptions] s
    JOIN [dbo].[st_plans] p ON s.planTypeID = p.planTypeID;

    OPEN sub_cursor;
    FETCH NEXT FROM sub_cursor INTO @subscriptionID, @userID, @planPrice, @currencyID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Determinar fecha de pago (primeros 3 días del mes, evitando fines de semana)
        SET @paymentDate = '2025-04-01'; -- Ejemplo: 1 de abril de 2025 (martes)
        IF DATEPART(WEEKDAY, @paymentDate) IN (1, 7) -- Domingo o sábado
            SET @paymentDate = DATEADD(DAY, 2, @paymentDate);

        -- Insertar 2-4 pagos por suscripción
        SET @i = 1 + ABS(CHECKSUM(NEWID())) % 3;
        WHILE @i > 0
        BEGIN
            DECLARE @paymentMethodID INT = 1 + ABS(CHECKSUM(NEWID())) % @maxPaymentMethodID; -- Asegurar que no exceda los IDs existentes
            INSERT INTO [dbo].[st_payments] (
                [paymentMethodID], [amount], [actualAmount], [result], [authentication], 
                [reference], [chargedToken], [description], [error], [paymentDate], 
                [checksum], [currencyID]
            )
            VALUES (
                @paymentMethodID,
                @planPrice,
                @planPrice,
                'Success',
                'AUTH_' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR),
                'REF_' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR),
                CONVERT(VARBINARY(250), 'TOKEN_' + CAST(@subscriptionID AS VARCHAR)),
                'Pago mensual suscripción ' + CAST(@subscriptionID AS VARCHAR),
                NULL,
                @paymentDate,
                CONVERT(VARBINARY(250), 'CHECKSUM_' + CAST(@subscriptionID AS VARCHAR)),
                @currencyID
            );

            SET @paymentID = SCOPE_IDENTITY();

            -- Insertar transacción
            INSERT INTO [dbo].[st_transactions] (
                [transactionAmount], [description], [transactionDate], [postTime], 
                [referenceNumber], [convertedAmount], [checksum], [currencyID], 
                [exchangeRateId], [paymentId], [userID], [transactionTypeID], 
                [transactionSubTypeID]
            )
            VALUES (
                @planPrice,
                'Transacción pago suscripción ' + CAST(@subscriptionID AS VARCHAR),
                @paymentDate,
                GETDATE(),
                'TX_' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR),
                @planPrice,
                CONVERT(VARBINARY(250), 'TX_CHECKSUM_' + CAST(@subscriptionID AS VARCHAR)),
                @currencyID,
                CASE WHEN @currencyID = 1 THEN 1 ELSE 2 END, -- Exchange rate CRC o USD
                @paymentID,
                @userID,
                1 + ABS(CHECKSUM(NEWID())) % 5, -- Entre 1 y 5
                1 + ABS(CHECKSUM(NEWID())) % 5  -- Entre 1 y 5
            );

            SET @i = @i - 1;
        END;
        FETCH NEXT FROM sub_cursor INTO @subscriptionID, @userID, @planPrice, @currencyID;
    END;
    CLOSE sub_cursor;
    DEALLOCATE sub_cursor;
END;
GO

-- Ejecutar el procedimiento
EXEC [dbo].[llenarPagosYTransacciones];
GO


-- Procedure para llenar schedule y detalles del schedule
CREATE PROCEDURE [dbo].[llenarSchedulesYDetails]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @subscriptionID INT;
    DECLARE @scheduleID INT;
    DECLARE @startDate DATETIME = '2025-04-01';
    DECLARE @i INT;

    -- Cursor para recorrer suscripciones
    DECLARE sub_cursor CURSOR FOR
    SELECT subcriptionID FROM [dbo].[st_subcriptions];

    OPEN sub_cursor;
    FETCH NEXT FROM sub_cursor INTO @subscriptionID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Insertar programación mensual
        INSERT INTO [dbo].[st_schedules] (
            [name], [recurrencyType], [repeat], [endDate], [subcriptionID]
        )
        VALUES (
            'Cobro mensual suscripción ' + CAST(@subscriptionID AS VARCHAR),
            1, -- Mensual
            'Every 1 month',
            DATEADD(YEAR, 2, @startDate),
            @subscriptionID
        );

        SET @scheduleID = SCOPE_IDENTITY();

        -- Insertar detalles de programación (24 meses)
        SET @i = 0;
        WHILE @i < 24
        BEGIN
            DECLARE @executionDate DATETIME = DATEADD(MONTH, @i, @startDate);
            INSERT INTO [dbo].[st_scheduleDetails] (
                [deleted], [baseDate], [datePart], [lastExecution], [nextExecution], [scheduleID]
            )
            VALUES (
                0,
                @executionDate,
                'First day of month',
                NULL,
                @executionDate,
                @scheduleID
            );
            SET @i = @i + 1;
        END;

        FETCH NEXT FROM sub_cursor INTO @subscriptionID;
    END;
    CLOSE sub_cursor;
    DEALLOCATE sub_cursor;
END;
GO

-- Ejecutar el procedimiento
EXEC [dbo].[llenarSchedulesYDetails];
GO

------------------------------------------------------------------------------

-- Ver suscripciones
SELECT * FROM [dbo].[st_subcriptions];
GO

-- Ver beneficiarios por plan
SELECT * FROM [dbo].[st_beneficiariesPerPlan];
GO

-- Ver pagos
SELECT * FROM [dbo].[st_payments];
GO

-- Ver transacciones
SELECT * FROM [dbo].[st_transactions];
GO

-- Ver programaciones
SELECT * FROM [dbo].[st_schedules];
GO

-- Ver detalles de programaciones
SELECT * FROM [dbo].[st_scheduleDetails];
GO

------------------------------------------------------------------------------

-- Procedure para llenar mediaFiles y archivos multimedia por contrato de proveedor
CREATE OR ALTER PROCEDURE [dbo].[llenarMediaFilesYProvidersMediaFiles]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @providerContractID INT;
    DECLARE @mediaFileID INT;
    DECLARE @adminUserID INT;
    DECLARE @mediaTypes TABLE (mediaTypeID INT, name VARCHAR(45), extension VARCHAR(10));
    DECLARE @i INT;

    -- Obtener un usuario válido para uploadedBy (usar el primer usuario si no hay administradores)
    SELECT @adminUserID = COALESCE(
        (SELECT TOP 1 u.userID 
         FROM [dbo].[st_users] u
         JOIN [dbo].[st_roles_has_st_users] rhu ON u.userID = rhu.userID
         WHERE rhu.roleID = 2), -- Intentar obtener un administrador
        (SELECT TOP 1 userID FROM [dbo].[st_users]) -- Usar el primer usuario si no hay administradores
    );

    -- Obtener tipos de medios
    INSERT INTO @mediaTypes (mediaTypeID, name, extension)
    SELECT mediaTypeID, name, mediaExtension FROM [dbo].[st_mediaTypes];

    -- Cursor para recorrer contratos de proveedores
    DECLARE contract_cursor CURSOR FOR
    SELECT providerContractID FROM [dbo].[st_providersContract];

    OPEN contract_cursor;
    FETCH NEXT FROM contract_cursor INTO @providerContractID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar 2-4 archivos por contrato
        SET @i = 2 + ABS(CHECKSUM(NEWID())) % 3;
        WHILE @i > 0
        BEGIN
            DECLARE @mediaTypeID INT = (SELECT TOP 1 mediaTypeID FROM @mediaTypes ORDER BY NEWID());
            DECLARE @mediaName VARCHAR(45) = CASE 
                WHEN @mediaTypeID = 1 THEN 'logo_provider_' + CAST(@providerContractID AS VARCHAR) + '.jpg'
                WHEN @mediaTypeID = 2 THEN 'contract_' + CAST(@providerContractID AS VARCHAR) + '.pdf'
                ELSE 'promo_video_' + CAST(@providerContractID AS VARCHAR) + '.mp4'
            END;
            DECLARE @extension VARCHAR(10) = (SELECT extension FROM @mediaTypes WHERE mediaTypeID = @mediaTypeID);

            -- Insertar en st_MediaFiles
            INSERT INTO [dbo].[st_MediaFiles] (
                [deleted], [mediaTypeID], [fileURL], [fileName], [lastUpdated], [fileSize], [uploadedBy], [status]
            )
            VALUES (
                0,
                @mediaTypeID,
                'https://soltura-media.com/files/' + @mediaName,
                @mediaName,
                GETDATE(),
                2000 + ABS(CHECKSUM(NEWID())) % 10000, -- Tamaño entre 2000 y 12000 KB
                @adminUserID,
                'Active'
            );

            SET @mediaFileID = SCOPE_IDENTITY();

            -- Insertar en st_providersMediaFiles
            INSERT INTO [dbo].[st_providersMediaFiles] ([providerContractID], [mediaFileID])
            VALUES (@providerContractID, @mediaFileID);

            SET @i = @i - 1;
        END;
        FETCH NEXT FROM contract_cursor INTO @providerContractID;
    END;
    CLOSE contract_cursor;
    DEALLOCATE contract_cursor;
END;
GO

-- Ejecutar el procedimiento
EXEC [dbo].[llenarMediaFilesYProvidersMediaFiles];
GO

-- Información de contacto del proveedor
INSERT INTO [dbo].[st_providerContactInfo] (
    [contact], [enabled], [createdAt], [lastUpdated], [providerID], [description], [ContactTypeID]
)
VALUES 
    -- Proveedor 1
    ('contacto@provider1.com', 1, GETDATE(), GETDATE(), 1, 'Correo principal', 1),
    ('+506 2222 1111', 1, GETDATE(), GETDATE(), 1, 'Teléfono principal', 2),
    ('San José, Costa Rica', 1, GETDATE(), GETDATE(), 1, 'Dirección principal', 3),
    ('+506 8888 1111', 1, GETDATE(), GETDATE(), 1, 'WhatsApp secundario', 4),
    -- Proveedor 2
    ('info@provider2.com', 1, GETDATE(), GETDATE(), 2, 'Correo principal', 1),
    ('+506 2222 2222', 1, GETDATE(), GETDATE(), 2, 'Teléfono principal', 2),
    ('Heredia, Costa Rica', 1, GETDATE(), GETDATE(), 2, 'Dirección principal', 3),
    ('+506 8888 2222', 1, GETDATE(), GETDATE(), 2, 'WhatsApp secundario', 4),
    -- Proveedor 3
    ('support@provider3.com', 1, GETDATE(), GETDATE(), 3, 'Correo principal', 1),
    ('+506 2222 3333', 1, GETDATE(), GETDATE(), 3, 'Teléfono principal', 2),
    ('Alajuela, Costa Rica', 1, GETDATE(), GETDATE(), 3, 'Dirección principal', 3),
    ('+506 8888 3333', 1, GETDATE(), GETDATE(), 3, 'WhatsApp secundario', 4),
    -- Proveedor 4
    ('contact@provider4.com', 1, GETDATE(), GETDATE(), 4, 'Correo principal', 1),
    ('+506 2222 4444', 1, GETDATE(), GETDATE(), 4, 'Teléfono principal', 2),
    ('Cartago, Costa Rica', 1, GETDATE(), GETDATE(), 4, 'Dirección principal', 3),
    ('+506 8888 4444', 1, GETDATE(), GETDATE(), 4, 'WhatsApp secundario', 4),
    -- Proveedor 5
    ('info@provider5.com', 1, GETDATE(), GETDATE(), 5, 'Correo principal', 1),
    ('+506 2222 5555', 1, GETDATE(), GETDATE(), 5, 'Teléfono principal', 2),
    ('Guanacaste, Costa Rica', 1, GETDATE(), GETDATE(), 5, 'Dirección principal', 3),
    ('+506 8888 5555', 1, GETDATE(), GETDATE(), 5, 'WhatsApp secundario', 4),
    -- Proveedor 6
    ('support@provider6.com', 1, GETDATE(), GETDATE(), 6, 'Correo principal', 1),
    ('+506 2222 6666', 1, GETDATE(), GETDATE(), 6, 'Teléfono principal', 2),
    ('Puntarenas, Costa Rica', 1, GETDATE(), GETDATE(), 6, 'Dirección principal', 3),
    ('+506 8888 6666', 1, GETDATE(), GETDATE(), 6, 'WhatsApp secundario', 4),
    -- Proveedor 7
    ('contact@provider7.com', 1, GETDATE(), GETDATE(), 7, 'Correo principal', 1),
    ('+506 2222 7777', 1, GETDATE(), GETDATE(), 7, 'Teléfono principal', 2),
    ('Limón, Costa Rica', 1, GETDATE(), GETDATE(), 7, 'Dirección principal', 3),
    ('+506 8888 7777', 1, GETDATE(), GETDATE(), 7, 'WhatsApp secundario', 4),
    -- Proveedor 8
    ('info@provider8.com', 1, GETDATE(), GETDATE(), 8, 'Correo principal', 1),
    ('+506 2222 8888', 1, GETDATE(), GETDATE(), 8, 'Teléfono principal', 2),
    ('San José, Costa Rica', 1, GETDATE(), GETDATE(), 8, 'Dirección principal', 3),
    ('+506 8888 8888', 1, GETDATE(), GETDATE(), 8, 'WhatsApp secundario', 4),
    -- Proveedor 9
    ('support@provider9.com', 1, GETDATE(), GETDATE(), 9, 'Correo principal', 1),
    ('+506 2222 9999', 1, GETDATE(), GETDATE(), 9, 'Teléfono principal', 2),
    ('Heredia, Costa Rica', 1, GETDATE(), GETDATE(), 9, 'Dirección principal', 3),
    ('+506 8888 9999', 1, GETDATE(), GETDATE(), 9, 'WhatsApp secundario', 4),
    -- Proveedor 10
    ('contact@provider10.com', 1, GETDATE(), GETDATE(), 10, 'Correo principal', 1),
    ('+506 2222 1010', 1, GETDATE(), GETDATE(), 10, 'Teléfono principal', 2),
    ('Alajuela, Costa Rica', 1, GETDATE(), GETDATE(), 10, 'Dirección principal', 3),
    ('+506 8888 1010', 1, GETDATE(), GETDATE(), 10, 'WhatsApp secundario', 4),
    -- Proveedor 11
    ('info@provider11.com', 1, GETDATE(), GETDATE(), 11, 'Correo principal', 1),
    ('+506 2222 1111', 1, GETDATE(), GETDATE(), 11, 'Teléfono principal', 2),
    ('Cartago, Costa Rica', 1, GETDATE(), GETDATE(), 11, 'Dirección principal', 3),
    ('+506 8888 1111', 1, GETDATE(), GETDATE(), 11, 'WhatsApp secundario', 4),
    -- Proveedor 12
    ('support@provider12.com', 1, GETDATE(), GETDATE(), 12, 'Correo principal', 1),
    ('+506 2222 1212', 1, GETDATE(), GETDATE(), 12, 'Teléfono principal', 2),
    ('Guanacaste, Costa Rica', 1, GETDATE(), GETDATE(), 12, 'Dirección principal', 3),
    ('+506 8888 1212', 1, GETDATE(), GETDATE(), 12, 'WhatsApp secundario', 4),
    -- Proveedor 13
    ('contact@provider13.com', 1, GETDATE(), GETDATE(), 13, 'Correo principal', 1),
    ('+506 2222 1313', 1, GETDATE(), GETDATE(), 13, 'Teléfono principal', 2),
    ('Puntarenas, Costa Rica', 1, GETDATE(), GETDATE(), 13, 'Dirección principal', 3),
    ('+506 8888 1313', 1, GETDATE(), GETDATE(), 13, 'WhatsApp secundario', 4),
    -- Proveedor 14
    ('info@provider14.com', 1, GETDATE(), GETDATE(), 14, 'Correo principal', 1),
    ('+506 2222 1414', 1, GETDATE(), GETDATE(), 14, 'Teléfono principal', 2),
    ('Limón, Costa Rica', 1, GETDATE(), GETDATE(), 14, 'Dirección principal', 3),
    ('+506 8888 1414', 1, GETDATE(), GETDATE(), 14, 'WhatsApp secundario', 4),
    -- Proveedor 15
    ('support@provider15.com', 1, GETDATE(), GETDATE(), 15, 'Correo principal', 1),
    ('+506 2222 1515', 1, GETDATE(), GETDATE(), 15, 'Teléfono principal', 2),
    ('San José, Costa Rica', 1, GETDATE(), GETDATE(), 15, 'Dirección principal', 3),
    ('+506 8888 1515', 1, GETDATE(), GETDATE(), 15, 'WhatsApp secundario', 4);
GO

-- Procedure para llenar información de contacto del usuario
CREATE PROCEDURE [dbo].[llenarUserContactInfo]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @userID INT;
    DECLARE @contactTypeID INT;
    DECLARE @contactValue VARCHAR(200);

    -- Cursor para recorrer usuarios
    DECLARE user_cursor CURSOR FOR
    SELECT userID FROM [dbo].[st_users];

    OPEN user_cursor;
    FETCH NEXT FROM user_cursor INTO @userID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Email
        SET @contactTypeID = 1; -- Email
        SET @contactValue = LOWER(
            (SELECT firstName FROM [dbo].[st_users] WHERE userID = @userID) + '.' +
            (SELECT lastName FROM [dbo].[st_users] WHERE userID = @userID) + '@soltura.com'
        );
        INSERT INTO [dbo].[st_userContactInfo] (
            [value], [enabled], [lastUpdated], [contactTypeID], [userId]
        )
        VALUES (
            @contactValue,
            1,
            GETDATE(),
            @contactTypeID,
            @userID
        );

        -- Teléfono y WhatsApp
        SET @contactTypeID = 2; -- Teléfono
        SET @contactValue = '+506 8' + CAST(ABS(CHECKSUM(NEWID())) % 10000000 AS VARCHAR);
        INSERT INTO [dbo].[st_userContactInfo] (
            [value], [enabled], [lastUpdated], [contactTypeID], [userId]
        )
        VALUES (
            @contactValue,
            1,
            GETDATE(),
            @contactTypeID,
            @userID
        );
        SET @contactTypeID = 4; -- WhatsApp
        INSERT INTO [dbo].[st_userContactInfo] (
            [value], [enabled], [lastUpdated], [contactTypeID], [userId]
        )
        VALUES (
            @contactValue,
            1,
            GETDATE(),
            @contactTypeID,
            @userID
        );

        FETCH NEXT FROM user_cursor INTO @userID;
    END;
    CLOSE user_cursor;
    DEALLOCATE user_cursor;
END;
GO

-- Ejecutar el procedimiento
EXEC [dbo].[llenarUserContactInfo];
GO

-- Procedure para llenar Tokens de uso y transacciones de uso
CREATE PROCEDURE [dbo].[llenarUsageTokensYTransactions]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @subscriptionID INT;
    DECLARE @userID INT;
    DECLARE @contractDetailsID INT;
    DECLARE @usageTokenID INT;
    DECLARE @maxUses INT;
    DECLARE @serviceName VARCHAR(45);

    -- Cursor para recorrer suscripciones
    DECLARE sub_cursor CURSOR FOR
    SELECT s.subcriptionID, s.userID
    FROM [dbo].[st_subcriptions] s;

    OPEN sub_cursor;
    FETCH NEXT FROM sub_cursor INTO @subscriptionID, @userID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Seleccionar un servicio aleatorio de los planes del usuario
        SELECT TOP 1 
            @contractDetailsID = cd.contractDetailsID,
            @maxUses = ISNULL(cd.maxUses, 10),
            @serviceName = sv.serviceName
        FROM [dbo].[st_contractDetails] cd
        JOIN [dbo].[st_providerServices] ps ON cd.providerServicesID = ps.providerServiceID
        JOIN [dbo].[st_services] sv ON ps.serviceID = sv.serviceID
        JOIN [dbo].[st_planServices] pls ON pls.serviceID = sv.serviceID
        JOIN [dbo].[st_subcriptions] s ON s.planTypeID = pls.planID
        WHERE s.subcriptionID = @subscriptionID
        ORDER BY NEWID();

        IF @contractDetailsID IS NOT NULL
        BEGIN
            -- Insertar token de uso
            INSERT INTO [dbo].[st_usageTokens] (
                [userID], [tokenType], [tokenCode], [createdAt], [expirationDate], 
                [status], [failedAttempts], [contractDetailsID], [maxUses]
            )
            VALUES (
                @userID,
                'ServiceAccess',
                CONVERT(VARBINARY(250), 'TOKEN_' + CAST(@subscriptionID AS VARCHAR) + '_' + CAST(ABS(CHECKSUM(NEWID())) % 1000000 AS VARCHAR)),
                GETDATE(),
                DATEADD(MONTH, 2, GETDATE()),
                'Active',
                0,
                @contractDetailsID,
                @maxUses
            );

            SET @usageTokenID = SCOPE_IDENTITY();

            -- Insertar 2-6 transacciones de uso
            DECLARE @i INT = 2 + ABS(CHECKSUM(NEWID())) % 5;
            WHILE @i > 0 AND @i <= @maxUses
            BEGIN
                INSERT INTO [dbo].[st_usageTransactions] (
                    [usageTokenID], [transactionDate], [usageNotes], [transactionType]
                )
                VALUES (
                    @usageTokenID,
                    DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 60, GETDATE()),
                    'Uso de servicio: ' + @serviceName,
                    'ServiceConsumption'
                );
                SET @i = @i - 1;
            END;
        END;
        FETCH NEXT FROM sub_cursor INTO @subscriptionID, @userID;
    END;
    CLOSE sub_cursor;
    DEALLOCATE sub_cursor;
END;
GO

-- Ejecutar el procedimiento
EXEC [dbo].[llenarUsageTokensYTransactions];
GO

------------------------------------------------------------------------------

-- Ver archivos multimedia
SELECT * FROM [dbo].[st_MediaFiles];
GO

-- Ver archivos asociados a proveedores
SELECT * FROM [dbo].[st_providersMediaFiles];
GO

-- Ver información de contacto de proveedores
SELECT * FROM [dbo].[st_providerContactInfo];
GO

-- Ver información de contacto de usuarios
SELECT * FROM [dbo].[st_userContactInfo];
GO

-- Ver tokens de uso
SELECT * FROM [dbo].[st_usageTokens];
GO

-- Ver transacciones de uso
SELECT * FROM [dbo].[st_usageTransactions];
GO

----------------------------------------------------------------------------

USE [Caso2DB]
GO

CREATE OR ALTER PROCEDURE [dbo].[llenarContractRenewals]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @providerContractID INT;
    DECLARE @renewalDate DATETIME = '2025-04-01';
    DECLARE @motives TABLE (motive VARCHAR(200));
    DECLARE @changes TABLE (change VARCHAR(200));
    DECLARE @i INT;

    -- Lista de motivos de renovación
    INSERT INTO @motives (motive)
    VALUES 
        ('Extensión de contrato por buen desempeño del proveedor'),
        ('Renovación para mantener servicios activos'),
        ('Acuerdo para incluir nuevos servicios'),
        ('Ajuste de términos por cambios en el mercado'),
        ('Continuación de colaboración estratégica'),
        ('Optimización de costos'),
        ('Expansión de servicios');

    -- Lista de cambios en el contrato
    INSERT INTO @changes (change)
    VALUES 
        ('Aumento del 10% en el costo del contrato'),
        ('Inclusión de un nuevo servicio de gimnasio'),
        ('Reducción del período de notificación a 30 días'),
        ('Actualización de términos de pago a mensual'),
        ('Ampliación de cobertura geográfica'),
        ('Incorporación de descuentos especiales'),
        ('Ajuste en el IVA al 15%');

    -- Cursor para recorrer contratos de proveedores
    DECLARE contract_cursor CURSOR FOR
    SELECT providerContractID FROM [dbo].[st_providersContract];

    OPEN contract_cursor;
    FETCH NEXT FROM contract_cursor INTO @providerContractID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar 0-2 renovaciones por contrato (75% de probabilidad)
        SET @i = 0 + ABS(CHECKSUM(NEWID())) % 3;
        WHILE @i > 0 AND ABS(CHECKSUM(NEWID())) % 4 != 0
        BEGIN
            DECLARE @motive VARCHAR(200) = (SELECT TOP 1 motive FROM @motives ORDER BY NEWID());
            DECLARE @change VARCHAR(200) = (SELECT TOP 1 change FROM @changes ORDER BY NEWID());

            INSERT INTO [dbo].[st_contractRenewals] (
                [renewalDate], [renewalMotive], [contractChanges], [providerContractID]
            )
            VALUES (
                @renewalDate,
                @motive,
                @change,
                @providerContractID
            );
            SET @i = @i - 1;
        END;
        FETCH NEXT FROM contract_cursor INTO @providerContractID;
    END;
    CLOSE contract_cursor;
    DEALLOCATE contract_cursor;
END;
GO

-- Ejecutar el procedimiento
EXEC [dbo].[llenarContractRenewals];
GO

-----------------------------------------------------------------

-- Ver renovaciones de contrato
SELECT * FROM [dbo].[st_contractRenewals];
GO