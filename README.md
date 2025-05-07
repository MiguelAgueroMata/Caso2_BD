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



## 2. SELECT que use CASE que agrupa dinámicamente datos por rango de duracion de planes
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

## 3. Imagine una cosulta que el sistema va a necesitar para mostrar cierta información, o reporte o pantalla, y que esa consulta vaya a requerir:
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

## 5. Crear una consulta con al menos 3 JOINs que analice información donde podría ser importante obtener un SET DIFFERENCE y un INTERSECTION

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

## 6. Crear un procedimiento almacenado transaccional que llame a otro SP transaccional, el cual a su vez llame a otro SP transaccional. Cada uno debe modificar al menos 2 tablas. Se debe demostrar que es posible hacer COMMIT y ROLLBACK con ejemplos exitosos y fallidos sin que haya interrumpción de la ejecución correcta de ninguno de los SP en ninguno de los niveles del llamado.

```SQL
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
```

| (No column name) | planID | planPrice | postTime                  | planName   | planTypeID | currencyID | description          | imageURL               | lastUpdated              | solturaPrice |
|------------------|--------|-----------|---------------------------|------------|------------|------------|----------------------|------------------------|---------------------------|--------------|
| st_plans         | 1      | 55336.63  | 2025-04-29 14:11:50.850   | Plan_1_271 | 2          | 1          | Descripción del plan #1 | https://logo.com/plan_1.jpg | 2025-04-29 14:11:50.850 | 8225.49      |


| (No column name)   | subcriptionID | description                                | logoURL               | enabled | planTypeID | userID |
|--------------------|---------------|--------------------------------------------|-----------------------|---------|------------|--------|
| st_subcriptions    | 1             | Suscripción actualizada por OuterTransactionSP | https://logo.com/plan_2.jpg | 1       | 2          | 8      |


| (No column name) | paymentID | paymentMethodID | amount | actualAmount | result  | authentication | reference | chargedToken      | description                          | error | paymentDate               | checksum              | currencyID |
|------------------|-----------|-----------------|--------|--------------|---------|----------------|-----------|-------------------|--------------------------------------|-------|---------------------------|-----------------------|------------|
| st_payments      | 105       | 1               | 1000   | 1000         | Success | AUTH_1         | REF_1     | 0x544F4B454E5F31 | Pago registrado por MiddleTransactionSP | NULL  | 2025-05-06 19:35:16.533 | 0x434845434B53554D5F31 | 1          |


| (No column name)    | transactionID | transactionAmount | description                          | transactionDate           | postTime                  | referenceNumber | convertedAmount | checksum              | currencyID | exchangeRateId | paymentId | userID | transactionTypeID | transactionSubTypeID |
|---------------------|---------------|-------------------|--------------------------------------|---------------------------|---------------------------|-----------------|-----------------|-----------------------|------------|----------------|-----------|--------|-------------------|----------------------|
| st_transactions     | 80            | 1000.00           | Transacción registrada por MiddleTransactionSP | 2025-05-06 19:35:16.533 | 2025-05-06 19:35:16.533 | TX_1            | 1000.00         | 0x54585F434845434B53554D5F31 | 1          | 1              | 105       | 8      | 1                 | 1                    |

| (No column name)   | usageTokenID | userID | tokenType      | tokenCode            | createdAt                 | expirationDate           | status  | failedAttempts | contractDetailsID | maxUses |
|--------------------|--------------|--------|----------------|-----------------------|---------------------------|---------------------------|---------|----------------|-------------------|---------|
| st_usageTokens     | 1            | 8      | ServiceAccess  | 0x544F4B454E5F315F323330393636 | 2025-04-29 14:15:22.023 | 2025-05-29 14:15:22.023 | Active  | 0              | 13                | 2       |

| (No column name)        | usageTransactionID | usageTokenID | transactionDate           | usageNotes                          | transactionType     |
|-------------------------|--------------------|--------------|---------------------------|-------------------------------------|---------------------|
| st_usageTransactions    | 38                 | 1            | 2025-05-06 19:35:16.537   | Uso registrado por InnerTransactionSP | ServiceConsumption  |

## 7. Será posible que haciendo una consulta SQL en esta base de datos se pueda obtener un JSON para ser consumido por alguna de las pantallas de la aplicación que tenga que ver con los planes, subscripciones, servicios o pagos. Justifique cuál pantalla podría requerir esta consulta.

