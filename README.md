# Tecnológico de Costa Rica
### *Campus Tecnológico Central Cartago*
Escuela de Ingeniería en Computación

__Curso:__ IC-4301 Bases de Datos I

__Profesor:__ 
* Rodriguez Nuñez Nuñez

__Estudiantes:__

* Miguel Eduardo Agüero Mata	

* Luis Andrés Arrieta Viquez

* Bryan Josué Marín Valverde

* Juan Pablo Cambronero

__Caso 2:__   Soltura

__Fecha de entrega:__  Martes, 6 de septiembre

Primer semestre 2025

---

EJEMPLO

| Syntax      | Description |
| ----------- | ----------- |
| Header      | Title       |
| Paragraph   | Text        |

---
## Mantenimiento de la Seguridad
```SQL
--------------------------------------------------------------------------------
-- 1) Servidor: crear logins de prueba
--------------------------------------------------------------------------------
USE [master];
GO

-- Login que puede conectar
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'TestReadOnly')
    CREATE LOGIN [TestReadOnly] WITH PASSWORD = N'P@ssw0rdRead!';
-- Login que NO puede conectar
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'TestNoConnect')
    CREATE LOGIN [TestNoConnect]   WITH PASSWORD = N'P@ssw0rdNo!';
GO

--------------------------------------------------------------------------------
-- 2) Base de datos: crear usuarios y controlar CONNECT
--------------------------------------------------------------------------------
USE [Caso2DB];
GO

-- Crear usuarios de BD para esos logins
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'ReadUser')
    CREATE USER [ReadUser]      FOR LOGIN [TestReadOnly];
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'NoConnectUser')
    CREATE USER [NoConnectUser] FOR LOGIN [TestNoConnect];
GO

-- Denegar permiso CONNECT a NoConnectUser
DENY CONNECT TO [NoConnectUser];
GO

--------------------------------------------------------------------------------
-- 3) Rol con SELECT sobre dbo.st_users
--------------------------------------------------------------------------------
-- Crear rol
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'rol_select_users')
    CREATE ROLE [rol_select_users];
-- Conceder SELECT en st_users
GRANT SELECT ON dbo.st_users TO [rol_select_users];
GO

-- Usuarios de prueba para este rol
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'U_Sel1')
    CREATE LOGIN [U_Sel1] WITH PASSWORD = N'Pass1!';
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'U_Sel1')
    CREATE USER [U_Sel1] FOR LOGIN [U_Sel1];

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = N'U_NoSel')
    CREATE LOGIN [U_NoSel] WITH PASSWORD = N'Pass2!';
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'U_NoSel')
    CREATE USER [U_NoSel] FOR LOGIN [U_NoSel];
GO

-- Añadir U_Sel1 al rol; U_NoSel queda fuera
EXEC sp_addrolemember N'rol_select_users', N'U_Sel1';
GO

--------------------------------------------------------------------------------
-- 4) Procedimiento que lista usuarios + permisos
--------------------------------------------------------------------------------
-- Eliminar SP si existe
IF OBJECT_ID(N'dbo.sp_ListaUsuarios', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ListaUsuarios;
GO

-- Crear SP
CREATE PROCEDURE dbo.sp_ListaUsuarios
AS
BEGIN
    SELECT userID, firstName, lastName
      FROM dbo.st_users;
END;
GO

-- Denegar SELECT directo y dar EXECUTE al SP
DENY SELECT ON dbo.st_users TO [U_Sel1];
GRANT EXECUTE ON dbo.sp_ListaUsuarios TO [U_Sel1];
GO

--------------------------------------------------------------------------------
-- 5) Row-Level Security: filtrar solo enabled = 1
--------------------------------------------------------------------------------
-- Eliminar política si existe (para luego eliminar la función)
IF EXISTS (SELECT * FROM sys.security_policies WHERE name = N'Policy_UsersEnabled')
    DROP SECURITY POLICY Security.Policy_UsersEnabled;
GO

-- Eliminar función si existe
IF OBJECT_ID(N'Security.fn_filter_enabled_users','IF') IS NOT NULL
    DROP FUNCTION Security.fn_filter_enabled_users;
GO

-- Crear esquema Security si no existe
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'Security')
    EXEC('CREATE SCHEMA Security');
GO

-- Crear función inline
CREATE FUNCTION Security.fn_filter_enabled_users(@enabled bit)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN (
    SELECT 1 AS fn_result
      WHERE @enabled = 1
);
GO

-- Crear política de filtro
CREATE SECURITY POLICY Security.Policy_UsersEnabled
  ADD FILTER PREDICATE Security.fn_filter_enabled_users(enabled)
    ON dbo.st_users
WITH (STATE = ON);
GO

--------------------------------------------------------------------------------
-- 6) Master Key, Certificado, Asymmetric Key y Symmetric Key
--------------------------------------------------------------------------------
-- Master Key de BD
IF NOT EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = '##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'MasterP@ss123!';
GO

-- Antes de dropear certificado, eliminar la symmetric key que depende de él
IF EXISTS (SELECT * FROM sys.symmetric_keys WHERE name = N'KeySimetricaDatos')
    DROP SYMMETRIC KEY KeySimetricaDatos;
GO

-- Ahora dropear certificado si existe
IF EXISTS (SELECT * FROM sys.certificates WHERE name = N'CertDatos')
    DROP CERTIFICATE CertDatos;
GO

-- Crear certificado para cifrado simétrico
CREATE CERTIFICATE CertDatos
  WITH SUBJECT = N'Certificado para cifrado de datos';
GO

-- Asymmetric Key protegido por la Master Key
IF EXISTS (SELECT * FROM sys.asymmetric_keys WHERE name = N'KeyAsimetricaDatos')
    DROP ASYMMETRIC KEY KeyAsimetricaDatos;
GO
CREATE ASYMMETRIC KEY KeyAsimetricaDatos
  WITH ALGORITHM = RSA_2048;
GO

-- Symmetric Key cifrada por el certificado recién creado
CREATE SYMMETRIC KEY KeySimetricaDatos
  WITH ALGORITHM = AES_256
  ENCRYPTION BY CERTIFICATE CertDatos;
GO

--------------------------------------------------------------------------------
-- 7) Tabla de datos sensibles y ejemplo de cifrado
--------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.SecretData','U') IS NOT NULL
    DROP TABLE dbo.SecretData;
GO

CREATE TABLE dbo.SecretData (
    id             INT IDENTITY PRIMARY KEY,
    info           VARCHAR(200),
    info_encrypted VARBINARY(MAX)
);
GO

-- Insertar fila cifrada
OPEN SYMMETRIC KEY KeySimetricaDatos
  DECRYPTION BY CERTIFICATE CertDatos;
GO

INSERT dbo.SecretData(info, info_encrypted)
VALUES (
    N'Texto súper secreto',
    EncryptByKey(Key_GUID(N'KeySimetricaDatos'), N'Texto súper secreto')
);
GO

CLOSE SYMMETRIC KEY KeySimetricaDatos;
GO

--------------------------------------------------------------------------------
-- 8) SP para descifrar datos
--------------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.sp_LeerSecretos','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_LeerSecretos;
GO

CREATE PROCEDURE dbo.sp_LeerSecretos
AS
BEGIN
    OPEN SYMMETRIC KEY KeySimetricaDatos
      DECRYPTION BY CERTIFICATE CertDatos;

    SELECT
      id,
      CONVERT(VARCHAR(200), DecryptByKey(info_encrypted)) AS info_descifrada
    FROM dbo.SecretData;

    CLOSE SYMMETRIC KEY KeySimetricaDatos;
END;
GO

-- Conceder ejecución a ReadUser
GRANT EXECUTE ON dbo.sp_LeerSecretos TO [ReadUser];
GO
```

