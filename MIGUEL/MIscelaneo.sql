USE Caso2DB;

-- Primero eliminamos las vistas si existen
IF EXISTS (SELECT * FROM sys.views WHERE name = 'VW_DetalleSuscripcionesPagos_Completa')
DROP VIEW [dbo].[VW_DetalleSuscripcionesPagos_Completa];
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'VW_DetalleSuscripcionesPagos')
DROP VIEW [dbo].[VW_DetalleSuscripcionesPagos];
GO

-- Creamos la vista indexada en un batch separado
CREATE VIEW [dbo].[VW_DetalleSuscripcionesPagos]
WITH SCHEMABINDING
AS
SELECT 
    u.userID,
    s.subcriptionID,
    p.paymentID,
    sv.serviceID,
    p.paymentDate,
    p.amount AS montoPago,
    sv.serviceName,
    st.name AS tipoServicio,
    p.currencyID,
    -- Usamos la clave primaria de planServices para garantizar unicidad
    ps.planServiceID AS idUnico
FROM [dbo].[st_users] u
JOIN [dbo].[st_subcriptions] s ON u.userID = s.userID
JOIN [dbo].[st_payments] p ON s.subcriptionID = p.paymentID
JOIN [dbo].[st_planServices] ps ON s.planTypeID = ps.planID
JOIN [dbo].[st_services] sv ON ps.serviceID = sv.serviceID
JOIN [dbo].[st_serviceType] st ON sv.serviceTypeID = st.serviceTypeID;
GO

-- Creamos el índice clustered en otro batch
CREATE UNIQUE CLUSTERED INDEX [IX_VW_DetalleSuscripcionesPagos]
ON [dbo].[VW_DetalleSuscripcionesPagos] (userID, subcriptionID, paymentID, serviceID, idUnico);
GO

-- Finalmente creamos la vista completa en otro batch
CREATE VIEW [dbo].[VW_DetalleSuscripcionesPagos_Completa]
AS
SELECT 
    v.userID,
    u.firstName + ' ' + u.lastName AS nombreCompleto,
    v.subcriptionID,
    v.paymentID,
    v.paymentDate,
    v.montoPago,
    c.symbol + ' ' + CAST(v.montoPago AS VARCHAR(20)) AS montoFormateado,
    v.serviceID,
    v.serviceName,
    v.tipoServicio,
    (SELECT COUNT(*) 
     FROM [dbo].[st_subcriptions] s2 
     WHERE s2.userID = v.userID) AS totalSuscripcionesUsuario
FROM [dbo].[VW_DetalleSuscripcionesPagos] v
JOIN [dbo].[st_users] u ON v.userID = u.userID
JOIN [dbo].[st_currencies] c ON v.currencyID = c.currencyId;
GO




-- Ver datos en la vista indexada
SELECT TOP 5 * FROM [dbo].[VW_DetalleSuscripcionesPagos];

-- Ver datos formateados
SELECT TOP 5 * FROM [dbo].[VW_DetalleSuscripcionesPagos_Completa];

-- Verificar que no hay duplicados en la clave del índice
SELECT userID, subcriptionID, paymentID, serviceID, idUnico, COUNT(*) as conteo
FROM [dbo].[VW_DetalleSuscripcionesPagos]
GROUP BY userID, subcriptionID, paymentID, serviceID, idUnico
HAVING COUNT(*) > 1;

-- Probar inserción dinámica
BEGIN TRANSACTION;
INSERT INTO [dbo].[st_payments] (
    [paymentMethodID], [amount], [actualAmount], [result], 
    [authentication], [reference], [chargedToken], [description],
    [error], [paymentDate], [checksum], [currencyID]
)
VALUES (
    1, 120000.00, 120000.00, 'Success',
    'AUTH_TEST6', 'REF_TEST6', 0x1234, 'Prueba final 2',
    NULL, GETDATE(), 0x5678, 1
);

-- Verificar que aparece en la vista
SELECT * FROM [dbo].[VW_DetalleSuscripcionesPagos_Completa]
WHERE paymentDate = CAST(GETDATE() AS DATE);

SELECT * FROM [dbo].[VW_DetalleSuscripcionesPagoS]
WHERE paymentDate = CAST(GETDATE() AS DATE);


ROLLBACK TRANSACTION; -- Para no afectar los datos reales

--SELECT * FROM st_payments WHERE reference = 'REF_TEST6'