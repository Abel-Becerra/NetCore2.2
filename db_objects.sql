USE master
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = 'pruebas')
BEGIN
	CREATE DATABASE pruebas
END
GO
USE pruebas
GO
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'usuarios')
BEGIN
CREATE TABLE usuarios(
	Nombre VARCHAR(1000),
	Usuario VARCHAR(200),
	Contraseña VARBINARY(256),
	Frase VARCHAR(100),
	CONSTRAINT PK_Usuarios PRIMARY KEY(Usuario)
)
INSERT usuarios VALUES('Manuel de la Cruz', 'mdelacruz', ENCRYPTBYPASSPHRASE('XLKJAL0823', 'ab3l4Rd0'), 'XLKJAL0823')
END
GO
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'monedas')
BEGIN
CREATE TABLE monedas(
	Id INT NOT NULL,
	Nombre VARCHAR(200),
	CONSTRAINT PK_Monedas PRIMARY KEY(Id)
)
INSERT monedas VALUES(1,'Pesos'),(2,'Dolares')
END
GO
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'proveedores')
BEGIN
CREATE TABLE proveedores(
	Id INT NOT NULL,
	Nombre VARCHAR(1000),
	CONSTRAINT PK_Proveedores PRIMARY KEY(Id)
)
INSERT INTO proveedores VALUES(1,'SAP'),(2,'Concur')
END
GO
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'recibos')
BEGIN
CREATE TABLE recibos(
	Id BIGINT NOT NULL,
	IdProveedor INT NOT NULL,
	Monto DECIMAL(19,2) NOT NULL,
	IdMoneda INT NOT NULL,
	Fecha DATE NOT NULL,
	Comentario VARCHAR(1000),
	FechaCreacion DATETIME NOT NULL,
	FechaModificacion DATETIME NOT NULL,
	Usuario VARCHAR(500),
	CONSTRAINT PK_Recibos PRIMARY KEY(Id)
)

ALTER TABLE recibos ADD CONSTRAINT FK_recibos_monedas FOREIGN KEY(IdMoneda) REFERENCES monedas (Id)

ALTER TABLE dbo.recibos ADD CONSTRAINT FK_recibos_proveedores FOREIGN KEY(IdProveedor) REFERENCES dbo.proveedores (Id)
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[MonedasGuardar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [MonedasGuardar] AS' 
END
GO
ALTER PROCEDURE [MonedasGuardar]
@Id INT OUTPUT,
@Nombre VARCHAR(200)
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @data TABLE (Id INT)

	IF ISNULL(@Id, 0) = 0 SET @Id = ISNULL((SELECT MAX(Id) FROM monedas), 0) + 1

	MERGE INTO monedas AS target
	USING (SELECT @Id, @Nombre) AS source (Id, Nombre)
		ON (target.Id = source.Id OR target.Nombre = source.Nombre)
	WHEN MATCHED THEN
		UPDATE SET Nombre = source.Nombre
	WHEN NOT MATCHED THEN
		INSERT (Id, Nombre) VALUES (source.Id, source.Nombre)
	OUTPUT inserted.Id INTO @data;

	SELECT @Id = Id FROM @data
SET NOCOUNT OFF;
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[MonedasObtener]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [MonedasObtener] AS' 
END
GO
ALTER PROCEDURE [MonedasObtener]
@Id INT = NULL,
@Nombre VARCHAR(1000) = NULL
AS
BEGIN
SET NOCOUNT ON;
	SELECT Id, Nombre FROM monedas WHERE Id = ISNULL(@Id, Id) OR Nombre = ISNULL(@Nombre, Nombre)
SET NOCOUNT OFF;
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ProveedoresGuardar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [ProveedoresGuardar] AS' 
END
GO
ALTER PROCEDURE [ProveedoresGuardar]
@Id INT OUTPUT,
@Nombre VARCHAR(1000)
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @data TABLE (Id INT)

	IF ISNULL(@Id, 0) = 0 SET @Id = ISNULL((SELECT MAX(Id) FROM proveedores), 0) + 1

	MERGE INTO proveedores AS target
	USING (SELECT @Id, @Nombre) AS source (Id, Nombre)
		ON (target.Id = source.Id OR target.Nombre = source.Nombre)
	WHEN MATCHED THEN
		UPDATE SET Nombre = source.Nombre
	WHEN NOT MATCHED THEN
		INSERT (Id, Nombre) VALUES (source.Id, source.Nombre)
	OUTPUT inserted.Id INTO @data;

	SELECT @Id = Id FROM @data
SET NOCOUNT OFF;
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ProveedoresObtener]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [ProveedoresObtener] AS' 
END
GO
ALTER PROCEDURE [ProveedoresObtener]
@Id INT = NULL,
@Nombre VARCHAR(1000) = NULL
AS
BEGIN
SET NOCOUNT ON;
	SELECT Id, Nombre FROM proveedores WHERE Id = ISNULL(@Id, Id) OR Nombre = ISNULL(@Nombre, Nombre)
