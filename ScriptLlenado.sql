USE Caso2DB;

INSERT INTO st_currencies(acronym, name, symbol, country) VALUES 
('CRC', 'Colón costarricense', '₡', 'Costa Rica'),
('USD', 'Dólar estadounidense', '$', 'Estados Unidos');


INSERT INTO st_users(firstName, lastName, password, enabled, birthDate, createdAt) VALUES
('Miguel', 'Aguero Mata', HASHBYTES('SHA2_256', 'my_secure_password' + 'salt_value2'), 1, GETDATE(), GETDATE());

INSERT INTO st_users(firstName, lastName, password, enabled, birthDate, createdAt) VALUES
('Luis', 'Arrieta', HASHBYTES('SHA2_256', 'my_secure_password' + 'salt_value'), 1, GETDATE(), GETDATE());

INSERT INTO st_users(firstName, lastName, password, enabled, birthDate, createdAt) VALUES
('Bryan', 'Marin', HASHBYTES('SHA2_256', 'my_secure_password' + 'salt_value3'), 0, GETDATE(), GETDATE());

INSERT INTO st_users(firstName, lastName, password, enabled, birthDate, createdAt) VALUES
('Juan', 'Pi', HASHBYTES('SHA2_256', 'my_secure_password' + 'salt_value4'), 1, GETDATE(), GETDATE());


INSERT INTO [dbo].[st_contactType] ([name])
VALUES 
('Teléfono'),
('Correo Electrónico'),
('Dirección'),
('WhatsApp'),
('Facebook');

-- 1.3 Tipos de Servicio
INSERT INTO [dbo].[st_serviceType] ([name], [description])
VALUES 
('Gimnasio', 'Servicios relacionados con gimnasios y centros de acondicionamiento físico'),
('Salud', 'Servicios médicos y de bienestar'),
('Parqueo', 'Servicios de estacionamiento'),
('Transporte', 'Servicios de movilidad y transporte'),
('Entretenimiento', 'Servicios de ocio y entretenimiento'),
('Educación', 'Servicios educativos y de capacitación'),
('Comida', 'Servicios de alimentación y restaurantes');

-- 1.4 Disponibilidad de Servicios
INSERT INTO [dbo].[st_serviceAvailability] ([name])
VALUES 
('Diario'),
('Semanal'),
('Mensual'),
('Anual'),
('Único');

-- 1.5 Tipos de Plan
INSERT INTO [dbo].[st_planType] ([name], [description], [enabled], [createdAt], [lastUpdated])
VALUES 
('Individual', 'Plan para un solo usuario', 1, GETDATE(), GETDATE()),
('Familiar', 'Plan para grupos familiares', 1, GETDATE(), GETDATE()),
('Corporativo', 'Plan para empresas', 1, GETDATE(), GETDATE()),
('Promocional', 'Planes con promociones especiales', 1, GETDATE(), GETDATE()),
('Premium', 'Planes con beneficios exclusivos', 1, GETDATE(), GETDATE());

-- 1.6 Tipos de Descuento
INSERT INTO [dbo].[st_discountType] ([name])
VALUES 
('Porcentaje'),
('Monto Fijo'),
('Cantidad Fija'),
('Temporada'),
('Promoción Especial');

-- 1.7 Tipos de Unidad de Uso
INSERT INTO [dbo].[st_usageUnitType] ([name])
VALUES 
('Visita'),
('Hora'),
('Día'),
('Semana'),
('Mes'),
('Año');

-- 1.8 Tipos de Transacción
INSERT INTO [dbo].[st_transactionType] ([name])
VALUES 
('Pago'),
('Reembolso'),
('Ajuste'),
('Cargo'),
('Descuento');

-- 1.9 Subtipos de Transacción
INSERT INTO [dbo].[st_transactionSubTypes] ([name])
VALUES 
('Suscripción'),
('Renovación'),
('Uso de servicio'),
('Membresía'),
('Paquete');

-- 1.10 Métodos de Pago
INSERT INTO [dbo].[st_paymentMethod] ([name], [secretKey], [key], [apiURL], [logoURL], [configJSON], [lastUpdated], [enabled])
VALUES 
('Tarjeta de Crédito', 0x7365637265746B657931, 0x6B657931, 'https://api.payments.com/creditcard', 'https://logo.com/creditcard.png', '{"currency":"USD"}', GETDATE(), 1),
('PayPal', 0x7365637265746B657932, 0x6B657932, 'https://api.paypal.com/v1', 'https://logo.com/paypal.png', '{"currency":"USD"}', GETDATE(), 1),
('Sinpe Móvil', 0x7365637265746B657933, 0x6B657933, 'https://api.sinpe.com/v1', 'https://logo.com/sinpe.png', '{"currency":"CRC"}', GETDATE(), 1),
('Transferencia Bancaria', 0x7365637265746B657934, 0x6B657934, 'https://api.bank.com/transfer', 'https://logo.com/banktransfer.png', '{"currency":"CRC"}', GETDATE(), 1);

INSERT INTO [dbo].[st_providers] ([name], [providerDescription], [status])
VALUES 
('GymPower', 'Cadena de gimnasios a nivel nacional', 1),
('SaludTotal', 'Clínicas médicas y servicios de salud', 1),
('ParkEasy', 'Sistema de parqueos inteligentes', 1),
('MoveFast', 'Servicios de transporte privado', 1),
('CineMax', 'Cadena de cines y entretenimiento', 1),
('EduOnline', 'Plataforma de educación en línea', 1),
('FoodExpress', 'Servicio de comida a domicilio', 1);

-- 2.2 Información de Contacto de Proveedores
INSERT INTO [dbo].[st_providerContactInfo] ([contact], [enabled], [createdAt], [lastUpdated], [providerID], [description], [ContactTypeID])
VALUES 
('info@gympower.com', 1, GETDATE(), GETDATE(), 1, 'Correo principal', 2),
('+506 2222-2222', 1, GETDATE(), GETDATE(), 1, 'Teléfono principal', 1),
('San José, Curridabat', 1, GETDATE(), GETDATE(), 1, 'Sede central', 3),
('info@saludtotal.com', 1, GETDATE(), GETDATE(), 2, 'Correo principal', 2),
('+506 2233-4455', 1, GETDATE(), GETDATE(), 2, 'Teléfono principal', 1),
('info@parkeasy.com', 1, GETDATE(), GETDATE(), 3, 'Correo principal', 2),
('info@movefast.com', 1, GETDATE(), GETDATE(), 4, 'Correo principal', 2),
('info@cinemax.com', 1, GETDATE(), GETDATE(), 5, 'Correo principal', 2),
('info@eduonline.com', 1, GETDATE(), GETDATE(), 6, 'Correo principal', 2),
('info@foodexpress.com', 1, GETDATE(), GETDATE(), 7, 'Correo principal', 2);

-- 2.3 Servicios
INSERT INTO [dbo].[st_services] ([enabled], [lastUpdated], [providersID], [serviceName], [logoURL], [Description], [serviceTypeID])
VALUES 
(1, GETDATE(), 1, 'Membresía GymPower', 'https://logo.com/gympower.png', 'Acceso ilimitado a todas las sucursales', 1),
(1, GETDATE(), 1, 'Entrenador Personal', 'https://logo.com/gympower.png', 'Sesiones con entrenador personal certificado', 1),
(1, GETDATE(), 2, 'Chequeo Médico', 'https://logo.com/saludtotal.png', 'Chequeo médico general', 2),
(1, GETDATE(), 2, 'Odontología', 'https://logo.com/saludtotal.png', 'Servicios odontológicos básicos', 2),
(1, GETDATE(), 3, 'Parqueo Diario', 'https://logo.com/parkeasy.png', 'Parqueo por día en ubicaciones seleccionadas', 3),
(1, GETDATE(), 3, 'Parqueo Mensual', 'https://logo.com/parkeasy.png', 'Parqueo mensual en ubicación fija', 3),
(1, GETDATE(), 4, 'Transporte Ejecutivo', 'https://logo.com/movefast.png', 'Servicio de transporte privado ejecutivo', 4),
(1, GETDATE(), 4, 'Transporte Compartido', 'https://logo.com/movefast.png', 'Servicio de transporte compartido económico', 4),
(1, GETDATE(), 5, 'Cine Ilimitado', 'https://logo.com/cinemax.png', 'Entradas ilimitadas al cine', 5),
(1, GETDATE(), 5, 'Combo Familiar', 'https://logo.com/cinemax.png', 'Entradas + combos de comida para familia', 5),
(1, GETDATE(), 6, 'Cursos Online', 'https://logo.com/eduonline.png', 'Acceso a todos los cursos en línea', 6),
(1, GETDATE(), 6, 'Certificaciones', 'https://logo.com/eduonline.png', 'Programas de certificación profesional', 6),
(1, GETDATE(), 7, 'Comida Diaria', 'https://logo.com/foodexpress.png', 'Entrega diaria de comida saludable', 7),
(1, GETDATE(), 7, 'Cena Gourmet', 'https://logo.com/foodexpress.png', 'Cena gourmet a domicilio', 7);