```SQL
-- Consulta para obtener las suscripciones de un usuario en formato JSON
CREATE OR ALTER PROCEDURE [dbo].[GetUserSubscriptionsJSON]
    @userID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        s.subcriptionID,
        s.description AS subscriptionDescription,
        s.logoURL AS subscriptionLogo,
        p.planID,
        p.planName,
        p.planPrice,
        p.currencyID,
        (
            SELECT DISTINCT 
                ps.serviceID,
                sv.serviceName,
                sv.description AS serviceDescription,
                sv.logoURL AS serviceLogo
            FROM [dbo].[st_planServices] ps
            JOIN [dbo].[st_services] sv ON ps.serviceID = sv.serviceID
            WHERE ps.planID = p.planID
            FOR JSON PATH
        ) AS services
    FROM [dbo].[st_subcriptions] s
    JOIN [dbo].[st_plans] p ON s.planTypeID = p.planTypeID
    WHERE s.userID = @userID
    FOR JSON PATH, ROOT('subscriptions');
END;
GO

-- Probar la consulta
EXEC [dbo].[GetUserSubscriptionsJSON] @userID = 8;
GO

-- Justificación hipotética de la pantalla que podría requerir esta consulta:
-- Esta consulta genera un JSON que sería ideal para una pantalla de "Mis Suscripciones" en una aplicación como Soltura. 
-- Esta pantalla permitiría a los usuarios ver un resumen de todas sus suscripciones activas, incluyendo detalles como el nombre y precio de los planes asociados, 
-- así como una lista de servicios incluidos en cada plan (con nombres e imágenes representadas por las URLs de logos). 
-- Por ejemplo, un usuario podría expandir cada suscripción para ver los servicios disponibles (como gimnasio, entretenimiento, etc.) y sus descripciones, 
-- lo que mejora la experiencia de usuario al proporcionar información clara y visualmente atractiva. 
-- Alternativamente, esta consulta podría servir para una pantalla de "Explorar Planes" si se adapta para mostrar planes disponibles antes de suscribirse, 
-- pero "Mis Suscripciones" es más relevante porque se centra en el consumo actual del usuario.
```

```JSON
```json
{
  "subscriptions": [
    {
      "subcriptionID": 53,
      "subscriptionDescription": "Suscripción de prueba",
      "subscriptionLogo": "https://logo.com/sub.jpg",
      "planID": 3,
      "planName": "Plan_3_199",
      "planPrice": 44023.92,
      "currencyID": 1,
      "services": [
        {
          "serviceID": 5,
          "serviceName": "Entretenimiento_568",
          "serviceDescription": "Servicio #1 del proveedor #2",
          "serviceLogo": "https://logo.com/service_730.jpg"
        },
        {
          "serviceID": 7,
          "serviceName": "Belleza_215",
          "serviceDescription": "Servicio #3 del proveedor #2",
          "serviceLogo": "https://logo.com/service_67.jpg"
        },
        {
          "serviceID": 11,
          "serviceName": "Parqueo_83",
          "serviceDescription": "Servicio #1 del proveedor #4",
          "serviceLogo": "https://logo.com/service_255.jpg"
        },
        {
          "serviceID": 15,
          "serviceName": "Belleza_119",
          "serviceDescription": "Servicio #3 del proveedor #5",
          "serviceLogo": "https://logo.com/service_279.jpg"
        },
        {
          "serviceID": 23,
          "serviceName": "Lavandería_891",
          "serviceDescription": "Servicio #4 del proveedor #7",
          "serviceLogo": "https://logo.com/service_525.jpg"
        }
      ]
    },
    {
      "subcriptionID": 53,
      "subscriptionDescription": "Suscripción de prueba",
      "subscriptionLogo": "https://logo.com/sub.jpg",
      "planID": 5,
      "planName": "Plan_5_646",
      "planPrice": 47197.31,
      "currencyID": 2,
      "services": [
        {
          "serviceID": 6,
          "serviceName": "Parqueo_235",
          "serviceDescription": "Servicio #2 del proveedor #2",
          "serviceLogo": "https://logo.com/service_602.jpg"
        },
        {
          "serviceID": 12,
          "serviceName": "Limpieza_420",
          "serviceDescription": "Servicio #2 del proveedor #4",
          "serviceLogo": "https://logo.com/service_313.jpg"
        },
        {
          "serviceID": 14,
          "serviceName": "Parqueo_809",
          "serviceDescription": "Servicio #2 del proveedor #5",
          "serviceLogo": "https://logo.com/service_794.jpg"
        },
        {
          "serviceID": 22,
          "serviceName": "Telefonía_548",
          "serviceDescription": "Servicio #3 del proveedor #7",
          "serviceLogo": "https://logo.com/service_164.jpg"
        }
      ]
    },
    {
      "subcriptionID": 53,
      "subscriptionDescription": "Suscripción de prueba",
      "subscriptionLogo": "https://logo.com/sub.jpg",
      "planID": 6,
      "planName": "Plan_6_119",
      "planPrice": 38942.93,
      "currencyID": 2,
      "services": [
        {
          "serviceID": 6,
          "serviceName": "Parqueo_235",
          "serviceDescription": "Servicio #2 del proveedor #2",
          "serviceLogo": "https://logo.com/service_602.jpg"
        },
        {
          "serviceID": 12,
          "serviceName": "Limpieza_420",
          "serviceDescription": "Servicio #2 del proveedor #4",
          "serviceLogo": "https://logo.com/service_313.jpg"
        },
        {
          "serviceID": 17,
          "serviceName": "Gimnasio_661",
          "serviceDescription": "Servicio #1 del proveedor #6",
          "serviceLogo": "https://logo.com/service_441.jpg"
        }
      ]
    },
    {
      "subcriptionID": 53,
      "subscriptionDescription": "Suscripción de prueba",
      "subscriptionLogo": "https://logo.com/sub.jpg",
      "planID": 7,
      "planName": "Plan_7_996",
      "planPrice": 20065.49,
      "currencyID": 1,
      "services": [
        {
          "serviceID": 8,
          "serviceName": "Telefonía_886",
          "serviceDescription": "Servicio #4 del proveedor #2",
          "serviceLogo": "https://logo.com/service_878.jpg"
        }
      ]
    },
    {
      "subcriptionID": 53,
      "subscriptionDescription": "Suscripción de prueba",
      "subscriptionLogo": "https://logo.com/sub.jpg",
      "planID": 9,
      "planName": "PlanPrueba",
      "planPrice": 15000.00,
      "currencyID": 1,
      "services": []
    }
  ]
}
```

## 8. Podrá su base de datos soportar un SP transaccional que actualice los contratos de servicio de un proveedor, el proveedor podría ya existir o ser nuevo, si es nuevo, solo se inserta. Las condiciones del contrato del proveedor, deben ser suministradas por un Table-Valued Parameter (TVP), si las condiciones son sobre items existentes, entonces se actualiza o inserta realizando las modificacinoes que su diseño requiera, si son condiciones nuevas, entonces se insertan.

```SQL
-- Crear el tipo de tabla para el TVP
CREATE TYPE [dbo].[ContractDetailsType] AS TABLE (
    providerContractID INT NULL, -- NULL para nuevas condiciones
    serviceBasePrice DECIMAL(10, 2),
    discount DECIMAL(5, 2),
    includesIVA BIT,
    contractPrice DECIMAL(10, 2),
    finalPrice DECIMAL(10, 2),
    IVA DECIMAL(5, 2),
    providerProfit DECIMAL(10, 2),
    solturaProfit DECIMAL(10, 2),
    profit DECIMAL(10, 2),
    solturaFee DECIMAL(10, 2),
    enabled BIT,
    providerServicesID INT,
    serviceAvailabilityID INT,
    discountTypeID INT,
    isMembership BIT,
    validFrom DATE,
    validTo DATE,
    usageUnitTypeID INT,
    usageValue INT,
    maxUses INT,
    bundleQuantity INT NULL,
    bundlePrice DECIMAL(10, 2) NULL
);
GO
```

```SQL
-- Script para procedimiento transaccional.
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
```

```SQL
-- Script para probar el procedimiento con un proveedor nuevo y uno existente, usando un TVP con condiciones nuevas y existentes.

