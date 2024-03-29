if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoDevice]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoDevice]
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoDeviceType]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoDeviceType]
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoDeviceSystem]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoDeviceSystem]
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoFactory]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoFactory]
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoDeviceStatus]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoDeviceStatus]
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoDeviceSpecification]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoDeviceSpecification]
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoDeviceRoutineCheckItem]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoDeviceRoutineCheckItem]
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoDeviceRoutineLubricateRequire]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoDeviceRoutineLubricateRequire]
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoDeviceRepair]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoDeviceRepair]
GO

CREATE TABLE [dbo].[iDemoDevice](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StationID] [int] NULL,
	[TypeID] [int] NULL,
	[Name] [nvarchar](256) NULL,
	[Number] [nvarchar](50) NULL,
	[FactoryNumber] [nvarchar](50) NULL,
	[Model] [nvarchar](50) NULL,
	[Standard] [nvarchar](50) NULL,
	[Price] [money] NULL,
	[Power] [decimal](18, 0) NULL,
	[Manufacture] [nvarchar](256) NULL,
	[ManufacturerID] [int] NULL,
	[Provider] [nvarchar](256) NULL,
	[ProviderID] [int] NULL,
	[DateOfManufacture] [datetime] NULL,
	[SystemID] [int] NULL,
	[IntendAge] [int] NULL,
	[StartDate] [datetime] NULL,
	[Location] [nvarchar](256) NULL,
	[Status] [int] NULL,
	[Picture] [nvarchar](256) NULL,
	[RecordTime] [datetime] NULL,
	[UserID] [nvarchar](10) NULL,
    CONSTRAINT [PK_iDemoDevice] PRIMARY KEY CLUSTERED 
    (
	[ID] ASC
    )
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[iDemoDeviceType](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[Remark] [nvarchar](256) NULL,
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[iDemoDeviceSystem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](256) NULL,
	[Remark] [nvarchar](2048) NULL,
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[iDemoFactory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[StationID] [int] NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[CountryID] [int] NULL,
	[ProvinceID] [int] NULL,
	[City] [nvarchar](64) NULL,
	[Dimensions] [decimal](18, 2) NULL,
	[TechnologyID] [int] NULL,
	[Remark] [ntext] NULL,
	[Long] [decimal](18, 2) NULL,
	[Lat] [decimal](18, 2) NULL,
	[MapX] [smallint] NULL,
	[MapY] [smallint] NULL,
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[iDemoDeviceStatus](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](64) NULL,
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[iDemoDeviceSpecification](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DeviceID] [int] NULL,
	[Name] [nvarchar](256) NULL,
	[Remark] [nvarchar](2048) NULL,
	[Attachments] [nvarchar](256) NULL,
    CONSTRAINT [PK_iDemoDeviceSpecification] PRIMARY KEY CLUSTERED 
    (
	[ID] ASC
    )
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[iDemoDeviceRoutineCheckItem](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DeviceID] [int] NULL,
	[Name] [nvarchar](256) NULL,
	[Require] [nvarchar](2048) NULL,
	[Period] [int] NULL,
    CONSTRAINT [PK_iDemoDeviceRoutineCheckItem] PRIMARY KEY CLUSTERED 
    (
	[ID] ASC
    )
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[iDemoDeviceRoutineLubricateRequire](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DeviceID] [int] NULL,
	[Name] [nvarchar](50) NULL,
	[Require] [nvarchar](2048) NULL,
	[Period] [int] NULL,
    CONSTRAINT [PK_iDemoDeviceRoutineLubricateRequire] PRIMARY KEY CLUSTERED 
    (
	[ID] ASC
    )
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[iDemoDeviceRepair](
	[TaskID] [int] NOT NULL,
	[DeviceID] [nvarchar](50) NULL,
	[Note] [nvarchar](500) NULL,
	[Attachment] [nvarchar](500) NULL
) ON [PRIMARY]
GO

INSERT INTO [iDemoDeviceType](Name) VALUES(N'電器設備')
INSERT INTO [iDemoDeviceType](Name) VALUES(N'化驗設備')
INSERT INTO [iDemoDeviceType](Name) VALUES(N'現場設備')
INSERT INTO [iDemoDeviceType](Name) VALUES(N'智能控制設備')

INSERT INTO [iDemoDeviceSystem](Name,Remark) VALUES(N'A2/O池',N'污水中有機物、N、P等污染物被降解的主要場所。')
INSERT INTO [iDemoDeviceSystem](Name,Remark) VALUES(N'二沉池',N'活性污泥與上清液泥水分離的場所。')
INSERT INTO [iDemoDeviceSystem](Name,Remark) VALUES(N'預處理',N'包括粗格柵、提升泵、細格柵、沉砂池。是原水進入污水廠的第一道處理工序，主要去除大塊漂浮物、懸浮物、砂粒等污染物質，為後續生物處理創造良好條件。')
INSERT INTO [iDemoDeviceSystem](Name,Remark) VALUES(N'消毒池',N'本廠採用紫外線消毒，是污水處理最後一道工序。')
INSERT INTO [iDemoDeviceSystem](Name,Remark) VALUES(N'污泥處理',N'本廠採用帶式壓濾機進行污泥脫水，脫水後污泥運至垃圾填埋場填埋。')
INSERT INTO [iDemoDeviceSystem](Name,Remark) VALUES(N'化驗室',N'負責日常水質分析')

INSERT INTO [iDemoFactory](StationID,Name,City) VALUES(1,N'郴州基地',N'郴州市')
INSERT INTO [iDemoFactory](StationID,Name,City) VALUES(2,N'桂陽基地',N'桂陽縣')
INSERT INTO [iDemoFactory](StationID,Name,City) VALUES(3,N'安寧基地',N'安寧市')
INSERT INTO [iDemoFactory](StationID,Name,City) VALUES(4,N'永興基地',N'永興縣')

INSERT INTO [iDemoDeviceStatus](Name) VALUES(N'正常')
INSERT INTO [iDemoDeviceStatus](Name) VALUES(N'故障')
INSERT INTO [iDemoDeviceStatus](Name) VALUES(N'停用')

INSERT INTO [iDemoDevice] VALUES(2,1,N'旋轉式格柵除污機',N'SWHYS-1',N'SWCGS-01',N'LF-1200',N'柵寬1.2m 柵條間隙 25mm',NULL,2,N'江蘇通用環保集團',NULL,N'江蘇通用環保集團',NULL,'2010-2-2 0:00:00',1,1,'2010-11-15 0:00:00',N'預處理階段1#粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,2,N'回轉式格柵清污機',N'SWHYS-2',N'2009-1254',N'XHG-1500',N'柵距：20mm;  柵條寬度： 1500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',2,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,3,N'帶式輸送機1',N'SWHYS-3',N'2009-1262',N'XBG-500',N'皮帶長度：5000mm ;500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',3,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,3,N'帶式輸送機2',N'SWHYS-4',N'2009-1262',N'XBG-500',N'皮帶長度：5000mm ;500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',3,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,3,N'帶式輸送機3',N'SWHYS-5',N'2009-1262',N'XBG-500',N'皮帶長度：5000mm ;500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',3,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,3,N'帶式輸送機4',N'SWHYS-6',N'2009-1262',N'XBG-500',N'皮帶長度：5000mm ;500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',3,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,3,N'帶式輸送機5',N'SWHYS-7',N'2009-1262',N'XBG-500',N'皮帶長度：5000mm ;500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',3,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,3,N'帶式輸送機6',N'SWHYS-8',N'2009-1262',N'XBG-500',N'皮帶長度：5000mm ;500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',3,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,3,N'帶式輸送機7',N'SWHYS-9',N'2009-1262',N'XBG-500',N'皮帶長度：5000mm ;500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',3,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,3,N'帶式輸送機8',N'SWHYS-10',N'2009-1262',N'XBG-500',N'皮帶長度：5000mm ;500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',3,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,3,N'帶式輸送機9',N'SWHYS-11',N'2009-1262',N'XBG-500',N'皮帶長度：5000mm ;500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',3,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
INSERT INTO [iDemoDevice] VALUES(2,3,N'帶式輸送機10',N'SWHYS-12',N'2009-1262',N'XBG-500',N'皮帶長度：5000mm ;500mm',NULL,2,N'江蘇一環集團有限公司',NULL,N'江蘇一環集團有限公司',NULL,'2010-2-2 0:00:00',3,1,'2010-11-15 0:00:00',N'粗格柵井',1,NULL,'2011-5-22 16:51:29','99199')
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'v_iDemoDevice')
DROP VIEW [dbo].v_iDemoDevice
GO

CREATE VIEW [dbo].v_iDemoDevice
AS
SELECT     dbo.iDemoDevice.ID, dbo.iDemoDevice.StationID, ISNULL(dbo.iDemoFactory.Name, dbo.iDemoDevice.StationID) AS StationName, 
                      dbo.iDemoDevice.Name, dbo.iDemoDevice.Number, dbo.iDemoDevice.Model, dbo.iDemoDevice.Standard, dbo.iDemoDevice.Power, 
                      dbo.iDemoDevice.Manufacture, dbo.iDemoDevice.ManufacturerID, dbo.iDemoDevice.Provider, dbo.iDemoDevice.ProviderID, 
                      dbo.iDemoDevice.DateOfManufacture, ISNULL(dbo.iDemoDeviceSystem.Name, dbo.iDemoDevice.SystemID) AS System, dbo.iDemoDevice.IntendAge, 
                      dbo.iDemoDevice.StartDate, dbo.iDemoDevice.Location, ISNULL(dbo.iDemoDeviceStatus.Name, dbo.iDemoDevice.Status) AS Status, 
                      ISNULL(dbo.iDemoDeviceSystem.Name, dbo.iDemoDevice.SystemID) AS SystemName, dbo.iDemoDevice.Price, dbo.iDemoDevice.Picture, 
                      dbo.iDemoDeviceType.Name AS Type
FROM         dbo.iDemoDevice LEFT OUTER JOIN
                      dbo.iDemoDeviceStatus ON dbo.iDemoDevice.Status = dbo.iDemoDeviceStatus.ID LEFT OUTER JOIN
                      dbo.iDemoFactory ON dbo.iDemoDevice.StationID = dbo.iDemoFactory.StationID LEFT OUTER JOIN
                      dbo.iDemoDeviceSystem ON dbo.iDemoDevice.SystemID = dbo.iDemoDeviceSystem.ID LEFT OUTER JOIN
                      dbo.iDemoDeviceType ON dbo.iDemoDevice.TypeID = dbo.iDemoDeviceType.ID
GO

if not exists(select * from BPMSecurityUserResource where RSID='ae77e96c-7d5f-4332-b9ad-1b90ada27118')
BEGIN

DELETE FROM BPMSecurityUserResourcePerm WHERE RSID=N'ae77e96c-7d5f-4332-b9ad-1b90ada27118'
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'ae77e96c-7d5f-4332-b9ad-1b90ada27118',NULL,6,N'演示網站')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'ae77e96c-7d5f-4332-b9ad-1b90ada27118',N'Execute',0,N'功能權限',N'Module',0)