```SQL 
-- Intentar conectar como TestReadOnly (debe funcionar):
EXECUTE AS LOGIN = 'TestReadOnly';
USE Caso2DB;            -- OK
SELECT 1 AS Conexion;   -- OK
REVERT;

-- Intentar conectar como TestNoConnect (debe fallar):
EXECUTE AS LOGIN = 'TestNoConnect';
USE Caso2DB;            -- ERROR: acceso denegado
REVERT;
```

Msg 916, Level 14, State 4, Line 220
The server principal "TestNoConnect" is not able to access the database "Caso2DB" under the current security context.

```SQL
-- Con U_Sel1 (pertenece al rol, puede hacer SELECT):
EXECUTE AS USER = 'U_Sel1';
SELECT TOP 5 * FROM dbo.st_users;   -- DEBE devolver filas
REVERT;

-- Con U_NoSel (no tiene rol, no puede SELECT):
EXECUTE AS USER = 'U_NoSel';
SELECT TOP 5 * FROM dbo.st_users;   -- ERROR: permiso denegado
REVERT;
```
Msg 229, Level 14, State 5, Line 229
The SELECT permission was denied on the object 'st_users', database 'Caso2DB', schema 'dbo'.
Msg 229, Level 14, State 5, Line 234
The SELECT permission was denied on the object 'st_users', database 'Caso2DB', schema 'dbo'.

