USE [master]
GO
/****** Object:  Database [FIAS_Praktika]    Script Date: 06.03.2025 0:26:02 ******/
CREATE DATABASE [FIAS_Praktika]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'FIAS_Praktika', FILENAME = N'C:\Users\Эмиль\FIAS_Praktika.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'FIAS_Praktika_log', FILENAME = N'C:\Users\Эмиль\FIAS_Praktika_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [FIAS_Praktika] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [FIAS_Praktika].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [FIAS_Praktika] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET ARITHABORT OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [FIAS_Praktika] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [FIAS_Praktika] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET  DISABLE_BROKER 
GO
ALTER DATABASE [FIAS_Praktika] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [FIAS_Praktika] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [FIAS_Praktika] SET  MULTI_USER 
GO
ALTER DATABASE [FIAS_Praktika] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [FIAS_Praktika] SET DB_CHAINING OFF 
GO
ALTER DATABASE [FIAS_Praktika] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [FIAS_Praktika] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [FIAS_Praktika] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [FIAS_Praktika] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [FIAS_Praktika] SET QUERY_STORE = OFF
GO
USE [FIAS_Praktika]
GO
/****** Object:  UserDefinedFunction [dbo].[ConcatAdresZayavka]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Функция 5: Формирование сводной строки из параметров адресной заявки (Adres_zayavka).
-- Функция принимает ID_adres и возвращает строку, объединяющую поля Parametr, Istoriya_znach и Aktual_znach.
--------------------------------------------------------------------
CREATE FUNCTION [dbo].[ConcatAdresZayavka]
(
    @ID_adres INT
)
RETURNS NVARCHAR(300)
AS
BEGIN
    DECLARE @result NVARCHAR(300);

    SELECT @result = CONCAT(
            'Параметр: ', Parametr, '; ',
            'История: ', Istoriya_znach, '; ',
            'Актуальное: ', Aktual_znach
        )
    FROM dbo.Adres_zayavka
    WHERE ID_adres = @ID_adres;

    RETURN @result;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[DaysSinceGAR]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Функция 2: Вычисление количества дней, прошедших с момента внесения записи (Data_Vnesenia) в таблице GAR.
-- Функция возвращает число дней от даты внесения до текущей даты.
--------------------------------------------------------------------
CREATE FUNCTION [dbo].[DaysSinceGAR]
(
    @ID_GAR INT
)
RETURNS INT
AS
BEGIN
    DECLARE @days INT;

    SELECT @days = DATEDIFF(DAY, Data_Vnesenia, GETDATE())
    FROM dbo.GAR
    WHERE ID_GAR = @ID_GAR;

    RETURN @days;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[FullGARAddress]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------
-- Функция 1: Получение полного текстового адреса из записи GAR по ID_GAR.
-- Функция возвращает строку, составленную из муниципального отдела, административного отдела и кадастрового номера.
--------------------------------------------------------------------
CREATE FUNCTION [dbo].[FullGARAddress]
(
    @ID_GAR INT
)
RETURNS NVARCHAR(400)
AS
BEGIN
    DECLARE @result NVARCHAR(400);

    SELECT @result = CONCAT(
            Mun_otdel, ', ',
            Administr_otdel, ', Кадастровый номер: ',
            Kadastr_nom
        )
    FROM dbo.GAR
    WHERE ID_GAR = @ID_GAR;

    RETURN @result;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[LatestDocumentGAR]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Функция 4: Получение информации о последнем документе, привязанном к адресу (GAR).
-- Функция ищет в таблице GAR_Dok и связанной таблице Dokuments документ с самой поздней датой.
-- Возвращается строка с информацией о документе: ID, тип, дату и наименование.
--------------------------------------------------------------------
CREATE FUNCTION [dbo].[LatestDocumentGAR]
(
    @ID_GAR INT
)
RETURNS NVARCHAR(400)
AS
BEGIN
    DECLARE @docInfo NVARCHAR(400);

    SELECT TOP 1 @docInfo = CONCAT(
            'Документ ID: ', CONVERT(NVARCHAR(10), d.ID_Dok), '; ',
            'Тип: ', d.Type_Dok, '; ',
            'Дата: ', CONVERT(NVARCHAR(10), d.Date_Dok, 120), '; ',
            'Наименование: ', d.Naimenovanie
        )
    FROM dbo.GAR_Dok gd
    INNER JOIN dbo.Dokuments d ON gd.ID_Dok = d.ID_Dok
    WHERE gd.ID_GAR = @ID_GAR
    ORDER BY d.Date_Dok DESC;

    RETURN @docInfo;
END;
GO
/****** Object:  UserDefinedFunction [dbo].[ZayavkaCountEmployee]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Функция 3: Подсчёт количества заявок (Zayavka), созданных указанным сотрудником.
-- Функция принимает ID сотрудника и возвращает число заявок, где поле Sozdatel_zayav соответствует заданному ID.
--------------------------------------------------------------------
CREATE FUNCTION [dbo].[ZayavkaCountEmployee]
(
    @ID_Empl INT
)
RETURNS INT
AS
BEGIN
    DECLARE @cnt INT;

    SELECT @cnt = COUNT(*)
    FROM dbo.Zayavka
    WHERE Sozdatel_zayav = @ID_Empl;

    RETURN @cnt;
END;
GO
/****** Object:  Table [dbo].[Dokuments]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Dokuments](
	[ID_Dok] [int] NOT NULL,
	[Type_Dok] [nvarchar](100) NULL,
	[Date_Dok] [date] NULL,
	[Naimenovanie] [nvarchar](200) NULL,
 CONSTRAINT [PK__Dokument__2BBC7EB8D1F164FC] PRIMARY KEY CLUSTERED 
(
	[ID_Dok] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[adres_objects]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[adres_objects](
	[ID_GAR] [int] NOT NULL,
	[Naimenovanie] [nvarchar](150) NULL,
	[Nalog_ID] [int] NOT NULL,
	[ID_KLADR] [int] NOT NULL,
 CONSTRAINT [PK__adres_ob__2EC80BD40D29FD40] PRIMARY KEY CLUSTERED 
(
	[ID_GAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GAR_Dok]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GAR_Dok](
	[ID_GAR] [int] NOT NULL,
	[ID_Dok] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID_GAR] ASC,
	[ID_Dok] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[History_adres]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[History_adres](
	[ID_change] [int] IDENTITY(1,1) NOT NULL,
	[ID_GAR] [int] NULL,
	[Period_deistviya] [nvarchar](100) NULL,
	[Stroka_adres] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK__History___5A674AE1DF070D21] PRIMARY KEY CLUSTERED 
(
	[ID_change] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GAR]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GAR](
	[ID_GAR] [int] NOT NULL,
	[Mun_otdel] [nvarchar](200) NOT NULL,
	[Administr_otdel] [nvarchar](200) NOT NULL,
	[IFNSL_FL] [int] NOT NULL,
	[IFNSL_YL] [int] NOT NULL,
	[OKATO] [int] NOT NULL,
	[OKTMO] [int] NOT NULL,
	[Pochta_Index] [int] NOT NULL,
	[ID_Reestr] [int] NOT NULL,
	[Kadastr_nom] [nvarchar](50) NOT NULL,
	[Status_zap] [nvarchar](50) NOT NULL,
	[Data_Vnesenia] [date] NOT NULL,
	[Data_aktual] [date] NOT NULL,
 CONSTRAINT [PK__GAR__2EC80BD4CBD82864] PRIMARY KEY CLUSTERED 
(
	[ID_GAR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[FullGAR]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------
-- Представление 1: Полная информация об адресном объекте (GAR) с данными из связанных таблиц
-- Объединяет данные из таблиц: GAR, adres_objects, History_adres и связанные документы через GAR_Dok и Dokuments.
--------------------------------------------------------------------
CREATE VIEW [dbo].[FullGAR] AS
SELECT 
    g.ID_GAR,
    g.Mun_otdel,
    g.Administr_otdel,
    g.IFNSL_FL,
    g.IFNSL_YL,
    g.OKATO,
    g.OKTMO,
    g.Pochta_Index,
    g.ID_Reestr,
    g.Kadastr_nom,
    g.Status_zap,
    g.Data_Vnesenia,
    g.Data_aktual,
    ao.Naimenovanie AS FullAddress,
    ao.Nalog_ID,
    ao.ID_KLADR,
    ha.Period_deistviya,
    ha.Stroka_adres,
    d.ID_Dok,
    d.Type_Dok,
    d.Date_Dok,
    d.Naimenovanie AS DocumentName
FROM dbo.GAR g
    LEFT JOIN dbo.adres_objects ao ON g.ID_GAR = ao.ID_GAR
    LEFT JOIN dbo.History_adres ha ON g.ID_GAR = ha.ID_GAR
    LEFT JOIN dbo.GAR_Dok gd ON g.ID_GAR = gd.ID_GAR
    LEFT JOIN dbo.Dokuments d ON gd.ID_Dok = d.ID_Dok;
GO
/****** Object:  Table [dbo].[Zayavka]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Zayavka](
	[ID_zayavki] [int] IDENTITY(1,1) NOT NULL,
	[Type_zayavki] [nvarchar](100) NULL,
	[Uroven] [nvarchar](100) NULL,
	[ID_GAR] [int] NULL,
	[Sozdatel_zayav] [int] NULL,
	[Data_sozdaniya] [date] NOT NULL,
	[Data_sozd2] [date] NOT NULL,
 CONSTRAINT [PK__Zayavka__60647E38721D15A9] PRIMARY KEY CLUSTERED 
(
	[ID_zayavki] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[ID_Empl] [int] NOT NULL,
	[FIO] [nvarchar](100) NOT NULL,
	[Phone] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](100) NULL,
 CONSTRAINT [PK__Employee__3386991744A1115B] PRIMARY KEY CLUSTERED 
(
	[ID_Empl] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Istor_izmen]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Istor_izmen](
	[ID_Izm] [int] IDENTITY(1,1) NOT NULL,
	[ID_GAR] [int] NULL,
	[Data_izmen] [date] NULL,
	[Type_izmen] [nvarchar](150) NULL,
	[ID_adres] [int] NULL,
 CONSTRAINT [PK__Istor_iz__2C42E25284831AF8] PRIMARY KEY CLUSTERED 
(
	[ID_Izm] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[ZayavkaDetails]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Представление 2: Детальная информация по заявке (Zayavka)
-- Объединяет данные из заявок, связанных адресных объектов, сотрудников, а также агрегирует
-- информацию о количестве изменений и последнем документе, связанном с адресом.
--------------------------------------------------------------------
CREATE VIEW [dbo].[ZayavkaDetails] AS
SELECT 
    z.ID_zayavki,
    z.Type_zayavki,
    z.Uroven,
    z.Data_sozdaniya,
    z.Data_sozd2,
    g.Kadastr_nom,
    g.Mun_otdel,
    g.Administr_otdel,
    e.FIO,
    e.Phone,
    e.Email,
    -- Подсчет количества записей об изменениях, связанных с данным адресом
    (SELECT COUNT(*) FROM dbo.Istor_izmen i WHERE i.ID_GAR = z.ID_GAR) AS ChangeCount,
    -- Последний по дате документ, связанный с адресом
    (SELECT TOP 1 d.Type_Dok 
     FROM dbo.GAR_Dok gd 
     INNER JOIN dbo.Dokuments d ON gd.ID_Dok = d.ID_Dok 
     WHERE gd.ID_GAR = z.ID_GAR 
     ORDER BY d.Date_Dok DESC) AS LatestDocumentType,
    (SELECT TOP 1 d.Naimenovanie 
     FROM dbo.GAR_Dok gd 
     INNER JOIN dbo.Dokuments d ON gd.ID_Dok = d.ID_Dok 
     WHERE gd.ID_GAR = z.ID_GAR 
     ORDER BY d.Date_Dok DESC) AS LatestDocumentName
FROM dbo.Zayavka z
    LEFT JOIN dbo.GAR g ON z.ID_GAR = g.ID_GAR
    LEFT JOIN dbo.Employees e ON z.Sozdatel_zayav = e.ID_Empl;
GO
/****** Object:  View [dbo].[EmployeeActivity]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Представление 3: Активность сотрудников по созданным заявкам
-- Для каждого сотрудника выводится общее количество созданных заявок и дата последней заявки.
--------------------------------------------------------------------
CREATE VIEW [dbo].[EmployeeActivity] AS
SELECT 
    e.ID_Empl,
    e.FIO,
    e.Phone,
    e.Email,
    COUNT(z.ID_zayavki) AS TotalApplications,
    MAX(z.Data_sozdaniya) AS LastApplicationDate
FROM dbo.Employees e
    LEFT JOIN dbo.Zayavka z ON e.ID_Empl = z.Sozdatel_zayav
GROUP BY e.ID_Empl, e.FIO, e.Phone, e.Email;
GO
/****** Object:  Table [dbo].[Adres_zayavka]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Adres_zayavka](
	[ID_adres] [int] IDENTITY(1,1) NOT NULL,
	[Parametr] [nvarchar](100) NOT NULL,
	[Istoriya_znach] [nvarchar](100) NULL,
	[Aktual_znach] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK__Adres_za__AD91EFC51B673D64] PRIMARY KEY CLUSTERED 
(
	[ID_adres] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[AdresZayavkaProsm]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Представление 4: Сводная информация по адресным заявкам
-- Объединяет данные из таблиц Adres_zayavka, Istor_izmen и GAR для отображения истории изменений
-- адресных параметров с информацией о соответствующем адресном объекте.
--------------------------------------------------------------------
CREATE VIEW [dbo].[AdresZayavkaProsm] AS
SELECT 
    az.ID_adres,
    az.Parametr,
    az.Istoriya_znach,
    az.Aktual_znach,
    i.Data_izmen,
    i.Type_izmen,
    g.ID_GAR,
    g.Kadastr_nom,
    g.Mun_otdel,
    g.Administr_otdel
FROM dbo.Adres_zayavka az
    LEFT JOIN dbo.Istor_izmen i ON az.ID_adres = i.ID_adres
    LEFT JOIN dbo.GAR g ON i.ID_GAR = g.ID_GAR;
GO
/****** Object:  Table [dbo].[Uvedomleniya]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Uvedomleniya](
	[ID_Uved] [int] IDENTITY(1,1) NOT NULL,
	[ID_Zayavki] [int] NULL,
	[Type_uved] [nvarchar](100) NULL,
	[Status_uved] [nvarchar](100) NULL,
	[Data_ispoln_1] [date] NULL,
	[Data_ispoln_2] [date] NULL,
	[Data_podpis_1] [date] NULL,
	[Data_pospis_2] [date] NULL,
	[Data_ozhid_ispoln] [date] NULL,
	[Kommentarii] [nvarchar](150) NULL,
	[Prichina_otkaza] [nvarchar](150) NULL,
 CONSTRAINT [PK__Uvedomle__ED77124BB0E524E2] PRIMARY KEY CLUSTERED 
(
	[ID_Uved] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[UvedProsm]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Представление 5: Обзор уведомлений по заявкам
-- Объединяет данные уведомлений, заявок, сотрудников и адресных объектов для создания
-- комплексного обзора статусов и сроков исполнения уведомлений.
--------------------------------------------------------------------
CREATE VIEW [dbo].[UvedProsm] AS
SELECT 
    u.ID_Uved,
    u.ID_Zayavki,
    z.Type_zayavki,
    z.Uroven,
    u.Type_uved,
    u.Status_uved,
    u.Data_ispoln_1,
    u.Data_ispoln_2,
    u.Data_podpis_1,
    u.Data_pospis_2,
    u.Data_ozhid_ispoln,
    u.Kommentarii,
    u.Prichina_otkaza,
    e.FIO AS CreatorName,
    e.Email AS CreatorEmail,
    g.Kadastr_nom,
    g.Mun_otdel
FROM dbo.Uvedomleniya u
    LEFT JOIN dbo.Zayavka z ON u.ID_Zayavki = z.ID_zayavki
    LEFT JOIN dbo.Employees e ON z.Sozdatel_zayav = e.ID_Empl
    LEFT JOIN dbo.GAR g ON z.ID_GAR = g.ID_GAR;
GO
/****** Object:  Table [dbo].[Type_status]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Type_status](
	[Status_uved] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK__Type_sta__AF2152A53F4C5376] PRIMARY KEY CLUSTERED 
(
	[Status_uved] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Type_uved]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Type_uved](
	[Type_uvedom] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK__Type_uve__70A38F4772775F56] PRIMARY KEY CLUSTERED 
(
	[Type_uvedom] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Type_zayavki]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Type_zayavki](
	[Type_zayavki] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK__Type_zay__72A54E93364CDA2D] PRIMARY KEY CLUSTERED 
(
	[Type_zayavki] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
INSERT [dbo].[adres_objects] ([ID_GAR], [Naimenovanie], [Nalog_ID], [ID_KLADR]) VALUES (10, N'г. Москва, ул. Арбат, д.12', 9001, 8001)
INSERT [dbo].[adres_objects] ([ID_GAR], [Naimenovanie], [Nalog_ID], [ID_KLADR]) VALUES (20, N'г. Санкт-Петербург, пр. Невский, д.28', 9002, 8002)
INSERT [dbo].[adres_objects] ([ID_GAR], [Naimenovanie], [Nalog_ID], [ID_KLADR]) VALUES (30, N'г. Казань, ул. Баумана, д.5', 9003, 8003)
INSERT [dbo].[adres_objects] ([ID_GAR], [Naimenovanie], [Nalog_ID], [ID_KLADR]) VALUES (40, N'г. Новосибирск, ул. Ленина, д.3', 9004, 8004)
INSERT [dbo].[adres_objects] ([ID_GAR], [Naimenovanie], [Nalog_ID], [ID_KLADR]) VALUES (50, N'г. Екатеринбург, ул. Мира, д.18', 9005, 8005)
INSERT [dbo].[adres_objects] ([ID_GAR], [Naimenovanie], [Nalog_ID], [ID_KLADR]) VALUES (60, N'г. Ростов, ул. Ленина, д.15', 9010, 8101)
INSERT [dbo].[adres_objects] ([ID_GAR], [Naimenovanie], [Nalog_ID], [ID_KLADR]) VALUES (70, N'г. Самара, ул. Советская, д.22', 9011, 8102)
INSERT [dbo].[adres_objects] ([ID_GAR], [Naimenovanie], [Nalog_ID], [ID_KLADR]) VALUES (80, N'г. Уфа, пр. Октября, д.30', 9012, 8103)
INSERT [dbo].[adres_objects] ([ID_GAR], [Naimenovanie], [Nalog_ID], [ID_KLADR]) VALUES (90, N'г. Краснодар, ул. Южная, д.7', 9013, 8104)
INSERT [dbo].[adres_objects] ([ID_GAR], [Naimenovanie], [Nalog_ID], [ID_KLADR]) VALUES (100, N'г. Воронеж, ул. Победы, д.9', 9014, 8105)
GO
SET IDENTITY_INSERT [dbo].[Adres_zayavka] ON 

INSERT [dbo].[Adres_zayavka] ([ID_adres], [Parametr], [Istoriya_znach], [Aktual_znach]) VALUES (1022, N'Почтовый индекс', N'101000', N'101001')
INSERT [dbo].[Adres_zayavka] ([ID_adres], [Parametr], [Istoriya_znach], [Aktual_znach]) VALUES (1023, N'Тип здания', N'Жилой', N'Коммерческий')
INSERT [dbo].[Adres_zayavka] ([ID_adres], [Parametr], [Istoriya_znach], [Aktual_znach]) VALUES (1024, N'Номер корпуса', N'1', N'2')
INSERT [dbo].[Adres_zayavka] ([ID_adres], [Parametr], [Istoriya_znach], [Aktual_znach]) VALUES (1025, N'Этаж', N'3', N'4')
INSERT [dbo].[Adres_zayavka] ([ID_adres], [Parametr], [Istoriya_znach], [Aktual_znach]) VALUES (1026, N'Тип постройки', N'Кирпичный', N'Панельный')
INSERT [dbo].[Adres_zayavka] ([ID_adres], [Parametr], [Istoriya_znach], [Aktual_znach]) VALUES (1027, N'Тип местности', N'Городская', N'Пригородная')
INSERT [dbo].[Adres_zayavka] ([ID_adres], [Parametr], [Istoriya_znach], [Aktual_znach]) VALUES (1028, N'Состояние здания', N'Новое', N'Требует ремонта')
INSERT [dbo].[Adres_zayavka] ([ID_adres], [Parametr], [Istoriya_znach], [Aktual_znach]) VALUES (1029, N'Наличие лифта', N'Есть', N'Нет')
INSERT [dbo].[Adres_zayavka] ([ID_adres], [Parametr], [Istoriya_znach], [Aktual_znach]) VALUES (1030, N'Материал стен', N'Бетон', N'Кирпич')
INSERT [dbo].[Adres_zayavka] ([ID_adres], [Parametr], [Istoriya_znach], [Aktual_znach]) VALUES (1031, N'Назначение здания', N'Жилое', N'Коммерческое')
SET IDENTITY_INSERT [dbo].[Adres_zayavka] OFF
GO
INSERT [dbo].[Dokuments] ([ID_Dok], [Type_Dok], [Date_Dok], [Naimenovanie]) VALUES (101, N'Свидетельство', CAST(N'2015-04-15' AS Date), N'Свидетельство о регистрации ИП')
INSERT [dbo].[Dokuments] ([ID_Dok], [Type_Dok], [Date_Dok], [Naimenovanie]) VALUES (102, N'Договор', CAST(N'2017-09-20' AS Date), N'Договор купли-продажи недвижимости')
INSERT [dbo].[Dokuments] ([ID_Dok], [Type_Dok], [Date_Dok], [Naimenovanie]) VALUES (103, N'Акт', CAST(N'2018-12-05' AS Date), N'Акт ввода в эксплуатацию')
INSERT [dbo].[Dokuments] ([ID_Dok], [Type_Dok], [Date_Dok], [Naimenovanie]) VALUES (104, N'Справка', CAST(N'2016-07-10' AS Date), N'Справка об объектах недвижимости')
INSERT [dbo].[Dokuments] ([ID_Dok], [Type_Dok], [Date_Dok], [Naimenovanie]) VALUES (105, N'Лицензия', CAST(N'2019-03-25' AS Date), N'Лицензия на строительство')
INSERT [dbo].[Dokuments] ([ID_Dok], [Type_Dok], [Date_Dok], [Naimenovanie]) VALUES (106, N'Сертификат', CAST(N'2020-05-20' AS Date), N'Сертификат соответствия')
INSERT [dbo].[Dokuments] ([ID_Dok], [Type_Dok], [Date_Dok], [Naimenovanie]) VALUES (107, N'Договор аренды', CAST(N'2021-08-10' AS Date), N'Договор аренды офиса')
INSERT [dbo].[Dokuments] ([ID_Dok], [Type_Dok], [Date_Dok], [Naimenovanie]) VALUES (108, N'Приказ', CAST(N'2022-01-15' AS Date), N'Приказ о назначениииии')
INSERT [dbo].[Dokuments] ([ID_Dok], [Type_Dok], [Date_Dok], [Naimenovanie]) VALUES (109, N'Акт', CAST(N'2022-06-30' AS Date), N'Акт сверки взаиморасчетов')
INSERT [dbo].[Dokuments] ([ID_Dok], [Type_Dok], [Date_Dok], [Naimenovanie]) VALUES (110, N'Протокол', CAST(N'2023-03-05' AS Date), N'Протокол собрания акционеровпппппвап')
GO
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (1, N'Александр Смирнов Иванович', N'79171234567', N'a.smirnov@example.ru')
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (2, N'Мария Иванова Владимировна', N'79177654321', N'm.ivanova@example.ru')
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (3, N'Дмитрий Кузнецов Сидорович', N'79179887766', N'd.kuznecov@example.ru')
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (4, N'Екатерина Петрова Антоновна', N'79175554433', N'e.petrova@example.ru')
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (5, N'Сергей Соколов Римович', N'79173332211', N's.sokolov@example.ru')
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (6, N'Иван Петров Сергеевичччч', N'79170001122', N'i.petrov@example.ru')
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (7, N'Ольга Николаева Михайловна', N'79170002233', N'o.nikolaeva@example.ru')
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (8, N'Владимир Федоров Романов', N'79170003344', N'v.romanov@example.ru')
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (9, N'Наталья Андреевна Сергеева', N'79170004455', N'n.sergeeva@example.ru')
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (10, N'Михаил Васильевич Григорьев', N'79170005566', N'm.grigoriev@example.com')
INSERT [dbo].[Employees] ([ID_Empl], [FIO], [Phone], [Email]) VALUES (15, N'Мухияров Ксения Чеевна', N'+89177961997', N'rimkatimka2@mail.ru')
GO
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (10, N'Мосгоротдел №1', N'Администрация г. Москва', 4501, 4601, 770000000, 770000000, 101000, 1001, N'77:01:000001:0', N'Активен', CAST(N'2010-01-01' AS Date), CAST(N'2024-01-01' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (20, N'СПБотдел №2', N'Администрация г. Санкт-Петербург', 4502, 4602, 780000000, 780000000, 190000, 1002, N'78:02:000002:0', N'Активен', CAST(N'2011-02-15' AS Date), CAST(N'2024-02-15' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (23, N'234', N'234', 2344, 3434, 788888343, 788884355, 23423, 234, N'234', N'234', CAST(N'2025-03-05' AS Date), CAST(N'2025-03-15' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (30, N'Казаньотдел №3', N'Администрация г. Казань', 4503, 4603, 790000000, 790000000, 420000, 1003, N'79:03:000003:0', N'Активен', CAST(N'2012-03-20' AS Date), CAST(N'2024-03-20' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (32, N'ывыв', N'ываыва', 3243, 2334, 234234343, 423443421, 1223, 23, N'123', N'ыва', CAST(N'2025-03-03' AS Date), CAST(N'2025-03-14' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (40, N'Новосибирскотдел №4', N'Администрация г. Новосибирск', 4504, 4604, 800000000, 800000000, 630000, 1004, N'80:04:000004:0', N'Неактивен', CAST(N'2013-04-25' AS Date), CAST(N'2024-04-25' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (50, N'Екатеринбурготдел №5', N'Администрация г. Екатеринбург', 4505, 4605, 810000000, 810000000, 620000, 1005, N'81:05:000005:0', N'Активен', CAST(N'2014-05-30' AS Date), CAST(N'2024-05-30' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (60, N'Ростовотдел №6', N'Администрация г. Ростов', 4506, 4606, 820000000, 820000000, 344000, 1006, N'82:06:000006:0', N'Активен', CAST(N'2015-02-01' AS Date), CAST(N'2025-02-01' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (70, N'Самаротдел №7', N'Администрация г. Самара', 4507, 4607, 830000000, 830000000, 443000, 1007, N'83:07:000007:0', N'Активен', CAST(N'2016-03-10' AS Date), CAST(N'2025-03-10' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (80, N'Уфимотдел №8', N'Администрация г. Уфа', 4508, 4608, 840000000, 840000000, 450000, 1008, N'84:08:000008:0', N'Активен', CAST(N'2017-04-15' AS Date), CAST(N'2025-04-15' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (90, N'Краснодаротдел №9', N'Администрация г. Краснодар', 4509, 4609, 850000000, 850000000, 350000, 1009, N'85:09:000009:0', N'Неактивен', CAST(N'2018-05-20' AS Date), CAST(N'2025-05-20' AS Date))
INSERT [dbo].[GAR] ([ID_GAR], [Mun_otdel], [Administr_otdel], [IFNSL_FL], [IFNSL_YL], [OKATO], [OKTMO], [Pochta_Index], [ID_Reestr], [Kadastr_nom], [Status_zap], [Data_Vnesenia], [Data_aktual]) VALUES (100, N'Воронежотдел №10', N'Администрация г. Воронеж', 4510, 4610, 860000000, 860000000, 394000, 1010, N'86:10:000010:0', N'Активен', CAST(N'2019-06-25' AS Date), CAST(N'2025-06-25' AS Date))
GO
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (10, 101)
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (10, 102)
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (20, 102)
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (30, 103)
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (40, 104)
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (50, 105)
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (60, 106)
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (70, 107)
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (80, 108)
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (90, 109)
INSERT [dbo].[GAR_Dok] ([ID_GAR], [ID_Dok]) VALUES (100, 110)
GO
SET IDENTITY_INSERT [dbo].[History_adres] ON 

INSERT [dbo].[History_adres] ([ID_change], [ID_GAR], [Period_deistviya], [Stroka_adres]) VALUES (1, 10, N'2000-2010', N'г. Москва, ул. Тверская, д.8')
INSERT [dbo].[History_adres] ([ID_change], [ID_GAR], [Period_deistviya], [Stroka_adres]) VALUES (2, 20, N'2005-2015', N'г. Санкт-Петербург, ул. Марата, д.22')
INSERT [dbo].[History_adres] ([ID_change], [ID_GAR], [Period_deistviya], [Stroka_adres]) VALUES (3, 30, N'2010-2020', N'г. Казань, ул. Кремлевская, д.3')
INSERT [dbo].[History_adres] ([ID_change], [ID_GAR], [Period_deistviya], [Stroka_adres]) VALUES (4, 40, N'2008-2018', N'г. Новосибирск, ул. Советская, д.15')
INSERT [dbo].[History_adres] ([ID_change], [ID_GAR], [Period_deistviya], [Stroka_adres]) VALUES (5, 50, N'2012-2022', N'г. Екатеринбург, ул. Гагарина, д.7')
INSERT [dbo].[History_adres] ([ID_change], [ID_GAR], [Period_deistviya], [Stroka_adres]) VALUES (6, 60, N'2010-2020', N'г. Ростов, ул. Советская, д.20')
INSERT [dbo].[History_adres] ([ID_change], [ID_GAR], [Period_deistviya], [Stroka_adres]) VALUES (7, 70, N'2011-2021', N'г. Самара, пр. Ленина, д.5')
INSERT [dbo].[History_adres] ([ID_change], [ID_GAR], [Period_deistviya], [Stroka_adres]) VALUES (8, 80, N'2012-2022', N'г. Уфа, ул. Пушкина, д.12')
INSERT [dbo].[History_adres] ([ID_change], [ID_GAR], [Period_deistviya], [Stroka_adres]) VALUES (9, 90, N'2013-2023', N'г. Краснодар, ул. Гагарина, д.3')
INSERT [dbo].[History_adres] ([ID_change], [ID_GAR], [Period_deistviya], [Stroka_adres]) VALUES (10, 100, N'2014-2024', N'г. Воронеж, ул. Кирова, д.10')
SET IDENTITY_INSERT [dbo].[History_adres] OFF
GO
SET IDENTITY_INSERT [dbo].[Istor_izmen] ON 

INSERT [dbo].[Istor_izmen] ([ID_Izm], [ID_GAR], [Data_izmen], [Type_izmen], [ID_adres]) VALUES (3, 10, CAST(N'2023-06-01' AS Date), N'Обновление сведений', 1022)
INSERT [dbo].[Istor_izmen] ([ID_Izm], [ID_GAR], [Data_izmen], [Type_izmen], [ID_adres]) VALUES (4, 20, CAST(N'2023-06-15' AS Date), N'Корректировка адреса', 1023)
INSERT [dbo].[Istor_izmen] ([ID_Izm], [ID_GAR], [Data_izmen], [Type_izmen], [ID_adres]) VALUES (5, 30, CAST(N'2023-07-10' AS Date), N'Исправление ошибки', 1024)
INSERT [dbo].[Istor_izmen] ([ID_Izm], [ID_GAR], [Data_izmen], [Type_izmen], [ID_adres]) VALUES (6, 40, CAST(N'2023-07-25' AS Date), N'Дополнение информации', 1025)
INSERT [dbo].[Istor_izmen] ([ID_Izm], [ID_GAR], [Data_izmen], [Type_izmen], [ID_adres]) VALUES (7, 50, CAST(N'2023-08-05' AS Date), N'Актуализация данных', 1026)
INSERT [dbo].[Istor_izmen] ([ID_Izm], [ID_GAR], [Data_izmen], [Type_izmen], [ID_adres]) VALUES (8, 60, CAST(N'2024-07-15' AS Date), N'Изменение параметров', 1027)
INSERT [dbo].[Istor_izmen] ([ID_Izm], [ID_GAR], [Data_izmen], [Type_izmen], [ID_adres]) VALUES (9, 70, CAST(N'2024-08-20' AS Date), N'Обновление адресных данных', 1028)
INSERT [dbo].[Istor_izmen] ([ID_Izm], [ID_GAR], [Data_izmen], [Type_izmen], [ID_adres]) VALUES (10, 80, CAST(N'2024-09-25' AS Date), N'Корректировка сведений', 1030)
INSERT [dbo].[Istor_izmen] ([ID_Izm], [ID_GAR], [Data_izmen], [Type_izmen], [ID_adres]) VALUES (11, 90, CAST(N'2024-10-30' AS Date), N'Дополнение информации', 1029)
INSERT [dbo].[Istor_izmen] ([ID_Izm], [ID_GAR], [Data_izmen], [Type_izmen], [ID_adres]) VALUES (12, 100, CAST(N'2024-11-05' AS Date), N'Актуализация адреса', 1031)
SET IDENTITY_INSERT [dbo].[Istor_izmen] OFF
GO
INSERT [dbo].[Type_status] ([Status_uved]) VALUES (N'В работе')
INSERT [dbo].[Type_status] ([Status_uved]) VALUES (N'Исполнен')
INSERT [dbo].[Type_status] ([Status_uved]) VALUES (N'Новый')
INSERT [dbo].[Type_status] ([Status_uved]) VALUES (N'Отклонён')
INSERT [dbo].[Type_status] ([Status_uved]) VALUES (N'Отложен')
GO
INSERT [dbo].[Type_uved] ([Type_uvedom]) VALUES (N'Личное')
INSERT [dbo].[Type_uved] ([Type_uvedom]) VALUES (N'Письменное')
INSERT [dbo].[Type_uved] ([Type_uvedom]) VALUES (N'Телефонное')
INSERT [dbo].[Type_uved] ([Type_uvedom]) VALUES (N'Факс')
INSERT [dbo].[Type_uved] ([Type_uvedom]) VALUES (N'Электронное')
GO
INSERT [dbo].[Type_zayavki] ([Type_zayavki]) VALUES (N'Активация')
INSERT [dbo].[Type_zayavki] ([Type_zayavki]) VALUES (N'Изменение')
INSERT [dbo].[Type_zayavki] ([Type_zayavki]) VALUES (N'Корректировка')
INSERT [dbo].[Type_zayavki] ([Type_zayavki]) VALUES (N'Регистрация')
INSERT [dbo].[Type_zayavki] ([Type_zayavki]) VALUES (N'Удаление')
GO
SET IDENTITY_INSERT [dbo].[Uvedomleniya] ON 

INSERT [dbo].[Uvedomleniya] ([ID_Uved], [ID_Zayavki], [Type_uved], [Status_uved], [Data_ispoln_1], [Data_ispoln_2], [Data_podpis_1], [Data_pospis_2], [Data_ozhid_ispoln], [Kommentarii], [Prichina_otkaza]) VALUES (1, 1, N'Электронное', N'Новый', CAST(N'2024-01-12' AS Date), CAST(N'2024-01-13' AS Date), CAST(N'2024-01-14' AS Date), CAST(N'2024-01-15' AS Date), CAST(N'2024-01-16' AS Date), N'Уведомление создано', NULL)
INSERT [dbo].[Uvedomleniya] ([ID_Uved], [ID_Zayavki], [Type_uved], [Status_uved], [Data_ispoln_1], [Data_ispoln_2], [Data_podpis_1], [Data_pospis_2], [Data_ozhid_ispoln], [Kommentarii], [Prichina_otkaza]) VALUES (2, 2, N'Письменное', N'В работе', CAST(N'2024-02-14' AS Date), CAST(N'2024-02-15' AS Date), CAST(N'2024-02-16' AS Date), CAST(N'2024-02-17' AS Date), CAST(N'2024-02-18' AS Date), N'Документы переданы на проверку', NULL)
INSERT [dbo].[Uvedomleniya] ([ID_Uved], [ID_Zayavki], [Type_uved], [Status_uved], [Data_ispoln_1], [Data_ispoln_2], [Data_podpis_1], [Data_pospis_2], [Data_ozhid_ispoln], [Kommentarii], [Prichina_otkaza]) VALUES (3, 3, N'Телефонное', N'Исполнен', CAST(N'2024-03-16' AS Date), CAST(N'2024-03-17' AS Date), CAST(N'2024-03-18' AS Date), CAST(N'2024-03-19' AS Date), CAST(N'2024-03-20' AS Date), N'Заявка выполнена успешно', NULL)
INSERT [dbo].[Uvedomleniya] ([ID_Uved], [ID_Zayavki], [Type_uved], [Status_uved], [Data_ispoln_1], [Data_ispoln_2], [Data_podpis_1], [Data_pospis_2], [Data_ozhid_ispoln], [Kommentarii], [Prichina_otkaza]) VALUES (4, 4, N'Личное', N'Отклонён', CAST(N'2024-04-18' AS Date), CAST(N'2024-04-19' AS Date), CAST(N'2024-04-20' AS Date), CAST(N'2024-04-21' AS Date), CAST(N'2024-04-22' AS Date), N'Неверная информация', N'Ошибка заполнения')
INSERT [dbo].[Uvedomleniya] ([ID_Uved], [ID_Zayavki], [Type_uved], [Status_uved], [Data_ispoln_1], [Data_ispoln_2], [Data_podpis_1], [Data_pospis_2], [Data_ozhid_ispoln], [Kommentarii], [Prichina_otkaza]) VALUES (5, 5, N'Факс', N'Отложен', CAST(N'2024-05-20' AS Date), CAST(N'2024-05-21' AS Date), CAST(N'2024-05-22' AS Date), CAST(N'2024-05-23' AS Date), CAST(N'2024-05-24' AS Date), N'Ожидание уточнения данныхkkkkk', N'Недостаточные документы')
SET IDENTITY_INSERT [dbo].[Uvedomleniya] OFF
GO
SET IDENTITY_INSERT [dbo].[Zayavka] ON 

INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1, N'Регистрация', N'Высокий', 10, 1, CAST(N'2024-01-10' AS Date), CAST(N'2024-01-11' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (2, N'Изменение', N'Средний', 20, 2, CAST(N'2024-02-12' AS Date), CAST(N'2024-02-13' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (3, N'Удаление', N'Низкий', 30, 3, CAST(N'2024-03-14' AS Date), CAST(N'2024-03-15' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (4, N'Корректировка', N'Средний', 40, 4, CAST(N'2024-04-16' AS Date), CAST(N'2024-04-17' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (5, N'Активация', N'Высокий', 50, 5, CAST(N'2024-05-18' AS Date), CAST(N'2024-05-19' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (7, N'Регистрация', N'Средний', 60, 6, CAST(N'2025-07-01' AS Date), CAST(N'2025-07-02' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (8, N'Изменение', N'Низкий', 70, 7, CAST(N'2025-08-03' AS Date), CAST(N'2025-08-04' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (9, N'Удаление', N'Высокий', 80, 8, CAST(N'2025-09-05' AS Date), CAST(N'2025-09-06' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (10, N'Корректировка', N'Средний', 90, 9, CAST(N'2024-10-07' AS Date), CAST(N'2025-10-08' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (11, N'Активация', N'Высокий', 100, 10, CAST(N'2024-11-09' AS Date), CAST(N'2025-11-10' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1042, N'Регистрация', N'Высокий', 10, 1, CAST(N'2023-03-05' AS Date), CAST(N'2023-03-06' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1043, N'Изменение', N'Средний', 20, 2, CAST(N'2023-04-10' AS Date), CAST(N'2023-04-11' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1044, N'Удаление', N'Низкий', 30, 3, CAST(N'2023-05-15' AS Date), CAST(N'2023-05-16' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1045, N'Корректировка', N'Средний', 40, 4, CAST(N'2023-06-20' AS Date), CAST(N'2023-06-21' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1046, N'Активация', N'Высокий', 50, 5, CAST(N'2023-07-25' AS Date), CAST(N'2023-07-26' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1047, N'Регистрация', N'Средний', 60, 6, CAST(N'2023-08-30' AS Date), CAST(N'2023-08-31' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1048, N'Изменение', N'Низкий', 70, 7, CAST(N'2023-09-05' AS Date), CAST(N'2023-09-06' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1049, N'Удаление', N'Высокий', 80, 8, CAST(N'2023-10-10' AS Date), CAST(N'2023-10-11' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1050, N'Корректировка', N'Средний', 90, 9, CAST(N'2023-11-15' AS Date), CAST(N'2023-11-16' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1051, N'Активация', N'Высокий', 100, 10, CAST(N'2023-12-20' AS Date), CAST(N'2023-12-21' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1052, N'Регистрация', N'Высокий', 20, 3, CAST(N'2024-01-05' AS Date), CAST(N'2024-01-06' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1053, N'Изменение', N'Средний', 30, 5, CAST(N'2024-02-10' AS Date), CAST(N'2024-02-11' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1054, N'Удаление', N'Низкий', 40, 7, CAST(N'2024-03-15' AS Date), CAST(N'2024-03-16' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1055, N'Корректировка', N'Средний', 50, 2, CAST(N'2024-04-20' AS Date), CAST(N'2024-04-21' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1056, N'Активация', N'Высокий', 60, 4, CAST(N'2024-05-25' AS Date), CAST(N'2024-05-26' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1057, N'Регистрация', N'Средний', 70, 6, CAST(N'2024-06-30' AS Date), CAST(N'2024-07-01' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1058, N'Изменение', N'Низкий', 80, 8, CAST(N'2024-07-05' AS Date), CAST(N'2024-07-06' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1059, N'Удаление', N'Высокий', 90, 9, CAST(N'2024-08-10' AS Date), CAST(N'2024-08-11' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1060, N'Корректировка', N'Средний', 100, 10, CAST(N'2024-09-15' AS Date), CAST(N'2024-09-16' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1061, N'Активация', N'Высокий', 10, 1, CAST(N'2024-10-20' AS Date), CAST(N'2024-10-21' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1077, N'Регистрация', N'Высокий', 30, 2, CAST(N'2024-11-01' AS Date), CAST(N'2024-11-02' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1078, N'Изменение', N'Средний', 40, 3, CAST(N'2024-11-05' AS Date), CAST(N'2024-11-06' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1079, N'Удаление', N'Низкий', 50, 4, CAST(N'2024-11-10' AS Date), CAST(N'2024-11-11' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1080, N'Активация', N'Высокий', 60, 5, CAST(N'2024-11-15' AS Date), CAST(N'2024-11-16' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1081, N'Корректировка', N'Средний', 70, 6, CAST(N'2024-11-20' AS Date), CAST(N'2024-11-21' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1082, N'Регистрация', N'Низкий', 80, 7, CAST(N'2024-11-25' AS Date), CAST(N'2024-11-26' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1083, N'Удаление', N'Средний', 90, 8, CAST(N'2024-11-28' AS Date), CAST(N'2024-11-29' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1084, N'Активация', N'Высокий', 100, 9, CAST(N'2024-12-01' AS Date), CAST(N'2024-12-02' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1085, N'Корректировка', N'Низкий', 10, 10, CAST(N'2024-12-05' AS Date), CAST(N'2024-12-06' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1087, N'Регистрация', N'Средний', 30, 2, CAST(N'2024-12-10' AS Date), CAST(N'2024-12-11' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1088, N'Активация', N'Низкий', 40, 3, CAST(N'2024-12-12' AS Date), CAST(N'2024-12-13' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1089, N'Удаление', N'Высокий', 50, 4, CAST(N'2024-12-15' AS Date), CAST(N'2024-12-16' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1090, N'Корректировка', N'Средний', 60, 5, CAST(N'2024-12-17' AS Date), CAST(N'2024-12-18' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1091, N'Активация', N'Высокий', 70, 6, CAST(N'2024-12-20' AS Date), CAST(N'2024-12-21' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1092, N'Регистрация', N'Высокий', 80, 7, CAST(N'2024-12-22' AS Date), CAST(N'2024-12-23' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1094, N'Удаление', N'Низкий', 100, 9, CAST(N'2024-12-26' AS Date), CAST(N'2024-12-27' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1095, N'Активация', N'Высокий', 10, 10, CAST(N'2024-12-28' AS Date), CAST(N'2024-12-29' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1096, N'Корректировка', N'Средний', 20, 1, CAST(N'2024-12-30' AS Date), CAST(N'2024-12-31' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1097, N'Регистрация', N'Низкий', 30, 2, CAST(N'2025-01-02' AS Date), CAST(N'2025-01-03' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1098, N'Регистрация', N'Средний', 40, 3, CAST(N'2025-01-04' AS Date), CAST(N'2025-01-05' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1099, N'Удаление', N'Высокий', 50, 4, CAST(N'2025-01-06' AS Date), CAST(N'2025-01-07' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1100, N'Регистрация', N'Низкий', 60, 5, CAST(N'2025-01-08' AS Date), CAST(N'2025-01-09' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1101, N'Активация', N'Средний', 70, 6, CAST(N'2025-01-10' AS Date), CAST(N'2025-01-11' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1102, N'Активация', N'Высокий', 80, 7, CAST(N'2025-01-12' AS Date), CAST(N'2025-01-13' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1103, N'Изменение', N'Средний', 90, 8, CAST(N'2025-01-14' AS Date), CAST(N'2025-01-15' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1104, N'Корректировка', N'Низкий', 100, 9, CAST(N'2025-01-16' AS Date), CAST(N'2025-01-17' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (1105, N'Регистрация', N'Средний', 10, 10, CAST(N'2025-01-18' AS Date), CAST(N'2025-01-19' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (2002, N'Активация', N'Высокий', 20, 3, CAST(N'2025-03-05' AS Date), CAST(N'2025-03-25' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (2003, N'Регистрация', N'Средний', 100, 10, CAST(N'2025-03-04' AS Date), CAST(N'2025-12-05' AS Date))
INSERT [dbo].[Zayavka] ([ID_zayavki], [Type_zayavki], [Uroven], [ID_GAR], [Sozdatel_zayav], [Data_sozdaniya], [Data_sozd2]) VALUES (3002, N'Регистрация', N'ываываыва', 10, 3, CAST(N'2025-03-05' AS Date), CAST(N'2025-02-28' AS Date))
SET IDENTITY_INSERT [dbo].[Zayavka] OFF
GO
/****** Object:  Index [UQ__adres_ob__7E18836992B00C9C]    Script Date: 06.03.2025 0:26:02 ******/
ALTER TABLE [dbo].[adres_objects] ADD  CONSTRAINT [UQ__adres_ob__7E18836992B00C9C] UNIQUE NONCLUSTERED 
(
	[ID_KLADR] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__adres_ob__F683A7589F2D4A95]    Script Date: 06.03.2025 0:26:02 ******/
