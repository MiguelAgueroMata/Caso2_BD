USE Caso2DB

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