USE [Caso2DB]
GO

-- Declarar el TVP
DECLARE @contractDetails [dbo].[ContractDetailsType];

-- Insertar datos en el TVP (una condición nueva y una existente si aplica)
INSERT INTO @contractDetails (
    providerContractID, serviceBasePrice, discount, includesIVA,
    contractPrice, finalPrice, IVA, providerProfit, solturaProfit,
    profit, solturaFee, enabled, providerServicesID, serviceAvailabilityID,
    discountTypeID, isMembership, validFrom, validTo, usageUnitTypeID,
    usageValue, maxUses, bundleQuantity, bundlePrice
)
VALUES 
    -- Nueva condición
    (NULL, 2000.00, 0.0, 1, 2000.00, 2000.00, 0.13, 1400.00, 600.00, 2000.00, 200.00, 1, 1, 1, 3, 0, '2025-01-01', '2025-12-31', 1, 5, 5, NULL, NULL),
    -- Condición existente (si existe un providerContractID, cámbialo por uno real)
    (1, 3000.00, 10.0, 1, 2700.00, 2700.00, 0.13, 1890.00, 810.00, 2700.00, 270.00, 1, 1, 1, 3, 0, '2025-01-01', '2025-12-31', 1, 5, 5, NULL, NULL);

-- Prueba con un proveedor nuevo
EXEC [dbo].[UpdateProviderContract]
    @providerName = 'ProveedorNuevo',
    @providerDescription = 'Descripción de proveedor nuevo',
    @contractType = 'Anual',
    @contractDescription = 'Contrato para proveedor nuevo',
    @startDate = '2025-01-01',
    @endDate = '2025-12-31',
    @authorizedSignatory = 0x1234,
    @contractDetails = @contractDetails;

-- Verificar resultados
SELECT * FROM [dbo].[st_providers] WHERE name = 'ProveedorNuevo';
SELECT * FROM [dbo].[st_providersContract] WHERE providerID = (SELECT providerID FROM [dbo].[st_providers] WHERE name = 'ProveedorNuevo');
SELECT * FROM [dbo].[st_contractDetails] WHERE providerContractID = (SELECT providerContractID FROM [dbo].[st_providersContract] WHERE providerID = (SELECT providerID FROM [dbo].[st_providers] WHERE name = 'ProveedorNuevo'));

