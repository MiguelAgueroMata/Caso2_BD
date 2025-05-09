USE [master]
GO
/****** Object:  Database [Caso2DB]    Script Date: 4/23/2025 9:37:05 PM ******/
CREATE DATABASE [Caso2DB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Caso2DB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Caso2DB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Caso2DB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\Caso2DB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [Caso2DB] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Caso2DB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Caso2DB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Caso2DB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Caso2DB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Caso2DB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Caso2DB] SET ARITHABORT OFF 
GO
ALTER DATABASE [Caso2DB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Caso2DB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Caso2DB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Caso2DB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Caso2DB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Caso2DB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Caso2DB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Caso2DB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Caso2DB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Caso2DB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [Caso2DB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Caso2DB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Caso2DB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Caso2DB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Caso2DB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Caso2DB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Caso2DB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Caso2DB] SET RECOVERY FULL 
GO
ALTER DATABASE [Caso2DB] SET  MULTI_USER 
GO
ALTER DATABASE [Caso2DB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Caso2DB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Caso2DB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Caso2DB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Caso2DB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [Caso2DB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'Caso2DB', N'ON'
GO
ALTER DATABASE [Caso2DB] SET QUERY_STORE = ON
GO
ALTER DATABASE [Caso2DB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [Caso2DB]
GO
/****** Object:  Table [dbo].[st_beneficiariesPerPlan]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_beneficiariesPerPlan](
	[beneficiarieID] [int] IDENTITY(1,1) NOT NULL,
	[startDate] [datetime] NOT NULL,
	[endDate] [datetime] NULL,
	[subscriptionID] [int] NOT NULL,
	[userID] [int] NOT NULL,
	[enabled] [bit] NOT NULL,
 CONSTRAINT [PK_st_beneficiariesPerPlan] PRIMARY KEY CLUSTERED 
(
	[beneficiarieID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_contactType]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_contactType](
	[contactInfoTypeId] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
 CONSTRAINT [PK_st_contactInfoType] PRIMARY KEY CLUSTERED 
(
	[contactInfoTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_contractDetails]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_contractDetails](
	[contractDetailsID] [int] IDENTITY(1,1) NOT NULL,
	[providerContractID] [int] NOT NULL,
	[serviceBasePrice] [decimal](10, 2) NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[discount] [float] NOT NULL,
	[includesIVA] [bit] NOT NULL,
	[contractPrice] [decimal](10, 2) NOT NULL,
	[finalPrice] [decimal](10, 2) NOT NULL,
	[IVA] [float] NULL,
	[providerProfit] [decimal](10, 2) NOT NULL,
	[solturaProfit] [decimal](10, 2) NOT NULL,
	[profit] [decimal](10, 2) NOT NULL,
	[solturaFee] [decimal](10, 2) NOT NULL,
	[enabled] [bit] NOT NULL,
	[providerServicesID] [int] NOT NULL,
	[serviceAvailabilityID] [int] NOT NULL,
	[discountTypeID] [int] NOT NULL,
	[isMembership] [bit] NOT NULL,
	[validFrom] [datetime] NULL,
	[validTo] [datetime] NULL,
	[usageUnitTypeID] [int] NOT NULL,
	[usageValue] [int] NULL,
	[maxUses] [int] NULL,
	[bundleQuantity] [int] NULL,
	[bundlePrice] [decimal](10, 2) NULL,
 CONSTRAINT [PK_st_contractDetails] PRIMARY KEY CLUSTERED 
(
	[contractDetailsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_contractRenewals]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_contractRenewals](
	[contractRenewalID] [int] IDENTITY(1,1) NOT NULL,
	[renewalDate] [datetime] NOT NULL,
	[renewalMotive] [varchar](200) NOT NULL,
	[contractChanges] [varchar](max) NOT NULL,
	[providerContractID] [int] NOT NULL,
 CONSTRAINT [PK_st_contractRenewals] PRIMARY KEY CLUSTERED 
(
	[contractRenewalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_currencies]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_currencies](
	[currencyID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
	[acronym] [varchar](10) NOT NULL,
	[symbol] [varchar](5) NOT NULL,
	[country] [varchar](45) NOT NULL,
 CONSTRAINT [PK_st_currencies] PRIMARY KEY CLUSTERED 
(
	[currencyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_discountType]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_discountType](
	[discountTypeID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
 CONSTRAINT [PK_st_discountType] PRIMARY KEY CLUSTERED 
(
	[discountTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_exchangeRate]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_exchangeRate](
	[exchangeRateID] [int] IDENTITY(1,1) NOT NULL,
	[currecyIdSource] [int] NOT NULL,
	[currencyIdDestiny] [int] NOT NULL,
	[startDate] [datetime] NOT NULL,
	[endDate] [datetime] NOT NULL,
	[exhangeRate] [float] NOT NULL,
	[currentExchangeRate] [bit] NOT NULL,
	[currencyID] [int] NOT NULL,
 CONSTRAINT [PK_st_exchangeRate] PRIMARY KEY CLUSTERED 
(
	[exchangeRateID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_MediaFiles]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_MediaFiles](
	[mediaFileID] [int] IDENTITY(1,1) NOT NULL,
	[deleted] [bit] NOT NULL,
	[mediaTypeID] [int] NOT NULL,
	[fileURL] [varchar](200) NOT NULL,
	[fileName] [varchar](45) NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[fileSize] [int] NOT NULL,
	[uploadedBy] [int] NOT NULL,
	[status] [varchar](60) NOT NULL,
 CONSTRAINT [PK_st_mediaFiles] PRIMARY KEY CLUSTERED 
(
	[mediaFileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_mediaTypes]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_mediaTypes](
	[mediaTypeID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
	[mediaExtension] [varchar](10) NULL,
 CONSTRAINT [PK_st_mediaTypes] PRIMARY KEY CLUSTERED 
(
	[mediaTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_paymentMethod]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_paymentMethod](
	[paymentMethodID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[secretKey] [varbinary](250) NOT NULL,
	[key] [varbinary](250) NOT NULL,
	[apiURL] [varchar](200) NOT NULL,
	[logoURL] [varchar](200) NULL,
	[configJSON] [varchar](500) NULL,
	[lastUpdated] [datetime] NULL,
	[enabled] [bit] NOT NULL,
 CONSTRAINT [PK_st_paymentMethod] PRIMARY KEY CLUSTERED 
(
	[paymentMethodID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_payments]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_payments](
	[paymentID] [int] IDENTITY(1,1) NOT NULL,
	[paymentMethodID] [int] NOT NULL,
	[amount] [decimal](10, 0) NOT NULL,
	[actualAmount] [float] NOT NULL,
	[result] [varchar](60) NOT NULL,
	[authentication] [varchar](200) NOT NULL,
	[reference] [varchar](60) NOT NULL,
	[chargedToken] [varbinary](250) NOT NULL,
	[description] [varchar](200) NULL,
	[error] [varchar](200) NULL,
	[paymentDate] [datetime] NOT NULL,
	[checksum] [varbinary](250) NOT NULL,
	[currencyID] [int] NOT NULL,
 CONSTRAINT [PK_st_payments] PRIMARY KEY CLUSTERED 
(
	[paymentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_Permissions]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_Permissions](
	[permissionID] [int] IDENTITY(1,1) NOT NULL,
	[description] [varchar](200) NOT NULL,
	[accessLevel] [int] NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[enabled] [bit] NOT NULL,
 CONSTRAINT [PK_st_Permissions] PRIMARY KEY CLUSTERED 
(
	[permissionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_permissions_has_st_users]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_permissions_has_st_users](
	[permissionID] [int] NOT NULL,
	[userID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_plans]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_plans](
	[planID] [int] IDENTITY(1,1) NOT NULL,
	[planPrice] [decimal](10, 2) NOT NULL,
	[postTime] [datetime] NULL,
	[planName] [varchar](60) NOT NULL,
	[planTypeID] [int] NOT NULL,
	[currencyID] [int] NOT NULL,
	[description] [varchar](max) NOT NULL,
	[imageURL] [varchar](200) NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[solturaPrice] [decimal](10, 2) NOT NULL,
 CONSTRAINT [PK_st_plans] PRIMARY KEY CLUSTERED 
(
	[planID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_planServices]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_planServices](
	[planServiceID] [int] IDENTITY(1,1) NOT NULL,
	[serviceID] [int] NOT NULL,
	[planID] [int] NOT NULL,
	[discountTypeID] [int] NULL,
	[bundleQuantity] [int] NULL,
	[bundlePrice] [decimal](10, 2) NULL,
	[originalPrice] [decimal](10, 2) NULL,
	[solturaPrice] [decimal](10, 2) NULL,
	[usageValue] [int] NULL,
	[maxUses] [int] NULL,
	[isMembership] [bit] NULL,
	[serviceAvailabilityTypeID] [int] NOT NULL,
	[validFrom] [datetime] NULL,
	[validTo] [datetime] NULL,
	[usageUnitTypeID] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_planType]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_planType](
	[planTypeID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
	[description] [varchar](200) NOT NULL,
	[enabled] [bit] NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
 CONSTRAINT [PK_st_planType] PRIMARY KEY CLUSTERED 
(
	[planTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_providerContactInfo]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_providerContactInfo](
	[providerContactInfoID] [int] IDENTITY(1,1) NOT NULL,
	[contact] [varchar](200) NOT NULL,
	[enabled] [bit] NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[providerID] [int] NOT NULL,
	[description] [varchar](200) NOT NULL,
	[ContactTypeID] [int] NOT NULL,
 CONSTRAINT [PK_st_providerContactInfo] PRIMARY KEY CLUSTERED 
(
	[providerContactInfoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_providers]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_providers](
	[providerID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[providerDescription] [varchar](200) NOT NULL,
	[status] [bit] NOT NULL,
 CONSTRAINT [PK_st_providers] PRIMARY KEY CLUSTERED 
(
	[providerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_providersContract]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_providersContract](
	[providerContractID] [int] IDENTITY(1,1) NOT NULL,
	[startDate] [datetime] NOT NULL,
	[endDate] [datetime] NOT NULL,
	[contractType] [varchar](100) NOT NULL,
	[contractDescription] [varchar](max) NOT NULL,
	[status] [bit] NOT NULL,
	[authorizedSignatory] [varbinary](1024) NOT NULL,
	[providerID] [int] NOT NULL,
 CONSTRAINT [PK_st_providersContract] PRIMARY KEY CLUSTERED 
(
	[providerContractID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_providerServices]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_providerServices](
	[providerServiceID] [int] IDENTITY(1,1) NOT NULL,
	[providerID] [int] NOT NULL,
	[serviceID] [int] NOT NULL,
 CONSTRAINT [PK_st_providerServices] PRIMARY KEY CLUSTERED 
(
	[providerServiceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_providersMediaFiles]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_providersMediaFiles](
	[providerMediaFileID] [int] IDENTITY(1,1) NOT NULL,
	[providerContractID] [int] NOT NULL,
	[mediaFileID] [int] NOT NULL,
 CONSTRAINT [PK_st_providersMediaFiles] PRIMARY KEY CLUSTERED 
(
	[providerMediaFileID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_Roles]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_Roles](
	[roleID] [int] IDENTITY(1,1) NOT NULL,
	[roleName] [varchar](60) NOT NULL,
	[description] [varchar](200) NULL,
	[createdAt] [datetime] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[enabled] [bit] NOT NULL,
 CONSTRAINT [PK_st_Roles] PRIMARY KEY CLUSTERED 
(
	[roleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_roles_has_st_permissions]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_roles_has_st_permissions](
	[rolesID] [int] NOT NULL,
	[permissionID] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_roles_has_st_users]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_roles_has_st_users](
	[roleID] [int] NOT NULL,
	[userID] [int] IDENTITY(1,1) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_scheduleDetails]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_scheduleDetails](
	[scheduleDetailsID] [int] IDENTITY(1,1) NOT NULL,
	[deleted] [bit] NOT NULL,
	[baseDate] [datetime] NOT NULL,
	[datePart] [varchar](30) NOT NULL,
	[lastExecution] [datetime] NULL,
	[nextExecution] [datetime] NULL,
	[scheduleID] [int] NOT NULL,
 CONSTRAINT [PK_st_scheduleDetails] PRIMARY KEY CLUSTERED 
(
	[scheduleDetailsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_schedules]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_schedules](
	[scheduleID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[recurrencyType] [int] NOT NULL,
	[repeat] [varchar](45) NOT NULL,
	[endDate] [datetime] NULL,
	[subcriptionID] [int] NOT NULL,
 CONSTRAINT [PK_st_schedules] PRIMARY KEY CLUSTERED 
(
	[scheduleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_serviceAvailability]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_serviceAvailability](
	[serviceAvailabilityID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](45) NOT NULL,
 CONSTRAINT [PK_st_serviceAvailability] PRIMARY KEY CLUSTERED 
(
	[serviceAvailabilityID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_services]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_services](
	[serviceID] [int] IDENTITY(1,1) NOT NULL,
	[enabled] [bit] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[providersID] [int] NOT NULL,
	[serviceName] [varchar](45) NOT NULL,
	[logoURL] [varchar](200) NOT NULL,
	[Description] [varchar](500) NOT NULL,
	[serviceTypeID] [int] NOT NULL,
 CONSTRAINT [PK_st_services] PRIMARY KEY CLUSTERED 
(
	[serviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_serviceType]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_serviceType](
	[serviceTypeID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
	[description] [varchar](200) NOT NULL,
 CONSTRAINT [PK_st_serviceType] PRIMARY KEY CLUSTERED 
(
	[serviceTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_subcriptions]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_subcriptions](
	[subcriptionID] [int] IDENTITY(1,1) NOT NULL,
	[description] [varchar](200) NULL,
	[logoURL] [varchar](200) NULL,
	[enabled] [bit] NOT NULL,
	[planTypeID] [int] NOT NULL,
	[userID] [int] NOT NULL,
 CONSTRAINT [PK_st_subcriptions] PRIMARY KEY CLUSTERED 
(
	[subcriptionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_transactions]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_transactions](
	[transactionID] [int] IDENTITY(1,1) NOT NULL,
	[transactionAmount] [decimal](10, 2) NOT NULL,
	[description] [varchar](200) NOT NULL,
	[transactionDate] [datetime] NULL,
	[postTime] [datetime] NOT NULL,
	[referenceNumber] [varchar](200) NOT NULL,
	[convertedAmount] [decimal](10, 2) NOT NULL,
	[checksum] [varbinary](250) NOT NULL,
	[currencyID] [int] NOT NULL,
	[exchangeRateId] [int] NOT NULL,
	[paymentId] [int] NOT NULL,
	[userID] [int] NOT NULL,
	[transactionTypeID] [int] NOT NULL,
	[transactionSubTypeID] [int] NOT NULL,
 CONSTRAINT [PK_st_transactions] PRIMARY KEY CLUSTERED 
(
	[transactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_transactionSubTypes]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_transactionSubTypes](
	[transactionSubTypesID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NOT NULL,
 CONSTRAINT [PK_st_transactionSubTypes] PRIMARY KEY CLUSTERED 
(
	[transactionSubTypesID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_transactionType]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_transactionType](
	[transactionTypeID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](60) NULL,
 CONSTRAINT [PK_st_transactionType] PRIMARY KEY CLUSTERED 
(
	[transactionTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_usageTokens]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_usageTokens](
	[usageTokenID] [int] IDENTITY(1,1) NOT NULL,
	[userID] [int] NOT NULL,
	[tokenType] [varchar](20) NOT NULL,
	[tokenCode] [varbinary](250) NOT NULL,
	[createdAt] [datetime] NOT NULL,
	[expirationDate] [datetime] NOT NULL,
	[status] [varchar](20) NOT NULL,
	[failedAttempts] [int] NOT NULL,
	[contractDetailsID] [int] NOT NULL,
	[maxUses] [int] NULL,
 CONSTRAINT [PK_st_deviceAuthentication] PRIMARY KEY CLUSTERED 
(
	[usageTokenID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_usageTransactions]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_usageTransactions](
	[usageTransactionID] [int] IDENTITY(1,1) NOT NULL,
	[usageTokenID] [int] NOT NULL,
	[transactionDate] [datetime] NOT NULL,
	[usageNotes] [varchar](300) NOT NULL,
	[transactionType] [varchar](60) NOT NULL,
 CONSTRAINT [PK_st_accessLogs] PRIMARY KEY CLUSTERED 
(
	[usageTransactionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_usageUnitType]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_usageUnitType](
	[usageUnitTypeID] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](20) NOT NULL,
 CONSTRAINT [PK_st_usageUnitType] PRIMARY KEY CLUSTERED 
(
	[usageUnitTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_userContactInfo]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_userContactInfo](
	[userContactInfoID] [int] IDENTITY(1,1) NOT NULL,
	[value] [varchar](200) NOT NULL,
	[enabled] [bit] NOT NULL,
	[lastUpdated] [datetime] NOT NULL,
	[contactTypeID] [int] NOT NULL,
	[userId] [int] NOT NULL,
 CONSTRAINT [PK_st_contactInfoPerUser] PRIMARY KEY CLUSTERED 
(
	[userContactInfoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[st_users]    Script Date: 4/23/2025 9:37:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[st_users](
	[userID] [int] IDENTITY(1,1) NOT NULL,
	[firstName] [varchar](45) NOT NULL,
	[lastName] [varchar](45) NOT NULL,
	[password] [varbinary](250) NOT NULL,
	[enabled] [bit] NOT NULL,
	[birthDate] [datetime] NOT NULL,
	[createdAt] [datetime] NOT NULL,
 CONSTRAINT [PK_st_users] PRIMARY KEY CLUSTERED 
(
	[userID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[st_beneficiariesPerPlan]  WITH CHECK ADD  CONSTRAINT [FK_st_beneficiariesPerPlan_st_subcriptions] FOREIGN KEY([subscriptionID])
REFERENCES [dbo].[st_subcriptions] ([subcriptionID])
GO
ALTER TABLE [dbo].[st_beneficiariesPerPlan] CHECK CONSTRAINT [FK_st_beneficiariesPerPlan_st_subcriptions]
GO
ALTER TABLE [dbo].[st_beneficiariesPerPlan]  WITH CHECK ADD  CONSTRAINT [FK_st_beneficiariesPerPlan_st_users] FOREIGN KEY([userID])
REFERENCES [dbo].[st_users] ([userID])
GO
ALTER TABLE [dbo].[st_beneficiariesPerPlan] CHECK CONSTRAINT [FK_st_beneficiariesPerPlan_st_users]
GO
ALTER TABLE [dbo].[st_contractDetails]  WITH CHECK ADD  CONSTRAINT [FK_st_contractDetails_st_discountType] FOREIGN KEY([discountTypeID])
REFERENCES [dbo].[st_discountType] ([discountTypeID])
GO
ALTER TABLE [dbo].[st_contractDetails] CHECK CONSTRAINT [FK_st_contractDetails_st_discountType]
GO
ALTER TABLE [dbo].[st_contractDetails]  WITH CHECK ADD  CONSTRAINT [FK_st_contractDetails_st_providersContract] FOREIGN KEY([providerContractID])
REFERENCES [dbo].[st_providersContract] ([providerContractID])
GO
ALTER TABLE [dbo].[st_contractDetails] CHECK CONSTRAINT [FK_st_contractDetails_st_providersContract]
GO
ALTER TABLE [dbo].[st_contractDetails]  WITH CHECK ADD  CONSTRAINT [FK_st_contractDetails_st_providerServices] FOREIGN KEY([providerServicesID])
REFERENCES [dbo].[st_providerServices] ([providerServiceID])
GO
ALTER TABLE [dbo].[st_contractDetails] CHECK CONSTRAINT [FK_st_contractDetails_st_providerServices]
GO
ALTER TABLE [dbo].[st_contractDetails]  WITH CHECK ADD  CONSTRAINT [FK_st_contractDetails_st_serviceAvailability] FOREIGN KEY([serviceAvailabilityID])
REFERENCES [dbo].[st_serviceAvailability] ([serviceAvailabilityID])
GO
ALTER TABLE [dbo].[st_contractDetails] CHECK CONSTRAINT [FK_st_contractDetails_st_serviceAvailability]
GO
ALTER TABLE [dbo].[st_contractDetails]  WITH CHECK ADD  CONSTRAINT [FK_st_contractDetails_st_usageUnitType] FOREIGN KEY([usageUnitTypeID])
REFERENCES [dbo].[st_usageUnitType] ([usageUnitTypeID])
GO
ALTER TABLE [dbo].[st_contractDetails] CHECK CONSTRAINT [FK_st_contractDetails_st_usageUnitType]
GO
ALTER TABLE [dbo].[st_contractRenewals]  WITH CHECK ADD  CONSTRAINT [FK_st_contractRenewals_st_providersContract] FOREIGN KEY([providerContractID])
REFERENCES [dbo].[st_providersContract] ([providerContractID])
GO
ALTER TABLE [dbo].[st_contractRenewals] CHECK CONSTRAINT [FK_st_contractRenewals_st_providersContract]
GO
ALTER TABLE [dbo].[st_exchangeRate]  WITH CHECK ADD  CONSTRAINT [FK_st_exchangeRate_st_currencies] FOREIGN KEY([currencyID])
REFERENCES [dbo].[st_currencies] ([currencyID])
GO
ALTER TABLE [dbo].[st_exchangeRate] CHECK CONSTRAINT [FK_st_exchangeRate_st_currencies]
GO
ALTER TABLE [dbo].[st_MediaFiles]  WITH CHECK ADD  CONSTRAINT [FK_st_mediaFiles_st_mediaTypes] FOREIGN KEY([mediaTypeID])
REFERENCES [dbo].[st_mediaTypes] ([mediaTypeID])
GO
ALTER TABLE [dbo].[st_MediaFiles] CHECK CONSTRAINT [FK_st_mediaFiles_st_mediaTypes]
GO
ALTER TABLE [dbo].[st_payments]  WITH CHECK ADD  CONSTRAINT [FK_st_payments_st_currencies] FOREIGN KEY([currencyID])
REFERENCES [dbo].[st_currencies] ([currencyID])
GO
ALTER TABLE [dbo].[st_payments] CHECK CONSTRAINT [FK_st_payments_st_currencies]
GO
ALTER TABLE [dbo].[st_payments]  WITH CHECK ADD  CONSTRAINT [FK_st_payments_st_paymentMethod] FOREIGN KEY([paymentMethodID])
REFERENCES [dbo].[st_paymentMethod] ([paymentMethodID])
GO
ALTER TABLE [dbo].[st_payments] CHECK CONSTRAINT [FK_st_payments_st_paymentMethod]
GO
ALTER TABLE [dbo].[st_permissions_has_st_users]  WITH CHECK ADD  CONSTRAINT [FK_st_permissions_has_st_users_st_Permissions] FOREIGN KEY([permissionID])
REFERENCES [dbo].[st_Permissions] ([permissionID])
GO
ALTER TABLE [dbo].[st_permissions_has_st_users] CHECK CONSTRAINT [FK_st_permissions_has_st_users_st_Permissions]
GO
ALTER TABLE [dbo].[st_permissions_has_st_users]  WITH CHECK ADD  CONSTRAINT [FK_st_permissions_has_st_users_st_users] FOREIGN KEY([userID])
REFERENCES [dbo].[st_users] ([userID])
GO
ALTER TABLE [dbo].[st_permissions_has_st_users] CHECK CONSTRAINT [FK_st_permissions_has_st_users_st_users]
GO
ALTER TABLE [dbo].[st_plans]  WITH CHECK ADD  CONSTRAINT [FK_st_plans_st_currencies] FOREIGN KEY([currencyID])
REFERENCES [dbo].[st_currencies] ([currencyID])
GO
ALTER TABLE [dbo].[st_plans] CHECK CONSTRAINT [FK_st_plans_st_currencies]
GO
ALTER TABLE [dbo].[st_plans]  WITH CHECK ADD  CONSTRAINT [FK_st_plans_st_planType] FOREIGN KEY([planTypeID])
REFERENCES [dbo].[st_planType] ([planTypeID])
GO
ALTER TABLE [dbo].[st_plans] CHECK CONSTRAINT [FK_st_plans_st_planType]
GO
ALTER TABLE [dbo].[st_planServices]  WITH CHECK ADD  CONSTRAINT [FK_st_planServices_st_discountType] FOREIGN KEY([discountTypeID])
REFERENCES [dbo].[st_discountType] ([discountTypeID])
GO
ALTER TABLE [dbo].[st_planServices] CHECK CONSTRAINT [FK_st_planServices_st_discountType]
GO
ALTER TABLE [dbo].[st_planServices]  WITH CHECK ADD  CONSTRAINT [FK_st_planServices_st_plans] FOREIGN KEY([planID])
REFERENCES [dbo].[st_plans] ([planID])
GO
ALTER TABLE [dbo].[st_planServices] CHECK CONSTRAINT [FK_st_planServices_st_plans]
GO
ALTER TABLE [dbo].[st_planServices]  WITH CHECK ADD  CONSTRAINT [FK_st_planServices_st_serviceAvailability] FOREIGN KEY([serviceAvailabilityTypeID])
REFERENCES [dbo].[st_serviceAvailability] ([serviceAvailabilityID])
GO
ALTER TABLE [dbo].[st_planServices] CHECK CONSTRAINT [FK_st_planServices_st_serviceAvailability]
GO
ALTER TABLE [dbo].[st_planServices]  WITH CHECK ADD  CONSTRAINT [FK_st_planServices_st_services] FOREIGN KEY([serviceID])
REFERENCES [dbo].[st_services] ([serviceID])
GO
ALTER TABLE [dbo].[st_planServices] CHECK CONSTRAINT [FK_st_planServices_st_services]
GO
ALTER TABLE [dbo].[st_planServices]  WITH CHECK ADD  CONSTRAINT [FK_st_planServices_st_usageUnitType] FOREIGN KEY([usageUnitTypeID])
REFERENCES [dbo].[st_usageUnitType] ([usageUnitTypeID])
GO
ALTER TABLE [dbo].[st_planServices] CHECK CONSTRAINT [FK_st_planServices_st_usageUnitType]
GO
ALTER TABLE [dbo].[st_providerContactInfo]  WITH CHECK ADD  CONSTRAINT [FK_st_providerContactInfo_st_contactType] FOREIGN KEY([ContactTypeID])
REFERENCES [dbo].[st_contactType] ([contactInfoTypeId])
GO
ALTER TABLE [dbo].[st_providerContactInfo] CHECK CONSTRAINT [FK_st_providerContactInfo_st_contactType]
GO
ALTER TABLE [dbo].[st_providerContactInfo]  WITH CHECK ADD  CONSTRAINT [FK_st_providerContactInfo_st_providers] FOREIGN KEY([providerID])
REFERENCES [dbo].[st_providers] ([providerID])
GO
ALTER TABLE [dbo].[st_providerContactInfo] CHECK CONSTRAINT [FK_st_providerContactInfo_st_providers]
GO
ALTER TABLE [dbo].[st_providersContract]  WITH CHECK ADD  CONSTRAINT [FK_st_providersContract_st_providers] FOREIGN KEY([providerID])
REFERENCES [dbo].[st_providers] ([providerID])
GO
ALTER TABLE [dbo].[st_providersContract] CHECK CONSTRAINT [FK_st_providersContract_st_providers]
GO
ALTER TABLE [dbo].[st_providerServices]  WITH CHECK ADD  CONSTRAINT [FK_st_providerServices_st_providers] FOREIGN KEY([providerID])
REFERENCES [dbo].[st_providers] ([providerID])
GO
ALTER TABLE [dbo].[st_providerServices] CHECK CONSTRAINT [FK_st_providerServices_st_providers]
GO
ALTER TABLE [dbo].[st_providerServices]  WITH CHECK ADD  CONSTRAINT [FK_st_providerServices_st_services] FOREIGN KEY([serviceID])
REFERENCES [dbo].[st_services] ([serviceID])
GO
ALTER TABLE [dbo].[st_providerServices] CHECK CONSTRAINT [FK_st_providerServices_st_services]
GO
ALTER TABLE [dbo].[st_providersMediaFiles]  WITH CHECK ADD  CONSTRAINT [FK_st_providersMediaFiles_st_MediaFiles] FOREIGN KEY([mediaFileID])
REFERENCES [dbo].[st_MediaFiles] ([mediaFileID])
GO
ALTER TABLE [dbo].[st_providersMediaFiles] CHECK CONSTRAINT [FK_st_providersMediaFiles_st_MediaFiles]
GO
ALTER TABLE [dbo].[st_providersMediaFiles]  WITH CHECK ADD  CONSTRAINT [FK_st_providersMediaFiles_st_providersContract] FOREIGN KEY([providerContractID])
REFERENCES [dbo].[st_providersContract] ([providerContractID])
GO
ALTER TABLE [dbo].[st_providersMediaFiles] CHECK CONSTRAINT [FK_st_providersMediaFiles_st_providersContract]
GO
ALTER TABLE [dbo].[st_roles_has_st_permissions]  WITH CHECK ADD  CONSTRAINT [FK_st_roles_has_st_permissions_st_Permissions] FOREIGN KEY([permissionID])
REFERENCES [dbo].[st_Permissions] ([permissionID])
GO
ALTER TABLE [dbo].[st_roles_has_st_permissions] CHECK CONSTRAINT [FK_st_roles_has_st_permissions_st_Permissions]
GO
ALTER TABLE [dbo].[st_roles_has_st_permissions]  WITH CHECK ADD  CONSTRAINT [FK_st_roles_has_st_permissions_st_Roles] FOREIGN KEY([rolesID])
REFERENCES [dbo].[st_Roles] ([roleID])
GO
ALTER TABLE [dbo].[st_roles_has_st_permissions] CHECK CONSTRAINT [FK_st_roles_has_st_permissions_st_Roles]
GO
ALTER TABLE [dbo].[st_roles_has_st_users]  WITH CHECK ADD  CONSTRAINT [FK_st_roles_has_st_users_st_Roles] FOREIGN KEY([roleID])
REFERENCES [dbo].[st_Roles] ([roleID])
GO
ALTER TABLE [dbo].[st_roles_has_st_users] CHECK CONSTRAINT [FK_st_roles_has_st_users_st_Roles]
GO
ALTER TABLE [dbo].[st_roles_has_st_users]  WITH CHECK ADD  CONSTRAINT [FK_st_roles_has_st_users_st_users] FOREIGN KEY([userID])
REFERENCES [dbo].[st_users] ([userID])
GO
ALTER TABLE [dbo].[st_roles_has_st_users] CHECK CONSTRAINT [FK_st_roles_has_st_users_st_users]
GO
ALTER TABLE [dbo].[st_scheduleDetails]  WITH CHECK ADD  CONSTRAINT [FK_st_scheduleDetails_st_schedules] FOREIGN KEY([scheduleID])
REFERENCES [dbo].[st_schedules] ([scheduleID])
GO
ALTER TABLE [dbo].[st_scheduleDetails] CHECK CONSTRAINT [FK_st_scheduleDetails_st_schedules]
GO
ALTER TABLE [dbo].[st_schedules]  WITH CHECK ADD  CONSTRAINT [FK_st_schedules_st_subcriptions] FOREIGN KEY([subcriptionID])
REFERENCES [dbo].[st_subcriptions] ([subcriptionID])
GO
ALTER TABLE [dbo].[st_schedules] CHECK CONSTRAINT [FK_st_schedules_st_subcriptions]
GO
ALTER TABLE [dbo].[st_services]  WITH CHECK ADD  CONSTRAINT [FK_st_services_st_serviceType] FOREIGN KEY([serviceTypeID])
REFERENCES [dbo].[st_serviceType] ([serviceTypeID])
GO
ALTER TABLE [dbo].[st_services] CHECK CONSTRAINT [FK_st_services_st_serviceType]
GO
ALTER TABLE [dbo].[st_subcriptions]  WITH CHECK ADD  CONSTRAINT [FK_st_subcriptions_st_planType] FOREIGN KEY([planTypeID])
REFERENCES [dbo].[st_planType] ([planTypeID])
GO
ALTER TABLE [dbo].[st_subcriptions] CHECK CONSTRAINT [FK_st_subcriptions_st_planType]
GO
ALTER TABLE [dbo].[st_subcriptions]  WITH CHECK ADD  CONSTRAINT [FK_st_subcriptions_st_users] FOREIGN KEY([userID])
REFERENCES [dbo].[st_users] ([userID])
GO
ALTER TABLE [dbo].[st_subcriptions] CHECK CONSTRAINT [FK_st_subcriptions_st_users]
GO
ALTER TABLE [dbo].[st_transactions]  WITH CHECK ADD  CONSTRAINT [FK_st_transactions_st_payments] FOREIGN KEY([paymentId])
REFERENCES [dbo].[st_payments] ([paymentID])
GO
ALTER TABLE [dbo].[st_transactions] CHECK CONSTRAINT [FK_st_transactions_st_payments]
GO
ALTER TABLE [dbo].[st_transactions]  WITH CHECK ADD  CONSTRAINT [FK_st_transactions_st_transactionSubTypes] FOREIGN KEY([transactionSubTypeID])
REFERENCES [dbo].[st_transactionSubTypes] ([transactionSubTypesID])
GO
ALTER TABLE [dbo].[st_transactions] CHECK CONSTRAINT [FK_st_transactions_st_transactionSubTypes]
GO
ALTER TABLE [dbo].[st_transactions]  WITH CHECK ADD  CONSTRAINT [FK_st_transactions_st_transactionType] FOREIGN KEY([transactionTypeID])
REFERENCES [dbo].[st_transactionType] ([transactionTypeID])
GO
ALTER TABLE [dbo].[st_transactions] CHECK CONSTRAINT [FK_st_transactions_st_transactionType]
GO
ALTER TABLE [dbo].[st_transactions]  WITH CHECK ADD  CONSTRAINT [FK_st_transactions_st_users] FOREIGN KEY([userID])
REFERENCES [dbo].[st_users] ([userID])
GO
ALTER TABLE [dbo].[st_transactions] CHECK CONSTRAINT [FK_st_transactions_st_users]
GO
ALTER TABLE [dbo].[st_usageTokens]  WITH CHECK ADD  CONSTRAINT [FK_st_deviceAuthentication_st_users] FOREIGN KEY([userID])
REFERENCES [dbo].[st_users] ([userID])
GO
ALTER TABLE [dbo].[st_usageTokens] CHECK CONSTRAINT [FK_st_deviceAuthentication_st_users]
GO
ALTER TABLE [dbo].[st_usageTokens]  WITH CHECK ADD  CONSTRAINT [FK_st_usageTokens_st_contractDetails] FOREIGN KEY([contractDetailsID])
REFERENCES [dbo].[st_contractDetails] ([contractDetailsID])
GO
ALTER TABLE [dbo].[st_usageTokens] CHECK CONSTRAINT [FK_st_usageTokens_st_contractDetails]
GO
ALTER TABLE [dbo].[st_usageTransactions]  WITH CHECK ADD  CONSTRAINT [FK_st_usageTransactions_st_usageTokens] FOREIGN KEY([usageTokenID])
REFERENCES [dbo].[st_usageTokens] ([usageTokenID])
GO
ALTER TABLE [dbo].[st_usageTransactions] CHECK CONSTRAINT [FK_st_usageTransactions_st_usageTokens]
GO
ALTER TABLE [dbo].[st_userContactInfo]  WITH CHECK ADD  CONSTRAINT [FK_st_contactInfoPerUser_st_contactInfoType] FOREIGN KEY([contactTypeID])
REFERENCES [dbo].[st_contactType] ([contactInfoTypeId])
GO
ALTER TABLE [dbo].[st_userContactInfo] CHECK CONSTRAINT [FK_st_contactInfoPerUser_st_contactInfoType]
GO
ALTER TABLE [dbo].[st_userContactInfo]  WITH CHECK ADD  CONSTRAINT [FK_st_contactInfoPerUser_st_users] FOREIGN KEY([userId])
REFERENCES [dbo].[st_users] ([userID])
GO
ALTER TABLE [dbo].[st_userContactInfo] CHECK CONSTRAINT [FK_st_contactInfoPerUser_st_users]
GO
USE [master]
GO
ALTER DATABASE [Caso2DB] SET  READ_WRITE 
GO
