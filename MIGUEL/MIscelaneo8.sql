USE Caso2DB

-- Ejecutar este script en SSMS después de habilitar 'xp_cmdshell'
DECLARE @sql NVARCHAR(MAX);
DECLARE @bcpCommand NVARCHAR(1000);
DECLARE @outputFile NVARCHAR(100) = 'C:\temp\usuarios_suscripciones.csv';

-- Crear consulta dinámica
SET @sql = 'SELECT 
    u.userID,
    u.firstName,
    u.lastName,
    CONVERT(VARCHAR(10), u.birthDate, 120),
    s.subcriptionID,
    p.planName,
    p.planPrice,
    CASE WHEN s.enabled = 1 THEN ''SI'' ELSE ''NO'' END
FROM 
    [dbo].[st_users] u
JOIN 
    [dbo].[st_subcriptions] s ON u.userID = s.userID
JOIN 
    [dbo].[st_plans] p ON s.planTypeID = p.planID';

-- Configurar bcp
SET @bcpCommand = 'bcp "' + @sql + '" queryout "' + @outputFile + '" ' +
                  '-c -t"," -r"\n" -S ' + @@SERVERNAME + ' -T';

-- Ejecutar comando (requiere permisos)
EXEC master..xp_cmdshell @bcpCommand;

-- Verificar resultado
EXEC master..xp_cmdshell 'type C:\Users\migue\OneDrive\Documents\Bases-de-Datos\Caso2\MIGUEL\usuarios_suscripciones.csv';