```SQL
-- U_Sel1 NO puede SELECT directo, pero SÍ ejecutar el SP:
EXECUTE AS USER = 'U_Sel1';
SELECT TOP 5 * FROM dbo.st_users;       -- ERROR: permiso denegado
EXEC dbo.sp_ListaUsuarios;              -- DEBE devolver lista de usuarios
REVERT;
```
Msg 229, Level 14, State 5, Line 242
The SELECT permission was denied on the object 'st_users', database 'Caso2DB', schema 'dbo'.

```SQL
UPDATE dbo.st_users SET enabled = 0 WHERE userID = 1;


----------------------------------------------------------------------------

SELECT userID, firstName, enabled
  FROM dbo.st_users;
  ```
  | userID | firstName  | enabled |
|:------:|:----------:|:-------:|
| 2      | Pablo      | 1       |
| 3      | Gabriel    | 1       |
| 4      | Juan       | 1       |
| 5      | Paula      | 1       |
| 6      | Miguel     | 1       |
| 7      | Paula      | 1       |
| 8      | Pablo      | 1       |
| 9      | Pablo      | 1       |
| 10     | Valeria    | 1       |
| 11     | José       | 1       |
| 12     | Luis       | 1       |
| 13     | Rafael     | 1       |
| 14     | Gabriel    | 1       |
| 15     | Daniela    | 1       |
| 16     | Natalia    | 1       |
| 17     | Valeria    | 1       |
| 18     | José       | 1       |
| 19     | José       | 1       |
| 20     | Sofía      | 1       |
| 21     | Camila     | 1       |
| 22     | Laura      | 1       |
| 23     | Andrés     | 1       |
| 24     | Sebastián  | 1       |
| 25     | Natalia    | 1       |
| 26     | Miguel     | 1       |
| 27     | Diego      | 1       |
| 28     | Sebastián  | 1       |
| 29     | Carlos     | 1       |
| 30     | Sofía      | 1       |
| 31     | Isabella   | 1       |
| 32     | Valeria    | 1       |
| 33     | Camila     | 1       |
| 34     | Santiago   | 1       |
| 35     | Luis       | 1       |
| 36     | Victoria   | 1       |
| 37     | Camila     | 1       |
| 38     | Paula      | 1       |
| 39     | Valeria    | 1       |
| 40     | Diego      | 1       |
| 41     | José       | 1       |
| 42     | Juan       | 1       |
| 43     | Victoria   | 1       |
| 44     | Emma       | 1       |
| 45     | Pablo      | 1       |
| 46     | Luis       | 1       |
| 47     | Lucía      | 1       |
| 48     | Daniela    | 1       |
| 49     | Elena      | 1       |
| 50     | Clara      | 1       |
| 51     | Daniela    | 1       |
| 52     | Carlos     | 1       |
| 53     | Juan       | 1       |
| 54     | Sebastián  | 1       |
| 55     | Lucía      | 1       |
| 56     | Isabella   | 1       |
| 57     | Mateo      | 1       |
| 58     | Sebastián  | 1       |
| 59     | Daniela    | 1       |
| 60     | Alejandro  | 1       |

```SQL
SELECT TOP 1 info, info_encrypted
  FROM dbo.SecretData;
```
| info               | info_encrypted                                                                                     |
|--------------------|---------------------------------------------------------------------------------------------------|
| Texto súper secreto | `0x00E02326D791AA43B30B31E0E8FFF294020000004E68FDDAE277E0F9333D7A90869A07EF75190996FDB38AE8C4363136A767D5BC22CAF818469FD15EC6316BE3CECF3E7BEBA33BA6D38D5508146D16A143125344` |