-- 2.4 Relación Proveedores-Servicios
INSERT INTO [dbo].[st_providerServices] ([providerID], [serviceID])
VALUES 
(1, 1), (1, 2),
(2, 3), (2, 4),
(3, 5), (3, 6),
(4, 7), (4, 8),
(5, 9), (5, 10),
(6, 11), (6, 12),
(7, 13), (7, 14);



INSERT INTO [dbo].[st_providersContract] ([startDate], [endDate], [contractType], [contractDescription], [status], [authorizedSignatory], [providerID])
VALUES 
('2023-01-01', '2024-12-31', 'Exclusivo', 'Contrato exclusivo con GymPower para membresías', 1, 0x7369676E617475726531, 1),
('2023-02-01', '2024-11-30', 'Estándar', 'Contrato estándar con SaludTotal', 1, 0x7369676E617475726532, 2),
('2023-03-01', '2024-10-31', 'Promocional', 'Contrato promocional con ParkEasy', 1, 0x7369676E617475726533, 3),
('2023-04-01', '2024-09-30', 'Exclusivo', 'Contrato exclusivo con MoveFast', 1, 0x7369676E617475726534, 4),
('2023-05-01', '2024-08-31', 'Estándar', 'Contrato estándar con CineMax', 1, 0x7369676E617475726535, 5),
('2023-06-01', '2024-07-31', 'Promocional', 'Contrato promocional con EduOnline', 1, 0x7369676E617475726536, 6),
('2023-07-01', '2024-06-30', 'Exclusivo', 'Contrato exclusivo con FoodExpress', 1, 0x7369676E617475726537, 7);

-- 3.2 Detalles de Contratos
INSERT INTO [dbo].[st_contractDetails] (
    [providerContractID], [serviceBasePrice], [lastUpdated], [createdAt], [discount], 
    [includesIVA], [contractPrice], [finalPrice], [IVA], [providerProfit], 
    [solturaProfit], [profit], [solturaFee], [enabled], [providerServicesID], 
    [serviceAvailabilityID], [discountTypeID], [isMembership], [validFrom], 
    [validTo], [usageUnitTypeID], [usageValue], [maxUses], [bundleQuantity], [bundlePrice]
)
VALUES 
-- GymPower Membresía (1)
(1, 50.00, GETDATE(), GETDATE(), 10.0, 1, 45.00, 50.85, 13.0, 35.00, 10.00, 5.85, 5.00, 1, 1, 3, 1, 1, '2023-01-01', '2024-12-31', 3, NULL, NULL, NULL, NULL),
-- GymPower Entrenador (2)
(1, 30.00, GETDATE(), GETDATE(), 15.0, 1, 25.50, 28.82, 13.0, 20.00, 5.50, 3.32, 2.00, 1, 2, 2, 1, 0, '2023-01-01', '2024-12-31', 1, 1, NULL, NULL, NULL),
-- SaludTotal Chequeo (3)
(2, 80.00, GETDATE(), GETDATE(), 5.0, 1, 76.00, 85.88, 13.0, 60.00, 16.00, 9.88, 6.00, 1, 3, 1, 1, 0, '2023-02-01', '2024-11-30', 1, 1, NULL, NULL, NULL),
-- SaludTotal Odontología (4)
(2, 60.00, GETDATE(), GETDATE(), 10.0, 1, 54.00, 61.02, 13.0, 45.00, 9.00, 7.02, 3.00, 1, 4, 1, 1, 0, '2023-02-01', '2024-11-30', 1, 1, NULL, NULL, NULL),
-- ParkEasy Diario (5)
(3, 5.00, GETDATE(), GETDATE(), 20.0, 1, 4.00, 4.52, 13.0, 3.00, 1.00, 0.52, 0.50, 1, 5, 1, 1, 0, '2023-03-01', '2024-10-31', 1, 1, NULL, NULL, NULL),
-- ParkEasy Mensual (6)
(3, 100.00, GETDATE(), GETDATE(), 15.0, 1, 85.00, 96.05, 13.0, 70.00, 15.00, 11.05, 5.00, 1, 6, 3, 1, 0, '2023-03-01', '2024-10-31', 3, NULL, NULL, NULL, NULL),
-- MoveFast Ejecutivo (7)
(4, 20.00, GETDATE(), GETDATE(), 10.0, 1, 18.00, 20.34, 13.0, 15.00, 3.00, 2.34, 1.00, 1, 7, 1, 1, 0, '2023-04-01', '2024-09-30', 1, 1, NULL, NULL, NULL),
-- MoveFast Compartido (8)
(4, 10.00, GETDATE(), GETDATE(), 5.0, 1, 9.50, 10.74, 13.0, 7.50, 2.00, 1.24, 0.50, 1, 8, 1, 1, 0, '2023-04-01', '2024-09-30', 1, 1, NULL, NULL, NULL),
-- CineMax Ilimitado (9)
(5, 30.00, GETDATE(), GETDATE(), 25.0, 1, 22.50, 25.43, 13.0, 18.00, 4.50, 2.93, 2.00, 1, 9, 3, 1, 1, '2023-05-01', '2024-08-31', 3, NULL, NULL, NULL, NULL),
-- CineMax Combo Familiar (10)
(5, 50.00, GETDATE(), GETDATE(), 15.0, 1, 42.50, 48.03, 13.0, 35.00, 7.50, 5.53, 3.00, 1, 10, 1, 1, 0, '2023-05-01', '2024-08-31', 1, 1, NULL, 4, 180.00),
-- EduOnline Cursos (11)
(6, 40.00, GETDATE(), GETDATE(), 10.0, 1, 36.00, 40.68, 13.0, 30.00, 6.00, 4.68, 2.00, 1, 11, 3, 1, 1, '2023-06-01', '2024-07-31', 3, NULL, NULL, NULL, NULL),
-- EduOnline Certificaciones (12)
(6, 100.00, GETDATE(), GETDATE(), 5.0, 1, 95.00, 107.35, 13.0, 80.00, 15.00, 12.35, 5.00, 1, 12, 1, 1, 0, '2023-06-01', '2024-07-31', 1, 1, NULL, NULL, NULL),
-- FoodExpress Comida Diaria (13)
(7, 15.00, GETDATE(), GETDATE(), 20.0, 1, 12.00, 13.56, 13.0, 9.00, 3.00, 1.56, 1.00, 1, 13, 2, 1, 0, '2023-07-01', '2024-06-30', 1, 5, 20, NULL, NULL),
-- FoodExpress Cena Gourmet (14)
(7, 25.00, GETDATE(), GETDATE(), 10.0, 1, 22.50, 25.43, 13.0, 18.00, 4.50, 2.93, 2.00, 1, 14, 1, 1, 0, '2023-07-01', '2024-06-30', 1, 1, NULL, NULL, NULL);

