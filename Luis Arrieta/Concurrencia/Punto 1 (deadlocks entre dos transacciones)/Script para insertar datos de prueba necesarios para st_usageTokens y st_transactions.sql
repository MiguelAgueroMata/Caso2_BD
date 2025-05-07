-- Script para insertar datos de prueba necesarios para st_usageTokens y st_transactions

USE [Caso2DB]
GO

-- Insertar un usuario
IF NOT EXISTS (SELECT 1 FROM dbo.st_users WHERE userID = 1)
    INSERT INTO dbo.st_users (firstName, lastName, password, enabled, birthDate, createdAt)
    VALUES ('Test', 'User', CONVERT(VARBINARY(250), 'password'), 1, '1990-01-01', GETDATE());

-- Insertar un método de pago
IF NOT EXISTS (SELECT 1 FROM dbo.st_paymentMethod WHERE paymentMethodID = 1)
    INSERT INTO dbo.st_paymentMethod (name, secretKey, [key], apiURL, enabled)
    VALUES ('Test Method', CONVERT(VARBINARY(250), 'SECRET'), CONVERT(VARBINARY(250), 'KEY'), 'http://test.com', 1);

-- Insertar una moneda
IF NOT EXISTS (SELECT 1 FROM dbo.st_currencies WHERE currencyID = 1)
    INSERT INTO dbo.st_currencies (name, acronym, symbol, country)
    VALUES ('USD', 'USD', '$', 'USA');

-- Insertar un pago
IF NOT EXISTS (SELECT 1 FROM dbo.st_payments WHERE paymentID = 1)
    INSERT INTO dbo.st_payments (paymentMethodID, amount, actualAmount, result, authentication, reference, chargedToken, description, paymentDate, checksum, currencyID)
    VALUES (1, 1000.00, 1000.00, 'Success', 'AUTH123', 'REF123', CONVERT(VARBINARY(250), 'TOKEN123'), 'Test Payment', GETDATE(), CONVERT(VARBINARY(250), 'CHECKSUM123'), 1);

-- Insertar un tipo de transacción
IF NOT EXISTS (SELECT 1 FROM dbo.st_transactionType WHERE transactionTypeID = 1)
    INSERT INTO dbo.st_transactionType (name)
    VALUES ('Service Usage');

-- Insertar un subtipo de transacción
IF NOT EXISTS (SELECT 1 FROM dbo.st_transactionSubTypes WHERE transactionSubTypesID = 1)
    INSERT INTO dbo.st_transactionSubTypes (name)
    VALUES ('Token Redemption');

-- Insertar una tasa de cambio
IF NOT EXISTS (SELECT 1 FROM dbo.st_exchangeRate WHERE exchangeRateID = 1)
    INSERT INTO dbo.st_exchangeRate (currencyIdSource, currencyIdDestiny, startDate, endDate, exchangeRate, currentExchangeRate, currencyID)
    VALUES (1, 1, GETDATE(), DATEADD(YEAR, 1, GETDATE()), 1.0, 1, 1);

-- Insertar un contrato de detalle (requerido por st_usageTokens)
IF NOT EXISTS (SELECT 1 FROM dbo.st_providers WHERE providerID = 1)
    INSERT INTO dbo.st_providers (name, providerDescription, status)
    VALUES ('Test Provider', 'Test', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.st_providersContract WHERE providerContractID = 1)
    INSERT INTO dbo.st_providersContract (startDate, endDate, contractType, contractDescription, status, authorizedSignatory, providerID)
    VALUES (GETDATE(), DATEADD(YEAR, 1, GETDATE()), 'Test', 'Test Contract', 1, CONVERT(VARBINARY(1024), 'SIGN'), 1);

IF NOT EXISTS (SELECT 1 FROM dbo.st_services WHERE serviceID = 1)
    INSERT INTO dbo.st_services (enabled, lastUpdated, providersID, serviceName, logoURL, Description, serviceTypeID)
    VALUES (1, GETDATE(), 1, 'Test Service', 'http://test.com/logo', 'Test', 1);

IF NOT EXISTS (SELECT 1 FROM dbo.st_providerServices WHERE providerServiceID = 1)
    INSERT INTO dbo.st_providerServices (providerID, serviceID)
    VALUES (1, 1);

IF NOT EXISTS (SELECT 1 FROM dbo.st_serviceAvailability WHERE serviceAvailabilityID = 1)
    INSERT INTO dbo.st_serviceAvailability (name)
    VALUES ('Available');

IF NOT EXISTS (SELECT 1 FROM dbo.st_discountType WHERE discountTypeID = 1)
    INSERT INTO dbo.st_discountType (name)
    VALUES ('None');

IF NOT EXISTS (SELECT 1 FROM dbo.st_usageUnitType WHERE usageUnitTypeID = 1)
    INSERT INTO dbo.st_usageUnitType (name)
    VALUES ('Unit');

IF NOT EXISTS (SELECT 1 FROM dbo.st_contractDetails WHERE contractDetailsID = 1)
    INSERT INTO dbo.st_contractDetails (providerContractID, serviceBasePrice, lastUpdated, createdAt, discount, includesIVA, contractPrice, finalPrice, IVA, providerProfit, solturaProfit, profit, solturaFee, enabled, providerServicesID, serviceAvailabilityID, discountTypeID, isMembership, usageUnitTypeID)
    VALUES (1, 100.00, GETDATE(), GETDATE(), 0.0, 0, 100.00, 100.00, 0.0, 50.00, 50.00, 100.00, 10.00, 1, 1, 1, 1, 0, 1);

-- Insertar un token de uso
IF NOT EXISTS (SELECT 1 FROM dbo.st_usageTokens WHERE usageTokenID = 1)
    INSERT INTO dbo.st_usageTokens (userID, tokenType, tokenCode, createdAt, expirationDate, status, failedAttempts, contractDetailsID)
    VALUES (1, 'Service', CONVERT(VARBINARY(250), 'TOKEN1'), GETDATE(), DATEADD(DAY, 30, GETDATE()), 'Active', 0, 1);

-- Insertar una transacción
IF NOT EXISTS (SELECT 1 FROM dbo.st_transactions WHERE transactionID = 1)
    INSERT INTO dbo.st_transactions (transactionAmount, description, transactionDate, postTime, referenceNumber, convertedAmount, checksum, currencyID, exchangeRateId, paymentId, userID, transactionTypeID, transactionSubTypeID)
    VALUES (100.00, 'Test Transaction', GETDATE(), GETDATE(), 'TXN123', 100.00, CONVERT(VARBINARY(250), 'CHECKSUM123'), 1, 1, 1, 1, 1, 1);
GO

SELECT * FROM dbo.st_usageTokens WHERE usageTokenID = 1;
SELECT * FROM dbo.st_transactions WHERE transactionID = 1;

SELECT failedAttempts FROM dbo.st_usageTokens WHERE usageTokenID = 1;
SELECT transactionAmount FROM dbo.st_transactions WHERE transactionID = 1;