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

-- Justificaci�n hipot�tica de la pantalla que podr�a requerir esta consulta:
-- Esta consulta genera un JSON que ser�a ideal para una pantalla de "Mis Suscripciones" en una aplicaci�n como Soltura. 
-- Esta pantalla permitir�a a los usuarios ver un resumen de todas sus suscripciones activas, incluyendo detalles como el nombre y precio de los planes asociados, 
-- as� como una lista de servicios incluidos en cada plan (con nombres e im�genes representadas por las URLs de logos). 
-- Por ejemplo, un usuario podr�a expandir cada suscripci�n para ver los servicios disponibles (como gimnasio, entretenimiento, etc.) y sus descripciones, 
-- lo que mejora la experiencia de usuario al proporcionar informaci�n clara y visualmente atractiva. 
-- Alternativamente, esta consulta podr�a servir para una pantalla de "Explorar Planes" si se adapta para mostrar planes disponibles antes de suscribirse, 
-- pero "Mis Suscripciones" es m�s relevante porque se centra en el consumo actual del usuario.