DELETE FROM BPMSecurityUserResource WHERE RSID=N'8cd49c07-0710-4903-9edf-a70e88d713ed'
DELETE FROM BPMSecurityUserResourcePerm WHERE RSID=N'8cd49c07-0710-4903-9edf-a70e88d713ed'
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'8cd49c07-0710-4903-9edf-a70e88d713ed',N'ae77e96c-7d5f-4332-b9ad-1b90ada27118',6,N'生產管理')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'8cd49c07-0710-4903-9edf-a70e88d713ed',N'Execute',0,N'功能權限',N'Module',0)

DELETE FROM BPMSecurityUserResource WHERE RSID=N'db7bb6b5-1578-4b76-8426-6a8247951119'
DELETE FROM BPMSecurityUserResourcePerm WHERE RSID=N'db7bb6b5-1578-4b76-8426-6a8247951119'
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'db7bb6b5-1578-4b76-8426-6a8247951119',N'8cd49c07-0710-4903-9edf-a70e88d713ed',1,N'生產設備')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'db7bb6b5-1578-4b76-8426-6a8247951119',N'Execute',0,N'功能權限',N'Module',0)

DELETE FROM BPMSecurityUserResource WHERE RSID=N'3a4d5082-ea35-412c-ba94-fb14418e3381'
DELETE FROM BPMSecurityUserResourcePerm WHERE RSID=N'3a4d5082-ea35-412c-ba94-fb14418e3381'
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'3a4d5082-ea35-412c-ba94-fb14418e3381',N'db7bb6b5-1578-4b76-8426-6a8247951119',1,N'設備管理')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'3a4d5082-ea35-412c-ba94-fb14418e3381',N'Execute',0,N'功能權限',N'Module',0)