-- 3.3 Renovaciones de Contratos
INSERT INTO [dbo].[st_contractRenewals] ([renewalDate], [renewalMotive], [contractChanges], [providerContractID])
VALUES 
('2023-06-15', 'Ajuste de precios por inflación', 'Aumento del 5% en precios base', 1),
('2023-07-20', 'Ampliación de cobertura', 'Inclusión de 2 nuevas sucursales', 2),
('2023-08-10', 'Cambio en términos de pago', 'Periodo de pago extendido a 60 días', 3);

SELECT * FROM st_providersContract;
SELECT * FROM st_contractRenewals;
SELECT * FROM st_contractDetails;

-- 4.1 Usuarios (30 usuarios: 25 con suscripción, 5 sin suscripción)
INSERT INTO [dbo].[st_users] ([firstName], [lastName], [password], [enabled], [birthDate], [createdAt])
VALUES 
-- Usuarios con suscripción (25)
('Juan', 'Pérez', 0x7061737331, 1, '1985-05-15', GETDATE()),
('María', 'Gómez', 0x7061737332, 1, '1990-08-22', GETDATE()),
('Carlos', 'Rodríguez', 0x7061737333, 1, '1988-03-10', GETDATE()),
('Ana', 'Martínez', 0x7061737334, 1, '1992-11-05', GETDATE()),
('Luis', 'Hernández', 0x7061737335, 1, '1987-07-30', GETDATE()),
('Laura', 'López', 0x7061737336, 1, '1995-02-18', GETDATE()),
('Pedro', 'García', 0x7061737337, 1, '1983-09-25', GETDATE()),
('Sofía', 'Díaz', 0x7061737338, 1, '1991-04-12', GETDATE()),
('Jorge', 'Morales', 0x7061737339, 1, '1989-12-08', GETDATE()),
('Carmen', 'Rojas', 0x706173733130, 1, '1986-06-20', GETDATE()),
('Ricardo', 'Vargas', 0x706173733131, 1, '1993-01-14', GETDATE()),
('Patricia', 'Fernández', 0x706173733132, 1, '1984-10-09', GETDATE()),
('Fernando', 'Jiménez', 0x706173733133, 1, '1994-07-03', GETDATE()),
('Gabriela', 'Ruiz', 0x706173733134, 1, '1982-12-28', GETDATE()),
('Roberto', 'Mendoza', 0x706173733135, 1, '1990-05-17', GETDATE()),
('Isabel', 'Castro', 0x706173733136, 1, '1987-08-11', GETDATE()),
('Mario', 'Ortiz', 0x706173733137, 1, '1992-03-24', GETDATE()),
('Lucía', 'Navarro', 0x706173733138, 1, '1985-11-19', GETDATE()),
('Diego', 'Romero', 0x706173733139, 1, '1991-09-07', GETDATE()),
('Valeria', 'Torres', 0x706173733230, 1, '1988-04-30', GETDATE()),
('Andrés', 'Silva', 0x706173733231, 1, '1993-02-15', GETDATE()),
('Natalia', 'Guerrero', 0x706173733232, 1, '1986-10-22', GETDATE()),
('José', 'Ríos', 0x706173733233, 1, '1989-07-08', GETDATE()),
('Adriana', 'Méndez', 0x706173733234, 1, '1994-01-25', GETDATE()),
('Raúl', 'Cruz', 0x706173733235, 1, '1983-06-13', GETDATE()),
-- Usuarios sin suscripción (5)
('Elena', 'Flores', 0x706173733236, 1, '1995-08-09', GETDATE()),
('Oscar', 'Soto', 0x706173733237, 1, '1980-12-03', GETDATE()),
('Claudia', 'Chaves', 0x706173733238, 1, '1996-04-17', GETDATE()),
('Alberto', 'Campos', 0x706173733239, 1, '1981-09-21', GETDATE()),
('Diana', 'Vega', 0x706173733330, 1, '1997-11-29', GETDATE());

-- 4.2 Información de Contacto de Usuarios
INSERT INTO [dbo].[st_userContactInfo] ([value], [enabled], [lastUpdated], [contactTypeID], [userId])
VALUES 
-- Usuario 1
('juan.perez@email.com', 1, GETDATE(), 2, 1),
('+506 8888-8888', 1, GETDATE(), 1, 1),
-- Usuario 2
('maria.gomez@email.com', 1, GETDATE(), 2, 2),
('+506 7777-7777', 1, GETDATE(), 1, 2),
-- Usuario 3
('carlos.rodriguez@email.com', 1, GETDATE(), 2, 3),
-- Usuario 4
('ana.martinez@email.com', 1, GETDATE(), 2, 4),
('+506 6666-6666', 1, GETDATE(), 1, 4),
-- Usuario 5
('luis.hernandez@email.com', 1, GETDATE(), 2, 5),
-- Usuario 6
('laura.lopez@email.com', 1, GETDATE(), 2, 6),
('+506 5555-5555', 1, GETDATE(), 1, 6),
-- Usuario 7
('pedro.garcia@email.com', 1, GETDATE(), 2, 7),
-- Usuario 8
('sofia.diaz@email.com', 1, GETDATE(), 2, 8),
('+506 4444-4444', 1, GETDATE(), 1, 8),
-- Usuario 9
('jorge.morales@email.com', 1, GETDATE(), 2, 9),
-- Usuario 10
('carmen.rojas@email.com', 1, GETDATE(), 2, 10),
('+506 3333-3333', 1, GETDATE(), 1, 10),
-- Usuario 11
('ricardo.vargas@email.com', 1, GETDATE(), 2, 11),
-- Usuario 12
('patricia.fernandez@email.com', 1, GETDATE(), 2, 12),
('+506 2222-2222', 1, GETDATE(), 1, 12),
-- Usuario 13
('fernando.jimenez@email.com', 1, GETDATE(), 2, 13),
-- Usuario 14
('gabriela.ruiz@email.com', 1, GETDATE(), 2, 14),
('+506 1111-1111', 1, GETDATE(), 1, 14),
-- Usuario 15
('roberto.mendoza@email.com', 1, GETDATE(), 2, 15),
-- Usuario 16
('isabel.castro@email.com', 1, GETDATE(), 2, 16),
('+506 9999-9999', 1, GETDATE(), 1, 16),
-- Usuario 17
('mario.ortiz@email.com', 1, GETDATE(), 2, 17),
-- Usuario 18
('lucia.navarro@email.com', 1, GETDATE(), 2, 18),
('+506 8888-7777', 1, GETDATE(), 1, 18),
-- Usuario 19
('diego.romero@email.com', 1, GETDATE(), 2, 19),
-- Usuario 20
('valeria.torres@email.com', 1, GETDATE(), 2, 20),
('+506 7777-6666', 1, GETDATE(), 1, 20),
-- Usuario 21
('andres.silva@email.com', 1, GETDATE(), 2, 21),
-- Usuario 22
('natalia.guerrero@email.com', 1, GETDATE(), 2, 22),
('+506 6666-5555', 1, GETDATE(), 1, 22),
-- Usuario 23
('jose.rios@email.com', 1, GETDATE(), 2, 23),
-- Usuario 24
('adriana.mendez@email.com', 1, GETDATE(), 2, 24),
('+506 5555-4444', 1, GETDATE(), 1, 24),
-- Usuario 25
('raul.cruz@email.com', 1, GETDATE(), 2, 25),
-- Usuario 26 (sin suscripción)
('elena.flores@email.com', 1, GETDATE(), 2, 26),
('+506 4444-3333', 1, GETDATE(), 1, 26),
-- Usuario 27 (sin suscripción)
('oscar.soto@email.com', 1, GETDATE(), 2, 27),
-- Usuario 28 (sin suscripción)
('claudia.chaves@email.com', 1, GETDATE(), 2, 28),
('+506 3333-2222', 1, GETDATE(), 1, 28),
-- Usuario 29 (sin suscripción)
('alberto.campos@email.com', 1, GETDATE(), 2, 29),
-- Usuario 30 (sin suscripción)
('diana.vega@email.com', 1, GETDATE(), 2, 30),
('+506 2222-1111', 1, GETDATE(), 1, 30);



