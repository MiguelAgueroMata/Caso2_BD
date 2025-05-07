USE [Caso2DB]
Go
------------------------------------------------------------
-- 1. Cursor LOCAL (no visible fuera de la sesión)
------------------------------------------------------------
DECLARE @message VARCHAR(100)
PRINT 'Demostrando un cursor LOCAL (visible solo en esta sesión)'

-- Creando el cursor local
DECLARE user_cursor CURSOR LOCAL FOR
SELECT firstName + ' ' + lastName AS NombreCompleto
FROM st_users
WHERE enabled = 1

-- Variables para almacenar resultados
DECLARE @nombreUsuario VARCHAR(100)

-- Abrir el cursor
OPEN user_cursor

-- Recuperar la primera fila
FETCH NEXT FROM user_cursor INTO @nombreUsuario

-- Mostrar hasta 5 usuarios
DECLARE @contador INT = 0
WHILE @@FETCH_STATUS = 0 AND @contador < 8
BEGIN
    SET @contador = @contador + 1
    PRINT 'Usuario #' + CAST(@contador AS VARCHAR) + ': ' + @nombreUsuario
    FETCH NEXT FROM user_cursor INTO @nombreUsuario
END

-- Cerrar y liberar el cursor
CLOSE user_cursor
DEALLOCATE user_cursor
GO

FETCH NEXT FROM user_cursor
-- Nota: Este cursor LOCAL no puede ser accedido desde otra conexión
-- Si intentas abrir otro Query y escribir 'FETCH NEXT FROM user_cursor', obtendrás un error


------------------------------------------------------------
-- 2. Cursor GLOBAL (accesible desde otras sesiones)
------------------------------------------------------------
PRINT '------------------------------------------------------------'
PRINT 'Demostrando un cursor GLOBAL (visible desde otras conexiones)'

-- Creando cursor global (separa en batches para demostrar persistencia)
DECLARE plan_cursor CURSOR GLOBAL FOR
SELECT planName, planPrice FROM st_plans WHERE planTypeID = 1

OPEN plan_cursor
GO

-- Continuación del cursor GLOBAL en el mismo connection
DECLARE @planNombre VARCHAR(100), @planPrecio DECIMAL(10,2), @contador INT = 0

PRINT 'Continuando procesamiento del cursor GLOBAL...'
FETCH NEXT FROM plan_cursor INTO @planNombre, @planPrecio

WHILE @@FETCH_STATUS = 0 AND @contador < 2
BEGIN
    SET @contador = @contador + 1
    PRINT '[GLOBAL] Plan #' + CAST(@contador AS VARCHAR) + ': ' + @planNombre + ' - $' + CAST(@planPrecio AS VARCHAR)
    FETCH NEXT FROM plan_cursor INTO @planNombre, @planPrecio
END
GO


CLOSE plan_cursor
DEALLOCATE plan_cursor
GO

FETCH NEXT FROM plan_cursor INTO @planNombre, @planPrecio
Go



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------



PRINT '------------------------------------------------------------'
PRINT 'Demostrando el uso de sp_recompile para recompilar stored procedures'

-- Crear un procedimiento almacenado de ejemplo para recompilar
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ObtenerUsuariosActivos]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[sp_ObtenerUsuariosActivos]
GO

CREATE PROCEDURE [dbo].[sp_ObtenerUsuariosActivos]
AS
BEGIN
    SELECT userID, firstName, lastName
    FROM st_users
    WHERE enabled = 1
END
GO

-- Recompilar un SP específico
EXEC sp_recompile 'dbo.sp_ObtenerUsuariosActivos';
PRINT 'Se ha recompilado el SP: sp_ObtenerUsuariosActivos'

-- Procedimiento que recompila todos los SPs cada cierto tiempo
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_RecompileAllProcedures]') AND type in (N'P'))
    DROP PROCEDURE [dbo].[sp_RecompileAllProcedures]
GO