SET NOCOUNT OFF;
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RecibosGuardar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [RecibosGuardar] AS' 
END
GO
ALTER PROCEDURE [RecibosGuardar]
@Id BIGINT OUTPUT,
@IdProveedor INT,
@Proveedor VARCHAR(1000),
@IdMoneda INT,
@Moneda VARCHAR(200),
@Monto DECIMAL(19, 2),
@Fecha DATE,
@Comentario VARCHAR(1000),
@Usuario VARCHAR(500)
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @data TABLE (Id INT)

	IF ISNULL(@IdMoneda, 0) = 0 AND @Moneda IS NULL
	BEGIN
		;THROW 60000, N'Se requiere la MONEDA', 1;
		RETURN
	END

	IF ISNULL(@IdProveedor, 0) = 0 AND @Proveedor IS NULL
	BEGIN
		;THROW 60000, N'Se requiere el PROVEEDOR', 1;
		RETURN
	END
	
	IF @Monto IS NULL
	BEGIN
		;THROW 60000, N'Se requiere el MONTO', 1;
		RETURN
	END
	
	IF @Fecha IS NULL
	BEGIN
		;THROW 60000, N'Se requiere la FECHA', 1;
		RETURN
	END

	IF ISNULL(@IdMoneda, 0) = 0
	BEGIN
		EXEC MonedasGuardar @IdMoneda OUTPUT, @Moneda
	END

	IF ISNULL(@IdProveedor, 0) = 0
	BEGIN
		EXEC ProveedoresGuardar @IdProveedor OUTPUT, @Proveedor
	END

	IF ISNULL(@Id, 0) = 0 SET @Id = ISNULL((SELECT MAX(Id) FROM recibos), 0) + 1

	MERGE INTO recibos AS target
	USING (SELECT @Id, @IdProveedor, @Monto, @IdMoneda, @Fecha, @Comentario, GETDATE(), GETDATE(), @Usuario)
		AS source (Id, IdProveedor, Monto, IdMoneda, Fecha, Comentario, FechaCreacion, FechaModificacion, Usuario)
			ON ((target.Id = source.Id AND source.Id IS NOT NULL) OR
				--No se puede saber si estan duplicando el recibo, asi que por seguridad no puede haber 2 recibos en la misma fecha
				--con el mismo monto en la misma moneda y para el mismo proveedor, esta regla es por seguridad y deberá cambiarse o quitarse
				--una vez definida la o las reglas de negocio que sean mas convenientes
				(source.Id IS NULL AND target.IdProveedor = source.IdProveedor AND target.Fecha = source.Fecha AND target.Monto = source.Monto AND target.IdMoneda = source.IdMoneda))
	WHEN MATCHED THEN
		UPDATE SET Comentario = source.Comentario, FechaModificacion = source.FechaModificacion, Usuario = source.Usuario,
			IdProveedor = source.IdProveedor, Fecha = source.Fecha, Monto = source.Monto, IdMoneda = source.IdMoneda
	WHEN NOT MATCHED THEN
		INSERT (Id, IdProveedor, Monto, IdMoneda, Fecha, Comentario, FechaCreacion, FechaModificacion, Usuario)
		VALUES (source.Id, source.IdProveedor, source.Monto, source.IdMoneda, source.Fecha, source.Comentario, source.FechaCreacion, NULL, source.Usuario)
	OUTPUT inserted.Id INTO @data;

	SELECT @Id = Id FROM @data