INSERT INTO [dbo].[st_plans] (
    [planPrice], [postTime], [planName], [planTypeID], [currencyID], 
    [description], [imageURL], [lastUpdated], [solturaPrice]
)
VALUES 
-- Plan 1: Joven Deportista
(79.99, GETDATE(), 'Joven Deportista', 1, 1, 
 'Plan ideal para jóvenes que buscan mantenerse activos con acceso a gimnasio y transporte', 
 'https://images.com/joven-deportista.jpg', GETDATE(), 69.99),

-- Plan 2: Familia de Verano
(149.99, GETDATE(), 'Familia de Verano', 2, 1, 
 'Plan familiar con beneficios en entretenimiento y alimentación para disfrutar el verano', 
 'https://images.com/familia-verano.jpg', GETDATE(), 129.99),

-- Plan 3: Viajero Frecuente
(199.99, GETDATE(), 'Viajero Frecuente', 1, 2, 
 'Plan para viajeros con beneficios en transporte y parqueos en zonas estratégicas', 
 'https://images.com/viajero-frecuente.jpg', GETDATE(), 179.99),

-- Plan 4: Nómada Digital
(129.99, GETDATE(), 'Nómada Digital', 1, 2, 
 'Plan perfecto para nómadas digitales con espacios de trabajo y membresías educativas', 
 'https://images.com/nomada-digital.jpg', GETDATE(), 109.99),

-- Plan 5: Salud Integral
(179.99, GETDATE(), 'Salud Integral', 1, 1, 
 'Plan enfocado en salud con acceso a servicios médicos y alimentación saludable', 
 'https://images.com/salud-integral.jpg', GETDATE(), 159.99),

-- Plan 6: Ejecutivo Premium
(249.99, GETDATE(), 'Ejecutivo Premium', 5, 2, 
 'Plan premium con beneficios exclusivos para ejecutivos exigentes', 
 'https://images.com/ejecutivo-premium.jpg', GETDATE(), 219.99),

-- Plan 7: Estudiante Activo
(59.99, GETDATE(), 'Estudiante Activo', 4, 1, 
 'Plan económico para estudiantes con beneficios en educación y transporte', 
 'https://images.com/estudiante-activo.jpg', GETDATE(), 49.99),

-- Plan 8: Pareja Dinámica
(119.99, GETDATE(), 'Pareja Dinámica', 2, 1, 
 'Plan para parejas con beneficios en entretenimiento y alimentación', 
 'https://images.com/pareja-dinamica.jpg', GETDATE(), 99.99),

-- Plan 9: Senior Gold
(89.99, GETDATE(), 'Senior Gold', 1, 1, 
 'Plan para adultos mayores con enfoque en salud y bienestar', 
 'https://images.com/senior-gold.jpg', GETDATE(), 79.99);

-- 5.2 Servicios por Plan
INSERT INTO [dbo].[st_planServices] (
    [serviceID], [planID], [discountTypeID], [bundleQuantity], [bundlePrice], 
    [originalPrice], [solturaPrice], [usageValue], [maxUses], [isMembership], 
    [serviceAvailabilityTypeID], [validFrom], [validTo], [usageUnitTypeID]
)
VALUES 
-- Plan 1: Joven Deportista (Gimnasio + Transporte)
(1, 1, 1, NULL, NULL, 50.00, 45.00, NULL, NULL, 1, 3, '2023-01-01', '2024-12-31', 3),
(8, 1, 1, NULL, NULL, 10.00, 9.00, 10, NULL, 0, 2, '2023-01-01', '2024-12-31', 1),

-- Plan 2: Familia de Verano (Cine + Comida)
(10, 2, 1, 4, 180.00, 50.00, 45.00, NULL, NULL, 0, 1, '2023-01-01', '2024-12-31', 1),
(13, 2, 1, NULL, NULL, 15.00, 13.50, 5, 20, 0, 2, '2023-01-01', '2024-12-31', 1),

-- Plan 3: Viajero Frecuente (Transporte + Parqueo)
(7, 3, 1, NULL, NULL, 20.00, 18.00, 15, NULL, 0, 2, '2023-01-01', '2024-12-31', 1),
(6, 3, 1, NULL, NULL, 100.00, 90.00, NULL, NULL, 1, 3, '2023-01-01', '2024-12-31', 3),

-- Plan 4: Nómada Digital (Educación + Parqueo)
(11, 4, 1, NULL, NULL, 40.00, 36.00, NULL, NULL, 1, 3, '2023-01-01', '2024-12-31', 3),
(5, 4, 1, NULL, NULL, 5.00, 4.50, 10, NULL, 0, 2, '2023-01-01', '2024-12-31', 1),

-- Plan 5: Salud Integral (Salud + Comida)
(3, 5, 1, NULL, NULL, 80.00, 72.00, 2, NULL, 0, 1, '2023-01-01', '2024-12-31', 1),
(13, 5, 1, NULL, NULL, 15.00, 13.50, 10, 30, 0, 2, '2023-01-01', '2024-12-31', 1),

-- Plan 6: Ejecutivo Premium (Transporte + Salud + Gimnasio)
(7, 6, 1, NULL, NULL, 20.00, 18.00, 20, NULL, 0, 2, '2023-01-01', '2024-12-31', 1),
(3, 6, 1, NULL, NULL, 80.00, 72.00, 4, NULL, 0, 1, '2023-01-01', '2024-12-31', 1),
(1, 6, 1, NULL, NULL, 50.00, 45.00, NULL, NULL, 1, 3, '2023-01-01', '2024-12-31', 3),

-- Plan 7: Estudiante Activo (Educación + Transporte)
(11, 7, 1, NULL, NULL, 40.00, 36.00, NULL, NULL, 1, 3, '2023-01-01', '2024-12-31', 3),
(8, 7, 1, NULL, NULL, 10.00, 9.00, 15, NULL, 0, 2, '2023-01-01', '2024-12-31', 1),

-- Plan 8: Pareja Dinámica (Cine + Comida)
(9, 8, 1, NULL, NULL, 30.00, 27.00, NULL, NULL, 1, 3, '2023-01-01', '2024-12-31', 3),
(14, 8, 1, NULL, NULL, 25.00, 22.50, 2, 8, 0, 1, '2023-01-01', '2024-12-31', 1),

-- Plan 9: Senior Gold (Salud + Gimnasio)
(4, 9, 1, NULL, NULL, 60.00, 54.00, 2, NULL, 0, 1, '2023-01-01', '2024-12-31', 1),
(1, 9, 1, NULL, NULL, 50.00, 45.00, NULL, NULL, 1, 3, '2023-01-01', '2024-12-31', 3);

-- 6. Suscripciones de Usuarios

-- 6.1 Suscripciones
INSERT INTO [dbo].[st_subcriptions] ([description], [logoURL], [enabled], [planTypeID], [userID])
VALUES 
-- Plan 1: Joven Deportista (3 suscripciones)
('Suscripción Joven Deportista Juan Pérez', 'https://logo.com/joven-deportista.jpg', 1, 1, 1),
('Suscripción Joven Deportista Carlos Rodríguez', 'https://logo.com/joven-deportista.jpg', 1, 1, 3),
('Suscripción Joven Deportista Laura López', 'https://logo.com/joven-deportista.jpg', 1, 1, 6),

-- Plan 2: Familia de Verano (4 suscripciones)
('Suscripción Familia de Verano María Gómez', 'https://logo.com/familia-verano.jpg', 1, 2, 2),
('Suscripción Familia de Verano Ana Martínez', 'https://logo.com/familia-verano.jpg', 1, 2, 4),
('Suscripción Familia de Verano Sofía Díaz', 'https://logo.com/familia-verano.jpg', 1, 2, 8),
('Suscripción Familia de Verano Valeria Torres', 'https://logo.com/familia-verano.jpg', 1, 2, 20),