-- Prueba con un proveedor existente
EXEC [dbo].[UpdateProviderContract]
    @providerName = 'Provider_123_Inc', -- Cambia por un nombre existente en tu base
    @providerDescription = 'Descripción actualizada',
    @contractType = 'Mensual',
    @contractDescription = 'Contrato actualizado',
    @startDate = '2025-01-01',
    @endDate = '2025-12-31',
    @authorizedSignatory = 0x5678,
    @contractDetails = @contractDetails;
```

### Tabla: providers
| providerID | name              | providerDescription         | status |
|------------|-------------------|----------------------------|--------|
| 8          | ProveedorNuevo    | Descripción de proveedor nuevo | 1      |
| 9          | Provider_123_Inc  | Descripción actualizada     | 1      |

### Tabla: providerContracts
| providerContractID | startDate                 | endDate                   | contractType | contractDescription       | status | authorizedSignatory | providerID |
|--------------------|---------------------------|---------------------------|--------------|---------------------------|--------|---------------------|------------|
| 8                  | 2025-01-01 00:00:00.000   | 2025-12-31 00:00:00.000   | Anual        | Contrato para proveedor nuevo | 1      | 0x1234              | 8          |
| 9                  | 2025-01-01 00:00:00.000   | 2025-12-31 00:00:00.000   | Mensual      | Contrato actualizado       | 1      | 0x5678              | 9          |

### Tabla: contractDetails
| contractDetailsID | providerContractID | serviceBasePrice | lastUpdated               | createdAt                 | discount | includesIVA | contractPrice | finalPrice | IVA  | providerProfit | solturaProfit | profit | solturaFee | enabled | providerServicesID | serviceAvailabilityID | discountTypeID | isMembership | validFrom                 | validTo                   | usageUnitTypeID | usageValue | maxUses | bundleQuantity | bundlePrice |
|-------------------|--------------------|------------------|---------------------------|---------------------------|----------|-------------|---------------|------------|------|----------------|---------------|--------|------------|---------|--------------------|-----------------------|----------------|--------------|---------------------------|---------------------------|-----------------|------------|---------|----------------|-------------|
| 24                | 8                  | 2000.00          | 2025-05-06 19:51:55.260   | 2025-05-06 19:51:50.910   | 0        | 1           | 2000.00       | 2000.00    | 0.13 | 1400.00        | 600.00        | 2000.00 | 200.00     | 1       | 1                  | 1                     | 3              | 0            | 2025-01-01 00:00:00.000   | 2025-12-31 00:00:00.000   | 1               | 5          | 5        | NULL           | NULL        |
| 26                | 9                  | 2000.00          | 2025-05-06 19:51:55.263   | 2025-05-06 19:51:50.917   | 0        | 1           | 2000.00       | 2000.00    | 0.13 | 1400.00        | 600.00        | 2000.00 | 200.00     | 1       | 1                  | 1                     | 3              | 0            | 2025-01-01 00:00:00.000   | 2025-12-31 00:00:00.000   | 1               | 5          | 5        | NULL           | NULL        |

---
## Concurrencia.

### 1. Cree una situación de deadlocks entre dos transacciones que podrían llegar a darse en el sistema en el momento de hacer un canje de un servicio donde el deadlock se de entre un SELECT y UPDATE en distintas tablas.

#### Deadlock 1
```SQL
USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Transacción 1 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Paso 1: Adquirir bloqueo exclusivo en st_usageTokens
UPDATE dbo.st_usageTokens
SET failedAttempts = failedAttempts
WHERE usageTokenID = 1;

-- Simular procesamiento con espera
WAITFOR DELAY '00:00:06';

-- Paso 2: Intentar UPDATE en st_transactions
UPDATE dbo.st_transactions
SET transactionAmount = transactionAmount + 10.00
WHERE transactionID = 1;

COMMIT TRANSACTION;

PRINT 'Transacción 1 completada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```

Transacción 1 iniciada at 2025-05-06 20:00:07.637
Transacción 1 completada at 2025-05-06 20:00:18.030

#### DEadlock 2

```SQL
USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Transacción 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Paso 1: Adquirir bloqueo exclusivo en st_transactions
UPDATE dbo.st_transactions
SET transactionAmount = transactionAmount
WHERE transactionID = 1;

-- Simular procesamiento con espera
WAITFOR DELAY '00:00:06';

-- Paso 2: Intentar UPDATE en st_usageTokens
UPDATE dbo.st_usageTokens
SET failedAttempts = failedAttempts + 1
WHERE usageTokenID = 1;

COMMIT TRANSACTION;

PRINT 'Transacción 2 completada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```