```SQL
-- 1) Borrar el SP existente
IF OBJECT_ID(N'dbo.sp_LeerSecretos','P') IS NOT NULL
  DROP PROCEDURE dbo.sp_LeerSecretos;
GO

-- 2) Recrear el SP sin ALTER, pero con NVARCHAR en la conversión
CREATE PROCEDURE dbo.sp_LeerSecretos
WITH EXECUTE AS OWNER
AS
BEGIN
  OPEN SYMMETRIC KEY KeySimetricaDatos
    DECRYPTION BY CERTIFICATE CertDatos;

  SELECT
    id,
    CONVERT(NVARCHAR(200), DecryptByKey(info_encrypted)) AS info_descifrada
  FROM dbo.SecretData;

  CLOSE SYMMETRIC KEY KeySimetricaDatos;
END;
GO

-- 3) Asegurarse de que ReadUser tiene permiso de ejecución
GRANT EXECUTE ON dbo.sp_LeerSecretos TO [ReadUser];
GO

-- 4) Ejecutar para verificar
EXEC dbo.sp_LeerSecretos;
GO
```

| id | info_descifrada      |
|----|----------------------|
| 1  | Texto súper secreto  |

## Miscelaneos

### 1. Procedimiento almacenado transaccional que realice una operación del sistema, relacionado a subscripciones, pagos, servicios, transacciones o planes, y que dicha operación requiera insertar y/o actualizar al menos 3 tablas.
 ```SQL
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
```


**Agregar tiempo a una subscripcion activa**
```SQL
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
```
| SubscriptionID | UserID | PlanID | Amount   | PaymentID | TransactionID | StartDate  | EndDate    | Status                        |
|:--------------:|:------:|:------:|:--------:|:---------:|:-------------:|:----------:|:----------:|:-----------------------------:|
| 27             | 1      | 1      | 54836.63 | 104       | 79            | 2025-05-06 | 2025-09-06 | Proceso completado exitosamente|

**Gestionar ID que no existe**
```SQL
DECLARE @Result2 INT
EXEC @Result2 = [dbo].[SP_GestionarSuscripcionPremium] 
    @UserID = 999,  -- ID que no existe
    @PlanID = 1
    
SELECT 'Resultado' = CASE @Result 
    WHEN 0 THEN 'Éxito' 
    WHEN -1 THEN 'Error de validación' 
    WHEN -99 THEN 'Error en ejecución' 
    ELSE 'Código desconocido: ' + CAST(@Result2 AS VARCHAR) 
END
```
| SubscriptionID | UserID | PlanID | Amount | PaymentID | TransactionID | StartDate | EndDate | Status                     |
|:--------------:|:------:|:------:|:------:|:---------:|:-------------:|:---------:|:-------:|:--------------------------:|
| 1              | NULL   | 999    | 1      | NULL      | NULL          | NULL      | NULL    | Error: Usuario no encontrado |

**Gestionar plan que no existe**
```SQL
DECLARE @Result3 INT
EXEC @Result3 = [dbo].[SP_GestionarSuscripcionPremium] 
    @UserID = 1, 
    @PlanID = 999  -- ID de plan que no existe
    
SELECT 'Resultado' = CASE @Result 
    WHEN 0 THEN 'Éxito' 
    WHEN -1 THEN 'Error de validación' 
    WHEN -99 THEN 'Error en ejecución' 
    ELSE 'Código desconocido: ' + CAST(@Result3 AS VARCHAR) 
END
```
| SubscriptionID | UserID | PlanID | Amount | PaymentID | TransactionID | StartDate | EndDate | Status                 |
|:--------------:|:------:|:------:|:------:|:---------:|:-------------:|:---------:|:-------:|:----------------------:|
| NULL           | 1      | 999    | NULL   | NULL      | NULL          | NULL      | NULL    | Error: Plan no encontrado |

---