-- Plan 3: Viajero Frecuente (3 suscripciones)
('Suscripción Viajero Frecuente Luis Hernández', 'https://logo.com/viajero-frecuente.jpg', 1, 1, 5),
('Suscripción Viajero Frecuente Pedro García', 'https://logo.com/viajero-frecuente.jpg', 1, 1, 7),
('Suscripción Viajero Frecuente Andrés Silva', 'https://logo.com/viajero-frecuente.jpg', 1, 1, 21),

-- Plan 4: Nómada Digital (4 suscripciones)
('Suscripción Nómada Digital Jorge Morales', 'https://logo.com/nomada-digital.jpg', 1, 1, 9),
('Suscripción Nómada Digital Ricardo Vargas', 'https://logo.com/nomada-digital.jpg', 1, 1, 11),
('Suscripción Nómada Digital Fernando Jiménez', 'https://logo.com/nomada-digital.jpg', 1, 1, 13),
('Suscripción Nómada Digital José Ríos', 'https://logo.com/nomada-digital.jpg', 1, 1, 23),

-- Plan 5: Salud Integral (3 suscripciones)
('Suscripción Salud Integral Carmen Rojas', 'https://logo.com/salud-integral.jpg', 1, 1, 10),
('Suscripción Salud Integral Patricia Fernández', 'https://logo.com/salud-integral.jpg', 1, 1, 12),
('Suscripción Salud Integral Roberto Mendoza', 'https://logo.com/salud-integral.jpg', 1, 1, 15),

-- Plan 6: Ejecutivo Premium (3 suscripciones)
('Suscripción Ejecutivo Premium Gabriela Ruiz', 'https://logo.com/ejecutivo-premium.jpg', 1, 5, 14),
('Suscripción Ejecutivo Premium Mario Ortiz', 'https://logo.com/ejecutivo-premium.jpg', 1, 5, 17),
('Suscripción Ejecutivo Premium Raúl Cruz', 'https://logo.com/ejecutivo-premium.jpg', 1, 5, 25),

-- Plan 7: Estudiante Activo (3 suscripciones)
('Suscripción Estudiante Activo Isabel Castro', 'https://logo.com/estudiante-activo.jpg', 1, 4, 16),
('Suscripción Estudiante Activo Lucía Navarro', 'https://logo.com/estudiante-activo.jpg', 1, 4, 18),
('Suscripción Estudiante Activo Adriana Méndez', 'https://logo.com/estudiante-activo.jpg', 1, 4, 24),

-- Plan 8: Pareja Dinámica (3 suscripciones)
('Suscripción Pareja Dinámica Diego Romero', 'https://logo.com/pareja-dinamica.jpg', 1, 2, 19),
('Suscripción Pareja Dinámica Natalia Guerrero', 'https://logo.com/pareja-dinamica.jpg', 1, 2, 22),
('Suscripción Pareja Dinámica Claudia Chaves', 'https://logo.com/pareja-dinamica.jpg', 1, 2, 28),

-- Plan 9: Senior Gold (3 suscripciones)
('Suscripción Senior Gold Elena Flores', 'https://logo.com/senior-gold.jpg', 1, 1, 26),
('Suscripción Senior Gold Oscar Soto', 'https://logo.com/senior-gold.jpg', 1, 1, 27),
('Suscripción Senior Gold Alberto Campos', 'https://logo.com/senior-gold.jpg', 1, 1, 29);

-- 6.2 Beneficiarios por Plan
INSERT INTO [dbo].[st_beneficiariesPerPlan] ([startDate], [endDate], [subscriptionID], [userID], [enabled])
VALUES 
-- Beneficiarios para Plan Familiar (Familia de Verano)
('2023-06-01', NULL, 4, 2, 1),  -- María Gómez es el titular
('2023-06-01', NULL, 4, 1, 1),   -- Juan Pérez es beneficiario
('2023-06-01', NULL, 4, 3, 1),   -- Carlos Rodríguez es beneficiario

('2023-07-01', NULL, 5, 4, 1),   -- Ana Martínez es el titular
('2023-07-01', NULL, 5, 5, 1),    -- Luis Hernández es beneficiario

('2023-08-01', NULL, 6, 8, 1),    -- Sofía Díaz es el titular
('2023-08-01', NULL, 6, 9, 1),    -- Jorge Morales es beneficiario

('2023-09-01', NULL, 7, 20, 1),   -- Valeria Torres es el titular
('2023-09-01', NULL, 7, 21, 1),   -- Andrés Silva es beneficiario

-- Beneficiarios para Pareja Dinámica
('2023-10-01', NULL, 24, 19, 1),  -- Diego Romero es el titular
('2023-10-01', NULL, 24, 20, 1),   -- Valeria Torres es beneficiario

('2023-11-01', NULL, 25, 22, 1),   -- Natalia Guerrero es el titular
('2023-11-01', NULL, 25, 23, 1),   -- José Ríos es beneficiario

('2023-12-01', NULL, 26, 28, 1),   -- Claudia Chaves es el titular
('2023-12-01', NULL, 26, 29, 1);   -- Alberto Campos es beneficiario

-- 7. Programación de Pagos

-- 7.1 Programación de Pagos
INSERT INTO [dbo].[st_schedules] ([name], [recurrencyType], [repeat], [endDate], [subcriptionID])
VALUES 
('Pago Mensual Juan Pérez', 3, '1', '2024-12-31', 1),
('Pago Mensual Carlos Rodríguez', 3, '1', '2024-12-31', 2),
('Pago Mensual Laura López', 3, '1', '2024-12-31', 3),
('Pago Mensual María Gómez', 3, '1', '2024-12-31', 4),
('Pago Mensual Ana Martínez', 3, '1', '2024-12-31', 5),
('Pago Mensual Sofía Díaz', 3, '1', '2024-12-31', 6),
('Pago Mensual Valeria Torres', 3, '1', '2024-12-31', 7),
('Pago Mensual Luis Hernández', 3, '1', '2024-12-31', 8),
('Pago Mensual Pedro García', 3, '1', '2024-12-31', 9),
('Pago Mensual Andrés Silva', 3, '1', '2024-12-31', 10),
('Pago Mensual Jorge Morales', 3, '1', '2024-12-31', 11),
('Pago Mensual Ricardo Vargas', 3, '1', '2024-12-31', 12),
('Pago Mensual Fernando Jiménez', 3, '1', '2024-12-31', 13),
('Pago Mensual José Ríos', 3, '1', '2024-12-31', 14),
('Pago Mensual Carmen Rojas', 3, '1', '2024-12-31', 15),
('Pago Mensual Patricia Fernández', 3, '1', '2024-12-31', 16),
('Pago Mensual Roberto Mendoza', 3, '1', '2024-12-31', 17),
('Pago Mensual Gabriela Ruiz', 3, '1', '2024-12-31', 18),
('Pago Mensual Mario Ortiz', 3, '1', '2024-12-31', 19),
('Pago Mensual Raúl Cruz', 3, '1', '2024-12-31', 20),
('Pago Mensual Isabel Castro', 3, '1', '2024-12-31', 21),
('Pago Mensual Lucía Navarro', 3, '1', '2024-12-31', 22),
('Pago Mensual Adriana Méndez', 3, '1', '2024-12-31', 23),
('Pago Mensual Diego Romero', 3, '1', '2024-12-31', 24),
('Pago Mensual Natalia Guerrero', 3, '1', '2024-12-31', 25),
('Pago Mensual Claudia Chaves', 3, '1', '2024-12-31', 26),
('Pago Mensual Elena Flores', 3, '1', '2024-12-31', 27),
('Pago Mensual Oscar Soto', 3, '1', '2024-12-31', 28),
('Pago Mensual Alberto Campos', 3, '1', '2024-12-31', 29);

-- 7.2 Detalles de Programación
INSERT INTO [dbo].[st_scheduleDetails] ([deleted], [baseDate], [datePart], [lastExecution], [nextExecution], [scheduleID])
VALUES 
(0, '2023-06-01', 'day', NULL, '2023-06-01', 1),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 2),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 3),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 4),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 5),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 6),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 7),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 8),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 9),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 10),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 11),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 12),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 13),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 14),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 15),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 16),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 17),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 18),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 19),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 20),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 21),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 22),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 23),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 24),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 25),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 26),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 27),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 28),
(0, '2023-06-01', 'day', NULL, '2023-06-01', 29);