Transacción 2 iniciada at 2025-05-06 20:00:10.483
Msg 1205, Level 13, State 51, Line 18
Transaction (Process ID 63) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.


### 2. Determinar si es posible que suceden deadlocks en cascada, donde A bloquea B, B bloquea C, y C bloquea A, debe poder observar el deadlock en algún monitor.

```SQL
USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Transacción A iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Paso 1: Adquirir bloqueo exclusivo en st_usageTokens
UPDATE dbo.st_usageTokens
SET failedAttempts = failedAttempts
WHERE usageTokenID = 1;

-- Simular procesamiento con espera
WAITFOR DELAY '00:00:06';

-- Paso 2: Intentar UPDATE en st_payments
UPDATE dbo.st_payments
SET amount = amount + 1.00
WHERE paymentID = 1;

COMMIT TRANSACTION;

PRINT 'Transacción A completada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
Transacción A iniciada at 2025-05-06 20:04:48.063
Transacción A completada at 2025-05-06 20:04:58.573

```SQL
USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Transacción B iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Paso 1: Adquirir bloqueo exclusivo en st_payments
UPDATE dbo.st_payments
SET amount = amount
WHERE paymentID = 1;

-- Simular procesamiento con espera
WAITFOR DELAY '00:00:06';

-- Paso 2: Intentar UPDATE en st_transactions
UPDATE dbo.st_transactions
SET transactionAmount = transactionAmount + 10.00
WHERE transactionID = 1;

COMMIT TRANSACTION;

PRINT 'Transacción B completada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
Transacción B iniciada at 2025-05-06 20:04:48.543
Msg 1205, Level 13, State 51, Line 18
Transaction (Process ID 62) was deadlocked on lock resources with another process and has been chosen as the deadlock victim. Rerun the transaction.

```SQL
USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Transacción C iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Paso 1: Adquirir bloqueo exclusivo en st_transactions
UPDATE dbo.st_transactions
SET transactionAmount = transactionAmount
WHERE transactionID = 1;

-- Simular procesamiento con espera
WAITFOR DELAY '00:00:06';

-- Paso 2: Intentar UPDATE en st_usageTokens
UPDATE dbo.st_usageTokens
SET failedAttempts = failedAttempts + 1
WHERE usageTokenID = 1;

COMMIT TRANSACTION;

PRINT 'Transacción C completada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
Transacción C iniciada at 2025-05-06 20:04:49.140
Transacción C completada at 2025-05-06 20:04:58.577

### 3.Determinar como deben usarse los niveles de isolacion: READ UNCOMMITTED, READ COMMITTED, REPEATABLE READ, SERIALIZABLE, mostrando los problemas posibles al usar cada tipo de isolación en casos particulares, se recomienda analizar casos como: obtener un reporte general histórico de alguna operación, calcular el tipo de cambio a utiliza en un momento dado, adquisición de planes cuando se están actualizando, cambios de precio durante subscripciones, agotamiento de existencias de algún beneficio.

#### Read Committed
#### 1 y 1.2
```SQL
-- 2. READ COMMITTED
-- Caso: Obtener un reporte general histórico
-- Tabla: st_transactions
-- Problema: Non-repeatable read
-- Sesion 1

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

PRINT 'Reporte iniciado at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Primera lectura
PRINT 'Primera lectura:';
SELECT transactionID, transactionAmount
FROM dbo.st_transactions
WHERE transactionID = 1;

-- Esperar para que Sesión 2 modifique
WAITFOR DELAY '00:00:05';

-- Segunda lectura
PRINT 'Segunda lectura:';
SELECT transactionID, transactionAmount
FROM dbo.st_transactions
WHERE transactionID = 1;

COMMIT TRANSACTION;

PRINT 'Reporte finalizado at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```

| transactionID | transactionAmount |
|---------------|-------------------|
| 1             | 2000.00           |

| transactionID | transactionAmount |
|---------------|-------------------|
| 1             | 277000.00         |

```SQL
-- 2. READ COMMITTED
-- Caso: Obtener un reporte general histórico
-- Tabla: st_transactions
-- Problema: Non-repeatable read
-- Sesion 2

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Modificar la transacción
UPDATE dbo.st_transactions
SET transactionAmount = 277000.00
WHERE transactionID = 1;

COMMIT TRANSACTION;

PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
Sesión 2 iniciada at 2025-05-06 20:08:02.743

Sesión 2 finalizada at 2025-05-06 20:08:02.743

#### 2 y 2.2

```SQL
-- 2. READ COMMITTED
-- Caso: Agotamiento de existencias
-- Tabla: st_usageTokens (usando maxUses como inventario)
-- Problema: Non-repeatable read (ajustado para tu estructura).
-- Sesion 1

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

PRINT 'Verificación de stock iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Primera verificación: Ver el valor específico de maxUses
PRINT 'Primera verificación:';
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

-- Esperar para que Sesión 2 modifique
WAITFOR DELAY '00:00:05';