DELETE FROM BPMSecurityUserResource WHERE RSID=N'd0ebfcf9-0007-44b3-b218-ef94628de67e'
DELETE FROM BPMSecurityUserResourcePerm WHERE RSID=N'd0ebfcf9-0007-44b3-b218-ef94628de67e'
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'd0ebfcf9-0007-44b3-b218-ef94628de67e',N'3a4d5082-ea35-412c-ba94-fb14418e3381',1,N'設備管理')

DELETE FROM BPMSecurityUserResourcePerm WHERE RSID=N'd0ebfcf9-0007-44b3-b218-ef94628de67e'
DELETE FROM BPMSecurityUserResourceACL WHERE RSID=N'd0ebfcf9-0007-44b3-b218-ef94628de67e'
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'd0ebfcf9-0007-44b3-b218-ef94628de67e',N'Execute',0,N'功能權限',N'Module',0)
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'd0ebfcf9-0007-44b3-b218-ef94628de67e',N'RecordRead',1,N'記錄查看',N'Record',0)
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'd0ebfcf9-0007-44b3-b218-ef94628de67e',N'New',2,N'新增',N'Module',0)
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'd0ebfcf9-0007-44b3-b218-ef94628de67e',N'Edit',3,N'編輯',N'Record',0)
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'd0ebfcf9-0007-44b3-b218-ef94628de67e',N'Delete',4,N'刪除',N'Record',0)
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'd0ebfcf9-0007-44b3-b218-ef94628de67e',N'Public',5,N'公開',N'Record',0)
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'd0ebfcf9-0007-44b3-b218-ef94628de67e',N'AssignPerm',6,N'授權',N'Record',0)