### 2. SELECT que use CASE que agrupa dinámicamente datos por rango de duracion de planes
```SQL
SELECT 
    p.name AS Proveedor,
    pc.providerContractID AS ContratoID,
    DATEDIFF(MONTH, pc.startDate, pc.endDate) AS DuracionMeses,
    CASE 
        WHEN DATEDIFF(MONTH, pc.startDate, pc.endDate) < 6 THEN 'Corto plazo (menos de 6 meses)'
        WHEN DATEDIFF(MONTH, pc.startDate, pc.endDate) BETWEEN 6 AND 12 THEN 'Mediano plazo (6-12 meses)'
        WHEN DATEDIFF(MONTH, pc.startDate, pc.endDate) BETWEEN 13 AND 24 THEN 'Largo plazo (1-2 años)'
        WHEN DATEDIFF(MONTH, pc.startDate, pc.endDate) > 24 THEN 'Muy largo plazo (más de 2 años)'
        ELSE 'Duración no especificada'
    END AS RangoDuracion,
    COUNT(*) OVER (PARTITION BY 
        CASE 
            WHEN DATEDIFF(MONTH, pc.startDate, pc.endDate) < 6 THEN 1
            WHEN DATEDIFF(MONTH, pc.startDate, pc.endDate) BETWEEN 6 AND 12 THEN 2
            WHEN DATEDIFF(MONTH, pc.startDate, pc.endDate) BETWEEN 13 AND 24 THEN 3
            WHEN DATEDIFF(MONTH, pc.startDate, pc.endDate) > 24 THEN 4
            ELSE 5
        END) AS TotalEnRango
FROM 
    [dbo].[st_providersContract] pc
JOIN 
    [dbo].[st_providers] p ON pc.providerID = p.providerID
WHERE 
    pc.status = 1 -- Solo contratos activos
ORDER BY 
    DuracionMeses DESC;
```
| Proveedor          | ContratoID | DuracionMeses | RangoDuracion           | TotalEnRango |
|--------------------|:----------:|:-------------:|-------------------------|:------------:|
| Provider_341_Inc   | 1          | 11            | Mediano plazo (6-12 meses) | 7            |
| Provider_120_Inc   | 2          | 11            | Mediano plazo (6-12 meses) | 7            |
| Provider_307_Inc   | 3          | 11            | Mediano plazo (6-12 meses) | 7            |
| Provider_107_Inc   | 4          | 11            | Mediano plazo (6-12 meses) | 7            |
| Provider_328_Inc   | 5          | 11            | Mediano plazo (6-12 meses) | 7            |
| Provider_810_Inc   | 6          | 11            | Mediano plazo (6-12 meses) | 7            |
| Provider_247_Inc   | 7          | 11            | Mediano plazo (6-12 meses) | 7            |

---

### 3. Imagine una cosulta que el sistema va a necesitar para mostrar cierta información, o reporte o pantalla, y que esa consulta vaya a requerir:
1. 4 JOINs entre tablas.
2. 2 funciones agregadas (ej. SUM, AVG).
3. 3 subconsultas or 3 CTEs
4. Un CASE, CONVERT, ORDER BY, HAVING, una función escalar, y operadores como IN, NOT IN, EXISTS.
5. Escriba dicha consulta y ejecutela con el query analizer, utilizando el analizador de pesos y costos del plan de ejecución, reacomode la consulta para que sea más eficiente sin necesidad de agregar nuevos índices.

