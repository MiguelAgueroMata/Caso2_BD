USE [Caso2DB]
GO

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