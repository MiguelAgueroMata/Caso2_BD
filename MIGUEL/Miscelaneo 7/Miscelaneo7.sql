USE [Caso2DB]
GO

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
EXEC [dbo].[GetUserSubscriptionsJSON] @userID = 1;
GO

-- Justificación hipotética de la pantalla que podría requerir esta consulta:
-- Esta consulta genera un JSON que sería ideal para una pantalla de "Mis Suscripciones" en una aplicación como Soltura. 
-- Esta pantalla permitiría a los usuarios ver un resumen de todas sus suscripciones activas, incluyendo detalles como el nombre y precio de los planes asociados, 
-- así como una lista de servicios incluidos en cada plan (con nombres e imágenes representadas por las URLs de logos). 
-- Por ejemplo, un usuario podría expandir cada suscripción para ver los servicios disponibles (como gimnasio, entretenimiento, etc.) y sus descripciones, 
-- lo que mejora la experiencia de usuario al proporcionar información clara y visualmente atractiva. 
-- Alternativamente, esta consulta podría servir para una pantalla de "Explorar Planes" si se adapta para mostrar planes disponibles antes de suscribirse, 
-- pero "Mis Suscripciones" es más relevante porque se centra en el consumo actual del usuario.