INSERT INTO [dbo].[st_payments] (
    [paymentMethodID], [amount], [actualAmount], [result], [authentication], 
    [reference], [chargedToken], [description], [error], [paymentDate], 
    [checksum], [currencyID]
)
VALUES 
-- Pagos para suscripciones en CRC (25 pagos)
(3, 79990, 79990, 'Aprobado', 'AUTH123', 'REF001', 0x746F6B656E31, 'Pago suscripción Joven Deportista', NULL, '2023-06-01', 0x636865636B73756D31, 1),
(3, 79990, 79990, 'Aprobado', 'AUTH124', 'REF002', 0x746F6B656E32, 'Pago suscripción Joven Deportista', NULL, '2023-06-01', 0x636865636B73756D32, 1),
(3, 79990, 79990, 'Aprobado', 'AUTH125', 'REF003', 0x746F6B656E33, 'Pago suscripción Joven Deportista', NULL, '2023-06-01', 0x636865636B73756D33, 1),
(1, 149990, 149990, 'Aprobado', 'AUTH126', 'REF004', 0x746F6B656E34, 'Pago suscripción Familia de Verano', NULL, '2023-06-01', 0x636865636B73756D34, 1),
(1, 149990, 149990, 'Aprobado', 'AUTH127', 'REF005', 0x746F6B656E35, 'Pago suscripción Familia de Verano', NULL, '2023-07-01', 0x636865636B73756D35, 1),
(1, 149990, 149990, 'Aprobado', 'AUTH128', 'REF006', 0x746F6B656E36, 'Pago suscripción Familia de Verano', NULL, '2023-08-01', 0x636865636B73756D36, 1),
(1, 149990, 149990, 'Aprobado', 'AUTH129', 'REF007', 0x746F6B656E37, 'Pago suscripción Familia de Verano', NULL, '2023-09-01', 0x636865636B73756D37, 1),
(2, 19999, 19999, 'Aprobado', 'AUTH130', 'REF008', 0x746F6B656E38, 'Pago suscripción Viajero Frecuente', NULL, '2023-06-01', 0x636865636B73756D38, 2),
(2, 19999, 19999, 'Aprobado', 'AUTH131', 'REF009', 0x746F6B656E39, 'Pago suscripción Viajero Frecuente', NULL, '2023-06-01', 0x636865636B73756D39, 2),
(2, 19999, 19999, 'Aprobado', 'AUTH132', 'REF010', 0x746F6B656E3130, 'Pago suscripción Viajero Frecuente', NULL, '2023-06-01', 0x636865636B73756D3130, 2),
(3, 129990, 129990, 'Aprobado', 'AUTH133', 'REF011', 0x746F6B656E3131, 'Pago suscripción Nómada Digital', NULL, '2023-06-01', 0x636865636B73756D3131, 2),
(3, 129990, 129990, 'Aprobado', 'AUTH134', 'REF012', 0x746F6B656E3132, 'Pago suscripción Nómada Digital', NULL, '2023-06-01', 0x636865636B73756D3132, 2),
(3, 129990, 129990, 'Aprobado', 'AUTH135', 'REF013', 0x746F6B656E3133, 'Pago suscripción Nómada Digital', NULL, '2023-06-01', 0x636865636B73756D3133, 2),
(3, 129990, 129990, 'Aprobado', 'AUTH136', 'REF014', 0x746F6B656E3134, 'Pago suscripción Nómada Digital', NULL, '2023-06-01', 0x636865636B73756D3134, 2),
(1, 179990, 179990, 'Aprobado', 'AUTH137', 'REF015', 0x746F6B656E3135, 'Pago suscripción Salud Integral', NULL, '2023-06-01', 0x636865636B73756D3135, 1),
(1, 179990, 179990, 'Aprobado', 'AUTH138', 'REF016', 0x746F6B656E3136, 'Pago suscripción Salud Integral', NULL, '2023-06-01', 0x636865636B73756D3136, 1),
(1, 179990, 179990, 'Aprobado', 'AUTH139', 'REF017', 0x746F6B656E3137, 'Pago suscripción Salud Integral', NULL, '2023-06-01', 0x636865636B73756D3137, 1),
(2, 24999, 24999, 'Aprobado', 'AUTH140', 'REF018', 0x746F6B656E3138, 'Pago suscripción Ejecutivo Premium', NULL, '2023-06-01', 0x636865636B73756D3138, 2),
(2, 24999, 24999, 'Aprobado', 'AUTH141', 'REF019', 0x746F6B656E3139, 'Pago suscripción Ejecutivo Premium', NULL, '2023-06-01', 0x636865636B73756D3139, 2),
(2, 24999, 24999, 'Aprobado', 'AUTH142', 'REF020', 0x746F6B656E3230, 'Pago suscripción Ejecutivo Premium', NULL, '2023-06-01', 0x636865636B73756D3230, 2),
(3, 59990, 59990, 'Aprobado', 'AUTH143', 'REF021', 0x746F6B656E3231, 'Pago suscripción Estudiante Activo', NULL, '2023-06-01', 0x636865636B73756D3231, 1),
(3, 59990, 59990, 'Aprobado', 'AUTH144', 'REF022', 0x746F6B656E3232, 'Pago suscripción Estudiante Activo', NULL, '2023-06-01', 0x636865636B73756D3232, 1),
(3, 59990, 59990, 'Aprobado', 'AUTH145', 'REF023', 0x746F6B656E3233, 'Pago suscripción Estudiante Activo', NULL, '2023-06-01', 0x636865636B73756D3233, 1),
(1, 119990, 119990, 'Aprobado', 'AUTH146', 'REF024', 0x746F6B656E3234, 'Pago suscripción Pareja Dinámica', NULL, '2023-10-01', 0x636865636B73756D3234, 1),
(1, 119990, 119990, 'Aprobado', 'AUTH147', 'REF025', 0x746F6B656E3235, 'Pago suscripción Pareja Dinámica', NULL, '2023-11-01', 0x636865636B73756D3235, 1),
(1, 119990, 119990, 'Aprobado', 'AUTH148', 'REF026', 0x746F6B656E3236, 'Pago suscripción Pareja Dinámica', NULL, '2023-12-01', 0x636865636B73756D3236, 1),
(3, 89990, 89990, 'Aprobado', 'AUTH149', 'REF027', 0x746F6B656E3237, 'Pago suscripción Senior Gold', NULL, '2023-06-01', 0x636865636B73756D3237, 1),
(3, 89990, 89990, 'Aprobado', 'AUTH150', 'REF028', 0x746F6B656E3238, 'Pago suscripción Senior Gold', NULL, '2023-06-01', 0x636865636B73756D3238, 1),
(3, 89990, 89990, 'Aprobado', 'AUTH151', 'REF029', 0x746F6B656E3239, 'Pago suscripción Senior Gold', NULL, '2023-06-01', 0x636865636B73756D3239, 1);

-- 8.2 Tasas de Cambio
INSERT INTO [dbo].[st_exchangeRate] (
    [currecyIdSource], [currencyIdDestiny], [startDate], [endDate], 
    [exhangeRate], [currentExchangeRate], [currencyID]
)
VALUES 
(1, 2, '2023-01-01', '2023-12-31', 0.0019, 1, 1),
(2, 1, '2023-01-01', '2023-12-31', 535.50, 1, 2);