-- Segunda verificación: Ver el mismo registro
PRINT 'Segunda verificación:';
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE usageTokenID = 1;

-- Verificar si el registro sigue siendo elegible para inventario
PRINT 'Verificación de elegibilidad para inventario:';
SELECT usageTokenID, maxUses
FROM dbo.st_usageTokens
WHERE maxUses > 0;

COMMIT TRANSACTION;

PRINT 'Verificación de stock finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
| usageTokenID | maxUses |
|-------------|---------|
| 1           | 2       |

| usageTokenID | maxUses |
|-------------|---------|
| 1           | 0       |

```SQL
-- 2. READ COMMITTED
-- Caso: Agotamiento de existencias
-- Tabla: st_usageTokens (usando maxUses como inventario)
-- Problema: Non-repeatable read (ajustado para tu estructura).
-- Sesion 2

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Reducir el stock
UPDATE dbo.st_usageTokens
SET maxUses = 0
WHERE usageTokenID = 1;

COMMIT TRANSACTION;

PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
Sesión 2 iniciada at 2025-05-06 20:11:03.260

Sesión 2 finalizada at 2025-05-06 20:11:03.260

---

#### Read Uncommited
#### 1 y 1.2

```SQL
-- 1. READ UNCOMMITTED
-- Caso: Obtener un reporte general histórico de alguna operación
-- Tabla: st_transactions
-- Problema: Dirty reads.

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 1 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Modificar una transacción sin hacer COMMIT
UPDATE dbo.st_transactions
SET transactionAmount = 9999.00
WHERE transactionID = 1;

PRINT 'Transacción modificada, esperando COMMIT...';
WAITFOR DELAY '00:00:10';

-- Descomenta para hacer COMMIT o ROLLBACK
-- COMMIT TRANSACTION;
ROLLBACK TRANSACTION;

PRINT 'Sesión 1 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
Sesión 1 iniciada at 2025-05-06 20:16:03.417
Transacción modificada, esperando COMMIT...
Sesión 1 finalizada at 2025-05-06 20:16:13.430

```SQL
-- 1. READ UNCOMMITTED
-- Caso: Obtener un reporte general histórico de alguna operación
-- Problema: Dirty reads (lectura de datos no confirmados).
-- Demostración:
-- Sesión 2: Genera un reporte con READ UNCOMMITTED y lee datos no confirmados.

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

PRINT 'Reporte iniciado at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Generar un reporte histórico
SELECT SUM(transactionAmount) AS TotalAmount
FROM dbo.st_transactions;

COMMIT TRANSACTION;

PRINT 'Reporte finalizado at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
Reporte iniciado at 2025-05-06 20:16:03.820
Reporte finalizado at 2025-05-06 20:16:03.820

|TotalAmount|
| :-------: |
|3090391.84 |

--- 

#### 2 y 2.2

```SQl
-- Caso: Calcular el tipo de cambio
-- Tabla: st_exchangeRate
-- Problema: Dirty read.
-- Sesion 1


USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 1 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Modificar el tipo de cambio sin hacer COMMIT
UPDATE dbo.st_exchangeRate
SET exchangeRate = 0.0930
WHERE exchangeRateID = 1;

PRINT 'Tipo de cambio modificado, esperando COMMIT...';
WAITFOR DELAY '00:00:10';

-- ROLLBACK para simular un error
ROLLBACK TRANSACTION;

PRINT 'Sesión 1 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
Sesión 1 iniciada at 2025-05-06 20:20:19.990

Tipo de cambio modificado, esperando COMMIT...

Sesión 1 finalizada at 2025-05-06 20:20:29.993

VALOR INICIAL
|exchangeRate|
| :-------: |
|0.002|

```SQL
-- Caso: Calcular el tipo de cambio
-- Tabla: st_exchangeRate
-- Problema: Dirty read.
-- Sesion2

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

PRINT 'Cálculo iniciado at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Calcular usando el tipo de cambio
SELECT exchangeRate
FROM dbo.st_exchangeRate
WHERE exchangeRateID = 1;

COMMIT TRANSACTION;

PRINT 'Cálculo finalizado at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
VALOR LUEGO DE FINALIZAR UNCOMMITTED
|exchangeRate|
| :-------: |
|0.093|

---

#### REPEATABLE READ


```SQL
-- 3. REPEATABLE READ
-- Caso: Cambios de precio durante suscripciones
-- Tabla: st_plans (usando planPrice a través de st_subcriptions)
-- Problema: Phantom read.
-- Sesion 1

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

PRINT 'Verificación de precio iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Primera verificación: Ver el precio del plan asociado a las suscripciones
PRINT 'Primera verificación:';
SELECT s.subcriptionID, p.planPrice
FROM dbo.st_subcriptions s
JOIN dbo.st_plans p ON s.planTypeID = p.planTypeID
WHERE s.planTypeID = 1;

