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