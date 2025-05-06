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


-------------------------------------------------------------------------------------------------

-- VERIFICACION

-- Intentar conectar como TestReadOnly (debe funcionar):
EXECUTE AS LOGIN = 'TestReadOnly';
USE Caso2DB;            -- OK
SELECT 1 AS Conexion;   -- OK
REVERT;

-- Intentar conectar como TestNoConnect (debe fallar):
EXECUTE AS LOGIN = 'TestNoConnect';
USE Caso2DB;            -- ERROR: acceso denegado
REVERT;


--------------------------------------------------------------------

-- Con U_Sel1 (pertenece al rol, puede hacer SELECT):
EXECUTE AS USER = 'U_Sel1';
SELECT TOP 5 * FROM dbo.st_users;   -- DEBE devolver filas
REVERT;

-- Con U_NoSel (no tiene rol, no puede SELECT):
EXECUTE AS USER = 'U_NoSel';
SELECT TOP 5 * FROM dbo.st_users;   -- ERROR: permiso denegado
REVERT;

----------------------------------------------------------------------


-- U_Sel1 NO puede SELECT directo, pero SÍ ejecutar el SP:
EXECUTE AS USER = 'U_Sel1';
SELECT TOP 5 * FROM dbo.st_users;       -- ERROR: permiso denegado
EXEC dbo.sp_ListaUsuarios;              -- DEBE devolver lista de usuarios
REVERT;


-------------------------------------------------------------------------------


UPDATE dbo.st_users SET enabled = 0 WHERE userID = 1;


----------------------------------------------------------------------------

SELECT userID, firstName, enabled
  FROM dbo.st_users;


--------------------------------------------------------------------------



SELECT TOP 1 info, info_encrypted
  FROM dbo.SecretData;



-----------------------------------------------------------------------


USE Caso2DB;
GO

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

-----------------------------------------------------------------------

