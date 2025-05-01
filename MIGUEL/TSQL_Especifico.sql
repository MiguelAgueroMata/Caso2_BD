USE [Caso2DB]
Go
------------------------------------------------------------
-- 1. Cursor LOCAL (no visible fuera de la sesión)
------------------------------------------------------------
DECLARE @message VARCHAR(100)
PRINT 'Demostrando un cursor LOCAL (visible solo en esta sesión)'

-- Creando el cursor local
DECLARE user_cursor CURSOR LOCAL FOR
SELECT firstName + ' ' + lastName AS NombreCompleto
FROM st_users
WHERE enabled = 1

-- Variables para almacenar resultados
DECLARE @nombreUsuario VARCHAR(100)

-- Abrir el cursor
OPEN user_cursor

-- Recuperar la primera fila
FETCH NEXT FROM user_cursor INTO @nombreUsuario

-- Mostrar hasta 5 usuarios
DECLARE @contador INT = 0
WHILE @@FETCH_STATUS = 0 AND @contador < 8
BEGIN
    SET @contador = @contador + 1
    PRINT 'Usuario #' + CAST(@contador AS VARCHAR) + ': ' + @nombreUsuario
    FETCH NEXT FROM user_cursor INTO @nombreUsuario
END

-- Cerrar y liberar el cursor
CLOSE user_cursor
DEALLOCATE user_cursor
GO

FETCH NEXT FROM user_cursor
-- Nota: Este cursor LOCAL no puede ser accedido desde otra conexión
-- Si intentas abrir otro Query y escribir 'FETCH NEXT FROM user_cursor', obtendrás un error


------------------------------------------------------------
-- 2. Cursor GLOBAL (accesible desde otras sesiones)
------------------------------------------------------------
PRINT '------------------------------------------------------------'
PRINT 'Demostrando un cursor GLOBAL (visible desde otras conexiones)'

-- Creando cursor global (separa en batches para demostrar persistencia)
DECLARE plan_cursor CURSOR GLOBAL FOR
SELECT planName, planPrice FROM st_plans WHERE planTypeID = 1

OPEN plan_cursor
GO

-- Continuación del cursor GLOBAL en el mismo connection
DECLARE @planNombre VARCHAR(100), @planPrecio DECIMAL(10,2), @contador INT = 0

PRINT 'Continuando procesamiento del cursor GLOBAL...'
FETCH NEXT FROM plan_cursor INTO @planNombre, @planPrecio

WHILE @@FETCH_STATUS = 0 AND @contador < 2
BEGIN
    SET @contador = @contador + 1
    PRINT '[GLOBAL] Plan #' + CAST(@contador AS VARCHAR) + ': ' + @planNombre + ' - $' + CAST(@planPrecio AS VARCHAR)
    FETCH NEXT FROM plan_cursor INTO @planNombre, @planPrecio
END
GO


CLOSE plan_cursor
DEALLOCATE plan_cursor
GO

FETCH NEXT FROM plan_cursor