```SQL
-- Versión optimizada y corregida usando CTEs
WITH 
-- CTE 1: Planes activos con información básica
PlanesActivos AS (
    SELECT 
        p.planID,
        p.planName,
        p.planPrice,
        pt.name AS tipoPlan,
        c.acronym AS moneda
    FROM 
        [dbo].[st_plans] p
    JOIN 
        [dbo].[st_planType] pt ON p.planTypeID = pt.planTypeID
    JOIN 
        [dbo].[st_currencies] c ON p.currencyID = c.currencyID
    WHERE 
        p.planPrice > 0
),

-- CTE 2: Suscripciones activas con información de usuarios
SuscripcionesActivas AS (
    SELECT 
        s.subcriptionID,
        s.userID,
        s.planTypeID,
        u.firstName + ' ' + u.lastName AS nombreUsuario,
        CONVERT(varchar, u.birthDate, 103) AS fechaNacimientoFormateada,
        DATEDIFF(YEAR, u.birthDate, GETDATE()) AS edad
    FROM 
        [dbo].[st_subcriptions] s
    JOIN 
        [dbo].[st_users] u ON s.userID = u.userID
    WHERE 
        s.enabled = 1
),

-- CTE 3: Pagos exitosos agrupados por plan
PagosPorPlan AS (
    SELECT 
        s.planTypeID,
        COUNT(p.paymentID) AS totalPagos,
        SUM(CAST(p.amount AS DECIMAL(10,2))) AS montoTotal,
        AVG(CAST(p.amount AS DECIMAL(10,2))) AS promedioPago
    FROM 
        [dbo].[st_payments] p
    JOIN 
        [dbo].[st_subcriptions] s ON p.description LIKE '%' + CAST(s.subcriptionID AS varchar) + '%'
    WHERE 
        p.result = 'Success'
    GROUP BY 
        s.planTypeID
)

-- Consulta principal con análisis de rendimiento de planes
SELECT 
    pa.planName AS 'Plan',
    pa.tipoPlan AS 'Tipo de Plan',
    pa.moneda AS 'Moneda',
    pa.planPrice AS 'Precio Actual',
    pp.totalPagos AS 'Total Suscripciones',
    pp.montoTotal AS 'Ingresos Totales',
    pp.promedioPago AS 'Pago Promedio',
    CASE 
        WHEN pp.totalPagos > 100 THEN 'Alto Rendimiento'
        WHEN pp.totalPagos BETWEEN 50 AND 100 THEN 'Rendimiento Medio'
        WHEN pp.totalPagos < 50 THEN 'Bajo Rendimiento'
        ELSE 'Sin datos'
    END AS 'Categoría Rendimiento',
    (SELECT COUNT(*) FROM SuscripcionesActivas sa WHERE sa.planTypeID = pa.planID) AS 'Usuarios Activos',
    (SELECT AVG(edad) FROM SuscripcionesActivas sa WHERE sa.planTypeID = pa.planID) AS 'Edad Promedio Usuarios',
    (SELECT TOP 1 nombreUsuario 
     FROM SuscripcionesActivas sa 
     WHERE sa.planTypeID = pa.planID 
     ORDER BY edad DESC) AS 'Usuario Mayor'
FROM 
    PlanesActivos pa
LEFT JOIN 
    PagosPorPlan pp ON pa.planID = pp.planTypeID
WHERE 
    pa.planID IN (SELECT DISTINCT planTypeID FROM [dbo].[st_subcriptions])
    AND pa.planID NOT IN (SELECT planID FROM [dbo].[st_plans] WHERE planPrice = 0)
    AND EXISTS (SELECT 1 FROM [dbo].[st_subcriptions] s WHERE s.planTypeID = pa.planID)
    AND (pp.montoTotal > 1000 OR pp.montoTotal IS NULL) -- Movido de HAVING a WHERE
ORDER BY 
    CASE WHEN pp.montoTotal IS NULL THEN 0 ELSE pp.montoTotal END DESC, 
    pa.planName;
 ```

 | Plan         | Tipo de Plan | Moneda | Precio Actual | Total Suscripciones | Ingresos Totales | Pago Promedio     | Categoría Rendimiento | Usuarios Activos | Edad Promedio Usuarios | Usuario Mayor    |
|:------------:|:------------:|:------:|:-------------:|:-------------------:|:----------------:|:-----------------:|:---------------------:|:----------------:|:----------------------:|:---------------:|
| Plan_1_271   | Familiar     | CRC    | 54,836.63     | 66                 | 2,672,912.00     | 40,498.666666     | Rendimiento Medio     | 12               | 39                     | Lucía Solano    |
| Plan_2_555   | Familiar     | USD    | 18,366.69     | 63                 | 2,465,400.00     | 39,133.333333     | Rendimiento Medio     | 6                | 35                     | Mateo Madrigal  |
| Plan_3_533   | Premium      | USD    | 53,677.83     | 38                 | 1,542,211.00     | 40,584.500000     | Bajo Rendimiento      | 6                | 48                     | Luis Salazar    |

---

### 4. Crear una consulta con al menos 3 JOINs que analice información donde podría ser importante obtener un SET DIFFERENCE y un INTERSECTION