-- 8.3 Transacciones
INSERT INTO [dbo].[st_transactions] (
    [transactionAmount], [description], [transactionDate], [postTime], 
    [referenceNumber], [convertedAmount], [checksum], [currencyID], 
    [exchangeRateId], [paymentId], [userID], [transactionTypeID], [transactionSubTypeID]
)
VALUES 
-- Transacciones para suscripciones (25 transacciones)
(79990, 'Suscripción Joven Deportista', '2023-06-01', GETDATE(), 'TRANS001', 79990, 0x636865636B3131, 1, 1, 1, 1, 1, 1),
(79990, 'Suscripción Joven Deportista', '2023-06-01', GETDATE(), 'TRANS002', 79990, 0x636865636B3132, 1, 1, 2, 3, 1, 1),
(79990, 'Suscripción Joven Deportista', '2023-06-01', GETDATE(), 'TRANS003', 79990, 0x636865636B3133, 1, 1, 3, 6, 1, 1),
(149990, 'Suscripción Familia de Verano', '2023-06-01', GETDATE(), 'TRANS004', 149990, 0x636865636B3134, 1, 1, 4, 2, 1, 1),
(149990, 'Suscripción Familia de Verano', '2023-07-01', GETDATE(), 'TRANS005', 149990, 0x636865636B3135, 1, 1, 5, 4, 1, 1),
(149990, 'Suscripción Familia de Verano', '2023-08-01', GETDATE(), 'TRANS006', 149990, 0x636865636B3136, 1, 1, 6, 8, 1, 1),
(149990, 'Suscripción Familia de Verano', '2023-09-01', GETDATE(), 'TRANS007', 149990, 0x636865636B3137, 1, 1, 7, 20, 1, 1),
(199.99, 'Suscripción Viajero Frecuente', '2023-06-01', GETDATE(), 'TRANS008', 107000, 0x636865636B3138, 2, 2, 8, 5, 1, 1),
(199.99, 'Suscripción Viajero Frecuente', '2023-06-01', GETDATE(), 'TRANS009', 107000, 0x636865636B3139, 2, 2, 9, 7, 1, 1),
(199.99, 'Suscripción Viajero Frecuente', '2023-06-01', GETDATE(), 'TRANS010', 107000, 0x636865636B3230, 2, 2, 10, 21, 1, 1),
(129.99, 'Suscripción Nómada Digital', '2023-06-01', GETDATE(), 'TRANS011', 69600, 0x636865636B3231, 2, 2, 11, 9, 1, 1),
(129.99, 'Suscripción Nómada Digital', '2023-06-01', GETDATE(), 'TRANS012', 69600, 0x636865636B3232, 2, 2, 12, 11, 1, 1),
(129.99, 'Suscripción Nómada Digital', '2023-06-01', GETDATE(), 'TRANS013', 69600, 0x636865636B3233, 2, 2, 13, 13, 1, 1),
(129.99, 'Suscripción Nómada Digital', '2023-06-01', GETDATE(), 'TRANS014', 69600, 0x636865636B3234, 2, 2, 14, 23, 1, 1),
(179990, 'Suscripción Salud Integral', '2023-06-01', GETDATE(), 'TRANS015', 179990, 0x636865636B3235, 1, 1, 15, 10, 1, 1),
(179990, 'Suscripción Salud Integral', '2023-06-01', GETDATE(), 'TRANS016', 179990, 0x636865636B3236, 1, 1, 16, 12, 1, 1),
(179990, 'Suscripción Salud Integral', '2023-06-01', GETDATE(), 'TRANS017', 179990, 0x636865636B3237, 1, 1, 17, 15, 1, 1),
(249.99, 'Suscripción Ejecutivo Premium', '2023-06-01', GETDATE(), 'TRANS018', 133800, 0x636865636B3238, 2, 2, 18, 14, 1, 1),
(249.99, 'Suscripción Ejecutivo Premium', '2023-06-01', GETDATE(), 'TRANS019', 133800, 0x636865636B3239, 2, 2, 19, 17, 1, 1),
(249.99, 'Suscripción Ejecutivo Premium', '2023-06-01', GETDATE(), 'TRANS020', 133800, 0x636865636B3330, 2, 2, 20, 25, 1, 1),
(59990, 'Suscripción Estudiante Activo', '2023-06-01', GETDATE(), 'TRANS021', 59990, 0x636865636B3331, 1, 1, 21, 16, 1, 1),
(59990, 'Suscripción Estudiante Activo', '2023-06-01', GETDATE(), 'TRANS022', 59990, 0x636865636B3332, 1, 1, 22, 18, 1, 1),
(59990, 'Suscripción Estudiante Activo', '2023-06-01', GETDATE(), 'TRANS023', 59990, 0x636865636B3333, 1, 1, 23, 24, 1, 1),
(119990, 'Suscripción Pareja Dinámica', '2023-10-01', GETDATE(), 'TRANS024', 119990, 0x636865636B3334, 1, 1, 24, 19, 1, 1),
(119990, 'Suscripción Pareja Dinámica', '2023-11-01', GETDATE(), 'TRANS025', 119990, 0x636865636B3335, 1, 1, 25, 22, 1, 1),
(119990, 'Suscripción Pareja Dinámica', '2023-12-01', GETDATE(), 'TRANS026', 119990, 0x636865636B3336, 1, 1, 26, 28, 1, 1),
(89990, 'Suscripción Senior Gold', '2023-06-01', GETDATE(), 'TRANS027', 89990, 0x636865636B3337, 1, 1, 27, 26, 1, 1),
(89990, 'Suscripción Senior Gold', '2023-06-01', GETDATE(), 'TRANS028', 89990, 0x636865636B3338, 1, 1, 28, 27, 1, 1),
(89990, 'Suscripción Senior Gold', '2023-06-01', GETDATE(), 'TRANS029', 89990, 0x636865636B3339, 1, 1, 29, 29, 1, 1);


-- 9.1 Tokens de Uso (actualizado con tipos específicos)
INSERT INTO [dbo].[st_usageTokens] (
    [userID], [tokenType], [tokenCode], [createdAt], [expirationDate], 
    [status], [failedAttempts], [contractDetailsID], [maxUses]
)
VALUES 
-- Tokens QR para membresías de gimnasio (3 usuarios)
(1, 'QR', 0x746F6B656E31323334, '2023-06-01', '2023-07-01', 'active', 0, 1, NULL),
(3, 'QR', 0x746F6B656E32333435, '2023-06-01', '2023-07-01', 'active', 0, 1, NULL),
(6, 'QR', 0x746F6B656E33343536, '2023-06-01', '2023-07-01', 'active', 0, 1, NULL),

-- Tokens NFC para transporte compartido (3 usuarios)
(1, 'NFC', 0x746F6B656E34353637, '2023-06-01', '2023-07-01', 'active', 0, 8, 10),
(3, 'NFC', 0x746F6B656E35363738, '2023-06-01', '2023-07-01', 'active', 0, 8, 10),
(6, 'NFC', 0x746F6B656E36373839, '2023-06-01', '2023-07-01', 'active', 0, 8, 10),

-- Tokens QR para cine ilimitado (4 usuarios)
(2, 'QR', 0x746F6B656E37383930, '2023-06-01', '2023-07-01', 'active', 0, 9, NULL),
(4, 'QR', 0x746F6B656E38393031, '2023-07-01', '2023-08-01', 'active', 0, 9, NULL),
(8, 'QR', 0x746F6B656E39303132, '2023-08-01', '2023-09-01', 'active', 0, 9, NULL),
(20, 'QR', 0x746F6B656E30313233, '2023-09-01', '2023-10-01', 'active', 0, 9, NULL),

-- Tokens cupón para comida diaria (3 usuarios)
(10, 'cupon', 0x746F6B656E31323335, '2023-06-01', '2023-07-01', 'active', 0, 13, 20),
(12, 'cupon', 0x746F6B656E32333436, '2023-06-01', '2023-07-01', 'active', 0, 13, 20),
(15, 'cupon', 0x746F6B656E33343537, '2023-06-01', '2023-07-01', 'active', 0, 13, 20),

-- Tokens QR para educación en línea (3 usuarios)
(16, 'QR', 0x746F6B656E34353638, '2023-06-01', '2023-07-01', 'active', 0, 11, NULL),
(18, 'QR', 0x746F6B656E35363739, '2023-06-01', '2023-07-01', 'active', 0, 11, NULL),
(24, 'QR', 0x746F6B656E36373830, '2023-06-01', '2023-07-01', 'active', 0, 11, NULL),