CREATE PROCEDURE [dbo].[sp_RecompileAllProcedures]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @procName NVARCHAR(500)
    DECLARE @sql NVARCHAR(1000)
    
    -- Crear un cursor para recorrer todos los procedimientos almacenados
    DECLARE proc_cursor CURSOR FOR 
    SELECT name FROM sys.procedures WHERE type = 'P' AND is_ms_shipped = 0
    
    OPEN proc_cursor
    FETCH NEXT FROM proc_cursor INTO @procName
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @sql = 'EXEC sp_recompile ''dbo.' + @procName + ''''
        EXEC sp_executesql @sql
        PRINT 'Recompilado: ' + @procName
        
        FETCH NEXT FROM proc_cursor INTO @procName
    END
    
    CLOSE proc_cursor
    DEALLOCATE proc_cursor
    
    PRINT 'Todos los procedimientos han sido recompilados'
END
GO

-- Para programar la recompilación periódica se puede utilizar SQL Server Agent Job
-- que ejecute este SP cada día, semana o mes según necesidades
PRINT 'Para programar recompilaciones periódicas, crear un SQL Server Agent Job que ejecute sp_RecompileAllProcedures'
PRINT 'Por ejemplo: Ejecutar cada domingo a las 2:00 AM'

EXEC [dbo].[sp_RecompileAllProcedures];



-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------



-- MERGE para actualizar o insertar planes desde una tabla temporal
MERGE INTO [dbo].[st_plans] AS target
USING (
    SELECT 
        planID = 100,  -- ID del plan a actualizar/insertar
        planPrice = 9999.00,
        planName = 'Plan Gogeta SSJ Blue',
        planTypeID = 1,
        currencyID = 1,
        description = 'Plan sayajin, no es para terricolas',
        imageURL = 'https://logo.com/premium_plus.jpg',
        lastUpdated = GETDATE(),
        solturaPrice = 45000.00 * 0.15
) AS source
ON (target.planID = source.planID)
WHEN MATCHED THEN
    UPDATE SET 
        target.planPrice = source.planPrice,
        target.planName = source.planName,
        target.planTypeID = source.planTypeID,
        target.lastUpdated = source.lastUpdated,
        target.description = source.description
WHEN NOT MATCHED THEN
    INSERT (planPrice, planName, planTypeID, currencyID, description, imageURL, lastUpdated, solturaPrice)
    VALUES (source.planPrice, source.planName, source.planTypeID, source.currencyID, 
            source.description, source.imageURL, source.lastUpdated, source.solturaPrice);



-- Verificar los resultados
SELECT planID, planName, planPrice, description, lastUpdated 
FROM st_plans 
WHERE planID IN (SELECT planID FROM st_plans)
OR planName = 'Plan Nuevo Sincronizado'





SELECT 
    serviceID, serviceName, SUBSTRING(Description, 1, 20) + '...' AS shortDescription, serviceTypeID
FROM [dbo].[st_services];


SELECT 
    userID,
    firstName,
    lastName,
    COALESCE([password], CONVERT(VARBINARY(250), 'default_password')) AS [password],
    COALESCE(CAST(birthDate AS VARCHAR), 'Fecha no especificada') AS birthDateText,
    COALESCE(enabled, 1) AS enabledStatus
FROM [dbo].[st_users];

USE Caso2DB
SELECT 
    paymentMethodID,
    name,
    COALESCE(secretKey, CONVERT(VARBINARY(250), '')) AS secretKey,
    COALESCE([key], CONVERT(VARBINARY(250), '')) AS [key],
    COALESCE(apiURL, 'URL no especificada') AS apiURL,
    COALESCE(logoURL, 'URL no especificada') AS logoURL,
    COALESCE(configJSON, 'Configuración no especificada') AS configJSON,
    COALESCE(CAST(lastUpdated AS VARCHAR), 'Fecha no especificada') AS lastUpdatedText,
    COALESCE(enabled, 1) AS enabledStatus
FROM [dbo].[st_paymentMethod];

SELECT * FROM st_paymentMethod

INSERT INTO [dbo].[st_paymentMethod] (
    [name],
    [secretKey],
    [key],
    [apiURL],
    [logoURL],
    [configJSON],
    [lastUpdated],
    [enabled]
)
VALUES (
    'Nuevo Método de Pago', -- Nombre del método de pago
    CONVERT(VARBINARY(250), 'mi_clave_secreta_encriptada'), -- SecretKey (binario)
    CONVERT(VARBINARY(250), 'mi_api_key_encriptada'), -- Key (binario)
    'https://api.nuevometodo.com/v1/pagos', -- URL de la API
    null, -- URL del logo (puede ser NULL)
    null, -- Configuración en JSON (puede ser NULL)
    GETDATE(), -- Fecha de última actualización
    1 -- Habilitado (1 = true, 0 = false)
);

-- Promedio de montos pagados por usuario
SELECT 
    u.userID,
    u.firstName + ' ' + u.lastName AS fullName,
    AVG(p.amount) AS averagePaymentAmount,
    COUNT(p.paymentID) AS totalPayments
FROM [dbo].[st_users] u
JOIN [dbo].[st_subcriptions] s ON u.userID = s.userID
JOIN [dbo].[st_payments] p ON s.subcriptionID = p.paymentID
GROUP BY u.userID, u.firstName, u.lastName
ORDER BY averagePaymentAmount DESC;


SELECT TOP 5
    p.planID,
    p.planName,
    COUNT(s.subcriptionID) AS subscriberCount
FROM [dbo].[st_plans] p
LEFT JOIN [dbo].[st_subcriptions] s ON p.planTypeID = s.planTypeID
GROUP BY p.planID, p.planName
ORDER BY subscriberCount DESC;


SELECT 
    u.userID,
    u.firstName,
    u.lastName,
    p.planName,
    s.enabled
FROM [dbo].[st_users] u
JOIN [dbo].[st_subcriptions] s ON u.userID = s.userID
JOIN [dbo].[st_plans] p ON s.planTypeID = p.planTypeID
WHERE p.planTypeID = 1  -- Plan Premium
  AND s.enabled = 1     -- Suscripción habilitada (&& sería equivalente a AND)
ORDER BY u.lastName, u.firstName;