```SQL
-- Consulta corregida que analiza usuarios, suscripciones y pagos con operaciones de conjuntos
WITH 
-- Usuarios con suscripciones activas
UsuariosActivos AS (
    SELECT u.userID, u.firstName, u.lastName, s.subcriptionID, s.planTypeID
    FROM [dbo].[st_users] u
    JOIN [dbo].[st_subcriptions] s ON u.userID = s.userID
    WHERE s.enabled = 1
),

-- Usuarios con pagos exitosos
UsuariosConPagos AS (
    SELECT DISTINCT u.userID
    FROM [dbo].[st_users] u
    JOIN [dbo].[st_payments] p ON p.description LIKE '%' + CAST(u.userID AS VARCHAR) + '%'
    WHERE p.result = 'Success'
),

-- Planes populares (con más de 50 suscriptores)
PlanesPopulares AS (
    SELECT planTypeID
    FROM [dbo].[st_subcriptions]
    GROUP BY planTypeID
    HAVING COUNT(*) > 50
)

-- Consulta principal
SELECT 
    p.planID,
    p.planName,
    COUNT(DISTINCT ua.userID) AS totalSuscriptores,
    
    -- INTERSECTION: Usuarios activos que también tienen pagos exitosos
    (
        SELECT COUNT(*) 
        FROM UsuariosActivos ua2
        WHERE ua2.planTypeID = p.planID
        AND ua2.userID IN (SELECT userID FROM UsuariosConPagos)
    ) AS usuariosConPagos,
    
    -- SET DIFFERENCE: Usuarios activos sin pagos registrados
    (
        SELECT COUNT(*) 
        FROM UsuariosActivos ua2
        WHERE ua2.planTypeID = p.planID
        AND ua2.userID NOT IN (SELECT userID FROM UsuariosConPagos)
    ) AS usuariosSinPagos,
    
    -- Porcentaje de usuarios con pagos
    CASE
        WHEN COUNT(DISTINCT ua.userID) > 0 THEN
            CAST(
                (SELECT COUNT(*) 
                 FROM UsuariosActivos ua2
                 WHERE ua2.planTypeID = p.planID
                 AND ua2.userID IN (SELECT userID FROM UsuariosConPagos)) * 100.0 / 
                COUNT(DISTINCT ua.userID)
            AS DECIMAL(5,2))
        ELSE 0.0
    END AS porcentajePagos,
    
    -- ¿Es un plan popular?
    CASE 
        WHEN p.planID IN (SELECT planTypeID FROM PlanesPopulares) THEN 'Sí'
        ELSE 'No'
    END AS esPopular
FROM 
    [dbo].[st_plans] p
LEFT JOIN 
    UsuariosActivos ua ON p.planID = ua.planTypeID
LEFT JOIN 
    [dbo].[st_planType] pt ON p.planTypeID = pt.planTypeID
LEFT JOIN 
    [dbo].[st_currencies] c ON p.currencyID = c.currencyID
WHERE 
    p.planPrice > 0
GROUP BY 
    p.planID, p.planName, p.planTypeID
ORDER BY 
    CASE WHEN COUNT(DISTINCT ua.userID) = 0 THEN 0 ELSE
        CAST(
            (SELECT COUNT(*) 
             FROM UsuariosActivos ua2
             WHERE ua2.planTypeID = p.planID
             AND ua2.userID IN (SELECT userID FROM UsuariosConPagos)) * 100.0 / 
            COUNT(DISTINCT ua.userID)
        AS DECIMAL(5,2))
    END DESC, 
    COUNT(DISTINCT ua.userID) DESC;
```
| planID | planName               | totalSuscriptores | usuariosConPagos | usuariosSinPagos | porcentajePagos | esPopular |
|:------:|:-----------------------|:-----------------:|:----------------:|:----------------:|:---------------:|:---------:|
| 2      | Plan_2_555             | 6                 | 5                | 1                | 83.33           | No        |
| 1      | Plan_1_271             | 12                | 9                | 3                | 75.00           | No        |
| 3      | Plan_3_533             | 6                 | 4                | 2                | 66.67           | No        |
| 4      | Plan_4_564             | 0                 | 0                | 0                | 0.00            | No        |
| 5      | Plan_5_879             | 0                 | 0                | 0                | 0.00            | No        |
| 6      | Plan_6_548             | 0                 | 0                | 0                | 0.00            | No        |
| 7      | Plan_7_286             | 0                 | 0                | 0                | 0.00            | No        |
| 8      | Plan_8_851             | 0                 | 0                | 0                | 0.00            | No        |
| 9      | Plan_9_696             | 0                 | 0                | 0                | 0.00            | No        |
| 10     | Plan Nuevo Sincronizado| 0                 | 0                | 0                | 0.00            | No        |
| 11     | Plan Premium Plus      | 0                 | 0                | 0                | 0.00            | No        |

---

    