ALTER TABLE [dbo].[adres_objects] ADD  CONSTRAINT [UQ__adres_ob__F683A7589F2D4A95] UNIQUE NONCLUSTERED 
(
	[Nalog_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UQ__GAR__420A870B50A42D7F]    Script Date: 06.03.2025 0:26:02 ******/
ALTER TABLE [dbo].[GAR] ADD  CONSTRAINT [UQ__GAR__420A870B50A42D7F] UNIQUE NONCLUSTERED 
(
	[ID_Reestr] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[adres_objects]  WITH CHECK ADD  CONSTRAINT [FK__adres_obj__ID_GA__4E88ABD4] FOREIGN KEY([ID_GAR])
REFERENCES [dbo].[GAR] ([ID_GAR])
GO
ALTER TABLE [dbo].[adres_objects] CHECK CONSTRAINT [FK__adres_obj__ID_GA__4E88ABD4]
GO
ALTER TABLE [dbo].[GAR_Dok]  WITH CHECK ADD  CONSTRAINT [FK__GAR_Dok__ID_Dok__49C3F6B7] FOREIGN KEY([ID_Dok])
REFERENCES [dbo].[Dokuments] ([ID_Dok])
GO
ALTER TABLE [dbo].[GAR_Dok] CHECK CONSTRAINT [FK__GAR_Dok__ID_Dok__49C3F6B7]
GO
ALTER TABLE [dbo].[GAR_Dok]  WITH CHECK ADD  CONSTRAINT [FK__GAR_Dok__ID_GAR__48CFD27E] FOREIGN KEY([ID_GAR])
REFERENCES [dbo].[GAR] ([ID_GAR])
GO
ALTER TABLE [dbo].[GAR_Dok] CHECK CONSTRAINT [FK__GAR_Dok__ID_GAR__48CFD27E]
GO
ALTER TABLE [dbo].[History_adres]  WITH CHECK ADD  CONSTRAINT [FK__History_a__ID_GA__5165187F] FOREIGN KEY([ID_GAR])
REFERENCES [dbo].[GAR] ([ID_GAR])
GO
ALTER TABLE [dbo].[History_adres] CHECK CONSTRAINT [FK__History_a__ID_GA__5165187F]
GO
ALTER TABLE [dbo].[Istor_izmen]  WITH CHECK ADD  CONSTRAINT [FK__Istor_izm__ID_ad__70DDC3D8] FOREIGN KEY([ID_adres])
REFERENCES [dbo].[Adres_zayavka] ([ID_adres])
GO
ALTER TABLE [dbo].[Istor_izmen] CHECK CONSTRAINT [FK__Istor_izm__ID_ad__70DDC3D8]
GO
ALTER TABLE [dbo].[Istor_izmen]  WITH CHECK ADD  CONSTRAINT [FK__Istor_izm__ID_GA__6FE99F9F] FOREIGN KEY([ID_GAR])
REFERENCES [dbo].[GAR] ([ID_GAR])
GO
ALTER TABLE [dbo].[Istor_izmen] CHECK CONSTRAINT [FK__Istor_izm__ID_GA__6FE99F9F]
GO
ALTER TABLE [dbo].[Uvedomleniya]  WITH CHECK ADD  CONSTRAINT [FK__Uvedomlen__ID_Za__60A75C0F] FOREIGN KEY([ID_Zayavki])
REFERENCES [dbo].[Zayavka] ([ID_zayavki])
GO
ALTER TABLE [dbo].[Uvedomleniya] CHECK CONSTRAINT [FK__Uvedomlen__ID_Za__60A75C0F]
GO
ALTER TABLE [dbo].[Uvedomleniya]  WITH CHECK ADD  CONSTRAINT [FK__Uvedomlen__Statu__628FA481] FOREIGN KEY([Status_uved])
REFERENCES [dbo].[Type_status] ([Status_uved])
GO
ALTER TABLE [dbo].[Uvedomleniya] CHECK CONSTRAINT [FK__Uvedomlen__Statu__628FA481]
GO
ALTER TABLE [dbo].[Uvedomleniya]  WITH CHECK ADD  CONSTRAINT [FK__Uvedomlen__Type___619B8048] FOREIGN KEY([Type_uved])
REFERENCES [dbo].[Type_uved] ([Type_uvedom])
GO
ALTER TABLE [dbo].[Uvedomleniya] CHECK CONSTRAINT [FK__Uvedomlen__Type___619B8048]
GO
ALTER TABLE [dbo].[Zayavka]  WITH CHECK ADD  CONSTRAINT [FK__Zayavka__ID_GAR__59063A47] FOREIGN KEY([ID_GAR])
REFERENCES [dbo].[GAR] ([ID_GAR])
GO
ALTER TABLE [dbo].[Zayavka] CHECK CONSTRAINT [FK__Zayavka__ID_GAR__59063A47]
GO
ALTER TABLE [dbo].[Zayavka]  WITH CHECK ADD  CONSTRAINT [FK__Zayavka__Sozdate__59FA5E80] FOREIGN KEY([Sozdatel_zayav])
REFERENCES [dbo].[Employees] ([ID_Empl])
GO
ALTER TABLE [dbo].[Zayavka] CHECK CONSTRAINT [FK__Zayavka__Sozdate__59FA5E80]
GO
ALTER TABLE [dbo].[Zayavka]  WITH CHECK ADD  CONSTRAINT [FK__Zayavka__Type_za__5812160E] FOREIGN KEY([Type_zayavki])
REFERENCES [dbo].[Type_zayavki] ([Type_zayavki])
GO
ALTER TABLE [dbo].[Zayavka] CHECK CONSTRAINT [FK__Zayavka__Type_za__5812160E]
GO
ALTER TABLE [dbo].[GAR]  WITH CHECK ADD  CONSTRAINT [CHK_IFNSL_FL] CHECK  ((len(CONVERT([varchar],[IFNSL_FL]))=(4)))
GO
ALTER TABLE [dbo].[GAR] CHECK CONSTRAINT [CHK_IFNSL_FL]
GO
ALTER TABLE [dbo].[GAR]  WITH CHECK ADD  CONSTRAINT [CHK_IFNSL_YL] CHECK  ((len(CONVERT([varchar],[IFNSL_YL]))=(4)))
GO
ALTER TABLE [dbo].[GAR] CHECK CONSTRAINT [CHK_IFNSL_YL]
GO
/****** Object:  StoredProcedure [dbo].[FullAddressDetails]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------
-- Процедура 1: Получить полную информацию об адресном объекте по ID_GAR
--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[FullAddressDetails]
    @ID_GAR INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        g.ID_GAR,
        g.Mun_otdel,
        g.Administr_otdel,
        g.IFNSL_FL,
        g.IFNSL_YL,
        g.OKATO,
        g.OKTMO,
        g.Pochta_Index,
        g.ID_Reestr,
        g.Kadastr_nom,
        g.Status_zap,
        g.Data_Vnesenia,
        g.Data_aktual,
        ao.Naimenovanie AS FullAddress,
        ha.Period_deistviya,
        ha.Stroka_adres,
        d.ID_Dok,
        d.Type_Dok,
        d.Date_Dok,
        d.Naimenovanie AS DocumentName
    FROM dbo.GAR g
        LEFT JOIN dbo.adres_objects ao ON g.ID_GAR = ao.ID_GAR
        LEFT JOIN dbo.History_adres ha ON g.ID_GAR = ha.ID_GAR
        LEFT JOIN dbo.GAR_Dok gd ON g.ID_GAR = gd.ID_GAR
        LEFT JOIN dbo.Dokuments d ON gd.ID_Dok = d.ID_Dok
    WHERE g.ID_GAR = @ID_GAR;
END;
GO
/****** Object:  StoredProcedure [dbo].[GetEmployee]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Процедура 5: Получение заявок, созданных определённым сотрудником
--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[GetEmployee]
    @ID_Empl INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        z.ID_zayavki,
        z.Type_zayavki,
        z.Uroven,
        z.ID_GAR,
        z.Sozdatel_zayav,
        z.Data_sozdaniya,
        z.Data_sozd2,
        g.Kadastr_nom,
        g.Mun_otdel,
        g.Administr_otdel,
        e.FIO,
        e.Phone,
        e.Email
    FROM dbo.Zayavka z
        INNER JOIN dbo.Employees e ON z.Sozdatel_zayav = e.ID_Empl
        LEFT JOIN dbo.GAR g ON z.ID_GAR = g.ID_GAR
    WHERE e.ID_Empl = @ID_Empl
    ORDER BY z.Data_sozdaniya DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[InsertNewZayavka]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Процедура 2: Вставка новой заявки (Zayavka)
--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[InsertNewZayavka]
    @Type_zayavki VARCHAR(100),
    @Uroven VARCHAR(100),
    @ID_GAR INT,
    @Sozdatel_zayav INT,
    @Data_sozdaniya DATE,
    @Data_sozd2 DATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.Zayavka (Type_zayavki, Uroven, ID_GAR, Sozdatel_zayav, Data_sozdaniya, Data_sozd2)
    VALUES (@Type_zayavki, @Uroven, @ID_GAR, @Sozdatel_zayav, @Data_sozdaniya, @Data_sozd2);

    SELECT SCOPE_IDENTITY() AS NewZayavkaID;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateUvedStatus]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Процедура 4: Обновление статуса уведомления (Uvedomleniya)
--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[UpdateUvedStatus]
    @ID_Uved INT,
    @NewStatus VARCHAR(100),
    @NewType_uved VARCHAR(100) = NULL,
    @NewData_ispoln_1 DATE = NULL,
    @Kommentarii VARCHAR(150) = NULL,
    @Prichina_otkaza VARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.Uvedomleniya
    SET Status_uved = @NewStatus,
        Type_uved = ISNULL(@NewType_uved, Type_uved),
        Data_ispoln_1 = ISNULL(@NewData_ispoln_1, Data_ispoln_1),
        Kommentarii = ISNULL(@Kommentarii, Kommentarii),
        Prichina_otkaza = ISNULL(@Prichina_otkaza, Prichina_otkaza)
    WHERE ID_Uved = @ID_Uved;

    SELECT * FROM dbo.Uvedomleniya WHERE ID_Uved = @ID_Uved;
END;
GO
/****** Object:  StoredProcedure [dbo].[ZayavkaHistory]    Script Date: 06.03.2025 0:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------------------------
-- Процедура 3: Получение истории изменений заявки по ID_GAR
--------------------------------------------------------------------
CREATE PROCEDURE [dbo].[ZayavkaHistory]
    @ID_GAR INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        iz.ID_Izm,
        iz.ID_GAR,
        iz.Data_izmen,
        iz.Type_izmen,
        iz.ID_adres,
        az.Parametr,
        az.Istoriya_znach,
        az.Aktual_znach
    FROM dbo.Istor_izmen iz
        LEFT JOIN dbo.Adres_zayavka az ON iz.ID_adres = az.ID_adres
    WHERE iz.ID_GAR = @ID_GAR
    ORDER BY iz.Data_izmen DESC;
END;
GO
USE [master]
GO
ALTER DATABASE [FIAS_Praktika] SET  READ_WRITE 
GO
