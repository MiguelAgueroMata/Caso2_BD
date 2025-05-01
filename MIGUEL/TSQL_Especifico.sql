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

FETCH NEXT FROM plan_cursor



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





PRINT '------------------------------------------------------------'
PRINT 'Demostrando uso de MERGE para sincronizar datos'

-- Crear tabla temporal con datos de planes "actualizados"
CREATE TABLE #PlanesActualizados (
    planID INT,
    planName VARCHAR(100),
    planPrice DECIMAL(10, 2),
    description VARCHAR(500)
)

-- Insertar datos de ejemplo (algunos existentes, algunos nuevos, algunos modificados)
INSERT INTO #PlanesActualizados (planID, planName, planPrice, description)
SELECT TOP 3 planID, planName, planPrice * 1.05, description + ' (Actualizado)'
FROM st_plans
WHERE planTypeID = 1

-- Agregar un plan completamente nuevo
INSERT INTO #PlanesActualizados (planID, planName, planPrice, description)
VALUES (9999, 'Plan Nuevo Sincronizado', 25000.00, 'Plan creado por sincronización MERGE')

-- Mostrar tabla temporal con los planes a sincronizar
SELECT * FROM #PlanesActualizados

-- Ejecutar MERGE para sincronizar los datos
MERGE INTO st_plans AS target
USING #PlanesActualizados AS source
ON (target.planID = source.planID)
WHEN MATCHED THEN
    UPDATE SET 
        target.planName = source.planName,
        target.planPrice = source.planPrice,
        target.description = source.description,
        target.lastUpdated = GETDATE()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (planPrice, postTime, planName, planTypeID, currencyID, description, imageURL, lastUpdated, solturaPrice)
    VALUES (
        source.planPrice, 
        GETDATE(),
        source.planName,
        1, -- Plan Premium por defecto
        1, -- CRC por defecto
        source.description,
        'https://logo.com/default_plan.jpg',
        GETDATE(),
        source.planPrice * 0.15
    );

PRINT 'MERGE completado - Planes sincronizados'

-- Verificar los resultados
SELECT planID, planName, planPrice, description, lastUpdated 
FROM st_plans 
WHERE planID IN (SELECT planID FROM #PlanesActualizados)
OR planName = 'Plan Nuevo Sincronizado'

-- Limpiar
DROP TABLE #PlanesActualizados



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