SET NOCOUNT OFF;
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RecibosObtener]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [RecibosObtener] AS' 
END
GO
ALTER PROCEDURE [RecibosObtener]
@Id BIGINT = NULL,
@IdProveedor INT = NULL,
@IdMoneda INT = NULL,
@MontoInicio DECIMAL(19, 2) = NULL,
@MontoFin DECIMAL(19, 2) = NULL,
@FechaInicio DATE = NULL,
@FechaFin DATE = NULL
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @sql NVARCHAR(MAX) = 'SELECT r.Id, r.IdProveedor, Proveedor = p.Nombre, r.Monto, r.IdMoneda, Moneda = m.Nombre, r.Fecha, r.Comentario, r.FechaCreacion, FechaModificacion = ISNULL(r.FechaModificacion,GETDATE()), r.Usuario, FechaFin = NULL, MontoFin = NULL FROM recibos r JOIN monedas m ON m.Id = r.IdMoneda JOIN proveedores p ON p.Id = r.IdProveedor'
	
	IF @Id IS NOT NULL SET @sql = @sql + ' WHERE r.Id = ' + CAST(@Id AS VARCHAR)

	IF @IdProveedor IS NOT NULL BEGIN
		SET @sql = @sql + CASE WHEN @sql LIKE '%WHERE' THEN ' AND ' ELSE ' WHERE ' END
		SET @sql = @sql + 'r.IdProveedor = ' + CAST(@IdProveedor AS VARCHAR)
	END

	IF @IdMoneda IS NOT NULL BEGIN
		SET @sql = @sql + CASE WHEN @sql LIKE '%WHERE' THEN ' AND ' ELSE ' WHERE ' END
		SET @sql = @sql + 'r.IdMoneda = ' + CAST(@IdMoneda AS VARCHAR)
	END

	IF @MontoFin IS NULL SET @MontoFin = @MontoInicio

	IF @MontoInicio IS NOT NULL AND @MontoFin IS NOT NULL BEGIN
		SET @sql = @sql + CASE WHEN @sql LIKE '%WHERE' THEN ' AND ' ELSE ' WHERE ' END
		SET @sql = @sql + 'r.Monto >= ' + CAST(@MontoInicio AS VARCHAR) + ' AND r.Monto <= ' + CAST(@MontoFin AS VARCHAR)
	END

	IF @FechaFin IS NULL SET @FechaFin = @FechaInicio

	IF @FechaInicio IS NOT NULL AND @FechaFin IS NOT NULL BEGIN
		SET @sql = @sql + CASE WHEN @sql LIKE '%WHERE' THEN ' AND ' ELSE ' WHERE ' END
		SET @sql = @sql + 'r.Fecha >= ''' + CAST(@FechaInicio AS VARCHAR) + ''' AND r.Fecha <= ''' + CAST(@FechaFin AS VARCHAR) + ''''
	END

	PRINT @sql
	EXECUTE(@sql)
SET NOCOUNT OFF;
END
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[UsuariosObtener]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [UsuariosObtener] AS' 
END
GO
ALTER PROCEDURE [UsuariosObtener]
@Usuario VARCHAR(200),
@Contraseña VARCHAR(200),
@Acceso BIT OUTPUT,
@Nombre VARCHAR(1000) OUTPUT
AS
BEGIN
SET NOCOUNT ON;
	SET @Acceso = 0

	IF EXISTS(SELECT 1 FROM usuarios WHERE Usuario = @Usuario AND @Contraseña = CONVERT(VARCHAR(200), DECRYPTBYPASSPHRASE(Frase, Contraseña)))
	BEGIN
		SET @Acceso = 1
		SET @Nombre = (SELECT Nombre FROM usuarios WHERE Usuario = @Usuario AND @Contraseña = CONVERT(VARCHAR(200), DECRYPTBYPASSPHRASE(Frase, Contraseña)))
	END
SET NOCOUNT OFF;
END
GO