-- Esperar para que Sesión 2 inserte
WAITFOR DELAY '00:00:05';

-- Segunda verificación
PRINT 'Segunda verificación:';
SELECT s.subcriptionID, p.planPrice
FROM dbo.st_subcriptions s
JOIN dbo.st_plans p ON s.planTypeID = p.planTypeID
WHERE s.planTypeID = 1;

COMMIT TRANSACTION;

PRINT 'Verificación de precio finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```

```SQL
-- 3. REPEATABLE READ
-- Caso: Cambios de precio durante suscripciones
-- Tabla: st_plans (usando planPrice a través de st_subcriptions)
-- Problema: Phantom read.
-- Sesion 2

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Insertar una nueva suscripción para el planTypeID = 1
INSERT INTO dbo.st_subcriptions (description, logoURL, enabled, planTypeID, userID)
VALUES ('Nueva suscripción', 'http://logo.com', 1, 1, 10);

COMMIT TRANSACTION;

PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```

Sesión 2 iniciada at 2025-05-06 20:24:56.027

Sesión 2 finalizada at 2025-05-06 20:24:56.033

| #  | Subscription ID | Plan Price |   | #  | subscriptionID | planPrice |
| -- | --------------: | ---------: | - | -- | -------------- | --------- |
| 1  |               4 |  53,677.83 |   | 1  | 4              | 53677.83  |
| 2  |               5 |  53,677.83 |   | 2  | 5              | 53677.83  |
| 3  |               7 |  53,677.83 |   | 3  | 7              | 53677.83  |
| 4  |              10 |  53,677.83 |   | 4  | 10             | 53677.83  |
| 5  |              12 |  53,677.83 |   | 5  | 12             | 53677.83  |
| 6  |              14 |  53,677.83 |   | 6  | 14             | 53677.83  |
| 7  |              15 |  53,677.83 |   | 7  | 15             | 53677.83  |
| 8  |              17 |  53,677.83 |   | 8  | 17             | 53677.83  |
| 9  |              20 |  53,677.83 |   | 9  | 20             | 53677.83  |
| 10 |              21 |  53,677.83 |   | 10 | 21             | 53677.83  |
| 11 |              22 |  53,677.83 |   | 11 | 22             | 53677.83  |
| 12 |              27 |  53,677.83 |   | 12 | 27             | 53677.83  |
| 13 |               4 |  20,734.75 |   | 13 | 28             | 53677.83  |
| 14 |               5 |  20,734.75 |   | 14 | 4              | 20734.75  |
| 15 |               7 |  20,734.75 |   | 15 | 5              | 20734.75  |
| 16 |              10 |  20,734.75 |   | 16 | 7              | 20734.75  |
| 17 |              12 |  20,734.75 |   | 17 | 10             | 20734.75  |
| 18 |              14 |  20,734.75 |   | 18 | 12             | 20734.75  |
| 19 |              15 |  20,734.75 |   | 19 | 14             | 20734.75  |
| 20 |              17 |  20,734.75 |   | 20 | 15             | 20734.75  |
| 21 |              20 |  20,734.75 |   | 21 | 17             | 20734.75  |
| 22 |              21 |  20,734.75 |   | 22 | 20             | 20734.75  |
| 23 |              22 |  20,734.75 |   | 23 | 21             | 20734.75  |
| 24 |              27 |  20,734.75 |   | 24 | 22             | 20734.75  |
| 25 |               4 |  24,771.26 |   | 25 | 27             | 20734.75  |
| 26 |               5 |  24,771.26 |   | 26 | 28             | 20734.75  |
| 27 |               7 |  24,771.26 |   | 27 | 4              | 24771.26  |
| 28 |              10 |  24,771.26 |   | 28 | 5              | 24771.26  |
| 29 |              12 |  24,771.26 |   | 29 | 7              | 24771.26  |
| 30 |              14 |  24,771.26 |   | 30 | 10             | 24771.26  |
| 31 |              15 |  24,771.26 |   | 31 | 12             | 24771.26  |
| 32 |              17 |  24,771.26 |   | 32 | 14             | 24771.26  |
| 33 |              20 |  24,771.26 |   | 33 | 15             | 24771.26  |
| 34 |              21 |  24,771.26 |   | 34 | 17             | 24771.26  |
| 35 |              22 |  24,771.26 |   | 35 | 20             | 24771.26  |
| 36 |              27 |  24,771.26 |   | 36 | 21             | 24771.26  |
| 37 |               4 |  57,291.70 |   | 37 | 22             | 24771.26  |
| 38 |               5 |  57,291.70 |   | 38 | 27             | 24771.26  |
| 39 |               7 |  57,291.70 |   | 39 | 28             | 24771.26  |
| 40 |              10 |  57,291.70 |   | 40 | 4              | 57291.70  |
| 41 |              12 |  57,291.70 |   | 41 | 5              | 57291.70  |
| 42 |              14 |  57,291.70 |   | 42 | 7              | 57291.70  |
| 43 |              15 |  57,291.70 |   | 43 | 10             | 57291.70  |
| 44 |              17 |  57,291.70 |   | 44 | 12             | 57291.70  |
| 45 |              20 |  57,291.70 |   | 45 | 14             | 57291.70  |
| 46 |              21 |  57,291.70 |   | 46 | 15             | 57291.70  |
| 47 |              22 |  57,291.70 |   | 47 | 17             | 57291.70  |
| 48 |              27 |  57,291.70 |   | 48 | 20             | 57291.70  |
| 49 |               4 |  25,000.00 |   | 49 | 21             | 57291.70  |
| 50 |               5 |  25,000.00 |   | 50 | 22             | 57291.70  |
| 51 |               7 |  25,000.00 |   | 51 | 27             | 57291.70  |
| 52 |              10 |  25,000.00 |   | 52 | 28             | 57291.70  |
| 53 |              12 |  25,000.00 |   | 53 | 4              | 25000.00  |
| 54 |              14 |  25,000.00 |   | 54 | 5              | 25000.00  |
| 55 |              15 |  25,000.00 |   | 55 | 7              | 25000.00  |
| 56 |              17 |  25,000.00 |   | 56 | 10             | 25000.00  |
| 57 |              20 |  25,000.00 |   | 57 | 12             | 25000.00  |
| 58 |              21 |  25,000.00 |   | 58 | 14             | 25000.00  |
| 59 |              22 |  25,000.00 |   | 59 | 15             | 25000.00  |
| 60 |              27 |  25,000.00 |   | 60 | 17             | 25000.00  |
| 61 |               4 |  45,000.00 |   | 61 | 20             | 25000.00  |
| 62 |               5 |  45,000.00 |   | 62 | 21             | 25000.00  |
| 63 |               7 |  45,000.00 |   | 63 | 22             | 25000.00  |
| 64 |              10 |  45,000.00 |   | 64 | 27             | 25000.00  |
| 65 |              12 |  45,000.00 |   | 65 | 28             | 25000.00  |
| 66 |              14 |  45,000.00 |   | 66 | 4              | 45000.00  |
| 67 |              15 |  45,000.00 |   | 67 | 5              | 45000.00  |
| 68 |              17 |  45,000.00 |   | 68 | 7              | 45000.00  |
| 69 |              20 |  45,000.00 |   | 69 | 10             | 45000.00  |
| 70 |              21 |  45,000.00 |   | 70 | 12             | 45000.00  |
| 71 |              22 |  45,000.00 |   | 71 | 14             | 45000.00  |
| 72 |              27 |  45,000.00 |   | 72 | 15             | 45000.00  |
|    |                 |            |   | 73 | 17             | 45000.00  |
|    |                 |            |   | 74 | 20             | 45000.00  |
|    |                 |            |   | 75 | 21             | 45000.00  |
|    |                 |            |   | 76 | 22             | 45000.00  |
|    |                 |            |   | 77 | 27             | 45000.00  |
|    |                 |            |   | 78 | 28             | 45000.00  |