INSERT INTO BPMSecurityUserResourceACL(RoleType,RoleParam1,RSID,AllowPermision,Inherited,Inheritable,CreateDate,CreateBy) VALUES('GroupSID',N'S_GS_90674E5E-AC3C-4032-9EDF-7477F2247542',N'8cd49c07-0710-4903-9edf-a70e88d713ed','Execute',0,1,getdate(),'sa')
INSERT INTO BPMSecurityUserResourceACL(RoleType,RoleParam1,RSID,AllowPermision,Inherited,Inheritable,CreateDate,CreateBy) VALUES('GroupSID',N'S_GS_90674E5E-AC3C-4032-9EDF-7477F2247542',N'db7bb6b5-1578-4b76-8426-6a8247951119','Execute',0,1,getdate(),'sa')
INSERT INTO BPMSecurityUserResourceACL(RoleType,RoleParam1,RSID,AllowPermision,Inherited,Inheritable,CreateDate,CreateBy) VALUES('GroupSID',N'S_GS_90674E5E-AC3C-4032-9EDF-7477F2247542',N'3a4d5082-ea35-412c-ba94-fb14418e3381','Execute',0,1,getdate(),'sa')
INSERT INTO BPMSecurityUserResourceACL(RoleType,RoleParam1,RSID,AllowPermision,Inherited,Inheritable,CreateDate,CreateBy) VALUES('GroupSID',N'S_GS_90674E5E-AC3C-4032-9EDF-7477F2247542',N'd0ebfcf9-0007-44b3-b218-ef94628de67e','Execute,New',0,1,getdate(),'sa')
INSERT INTO BPMSecurityUserResourceACL(RoleType,RoleParam1,RoleParam2,RSID,AllowPermision,Inherited,Inheritable,CreateDate,CreateBy) VALUES('CustomCode',N'Initiator',N'提交人',N'd0ebfcf9-0007-44b3-b218-ef94628de67e','RecordRead,Edit,Delete,Public',0,1,getdate(),'sa')
INSERT INTO BPMSecurityUserResourceACL(RoleType,RoleParam1,RoleParam2,RSID,AllowPermision,Inherited,Inheritable,CreateDate,CreateBy) VALUES('CustomCode',N'Initiator.GetParentOU("公司").GetAllRoles("設備管理員")',N'提交人所在"公司"內的"設備管理員',N'd0ebfcf9-0007-44b3-b218-ef94628de67e','RecordRead,Edit,Delete,Public,AssignPerm',0,1,getdate(),'sa')
END
GO

/***iDemoRPTSales***/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoRPTSales]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoRPTSales]

CREATE TABLE [dbo].[iDemoRPTSales](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[City] [nvarchar](50) NULL,
	[Shop] [nvarchar](50) NULL,
	[Employee] [nvarchar](50) NULL,
	[Date] [datetime] NULL,
	[Sales] [money] NULL
) ON [PRIMARY]
GO

/****模擬資料***/
DECLARE @temptb TABLE  
(
    ID int IDENTITY(1,1),
    City nvarchar(50),  
    Shop nvarchar(50),
	Employee nvarchar(50)
)

INSERT INTO @temptb VALUES(N'台灣',N'淮海店',N'張三')
INSERT INTO @temptb VALUES(N'北京',N'上地店',N'全十')
INSERT INTO @temptb VALUES(N'台灣',N'淮海店',N'李四')
INSERT INTO @temptb VALUES(N'台灣',N'中山店',N'趙六')
INSERT INTO @temptb VALUES(N'台灣',N'淮海店',N'王五')
INSERT INTO @temptb VALUES(N'北京',N'中關村店',N'謝二')
INSERT INTO @temptb VALUES(N'台灣',N'中山店',N'徐七')
INSERT INTO @temptb VALUES(N'台灣',N'莘莊店',N'孫九')
INSERT INTO @temptb VALUES(N'北京',N'上地店',N'鄭一')
INSERT INTO @temptb VALUES(N'台灣',N'莘莊店',N'錢八')
INSERT INTO @temptb VALUES(N'北京',N'中關村店',N'魏三')