-- Token NFC adicional para transporte ejecutivo
(14, 'NFC', 0x746F6B656E37383931, '2023-06-01', '2023-07-01', 'active', 0, 7, 20),

-- Token cupón para cena gourmet
(19, 'cupon', 0x746F6B656E38393032, '2023-06-01', '2023-07-01', 'active', 0, 14, 2);

INSERT INTO [dbo].[st_usageTransactions] (
    [usageTokenID], [transactionDate], [usageNotes], [transactionType]
)
VALUES 
-- Usos de gimnasio
(1, '2023-06-05', 'Acceso a gimnasio central', 'access'),
(1, '2023-06-12', 'Acceso a gimnasio central', 'access'),
(1, '2023-06-19', 'Acceso a gimnasio central', 'access'),
(2, '2023-06-07', 'Acceso a gimnasio norte', 'access'),
(2, '2023-06-14', 'Acceso a gimnasio norte', 'access'),
(3, '2023-06-10', 'Acceso a gimnasio sur', 'access'),

-- Usos de transporte
(4, '2023-06-02', 'Viaje a trabajo', 'service'),
(4, '2023-06-09', 'Viaje a centro comercial', 'service'),
(5, '2023-06-05', 'Viaje a aeropuerto', 'service'),
(6, '2023-06-08', 'Viaje a universidad', 'service'),

-- Usos de cine
(7, '2023-06-03', 'Película: Avengers', 'access'),
(7, '2023-06-10', 'Película: Jurassic Park', 'access'),
(8, '2023-07-05', 'Película: Fast X', 'access'),
(9, '2023-08-12', 'Película: Barbie', 'access'),

-- Usos de comida
(10, '2023-06-01', 'Entrega comida saludable', 'delivery'),
(10, '2023-06-02', 'Entrega comida saludable', 'delivery'),
(11, '2023-06-03', 'Entrega comida saludable', 'delivery'),
(12, '2023-06-04', 'Entrega comida saludable', 'delivery'),

-- Usos de educación
(13, '2023-06-15', 'Acceso a curso de programación', 'access'),
(13, '2023-06-20', 'Acceso a curso de marketing', 'access'),
(14, '2023-06-18', 'Acceso a curso de diseño', 'access'),
(15, '2023-06-22', 'Acceso a curso de negocios', 'access');


SELECT * FROM st_usageTokens;
SELECT * FROM st_usageTransactions;


-- 10.1 Permisos
INSERT INTO [dbo].[st_Permissions] (
    [description], [accessLevel], [createdAt], [lastUpdated], [enabled]
)
VALUES 
('Administrar usuarios', 3, GETDATE(), GETDATE(), 1),
('Administrar proveedores', 3, GETDATE(), GETDATE(), 1),
('Administrar planes', 3, GETDATE(), GETDATE(), 1),
('Ver reportes', 2, GETDATE(), GETDATE(), 1),
('Realizar pagos', 1, GETDATE(), GETDATE(), 1),
('Gestionar suscripciones', 2, GETDATE(), GETDATE(), 1),
('Configurar sistema', 3, GETDATE(), GETDATE(), 1),
('Ver dashboard', 1, GETDATE(), GETDATE(), 1);

-- 10.2 Roles
INSERT INTO [dbo].[st_Roles] (
    [roleName], [description], [createdAt], [lastUpdated], [enabled]
)
VALUES 
('Admin', 'Administrador del sistema con todos los permisos', GETDATE(), GETDATE(), 1),
('Manager', 'Gerente con permisos de gestión', GETDATE(), GETDATE(), 1),
('User', 'Usuario estándar con permisos básicos', GETDATE(), GETDATE(), 1),
('Provider', 'Rol para proveedores con acceso limitado', GETDATE(), GETDATE(), 1);

-- 10.3 Relación Roles-Permisos
INSERT INTO [dbo].[st_roles_has_st_permissions] ([rolesID], [permissionID])
VALUES 
-- Admin tiene todos los permisos
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8),
-- Manager tiene permisos de gestión
(2, 2), (2, 3), (2, 4), (2, 6), (2, 8),
-- User tiene permisos básicos
(3, 5), (3, 8),
-- Provider tiene permisos limitados
(4, 2), (4, 8);


-- 10.4 Relación Usuarios-Roles
INSERT INTO [dbo].[st_roles_has_st_users] ([roleID], [userID])
VALUES 
-- Asignar admin a usuario 1
(1, 1),
-- Asignar manager a usuarios 2 y 3
(2, 2), (2, 3),
-- Asignar user a los demás usuarios con suscripción (4-25)
(3, 4), (3, 5), (3, 6), (3, 7), (3, 8), (3, 9), (3, 10),
(3, 11), (3, 12), (3, 13), (3, 14), (3, 15), (3, 16), (3, 17),
(3, 18), (3, 19), (3, 20), (3, 21), (3, 22), (3, 23), (3, 24), (3, 25),
-- Asignar provider a usuarios 26-30 (sin suscripción)
(4, 26), (4, 27), (4, 28), (4, 29), (4, 30);

-- 10.5 Relación Usuarios-Permisos directos (para casos especiales)
INSERT INTO [dbo].[st_permissions_has_st_users] ([permissionID], [userID])
VALUES 
-- Usuario 2 tiene permiso adicional de configurar sistema
(7, 2),
-- Usuario 4 tiene permiso adicional de ver reportes
(4, 4);

-- 11.1 Tipos de Medios
INSERT INTO [dbo].[st_mediaTypes] ([name], [mediaExtension])
VALUES 
('Imagen', 'jpg'),
('Documento', 'pdf'),
('Video', 'mp4'),
('Logo', 'png');

-- 11.2 Archivos Multimedia
INSERT INTO [dbo].[st_MediaFiles] (
    [deleted], [mediaTypeID], [fileURL], [fileName], 
    [lastUpdated], [fileSize], [uploadedBy], [status]
)
VALUES 
(0, 1, 'https://storage.com/images/contract1.jpg', 'contract1.jpg', GETDATE(), 1024, 1, 'active'),
(0, 2, 'https://storage.com/docs/terms.pdf', 'terms.pdf', GETDATE(), 2048, 1, 'active'),
(0, 4, 'https://storage.com/logos/gympower.png', 'gympower.png', GETDATE(), 512, 1, 'active'),
(0, 4, 'https://storage.com/logos/saludtotal.png', 'saludtotal.png', GETDATE(), 512, 1, 'active'),
(0, 4, 'https://storage.com/logos/parkeasy.png', 'parkeasy.png', GETDATE(), 512, 1, 'active'),
(0, 3, 'https://storage.com/videos/tutorial.mp4', 'tutorial.mp4', GETDATE(), 4096, 1, 'active');

-- 11.3 Relación Proveedores-Archivos Multimedia
INSERT INTO [dbo].[st_providersMediaFiles] ([providerContractID], [mediaFileID])
VALUES 
(1, 1), (1, 3),
(2, 2), (2, 4),
(3, 5),
(5, 6);


SELECT * FROM st_currencies;
SELECT * FROM st_users;
SELECT * FROM st_providers;
SELECT * FROM st_services;
SELECT * FROM st_providerContactInfo;
SELECT * FROM st_providerServices;

SELECT * FROM st_users;
SELECT * FROM st_userContactInfo;
SELECT * FROM st_ContactType;

SELECT * FROM st_plans;
SELECT * FROM st_planServices;
SELECT * FROM st_subcriptions;
SELECT * FROM st_beneficiariesPerPlan;

SELECT * FROM st_payments;
SELECT * FROM st_transactions;
SELECT * FROM st_exchangeRate;

SELECT * FROM st_roles_has_st_permissions;
SELECT * FROM st_Roles;
SELECT * FROM st_Permissions;
SELECT * FROM st_roles_has_st_users;
SELECT * FROM st_mediaTypes;
SELECT * FROM st_MediaFiles;
SELECT * FROM st_providersMediaFiles;