#### Serializable

Precio antes de ejecutar el Serializable\

|planID|	planPrice|
| :--: | :--: |
|1|	15000.00|

```SQL
-- 4. SERIALIZABLE
-- Caso: Adquisición de planes cuando se están actualizando
-- Tabla: st_plans
-- Problema: Riesgo de deadlocks.
-- Sesion 1

USE [Caso2DB]
GO

SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

PRINT 'Adquisición de plan iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Verificar el precio del plan
SELECT planID, planPrice
FROM dbo.st_plans
WHERE planID = 1;

-- Simular procesamiento
WAITFOR DELAY '00:00:05';

-- Confirmar adquisición (simulada)
UPDATE dbo.st_plans
SET planPrice = planPrice
WHERE planID = 1;

COMMIT TRANSACTION;

PRINT 'Adquisición de plan finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO

```

```SQL
-- 4. SERIALIZABLE
-- Caso: Adquisición de planes cuando se están actualizando
-- Tabla: st_plans
-- Problema: Riesgo de deadlocks.
-- Sesion 2

USE [Caso2DB]
GO

SET NOCOUNT ON;
PRINT 'Sesión 2 iniciada at ' + CONVERT(VARCHAR, GETDATE(), 121)

BEGIN TRANSACTION;

-- Actualizar el precio del plan
UPDATE dbo.st_plans
SET planPrice = 157980
WHERE planID = 1;

COMMIT TRANSACTION;

PRINT 'Sesión 2 finalizada at ' + CONVERT(VARCHAR, GETDATE(), 121)
GO
```
Sesión 2 iniciada at 2025-05-06 20:37:20.673

Sesión 2 finalizada at 2025-05-06 20:37:25.350

Precio luego de la ejecucion
|planID|	planPrice|
| :--: | :--: |
|1|	157980.00|