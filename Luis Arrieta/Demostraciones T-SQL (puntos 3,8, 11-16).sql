USE [Caso2DB]
GO

------------------------------------------------------------
-- 1. Trigger para log de inserciones en pagos
------------------------------------------------------------
PRINT 'Demostrando el uso de un TRIGGER para log de inserciones en pagos'

-- Crear tabla de log para pagos
IF OBJECT_ID('dbo.st_paymentLog', 'U') IS NOT NULL
    DROP TABLE dbo.st_paymentLog;
GO

CREATE TABLE dbo.st_paymentLog (
    logID INT IDENTITY(1,1) PRIMARY KEY,
    paymentID INT,
    amount DECIMAL(10,2),
    paymentDate DATETIME,
    userID INT NULL, -- Permitir NULL ya que no podemos obtener userID directamente
    logAction VARCHAR(50),
    logDate DATETIME DEFAULT GETDATE()
);
GO

-- Crear trigger
IF EXISTS (SELECT * FROM sys.triggers WHERE name = 'trg_LogPaymentInsert')
    DROP TRIGGER dbo.trg_LogPaymentInsert;
GO

CREATE TRIGGER dbo.trg_LogPaymentInsert
ON dbo.st_payments
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.st_paymentLog (paymentID, amount, paymentDate, userID, logAction)
    SELECT 
        i.paymentID,
        i.amount,
        i.paymentDate,
        NULL, -- No hay relación directa para obtener userID
        'INSERT'
    FROM inserted i;
END;
GO

-- Probar el trigger con una inserción válida
INSERT INTO dbo.st_payments (
    paymentMethodID, amount, actualAmount, result, authentication, 
    reference, chargedToken, description, paymentDate, checksum, currencyID
)
VALUES (
    1, 25000.00, 25000.00, 'Success', 'AUTH_TEST',
    'REF_TEST', CONVERT(VARBINARY(250), 'TOKEN_TEST'), 'Pago de prueba', GETDATE(),
    CONVERT(VARBINARY(250), 'CHECKSUM_TEST'), 1
);

-- Verificar el log
SELECT * FROM dbo.st_paymentLog;
GO

------------------------------------------------------------
-- 2. Combinación: LTRIM, UNION, DISTINCT, &&
------------------------------------------------------------
PRINT 'Demostrando LTRIM, UNION, DISTINCT y && en una sola consulta'

-- Reporte de servicios asignados a planes premium y familiares
SELECT DISTINCT -- Uso de DISTINCT para evitar duplicados
    s.serviceID,
    s.serviceName,
    LTRIM(s.description) AS cleanedDescription, -- Uso de LTRIM
    p.planName,
    'Premium' AS planCategory
FROM dbo.st_services s
JOIN dbo.st_planServices ps ON s.serviceID = ps.serviceID
JOIN dbo.st_plans p ON ps.planID = p.planID
WHERE p.planTypeID = 1
UNION -- Uso de UNION
SELECT DISTINCT
    s.serviceID,
    s.serviceName,
    LTRIM(s.description) AS cleanedDescription,
    p.planName,
    'Familiar' AS planCategory
FROM dbo.st_services s
JOIN dbo.st_planServices ps ON s.serviceID = ps.serviceID
JOIN dbo.st_plans p ON ps.planID = p.planID
WHERE p.planTypeID = 2
ORDER BY serviceName, planName;

PRINT 'Explicación de &&: En T-SQL, se usa AND en lugar de &&. && es un operador lógico en lenguajes como C, C++, JavaScript.'
PRINT 'En esta consulta, AND combina condiciones implícitamente en los JOINs.'
GO

------------------------------------------------------------
-- 3. Combinación: SCHEMABINDING, WITH ENCRYPTION, EXECUTE AS
------------------------------------------------------------
PRINT 'Demostrando SCHEMABINDING, WITH ENCRYPTION, EXECUTE AS en un procedimiento'

-- Crear vista con SCHEMABINDING
IF OBJECT_ID('dbo.vw_ActiveSubscriptions', 'V') IS NOT NULL
    DROP VIEW dbo.vw_ActiveSubscriptions;
GO

CREATE VIEW dbo.vw_ActiveSubscriptions
WITH SCHEMABINDING
AS
SELECT 
    s.subcriptionID,
    s.userID,
    u.firstName,
    u.lastName,
    p.planName
FROM dbo.st_subcriptions s
JOIN dbo.st_users u ON s.userID = u.userID
JOIN dbo.st_plans p ON s.planTypeID = p.planTypeID
WHERE s.enabled = 1;
GO

-- Crear procedimiento con WITH ENCRYPTION y EXECUTE AS
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ReportActiveSubscriptions]'))
    DROP PROCEDURE [dbo].[sp_ReportActiveSubscriptions];
GO

CREATE PROCEDURE [dbo].[sp_ReportActiveSubscriptions]
WITH ENCRYPTION, EXECUTE AS 'dbo'
AS
BEGIN
    SET NOCOUNT ON;
    PRINT 'Reporte de suscripciones activas ejecutado con permisos de dbo (EXECUTE AS).'
    PRINT 'El procedimiento está encriptado (WITH ENCRYPTION) y usa una vista con SCHEMABINDING.'
    
    SELECT 
        subcriptionID,
        firstName + ' ' + lastName AS fullName,
        planName
    FROM dbo.vw_ActiveSubscriptions
    ORDER BY fullName;
END;
GO

-- Probar el procedimiento
EXEC dbo.sp_ReportActiveSubscriptions;
GO

-- Demostrar SCHEMABINDING (intentar modificar tabla)
BEGIN TRY
    ALTER TABLE dbo.st_subcriptions DROP COLUMN enabled;
    PRINT 'Modificación de tabla exitosa (no debería ocurrir)';
END TRY
BEGIN CATCH
    PRINT 'Error: No se puede modificar la tabla debido a SCHEMABINDING en la vista vw_ActiveSubscriptions';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- Demostrar WITH ENCRYPTION (intentar ver definición)
EXEC sp_helptext 'dbo.sp_ReportActiveSubscriptions';
-- Resultado: 'The text for object ''dbo.sp_ReportActiveSubscriptions'' is encrypted.'
GO