DECLARE @currentIndex int
DECLARE @totalRows int
DECLARE @city  nvarchar(50)
DECLARE @shop  nvarchar(50)
DECLARE @employee  nvarchar(50)
DECLARE @date datetime
SET @currentIndex=1
SELECT @totalRows=count(*) from @temptb  
  
WHILE(@currentIndex<=@totalRows)  
BEGIN
	DECLARE @year int
	SET @year = 2010
	WHILE(@year <= 2020)
	BEGIN
		DECLARE @month int
		SET @month = 1
		WHILE(@month <= 12)
		BEGIN
			DECLARE @day int
			SET @day = 1
			WHILE(@day <= 2)
			BEGIN
				SELECT @city=City FROM @temptb WHERE ID=@currentIndex  
				SELECT @shop=Shop FROM @temptb WHERE ID=@currentIndex
				SELECT @employee=Employee FROM @temptb WHERE ID=@currentIndex
				SELECT @date=CAST(@year AS nvarchar(4)) + '-' + CAST(@month AS nvarchar(2)) + '-' + CAST(@day AS nvarchar(2))

				INSERT INTO iDemoRPTSales(City,Shop,Employee,Date,Sales)
					VALUES(@city,@shop,@employee,@date,@currentIndex+@month+(@year%100)*1000/2)

				SET @day=@day+1;
			END
			SET @month=@month+1;  
		END
		SET @year=@year+1;  
	END
	SET @currentIndex=@currentIndex+1;  
END  
GO

/***iDemoRPTDeviceRepair***/
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iDemoRPTDeviceRepair]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[iDemoRPTDeviceRepair]

CREATE TABLE [dbo].[iDemoRPTDeviceRepair](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime] NULL,
	[Dept] [nvarchar](50) NULL,
	[DeviceName] [nvarchar](50) NULL,
	[RepairDesc] [nvarchar](50) NULL,
	[Period] [nvarchar](50) NULL,
	[Memo] [nvarchar](50) NULL
) ON [PRIMARY]
GO

/****模擬資料***/
DECLARE @temptb TABLE  
(
    ID int IDENTITY(1,1),
    Dept nvarchar(50),  
    Device nvarchar(50),
	RepairDesc nvarchar(50)
)

INSERT INTO @temptb VALUES(N'機修車間',N'門機518',N'起升聯軸節鬆動拆修，鎖緊螺母緊固。')
INSERT INTO @temptb VALUES(N'機修車間',N'橋吊06',N'舉升油管接口漏油更換密封圈。')
INSERT INTO @temptb VALUES(N'電氣維修',N'龍門吊15',N'更換起升鋼絲繩。')
INSERT INTO @temptb VALUES(N'電氣維修',N'推高機04',N'行走、起升反應慢，檔位閥彈簧更換，工作壓力調大。')

DECLARE @currentIndex int
DECLARE @totalRows int
DECLARE @Dept nvarchar(50)
DECLARE @DeviceName nvarchar(50)
DECLARE @RepairDesc nvarchar(50)
DECLARE @Date datetime
SET @currentIndex=1
SELECT @totalRows=count(*) from @temptb  
  
WHILE(@currentIndex<=@totalRows)  
BEGIN
	DECLARE @year int
	SELECT @year=YEAR(GETDATE())
	DECLARE @month int
	SET @month = 1
	DECLARE @day int
	SET @day = 1
	WHILE(@day <= 31)
	BEGIN
		SELECT @Dept=Dept FROM @temptb WHERE ID=@currentIndex  
		SELECT @DeviceName=Device FROM @temptb WHERE ID=@currentIndex
		SELECT @RepairDesc=RepairDesc FROM @temptb WHERE ID=@currentIndex
		SELECT @Date=CAST(@year AS nvarchar(4)) + '-' + CAST(@month AS nvarchar(2)) + '-' + CAST(@day AS nvarchar(2))

		INSERT INTO iDemoRPTDeviceRepair(Date,Dept,DeviceName,RepairDesc,Memo)
			VALUES(@Date,@Dept,@DeviceName,@RepairDesc + CAST(@day+@currentIndex-1 AS nvarchar(2)),'M' + CAST(@day+@currentIndex-1 AS nvarchar(2)))

		SET @day=@day+1;
	END
	SET @currentIndex=@currentIndex+1;  
END  
GO