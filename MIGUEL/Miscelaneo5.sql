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