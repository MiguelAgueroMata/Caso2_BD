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

	
-- Verificar resultados
SELECT * FROM [dbo].[st_providers] WHERE name = 'Provider_123_Inc';
SELECT * FROM [dbo].[st_providersContract] WHERE providerID = (SELECT providerID FROM [dbo].[st_providers] WHERE name = 'Provider_123_Inc');
SELECT * FROM [dbo].[st_contractDetails] WHERE providerContractID = (SELECT providerContractID FROM [dbo].[st_providersContract] WHERE providerID = (SELECT providerID FROM [dbo].[st_providers] WHERE name = 'Provider_123_Inc'));
GO
