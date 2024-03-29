--開啟SQL查詢通知
--DECLARE @DBName nvarchar(50);
--SELECT @DBName=Name From Master..SysDataBases Where DbId=(Select Dbid From Master..SysProcesses Where Spid = @@spid);
--if not exists(SELECT * FROM sys.databases WHERE name = @DBName AND is_broker_enabled=1)
--BEGIN
--DECLARE @query nvarchar(400);
--SELECT @query=
--'ALTER DATABASE '+@DBName+' SET NEW_BROKER WITH ROLLBACK IMMEDIATE;'+
--'ALTER DATABASE '+@DBName+' SET ENABLE_BROKER;';
--exec sp_executesql @query
--END
--GO


if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMQuery]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[BPMQuery]
GO

CREATE PROCEDURE BPMQuery 
@sql nvarchar(4000), --查詢字符串
@curpage int, --第N頁
@pagesize int, --每頁行數
@rowcount int output
as
set nocount on
declare @P1 int --P1是游標的id
declare @rowindex int
exec sp_cursoropen @P1 output,@sql,@scrollopt=1,@ccopt=1,@rowcount=@rowcount output
--select ceiling(1.0*@rowcount/@pagesize) as 總頁數,@rowcount as 總行數,@currentpage as 目前頁 
set @rowindex = (@curpage-1)*@pagesize+1
exec sp_cursorfetch @P1,16,@rowindex,@pagesize 
exec sp_cursorclose @P1
set nocount off
return @rowcount
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMQueryNew]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[BPMQueryNew]
GO

CREATE PROCEDURE BPMQueryNew 
@sql nvarchar(4000), --查詢字符串
@rowindex int, --第N行，從1開始
@rows int, --行數
@rowcount int output
as
set nocount on
declare @P1 int --P1是游標的id
exec sp_cursoropen @P1 output,@sql,@scrollopt=1,@ccopt=1,@rowcount=@rowcount output
--select ceiling(1.0*@rowcount/@pagesize) as 總頁數,@rowcount as 總行數,@currentpage as 目前頁 
exec sp_cursorfetch @P1,16,@rowindex,@rows 
exec sp_cursorclose @P1
set nocount off
return @rowcount
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[CreateSnapshot]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[CreateSnapshot]
GO

CREATE PROCEDURE CreateSnapshot 
@TaskID int, --任務號
@VerDesc nvarchar(500), --版本描述
@FormData ntext --XML格式的表單資料
as
DECLARE @ver int

SELECT @ver = max(Version) FROM BPMSysSnapshot WHERE TaskID=@TaskID
IF @ver IS NULL
  SET @ver = 1
ELSE
  SET @ver = @ver + 1

INSERT INTO BPMSysSnapshot(TaskID,Version,VerDesc,FormData) VALUES(@TaskID,@ver,@VerDesc,@FormData)
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PublicTask]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[PublicTask]
GO

CREATE PROCEDURE PublicTask 
@TaskID int,
@SID nvarchar(100),
@CreateBy nvarchar(100)
as
IF exists (SELECT * FROM BPMSecurityTACL WHERE TaskID=@TaskID and SID=@SID)
UPDATE BPMSecurityTACL SET AllowRead=1 WHERE TaskID=@TaskID and SID=@SID
ELSE
INSERT INTO BPMSecurityTACL(TaskID,SID,AllowRead,AllowAdmin,ShareByUser,CreateDate,CreateBy) VALUES(@TaskID,@SID,1,0,1,GetDate(),@CreateBy)
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMInstProcSteps]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMInstProcSteps] (
	[StepID] [int] IDENTITY (1, 1) NOT NULL ,
	[TaskID] [int] NOT NULL ,
	[ProcessName] [nvarchar] (30) NOT NULL ,
	[NodeName] [nvarchar] (30) NOT NULL ,
	[OwnerPosition] [nvarchar] (200) NULL ,
	[OwnerAccount] [nvarchar] (50) NULL ,
	[AgentAccount] [nvarchar] (50) NULL ,
	[ReceiveAt] [datetime] NOT NULL ,
	[FinishAt] [datetime] NULL ,
	[SelAction] [nvarchar] (30) NULL ,
	[Share] [bit] NOT NULL ,
	[Memo] [nvarchar] (200) NULL ,
	[HumanStep] [bit] NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMInstRouting]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMInstRouting] (
	[TaskID] [int] NOT NULL ,
	[FromStepID] [int] NOT NULL ,
	[ToStepID] [int] NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMInstShare]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMInstShare] (
	[StepID] [int] NOT NULL ,
	[UserAccount] [nvarchar] (50) NOT NULL ,
	[MemberFullName] [nvarchar] (200) NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMInstTasks]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMInstTasks] (
	[TaskID] [int] IDENTITY (1, 1) NOT NULL ,
	[ProcessName] [nvarchar] (30) NOT NULL ,
	[OwnerPosition] [nvarchar](200) NOT NULL,
	[OwnerAccount] [nvarchar] (50) NULL ,
	[AgentAccount] [nvarchar] (50) NULL ,
	[CreateAt] [datetime] NOT NULL ,
	[Description] [nvarchar] (1024) NULL ,
	[FinishAt] [datetime] NULL ,
	[State] [char] (10) NOT NULL ,
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysOUFGOUs]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMSysOUFGOUs] (
	[OUID] [int] NOT NULL ,
	[UserAccount] [nvarchar] (50) NOT NULL ,
	[FGOUID] [int] NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysOUFGYWs]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMSysOUFGYWs] (
	[OUID] [int] NOT NULL ,
	[UserAccount] [nvarchar] (50) NOT NULL ,
	[YWName] [nvarchar] (30) NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysOUMembers]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMSysOUMembers] (
	[OUID] [int] NOT NULL ,
	[UserAccount] [nvarchar] (50) NOT NULL ,
	[OrderIndex] [int] NOT NULL ,
	[UserDefaultRole] [bit] NOT NULL ,
	[LeaderTitle] [nvarchar] (30) NULL ,
	[Department] [nvarchar] (50) NULL ,
	[FGOUEnabled] [bit] NOT NULL ,
	[FGYWEnabled] [bit] NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysOURoleMembers]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMSysOURoleMembers] (
	[OUID] [int] NOT NULL ,
	[RoleName] [nvarchar] (30) NOT NULL ,
	[MemberOUID] [int] NOT NULL ,
	[UserAccount] [nvarchar] (50) NOT NULL ,
	[OrderIndex] [int] NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysOURoles]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMSysOURoles] (
	[OUID] [int] NOT NULL ,
	[RoleName] [nvarchar] (30) NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysOUSupervisors]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMSysOUSupervisors] (
	[OUID] [int] NOT NULL ,
	[UserAccount] [nvarchar] (50) NOT NULL ,
	[SupervisorOUID] [int] NOT NULL ,
	[SupervisorUserAccount] [nvarchar] (50) NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysOUs]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMSysOUs] (
	[OUID] [int] IDENTITY (1, 1) NOT NULL ,
	[ParentOUID] [int] NULL ,
	[OUName] [nvarchar] (30) NOT NULL ,
	[OULevel] [nvarchar] (30) NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysUserCommonInfo]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMSysUserCommonInfo] (
	[Account] [nvarchar] (50) NOT NULL ,
	[IsOutOfOffice] [bit] NOT NULL ,
	[UseAgent] [bit] NOT NULL ,
	[Agent] [nvarchar] (300) NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysUsers]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[BPMSysUsers] (
	[Account] [nvarchar] (50) NOT NULL ,
	[Password] [char] (100) NOT NULL ,
	[SysUser] [bit] NOT NULL ,
	[DisplayName] [nvarchar] (30) NULL ,
	[Description] [nvarchar] (200) NULL ,
	[Sex] [char] (7) NULL ,
	[Birthday] [datetime] NULL ,
	[HRID] [nvarchar] (30) NULL ,
	[DateHired] [datetime] NULL ,
	[Office] [nvarchar] (100) NULL ,
	[CostCenter] [nvarchar] (30) NULL ,
	[OfficePhone] [nvarchar] (30) NULL ,
	[HomePhone] [nvarchar] (30) NULL ,
	[Mobile] [nvarchar] (30) NULL ,
	[EMail] [nvarchar] (100) NULL ,
	[WWWHomePage] [nvarchar] (200) NULL ,
	[Location] [nvarchar] (50) NULL ,
	[Age] [int] NULL ,
	[UserLevel] [int] NULL ,
	[家庭電話] [nvarchar] (50) NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[Purchase]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[Purchase] (
	[TaskID] [int] NOT NULL ,
	[RequestUser] [nvarchar] (50) NULL ,
	[Phone] [nvarchar] (50) NULL ,
	[Dept] [nvarchar] (50) NULL ,
	[RequestDate] [datetime] NULL ,
	[UseDate] [datetime] NULL ,
	[Reason] [nvarchar] (200) NULL ,
	[Amount] [float] NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[PurchaseDetail]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[PurchaseDetail] (
	[ItemID] [int] IDENTITY(1,1) NOT NULL,
	[TaskID] [int] NOT NULL ,
	[OrderIndex] [int] NOT NULL ,
	[ItemName] [nvarchar] (50) NULL ,
	[ItemCat] [nvarchar] (50) NULL ,
	[ItemDesc] [nvarchar] (50) NULL ,
	[Price] [float] NULL ,
	[Qty] [float] NULL ,
	[SubTotal] [float] NULL ,
	[RequestUser] [nvarchar] (50) NULL,
	CONSTRAINT [PK_PurchaseDetail] PRIMARY KEY CLUSTERED 
	(
		[ItemID] ASC
	) ON [PRIMARY]
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SetProductCat]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[SetProductCat] (
	[ProductCat] [nvarchar] (30) NOT NULL 
) ON [PRIMARY]

ALTER TABLE [dbo].[SetProductCat] WITH NOCHECK ADD 
	CONSTRAINT [PK_SetProductCat] PRIMARY KEY  CLUSTERED 
	(
		[ProductCat]
	)  ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[SetProduct]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
CREATE TABLE [dbo].[SetProduct] (
	[ProdCat] [nvarchar] (50) NOT NULL ,
	[ProdName] [nvarchar] (50) NOT NULL ,
	[ProdDesc] [nvarchar] (50) NULL ,
	[Price] [float] NOT NULL 
) ON [PRIMARY]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DF_BPMInstProcSteps_ReceiveAt]'))
ALTER TABLE [dbo].[BPMInstProcSteps] ADD 
	CONSTRAINT [DF_BPMInstProcSteps_ReceiveAt] DEFAULT (getdate()) FOR [ReceiveAt],
	CONSTRAINT [DF_BPMInstProcSteps_Share] DEFAULT (0) FOR [Share],
	CONSTRAINT [DF_BPMInstProcSteps_HumanStep] DEFAULT (1) FOR [HumanStep]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DF_BPMInstTasks_CreateAt]'))
ALTER TABLE [dbo].[BPMInstTasks] ADD 
	CONSTRAINT [DF_BPMInstTasks_CreateAt] DEFAULT (getdate()) FOR [CreateAt],
	CONSTRAINT [DF_BPMInstTasks_Status] DEFAULT ('running') FOR [State]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DF_BPMSysOUMembers_OUFGEnabled]'))
ALTER TABLE [dbo].[BPMSysOUMembers] ADD 
	CONSTRAINT [DF_BPMSysOUMembers_OUFGEnabled] DEFAULT (0) FOR [FGOUEnabled],
	CONSTRAINT [DF_BPMSysOUMembers_FGYWEnabled] DEFAULT (0) FOR [FGYWEnabled]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DF_BPMSysUserCommonInfo_UseAgent]'))
ALTER TABLE [dbo].[BPMSysUserCommonInfo] ADD 
	CONSTRAINT [DF_BPMSysUserCommonInfo_UseAgent] DEFAULT (0) FOR [UseAgent]
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DF_BPMSysUsers_SystemUser]'))
ALTER TABLE [dbo].[BPMSysUsers] ADD 
	CONSTRAINT [DF_BPMSysUsers_SystemUser] DEFAULT (0) FOR [SysUser]
GO

/********************************************* ver3.01 DBUpdate *********************************************/

if exists(select * from syscolumns where name = 'InitiatorPosition' and id = object_id('BPMInstTasks'))
BEGIN
EXEC sp_rename 'BPMInstTasks.InitiatorPosition', 'OwnerPosition', 'COLUMN'
EXEC sp_rename 'BPMInstTasks.InitiatorAccount', 'OwnerAccount', 'COLUMN'
ALTER TABLE BPMInstTasks ADD AgentAccount [nvarchar] (50) NULL
END
GO

if exists(select * from syscolumns where name = 'RecipientPosition' and id = object_id('BPMInstProcSteps'))
BEGIN
EXEC sp_rename 'BPMInstProcSteps.RecipientPosition', 'OwnerPosition', 'COLUMN'
EXEC sp_rename 'BPMInstProcSteps.RecipientAccount', 'OwnerAccount', 'COLUMN'
ALTER TABLE BPMInstProcSteps ADD AgentAccount [nvarchar] (50) NULL
END
GO

if not exists(select * from syscolumns where name = 'SerialNum' and id = object_id('BPMInstTasks'))
BEGIN
ALTER TABLE BPMInstTasks ADD SerialNum [nvarchar] (50) NULL
END
GO

/********************************************* ver3.02 DBUpdate *********************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[IX_BPMSysOUFGOUs]'))
ALTER TABLE BPMSysOUFGOUs DROP CONSTRAINT IX_BPMSysOUFGOUs
GO

/********************************************* ver3.03 DBUpdate *********************************************/
if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysSnapshot]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysSnapshot] (
	[TaskID] [int] NOT NULL ,
	[Version] [int] NOT NULL ,
	[CreateDate] [datetime] DEFAULT (getdate()) NOT NULL ,
	[VerDesc] [nvarchar] (500) NULL ,
	[FormData] [ntext]  NULL 
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

/********************************************* ver3.04 DBUpdate *********************************************/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DF_BPMInstTasks_Deleted]'))
ALTER TABLE BPMInstTasks DROP CONSTRAINT DF_BPMInstTasks_Deleted
GO

if exists(select * from syscolumns where name = 'Deleted' and id = object_id('BPMInstTasks'))
BEGIN
ALTER TABLE BPMInstTasks DROP COLUMN Deleted
END
GO

if not exists(select * from syscolumns where name = 'OptUser' and id = object_id('BPMInstTasks'))
BEGIN
ALTER TABLE BPMInstTasks ADD OptUser [nvarchar] (50) NULL
END
GO

if not exists(select * from syscolumns where name = 'OptAt' and id = object_id('BPMInstTasks'))
BEGIN
ALTER TABLE BPMInstTasks ADD OptAt [datetime] NULL
END
GO

if not exists(select * from syscolumns where name = 'OptMemo' and id = object_id('BPMInstTasks'))
BEGIN
ALTER TABLE BPMInstTasks ADD OptMemo [nvarchar] (50) NULL
END
GO

if not exists(select * from syscolumns where name = 'RSID' and id = object_id('BPMSysOUs'))
BEGIN
ALTER TABLE BPMSysOUs ADD RSID [char] (36) NOT NULL DEFAULT(newid())
END
GO

if not exists(select * from syscolumns where name = 'SID' and id = object_id('BPMSysOUs'))
BEGIN
ALTER TABLE BPMSysOUs ADD SID [char] (36) NOT NULL DEFAULT(newid())
END
GO

if not exists(select * from syscolumns where name = 'SID' and id = object_id('BPMSysUsers'))
BEGIN
ALTER TABLE BPMSysUsers ADD SID [char] (36) NOT NULL DEFAULT(newid())
END
GO


if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSecurityACL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSecurityACL] (
	[IDA] [int] IDENTITY (1, 1) NOT NULL ,
	[RoleType] [varchar] (30) NOT NULL ,
	[RoleParam1] [ntext] NOT NULL ,
	[RoleParam2] [nvarchar] (50) NULL ,
	[RoleParam3] [nvarchar] (50) NULL ,
	[RSID] [nvarchar] (400) NOT NULL ,
	[AllowPermision] [nvarchar] (200) NULL ,
	[DenyPermision] [nvarchar] (200) NULL ,
	[Inherited] [bit] NOT NULL ,
	[Inheritable] [bit] NOT NULL ,
	[CreateDate] [datetime] NOT NULL ,
	[CreateBy] [nvarchar] (50) NOT NULL 
) ON [PRIMARY]
INSERT INTO BPMSecurityACL VALUES('GroupSID','S_GS_90674E5E-AC3C-4032-9EDF-7477F2247542',NULL,NULL,'1CCFE783-7FBF-4582-B2F3-CE11F57917E7','Read',NULL,0,1,getdate(),'sa')
INSERT INTO BPMSecurityACL VALUES('GroupSID','S_GS_90674E5E-AC3C-4032-9EDF-7477F2247542',NULL,NULL,'7CBB72A3-1731-4212-8C5C-9C4E0C86FE31','Read,Execute',NULL,0,1,getdate(),'sa')
INSERT INTO BPMSecurityACL VALUES('GroupSID','S_GS_90674E5E-AC3C-4032-9EDF-7477F2247542',NULL,NULL,'036F6F25-A004-4109-962F-AD9F0A8F516A','Read',NULL,0,1,getdate(),'sa')
INSERT INTO BPMSecurityACL VALUES('GroupSID','S_GS_90674E5E-AC3C-4032-9EDF-7477F2247542',NULL,NULL,'45D14DE0-13F1-47de-80D5-CBE657BD39C9','Read,Execute',NULL,0,1,getdate(),'sa')
INSERT INTO BPMSecurityACL VALUES('GroupSID','S_GS_90674E5E-AC3C-4032-9EDF-7477F2247542',NULL,NULL,'79A6D413-827D-4dfa-AEA3-4C64CA715975','Read',NULL,0,1,getdate(),'sa')
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSecurityGroupMembers]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSecurityGroupMembers] (
	[GroupName] [nvarchar] (50) NOT NULL ,
	[UserAccount] [nvarchar] (50) NOT NULL 
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSecurityGroups]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSecurityGroups] (
	[GroupName] [nvarchar] (50) NOT NULL ,
	[SID] [nvarchar] (50) NOT NULL 
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSecurityTACL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSecurityTACL] (
	[TaskID] [int] NOT NULL ,
	[SID] [nvarchar] (50) NOT NULL ,
	[AllowRead] [bit] NOT NULL ,
	[AllowAdmin] [bit] NOT NULL ,
	[ShareByUser] [bit] NOT NULL ,
	[CreateDate] [datetime] NULL ,
	[CreateBy] [nvarchar] (50) NULL 
) ON [PRIMARY]
END
GO

if not exists(select * from syscolumns where name = 'HandlerAccount' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD HandlerAccount [nvarchar] (50) NULL
END
GO

/********************************************* ver3.05 DBUpdate *********************************************/

if not exists(select * from syscolumns where name = 'LnkID' and id = object_id('BPMSysOUSupervisors'))
BEGIN
ALTER TABLE BPMSysOUSupervisors ADD LnkID [int] IDENTITY (1, 1) NOT NULL
END
GO

if not exists(select * from syscolumns where name = 'FGYWEnabled' and id = object_id('BPMSysOUSupervisors'))
BEGIN
ALTER TABLE BPMSysOUSupervisors ADD FGYWEnabled [bit] NOT NULL DEFAULT(0)
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysOUSupervisorFGYWs]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysOUSupervisorFGYWs] (
	[LnkID] [int] NOT NULL ,
	[YWName] [nvarchar] (30) NULL 
) ON [PRIMARY]
END
GO

if exists(select * from BPMSecurityGroups where GroupName='Administrator' AND SID='S_GS_B639EB43-67D7-42fb-BD2E-B754BB11915B')
BEGIN
DELETE BPMSecurityGroups WHERE GroupName='Administrators'
UPDATE BPMSecurityGroups SET GroupName='Administrators' WHERE GroupName='Administrator' AND SID='S_GS_B639EB43-67D7-42fb-BD2E-B754BB11915B'
UPDATE BPMSecurityGroupMembers SET GroupName='Administrators' WHERE GroupName='Administrator'
END
GO

if not exists(select * from syscolumns where name = 'RejectedNotifys' and id = object_id('BPMSysUserCommonInfo'))
BEGIN
ALTER TABLE BPMSysUserCommonInfo ADD RejectedNotifys [nvarchar] (200) NULL
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysSettings]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysSettings] (
	[ItemName] [nvarchar] (50) NOT NULL ,
	[ItemValue] [nvarchar] (1024) NULL 
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysMessagesFailed]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysMessagesFailed] (
	[MessageID] [int] NOT NULL ,
	[ProviderName] [nvarchar] (30) NOT NULL ,
	[Address] [nvarchar] (100) NOT NULL ,
	[Title] [nvarchar] (500) NULL ,
	[Message] [ntext] NULL ,
	[CreateAt] [datetime] NOT NULL ,
	[FailCount] [int] NOT NULL ,
	[RemoveAt] [datetime] NOT NULL 
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysMessagesQueue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysMessagesQueue] (
	[MessageID] [int] IDENTITY (1, 1) NOT NULL ,
	[ProviderName] [nvarchar] (30) NOT NULL ,
	[Address] [nvarchar] (100) NOT NULL ,
	[Title] [nvarchar] (500) NULL ,
	[Message] [ntext] NULL ,
	[CreateAt] [datetime] NOT NULL ,
	[LastSendAt] [datetime] NULL ,
	[FailCount] [int] NOT NULL 
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysMessagesSucceed]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysMessagesSucceed] (
	[MessageID] [int] NOT NULL ,
	[ProviderName] [nvarchar] (30) NOT NULL ,
	[Address] [nvarchar] (100) NOT NULL ,
	[Title] [nvarchar] (500) NULL ,
	[Message] [ntext] NULL ,
	[CreateAt] [datetime] NOT NULL ,
	[SendAt] [datetime] NOT NULL 
) ON [PRIMARY]
END
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_NewTaskNormal_Title')
INSERT INTO BPMSysSettings VALUES('Mail_NewTaskNormal_Title',N'[工作流][新任務]提交人：<%=Initiator.UserFriendlyName%>，業務名：<%=Context.Current.Process.Name%>，流水號：<%=Context.Current.Task.SerialNum%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_NewTaskNormal_Message')
INSERT INTO BPMSysSettings VALUES('Mail_NewTaskNormal_Message',N'業務名：<%=Context.Current.Process.Name%>
提交人：<%=Initiator.UserFriendlyName%>
提交日期：<%=Context.Current.Task.CreateAt.ToString()%>
流水號：<%=Context.Current.Task.SerialNum%>
來自：<%=Context.Current.LoginUser.FriendlyName%>
內容摘要：
<%=Context.Current.Task.Description%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_Approved_Title')
INSERT INTO BPMSysSettings VALUES('Mail_Approved_Title',N'[工作流][已同意]業務名：<%=Context.Current.Process.Name%>，流水號：<%=Context.Current.Task.SerialNum%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_Approved_Message')
INSERT INTO BPMSysSettings VALUES('Mail_Approved_Message',N'業務名：<%=Context.Current.Process.Name%>
提交人：<%=Initiator.UserFriendlyName%>
提交日期：<%=Context.Current.Task.CreateAt.ToString()%>
流水號：<%=Context.Current.Task.SerialNum%>
同意人：<%=Context.Current.LoginUser.FriendlyName%>
同意日期：<%=Context.Current.Task.FinishAt.ToString()%>
內容摘要：
<%=Context.Current.Task.Description%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_Rejected_Title')
INSERT INTO BPMSysSettings VALUES(N'Mail_Rejected_Title',N'[工作流][已拒絕]業務名：<%=Context.Current.Process.Name%>，流水號：<%=Context.Current.Task.SerialNum%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_Rejected_Message')
INSERT INTO BPMSysSettings VALUES('Mail_Rejected_Message',N'業務名：<%=Context.Current.Process.Name%>
提交人：<%=Initiator.UserFriendlyName%>
提交日期：<%=Context.Current.Task.CreateAt.ToString()%>
流水號：<%=Context.Current.Task.SerialNum%>
拒絕人：<%=Context.Current.LoginUser.FriendlyName%>
拒絕日期：<%=Context.Current.Task.FinishAt.ToString()%>
內容摘要：
<%=Context.Current.Task.Description%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_Aborted_Title')
INSERT INTO BPMSysSettings VALUES('Mail_Aborted_Title',N'[工作流][已撤銷]業務名：<%=Context.Current.Process.Name%>，流水號：<%=Context.Current.Task.SerialNum%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_Aborted_Message')
INSERT INTO BPMSysSettings VALUES(N'Mail_Aborted_Message',N'業務名：<%=Context.Current.Process.Name%>
提交人：<%=Initiator.UserFriendlyName%>
提交日期：<%=Context.Current.Task.CreateAt.ToString()%>
流水號：<%=Context.Current.Task.SerialNum%>
撤消日期：<%=DateTime.Now.ToString()%>
撤銷人：<%=Context.Current.LoginUser.FriendlyName%>
內容摘要：
<%=Context.Current.Task.Description%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_Deleted_Title')
INSERT INTO BPMSysSettings VALUES('Mail_Deleted_Title',N'[工作流][已刪除]業務名：<%=Context.Current.Process.Name%>，流水號：<%=Context.Current.Task.SerialNum%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_Deleted_Message')
INSERT INTO BPMSysSettings VALUES('Mail_Deleted_Message',N'業務名：<%=Context.Current.Process.Name%>
提交人：<%=Initiator.UserFriendlyName%>
提交日期：<%=Context.Current.Task.CreateAt.ToString()%>
流水號：<%=Context.Current.Task.SerialNum%>
刪除日期：<%=DateTime.Now.ToString()%>
刪除人：<%=Context.Current.LoginUser.FriendlyName%>
內容摘要：
<%=Context.Current.Task.Description%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_StepStopHumanOpt_Title')
INSERT INTO BPMSysSettings VALUES('Mail_StepStopHumanOpt_Title',N'[工作流][步驟中止]提交人：<%=Initiator.UserFriendlyName%>，業務名：<%=Context.Current.Process.Name%>，流水號：<%=Context.Current.Task.SerialNum%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_StepStopHumanOpt_Message')
INSERT INTO BPMSysSettings VALUES('Mail_StepStopHumanOpt_Message',N'被中止步驟：<%=Context.Current.Step.NodeName%>

任務基本信息：
業務名：<%=Context.Current.Process.Name%>
提交人：<%=Initiator.UserFriendlyName%>
提交日期：<%=Context.Current.Task.CreateAt.ToString()%>
流水號：<%=Context.Current.Task.SerialNum%>

任務被執行了以下操作：
操作人：<%=Context.Current.LoginUser.FriendlyName%>\n執行操作：<%=Context.Current.Step.SelActionDisplayString%>
操作日期：<%=DateTime.Now.ToString()%>

內容摘要：
<%=Context.Current.Task.Description%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_StepStopVoteFinished_Title')
INSERT INTO BPMSysSettings VALUES('Mail_StepStopVoteFinished_Title',N'[工作流][投票結束]提交人：<%=Initiator.UserFriendlyName%>，業務名：<%=Context.Current.Process.Name%>，流水號：<%=Context.Current.Task.SerialNum%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_StepStopVoteFinished_Message')
INSERT INTO BPMSysSettings VALUES('Mail_StepStopVoteFinished_Message',N'業務名：<%=Context.Current.Process.Name%>
提交人：<%=Initiator.UserFriendlyName%>
提交日期：<%=Context.Current.Task.CreateAt.ToString()%>
流水號：<%=Context.Current.Task.SerialNum%>
內容摘要：
<%=Context.Current.Task.Description%>')
GO


/********************************************* ver3.08 DBUpdate *********************************************/
if not exists(select * from syscolumns where name = 'SubNodeName' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD SubNodeName [nvarchar] (30) NULL
END
GO

if not exists(select * from syscolumns where name = 'Error' and id = object_id('BPMSysMessagesFailed'))
BEGIN
ALTER TABLE BPMSysMessagesFailed ADD Error [ntext] NULL
END
GO

if not exists(select * from syscolumns where name = 'LogonProvider' and id = object_id('BPMSysUsers'))
BEGIN
ALTER TABLE BPMSysUsers ADD LogonProvider [nvarchar] (30) NULL
END
GO

if not exists(select * from syscolumns where name = 'AutoProcess' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD AutoProcess [bit] DEFAULT(0) NOT NULL
END
GO

if not exists(select * from syscolumns where name = 'Comments' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD Comments [ntext] NULL
END
GO

/********************************************* ver3.09 DBUpdate *********************************************/
if not exists(select * from syscolumns where name = 'Level' and id = object_id('BPMSysOUMembers'))
BEGIN
ALTER TABLE BPMSysOUMembers ADD [Level] [int] DEFAULT(0) NOT NULL
END
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_TimeoutNotify_Title')
INSERT INTO BPMSysSettings VALUES('Mail_TimeoutNotify_Title',N'[工作流][催辦通知]提交人：<%=Initiator.UserFriendlyName%>，業務名：<%=Context.Current.Process.Name%>，流水號：<%=Context.Current.Task.SerialNum%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_TimeoutNotify_Message')
INSERT INTO BPMSysSettings VALUES(N'Mail_TimeoutNotify_Message',
'請速辦理以下業務：
業務名：<%=Context.Current.Process.Name%>
提交人：<%=Initiator.UserFriendlyName%>
提交日期：<%=Context.Current.Task.CreateAt.ToString()%>
流水號：<%=Context.Current.Task.SerialNum%>
內容摘要：
<%=Context.Current.Task.Description%>')
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysTimeoutQueue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysTimeoutQueue] (
	[ItemType] [nvarchar](30) NOT NULL,
	[ObjectID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ExpireDate] [datetime] NOT NULL,
	[LastProcessDate] [datetime] NULL,
	[FailCount] [int] NULL
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysTimeoutSucceed]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysTimeoutSucceed] (
	[ItemType] [nvarchar](30) NOT NULL,
	[ObjectID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ExpireDate] [datetime] NOT NULL,
	[DoneDate] [datetime] NOT NULL,
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysTimeoutFailed]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysTimeoutFailed] (
	[ItemType] [nvarchar](30) NOT NULL,
	[ObjectID] [int] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ExpireDate] [datetime] NOT NULL,
	[RemoveDate] [datetime] NOT NULL,
	[FailCount] [int] NOT NULL,
	[Error] [ntext] NULL,
) ON [PRIMARY]
END
GO

if not exists(select * from syscolumns where name = 'UsedMinutes' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD UsedMinutes [int] NULL
ALTER TABLE BPMInstProcSteps ADD UsedMinutesWork [int] NULL
END
GO

/********************************************* ver3.10 DBUpdate *********************************************/
if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysAppLog]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysAppLog](
	[ObjectID] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_BPMSysAppLog_ObjectID]  DEFAULT (newid()),
	[LogDate] [datetime] NOT NULL,
	[ClientIP] [char](36) NOT NULL,
	[UserAccount] [nvarchar](50) NOT NULL,
	[Action] [nvarchar](50) NOT NULL,
	[ActParam1] [nvarchar](50) NULL,
	[ActParam2] [nvarchar](50) NULL,
	[ActParam3] [nvarchar](50) NULL,
	[TickUsed] [int] NOT NULL,
	[Succeed] [bit] NOT NULL,
	[Error] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysAppLogACL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysAppLogACL](
	[ItemID] [uniqueidentifier] ROWGUIDCOL  NOT NULL CONSTRAINT [DF_BPMSysAppLogACL_ObjectID]  DEFAULT (newid()),
	[CreateDate] [datetime] NOT NULL CONSTRAINT [DF_BPMSysAppLogACL_CreateDate]  DEFAULT (getdate()),
	[ObjectID] [uniqueidentifier] NOT NULL,
	[SID] [nvarchar](50) NULL
) ON [PRIMARY]
END
GO

if not exists(select * from syscolumns where name = 'RecedeFromStep' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD RecedeFromStep [int] NULL
END
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_RecedeBack_Title')
INSERT INTO BPMSysSettings VALUES('Mail_RecedeBack_Title',N'[工作流][退回通知]提交人：<%=Initiator.UserFriendlyName%>，業務名：<%=Context.Current.Process.Name%>，流水號：<%=Context.Current.Task.SerialNum%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_RecedeBack_Message')
INSERT INTO BPMSysSettings VALUES('Mail_RecedeBack_Message',N'業務名：<%=Context.Current.Process.Name%>
提交人：<%=Initiator.UserFriendlyName%>
提交日期：<%=Context.Current.Task.CreateAt.ToString()%>
流水號：<%=Context.Current.Task.SerialNum%>
來自：<%=Context.Current.LoginUser.FriendlyName%>
內容摘要：
<%=Context.Current.Task.Description%>')
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMInstDrafts]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMInstDrafts](
	[DraftID] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[ProcessName] [nvarchar](50) NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[ModifyDate] [datetime] NOT NULL,
	[Account] [nvarchar](50) NOT NULL,
	[OwnerPosition] [nvarchar](200) NOT NULL,
	[OwnerAccount] [nvarchar](50) NOT NULL,
	[FormData] [ntext] NOT NULL,
	[Description] [nvarchar](200) NULL,
	[Comment] [nvarchar](200) NULL
) ON [PRIMARY]
END
GO

if not exists(select * from syscolumns where name = 'TimeoutNotifyCount' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD TimeoutNotifyCount [int] NOT NULL DEFAULT(0);
END
GO

/********************************************* ver3.20a DBUpdate *********************************************/
if not exists(select * from syscolumns where name = 'FormDataSetID' and id = object_id('BPMInstTasks'))
BEGIN
ALTER TABLE BPMInstTasks ADD FormDataSetID [int] NULL;
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMInstFormDataSets]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMInstFormDataSets](
	[FormDataSetID] [int] IDENTITY(1,1) NOT NULL,
	[FormDataSetDesc] [nvarchar](50) NULL
) ON [PRIMARY]
END

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMInstFormDataSetLinks]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMInstFormDataSetLinks](
	[FormDataSetID] [int] NOT NULL,
	[DataSourceName] [nvarchar](50) NULL,
	[TableName] [nvarchar](50) NOT NULL,
	[KeyValue] [nvarchar](50) NOT NULL
) ON [PRIMARY]
END
GO

/********************************************* ver3.20g DBUpdate *********************************************/
if not exists(select * from syscolumns where name = 'OutOfOfficeState' and id = object_id('BPMSysUserCommonInfo'))
BEGIN
ALTER TABLE BPMSysUserCommonInfo ADD OutOfOfficeState [nvarchar](50) NULL;
ALTER TABLE BPMSysUserCommonInfo ADD OutOfOfficeFrom [datetime] NULL;
ALTER TABLE BPMSysUserCommonInfo ADD OutOfOfficeTo [datetime] NULL;
END
GO

if exists(select * from dbo.sysobjects where id = object_id(N'[dbo].[DF_BPMSysUserComInfo_IsOutOfOffice]'))
BEGIN
ALTER TABLE BPMSysUserCommonInfo DROP [DF_BPMSysUserComInfo_IsOutOfOffice];
END
GO

if exists(select * from syscolumns where name = 'IsOutOfOffice' and id = object_id('BPMSysUserCommonInfo'))
BEGIN
EXEC ('UPDATE BPMSysUserCommonInfo SET OutOfOfficeState=''Out'' WHERE IsOutOfOffice = 1');
ALTER TABLE BPMSysUserCommonInfo DROP COLUMN IsOutOfOffice;
END
GO

/********************************************* ver3.20j DBUpdate *********************************************/
if not exists(select * from syscolumns where name = 'RisedConsignID' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD RisedConsignID [int] NULL;
ALTER TABLE BPMInstProcSteps ADD BelongConsignID [int] NULL;
ALTER TABLE BPMInstProcSteps ADD ConsignOwnerAccount [nvarchar](50) NULL;
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMInstConsign]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMInstConsign](
	[ConsignID] [int] IDENTITY (1, 1) NOT NULL ,
	[Enabled] [bit] DEFAULT(1) NOT NULL,
	[OwnerStepID] [int] NOT NULL,
	[ReturnType] [nvarchar](20) NOT NULL,
	[RoutingType] [nvarchar](20) NOT NULL
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMInstConsignUsers]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMInstConsignUsers](
	[ConsignID] [int] NOT NULL ,
	[UserAccount] [nvarchar](50) NOT NULL
) ON [PRIMARY]
END
GO

/********************************************* ver3.20r DBUpdate *********************************************/
if not exists(select * from syscolumns where name = 'TimeoutFirstNotifyDate' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD TimeoutFirstNotifyDate [datetime] NULL;
ALTER TABLE BPMInstProcSteps ADD TimeoutDeadline [datetime] NULL;
ALTER TABLE BPMInstProcSteps ADD StandardMinutesWork [int] NULL;
END
GO

/********************************************* ver3.20x DBUpdate *********************************************/
if not exists (select * from BPMSysUsers where Account='sa')
INSERT INTO BPMSysUsers(Account,Password,SysUser,SID) VALUES('sa','',1,'9864A43A-876C-46e6-829B-A7223D8B6B76')
GO

--if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysSeeks]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
--BEGIN
--CREATE TABLE [dbo].[BPMSysSeeks](
--	[DataSourceName] [nvarchar](50) NULL,
--	[TableName] [nvarchar](50) NOT NULL,
--	[ColumnName] [nvarchar](50) NOT NULL,
--	[Prefix] [nvarchar](50) NULL,
--	[Columns] [int] NOT NULL,
--	[CurrSeekValue] [int] NOT NULL,
--	[ActiveDate] [datetime] NOT NULL
--) ON [PRIMARY]
--END
--GO

--if not exists(select * from syscolumns where name = 'DataSourceName' and id = object_id('BPMSysSeeks'))
--BEGIN
--ALTER TABLE BPMSysSeeks ADD DataSourceName [nvarchar](50) NULL;
--END
--GO

/********************************************* ver3.40i DBUpdate *********************************************/
if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysTaskRule]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysTaskRule](
	[RuleID] [int] IDENTITY(1,1) NOT NULL,
	[Enabled] [bit] NOT NULL,
	[Account] [nvarchar](50) NOT NULL,
	[OrderIndex] [int] NOT NULL,
	[RuleType] [nvarchar](50) NOT NULL,
	[ProcessDefineType] [nvarchar](50) NULL
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysTaskRuleProcess]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysTaskRuleProcess](
	[RuleID] [int] NOT NULL,
	[OrderIndex] [int] NOT NULL,
	[ProcessName] [nvarchar](50) NOT NULL,
	[Condition] [ntext] NULL
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysUserElement]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysUserElement](
	[ParentObjectID] [int] NOT NULL,
	[Category] [nvarchar](50) NOT NULL,
	[OrderIndex] [int] NOT NULL,
	[UserElementType] [nvarchar](50) NOT NULL,
	[SParam1] [nvarchar](256) NULL,
	[SParam2] [nvarchar](256) NULL,
	[SParam3] [nvarchar](256) NULL,
	[SParam4] [nvarchar](256) NULL,
	[SParam5] [nvarchar](256) NULL,
	[LParam1] [int] NULL,
	[LParam2] [int] NULL,
	[LParam3] [int] NULL,
	[Include] [bit] NOT NULL,
	[Exclude] [bit] NOT NULL,
	[Express] [ntext] NULL
) ON [PRIMARY]
END
GO

/********************************************* ver3.50a DBUpdate *********************************************/
if not exists(select * from syscolumns where name = 'Code' and id = object_id('BPMSysOUs'))
BEGIN
ALTER TABLE BPMSysOUs ADD Code [nvarchar](50) NULL;
END
GO

/********************************************* ver3.50a DBUpdate *********************************************/
if not exists(select * from syscolumns where name = 'Disabled' and id = object_id('BPMSysUsers'))
BEGIN
ALTER TABLE BPMSysUsers ADD Disabled [bit] NOT NULL DEFAULT (0);
END
GO

/********************************************* ver3.50d DBUpdate *********************************************/
if not exists(select * from syscolumns where name = 'ItemID' and id = object_id('BPMSysTimeoutQueue'))
BEGIN
ALTER TABLE BPMSysTimeoutQueue ADD ItemID [int] IDENTITY (1, 1) NOT NULL;
ALTER TABLE BPMSysTimeoutFailed ADD ItemID [int] IDENTITY (1, 1) NOT NULL;
ALTER TABLE BPMSysTimeoutSucceed ADD ItemID [int] IDENTITY (1, 1) NOT NULL;
ALTER TABLE BPMSysTimeoutFailed ADD QueueItemID [int] NOT NULL DEFAULT(-1);
ALTER TABLE BPMSysTimeoutSucceed ADD QueueItemID [int] NOT NULL DEFAULT(-1);
END
GO

if not exists(select * from syscolumns where name = 'BatchApprove' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD BatchApprove [bit] DEFAULT(0) NOT NULL
END
GO

/********************************************* ver3.50l DBUpdate *********************************************/
if not exists(select * from syscolumns where name = 'Posted' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD Posted [bit] DEFAULT(0) NOT NULL;
INSERT BPMSysSettings(ItemName,ItemValue) VALUES('Flag_PostedColumnCreated','1');
END
GO

if exists (select * from BPMSysSettings WHERE ItemName = 'Flag_PostedColumnCreated')
BEGIN
Update BPMInstProcSteps SET Posted=1 WHERE StepID IN(SELECT min(StepID) FROM BPMInstProcSteps Group By TaskID);
DELETE FROM BPMSysSettings WHERE ItemName = 'Flag_PostedColumnCreated';
END
GO

if not exists(select * from syscolumns where name = 'FormSaved' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD FormSaved [bit] DEFAULT(1) NOT NULL;
END
GO

/********************************************* ver3.50x DBUpdate *********************************************/
if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_IndicateTask_Title')
INSERT INTO BPMSysSettings VALUES('Mail_IndicateTask_Title',N'[工作流][閱示]邀請人：<%=Context.Current.LoginUser.FriendlyName%>，業務名：<%=Context.Current.Process.Name%>，流水號：<%=Context.Current.Task.SerialNum%>')
GO

if not exists (select * from BPMSysSettings WHERE ItemName = 'Mail_IndicateTask_Message')
INSERT INTO BPMSysSettings VALUES('Mail_IndicateTask_Message',
N'業務名：<%=Context.Current.Process.Name%>
提交人：<%=Initiator.UserFriendlyName%>
提交日期：<%=Context.Current.Task.CreateAt.ToString()%>
流水號：<%=Context.Current.Task.SerialNum%>
來自：<%=Context.Current.LoginUser.FriendlyName%>
內容摘要：
<%=Context.Current.Task.Description%>')
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSecurityUserResource]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSecurityUserResource](
	[RSID] [nvarchar](50) NOT NULL CONSTRAINT [DF_BPMSecurityUserResource_RSID]  DEFAULT (newid()),
	[ParentRSID] [nvarchar](50) NULL,
	[OrderIndex] [int] NOT NULL CONSTRAINT [DF_BPMSecurityUserResource_OrderIndex]  DEFAULT ((0)),
	[ResourceName] [nvarchar](200) NOT NULL
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSecurityUserResourceACL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSecurityUserResourceACL](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[RoleType] [varchar](30) NOT NULL,
	[RoleParam1] [ntext] NOT NULL,
	[RoleParam2] [nvarchar](50) NULL,
	[RoleParam3] [nvarchar](50) NULL,
	[RSID] [nvarchar](50) NOT NULL,
	[AllowPermision] [nvarchar](200) NULL,
	[DenyPermision] [nvarchar](200) NULL,
	[LeadershipTokenPermision] [nvarchar](200) NULL,
	[Inherited] [bit] NOT NULL,
	[Inheritable] [bit] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[CreateBy] [nvarchar](50) NOT NULL
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSecurityUserResourcePerm]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSecurityUserResourcePerm](
	[RSID] [nvarchar](50) NOT NULL,
	[PermName] [nvarchar](50) NOT NULL,
	[OrderIndex] [int] NOT NULL CONSTRAINT [DF_BPMSecurityUserResourcePerm_OrderIndex]  DEFAULT ((0)),
	[PermDisplayName] [nvarchar](50) NOT NULL,
	[PermType] [nvarchar](50) NOT NULL,
	[LeadershipTokenEnabled] [bit] NOT NULL
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSecurityRecordACL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSecurityRecordACL](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TableName] [nvarchar](50) NOT NULL,
	[KeyValue] [nvarchar](50) NOT NULL,
	[SIDType] [varchar](30) NOT NULL,
	[SID] [nvarchar](50) NOT NULL,
	[Permision] [nvarchar](50) NOT NULL,
	[LeadershipToken] [bit] NOT NULL,
	[PublicByUser] [bit] NOT NULL,
	[CreateDate] [datetime] NULL,
	[CreateBy] [nvarchar](50) NULL,
	[Comments] [nvarchar](500) NULL
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[YZAppFileConvert]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[YZAppFileConvert](
	[ItemGuid] [varchar](50) NOT NULL,
	[CreateDate] [datetime] NULL CONSTRAINT [DF_YZAppFileConvert_CreateDate]  DEFAULT (getdate()),
	[FileBody] [image] NOT NULL,
	[Processed] [bit] NULL CONSTRAINT [DF_YZAppFileConvert_Processed]  DEFAULT ((0)),
	[Image] [image] NULL,
	[Width] [int] NULL CONSTRAINT [DF_YZAppFileConvert_Width]  DEFAULT ((0)),
	[Height] [int] NULL CONSTRAINT [DF_YZAppFileConvert_Height]  DEFAULT ((0)),
	[ErrorMsg] [ntext] NULL
) ON [PRIMARY]
END
GO

if not exists(select * from syscolumns where name = 'SID' and id = object_id('BPMSysOURoles'))
BEGIN
ALTER TABLE BPMSysOURoles ADD SID [nvarchar](50) DEFAULT(NEWID()) NOT NULL;
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSecurityExtToken]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSecurityExtToken](
	[Account] [nvarchar](50) NOT NULL,
	[SIDType] [nvarchar](20) NOT NULL,
	[SID] [nvarchar](50) NOT NULL,
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[YZAppAttachment]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[YZAppAttachment](
	[FileID] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](256) NULL,
	[Ext] [nvarchar](8) NULL,
	[Size] [int] NULL,
	[LastUpdate] [datetime] NULL DEFAULT (getdate()),
	[OwnerAccount] [nvarchar](30) NULL,
) ON [PRIMARY]
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[iSYSFactory]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[iSYSFactory](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Remark] [nvarchar](512) NULL,
	[MapX] [int] NULL,
	[MapY] [int] NULL
) ON [PRIMARY]
END
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'v_iSYSLoginStation')
DROP VIEW [dbo].[v_iSYSLoginStation]
GO

CREATE VIEW [dbo].[v_iSYSLoginStation]
AS
SELECT Code AS ID, Name, MapX, MapY
FROM dbo.iSYSFactory
GO

if not exists(select * from syscolumns where name = 'NameSpell' and id = object_id('BPMSysUsers'))
BEGIN
ALTER TABLE BPMSysUsers ADD NameSpell [nvarchar] (50) NULL
END
GO

if not exists(select * from BPMSecurityUserResource where RSID='efec54e1-bb63-43f8-8635-3b07d1199309')
BEGIN
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'efec54e1-bb63-43f8-8635-3b07d1199309',NULL,0,N'系統管理')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'efec54e1-bb63-43f8-8635-3b07d1199309',N'Execute',0,N'功能權限',N'Module',0)
END
GO

if not exists(select * from BPMSecurityUserResource where RSID='E0DCB7ED-1289-40e2-A945-6F8E1578BA2A')
BEGIN
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'E0DCB7ED-1289-40e2-A945-6F8E1578BA2A',N'efec54e1-bb63-43f8-8635-3b07d1199309',0,N'流程管理')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'E0DCB7ED-1289-40e2-A945-6F8E1578BA2A',N'Execute',0,N'功能權限',N'Module',0)
END
GO

if not exists(select * from BPMSecurityUserResource where RSID='A6F94246-9BCA-409c-9938-5A4FC963FF02')
BEGIN
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'A6F94246-9BCA-409c-9938-5A4FC963FF02',N'E0DCB7ED-1289-40e2-A945-6F8E1578BA2A',0,N'流程管理')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'A6F94246-9BCA-409c-9938-5A4FC963FF02',N'Execute',0,N'功能權限',N'Module',0)
END
GO

if not exists(select * from BPMSecurityUserResource where RSID='5E6FD5EC-D784-4888-BE30-F8F2600EC01F')
BEGIN
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'5E6FD5EC-D784-4888-BE30-F8F2600EC01F',N'E0DCB7ED-1289-40e2-A945-6F8E1578BA2A',1,N'線上使用者')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'5E6FD5EC-D784-4888-BE30-F8F2600EC01F',N'Execute',0,N'功能權限',N'Module',0)
END
GO

if not exists(select * from BPMSecurityUserResource where RSID='C79E4457-9A8C-4b2f-AD1F-4A349B768A25')
BEGIN
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'C79E4457-9A8C-4b2f-AD1F-4A349B768A25',N'E0DCB7ED-1289-40e2-A945-6F8E1578BA2A',2,N'系統日誌')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'C79E4457-9A8C-4b2f-AD1F-4A349B768A25',N'Execute',0,N'功能權限',N'Module',0)
END
GO

if not exists(select * from BPMSecurityUserResource where RSID='BB1E3F5B-CA27-455a-89D4-C62BF80F3230')
BEGIN
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'BB1E3F5B-CA27-455a-89D4-C62BF80F3230',N'E0DCB7ED-1289-40e2-A945-6F8E1578BA2A',3,N'系統利用率')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'BB1E3F5B-CA27-455a-89D4-C62BF80F3230',N'Execute',0,N'功能權限',N'Module',0)
END
GO

if not exists(select * from BPMSecurityUserResource where RSID='725DC58D-277E-4c78-BA7A-3B96ED58E0B5')
BEGIN
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'725DC58D-277E-4c78-BA7A-3B96ED58E0B5',N'E0DCB7ED-1289-40e2-A945-6F8E1578BA2A',4,N'處理效率')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'725DC58D-277E-4c78-BA7A-3B96ED58E0B5',N'Execute',0,N'功能權限',N'Module',0)
END
GO

if not exists(select * from BPMSecurityUserResource where RSID='C2FB0BC1-934E-486f-91DC-980761222588')
BEGIN
INSERT INTO BPMSecurityUserResource(RSID,ParentRSID,OrderIndex,ResourceName) VALUES(N'C2FB0BC1-934E-486f-91DC-980761222588',N'E0DCB7ED-1289-40e2-A945-6F8E1578BA2A',5,N'超時統計')
INSERT INTO BPMSecurityUserResourcePerm(RSID,PermName,OrderIndex,PermDisplayName,PermType,LeadershipTokenEnabled) VALUES(N'C2FB0BC1-934E-486f-91DC-980761222588',N'Execute',0,N'功能權限',N'Module',0)
END
GO

if exists(select * from syscolumns where name = 'Comment' and id = object_id('BPMInstDrafts'))
BEGIN
ALTER TABLE BPMInstDrafts DROP COLUMN Comment
END
GO

if not exists(select * from syscolumns where name = 'Comments' and id = object_id('BPMInstDrafts'))
BEGIN
ALTER TABLE BPMInstDrafts ADD Comments [ntext] NULL
END
GO

if not exists(select * from syscolumns where name = 'Attachments' and id = object_id('BPMSysMessagesQueue'))
BEGIN
ALTER TABLE BPMSysMessagesQueue ADD Attachments [ntext] NULL
END
GO

if not exists(select * from syscolumns where name = 'Attachments' and id = object_id('BPMSysMessagesSucceed'))
BEGIN
ALTER TABLE BPMSysMessagesSucceed ADD Attachments [ntext] NULL
END
GO

if not exists(select * from syscolumns where name = 'Attachments' and id = object_id('BPMSysMessagesFailed'))
BEGIN
ALTER TABLE BPMSysMessagesFailed ADD Attachments [ntext] NULL
END
GO

if not exists(select * from syscolumns where name = 'ParentStepID' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD ParentStepID [int] NULL
END
GO

if not exists(select * from syscolumns where name = 'NodePath' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD NodePath [nvarchar] (200) NULL
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysSqlTrace]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysSqlTrace](
	[RunDate] [datetime] NULL,
	[UserAccount] [nvarchar](50) NULL,
	[SqlText] [nvarchar](2000) NULL,
	[SqlTextFull] [ntext] NULL,
	[TickUsed] [int] NULL,
	[Error] [ntext] NULL,
	[xml] [ntext] NULL
) ON [PRIMARY]
END
GO

if not exists(select * from syscolumns where name = 'OrderIndex' and id = object_id('BPMSysOUs'))
BEGIN
ALTER TABLE BPMSysOUs ADD OrderIndex [int] NOT NULL DEFAULT(1)
END
GO

/***v4.6***/
/*************************4.6資料庫表結構升級開始**************************/
--BPMInstTasks表升級
if not exists(select * from syscolumns where name = 'ExtYear' and id = object_id('BPMInstTasks'))
BEGIN
ALTER TABLE BPMInstTasks ADD [ExtYear]  AS YEAR(CreateAt) PERSISTED
ALTER TABLE BPMInstTasks ADD [ExtInitiator]  AS ISNULL([AgentAccount],[OwnerAccount]) PERSISTED
ALTER TABLE BPMInstTasks ADD [ExtDeleted]  AS CONVERT(bit,(CASE [State] WHEN 'Deleted' THEN 1 else 0 end)) PERSISTED
END
GO

--BPMInstProcSteps表升級
if not exists(select * from syscolumns where name = 'ExtYear' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD [ExtYear] [int]  --需維護***
ALTER TABLE BPMInstProcSteps ADD [ExtStepYear]  AS YEAR(ReceiveAt) PERSISTED
ALTER TABLE BPMInstProcSteps ADD [ExtRecipient]  AS (ISNULL([AgentAccount],[OwnerAccount])) PERSISTED
ALTER TABLE BPMInstProcSteps ADD [ExtDeleted] bit NOT NULL Default(0) --需維護***

--BPMInstProcSteps表資料升級
exec sp_executesql N'
WITH X AS
(
SELECT A.*,B.ExtYear TaskYear,B.ExtDeleted TaskDeleted FROM BPMInstProcSteps A LEFT JOIN BPMInstTasks B ON A.TaskID=B.TaskID
)
UPDATE X SET ExtYear=TaskYear,ExtDeleted=ISNULL(TaskDeleted,1)
'
END
GO

--BPMSecurityTACL表升級
if not exists(select * from syscolumns where name = 'ExtYear' and id = object_id('BPMSecurityTACL'))
BEGIN
ALTER TABLE BPMSecurityTACL ADD ID [int] IDENTITY (1, 1) NOT NULL;
ALTER TABLE BPMSecurityTACL ADD [ExtYear] [int] --需維護***
ALTER TABLE BPMSecurityTACL ADD [ExtDeleted] bit NOT NULL Default(0) --需維護***

--BPMSecurityTACL表資料升級
exec sp_executesql N'
WITH X AS
(
SELECT A.*,B.ExtYear TaskYear,B.ExtDeleted TaskDeleted FROM BPMSecurityTACL A LEFT JOIN BPMInstTasks B ON A.TaskID=B.TaskID
)
UPDATE X SET ExtYear=TaskYear,ExtDeleted=ISNULL(TaskDeleted,1)
'
END
GO

--BPMInstShare表升級
if not exists(select * from syscolumns where name = 'ItemID' and id = object_id('BPMInstShare'))
BEGIN
ALTER TABLE BPMInstShare ADD ItemID [int] IDENTITY (1, 1) NOT NULL;

--BPMInstShare表資料升級
--StepID UserAccount要唯一***
exec sp_executesql N'
SELECT MIN(ItemID) AS ItemID,StepID,UserAccount INTO #tmp FROM BPMInstShare GROUP BY StepID,UserAccount HAVING COUNT(*)>1
DELETE BPMInstShare FROM BPMInstShare,#tmp WHERE #tmp.StepID=BPMInstShare.StepID AND #tmp.UserAccount=BPMInstShare.UserAccount AND BPMInstShare.ItemID <> #tmp.ItemID
DROP TABLE #tmp
'
END
GO

--BPMSysAppLog表升級
if not exists(select * from syscolumns where name = 'ExtDate' and id = object_id('BPMSysAppLog'))
BEGIN
ALTER TABLE BPMSysAppLog ADD [ExtDate] AS DATEADD(dd, 0, DATEDIFF(dd, 0, LogDate)) PERSISTED --日誌日期
END
GO

--BPMSysAppLogACL表升級
if not exists(select * from syscolumns where name = 'ExtDate' and id = object_id('BPMSysAppLogACL'))
BEGIN
ALTER TABLE BPMSysAppLogACL ADD [ExtDate] AS DATEADD(dd, 0, DATEDIFF(dd, 0, CreateDate)) PERSISTED --日誌日期
END
GO

--建立表：BPMSysMemberIDMap
if (object_id('BPMSysMemberIDMap') is null)
BEGIN
CREATE TABLE [dbo].[BPMSysMemberIDMap](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MemberFullName] [nvarchar](300) NOT NULL,
	CONSTRAINT [YZPK_BPMSysMemberIDMap] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	) ON [PRIMARY]
) ON [PRIMARY]
END
GO

--建立表BPMSysMemberIDMap的索引：YZIX_BPMSysMemberIDMap_MemberFullName
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysMemberIDMap_MemberFullName')
BEGIN
CREATE NONCLUSTERED INDEX [YZIX_BPMSysMemberIDMap_MemberFullName] ON [dbo].[BPMSysMemberIDMap] 
(
	[MemberFullName] ASC
) ON [PRIMARY]
END
GO

/***BPMInstTasks,OwnerPosition->OwnerPositionID-開始***/
--建立OwnerPositionID列
if not exists(select * from syscolumns where name = 'OwnerPositionID' and id = object_id('BPMInstTasks'))
BEGIN
ALTER TABLE BPMInstTasks ADD [OwnerPositionID] [int]
END
GO

--將OwnerPosition的值轉化為OwnerPositionID
if exists(select * from syscolumns where name = 'OwnerPosition' and id = object_id('BPMInstTasks'))
BEGIN
exec sp_executesql N'
--BPMSysMemberIDMap表更新
WITH
X AS(
SELECT DISTINCT OwnerPosition FROM BPMInstTasks WHERE OwnerPosition IS NOT NULL AND OwnerPosition NOT IN(SELECT MemberFullName FROM BPMSysMemberIDMap)
)
INSERT INTO BPMSysMemberIDMap(MemberFullName) SELECT OwnerPosition FROM X;

--OwnerPositionID列更新
WITH
D AS(
SELECT A.*,B.ID NewMemberID FROM BPMInstTasks A INNER JOIN BPMSysMemberIDMap B ON A.OwnerPosition=B.MemberFullName
)
UPDATE D SET OwnerPositionID=NewMemberID;

--刪除OwnerPosition列
ALTER TABLE BPMInstTasks DROP COLUMN OwnerPosition
'
END
GO
/***BPMInstTasks,OwnerPosition->OwnerPositionID-結束***/

/***BPMInstProcSteps,OwnerPosition->OwnerPositionID-開始***/
--建立OwnerPositionID列
if not exists(select * from syscolumns where name = 'OwnerPositionID' and id = object_id('BPMInstProcSteps'))
BEGIN
ALTER TABLE BPMInstProcSteps ADD [OwnerPositionID] [int]
END
GO

--將OwnerPosition的值轉化為OwnerPositionID
if exists(select * from syscolumns where name = 'OwnerPosition' and id = object_id('BPMInstProcSteps'))
BEGIN
exec sp_executesql N'
--BPMSysMemberIDMap表更新
WITH
X AS(
SELECT DISTINCT OwnerPosition FROM BPMInstProcSteps WHERE OwnerPosition IS NOT NULL AND OwnerPosition NOT IN(SELECT MemberFullName FROM BPMSysMemberIDMap)
)
INSERT INTO BPMSysMemberIDMap(MemberFullName) SELECT OwnerPosition FROM X;

--OwnerPositionID列更新
WITH
D AS(
SELECT A.*,B.ID NewMemberID FROM BPMInstProcSteps A INNER JOIN BPMSysMemberIDMap B ON A.OwnerPosition=B.MemberFullName
)
UPDATE D SET OwnerPositionID=NewMemberID;

--刪除OwnerPosition列
ALTER TABLE BPMInstProcSteps DROP COLUMN OwnerPosition
'
END
GO
/***BPMInstProcSteps,OwnerPosition->OwnerPositionID-結束***/

/***BPMInstShare,MemberFullName->PositionID-開始***/
--PositionID
if not exists(select * from syscolumns where name = 'PositionID' and id = object_id('BPMInstShare'))
BEGIN
ALTER TABLE BPMInstShare ADD PositionID [int]
END
GO

--將OwnerPosition的值轉化為OwnerPositionID
if exists(select * from syscolumns where name = 'MemberFullName' and id = object_id('BPMInstShare'))
BEGIN
exec sp_executesql N'
--BPMSysMemberIDMap表更新
WITH
X AS(
SELECT DISTINCT MemberFullName FROM BPMInstShare WHERE MemberFullName IS NOT NULL AND MemberFullName NOT IN(SELECT MemberFullName FROM BPMSysMemberIDMap)
)
INSERT INTO BPMSysMemberIDMap(MemberFullName) SELECT MemberFullName FROM X;

--PositionID
WITH
D AS(
SELECT A.*,B.ID NewMemberID FROM BPMInstShare A INNER JOIN BPMSysMemberIDMap B ON A.MemberFullName=B.MemberFullName
)
UPDATE D SET PositionID=NewMemberID;

--刪除OwnerPosition列
ALTER TABLE BPMInstShare DROP COLUMN MemberFullName
'
END
GO
/***BPMInstShare,MemberFullName->PositionID-結束***/


/***BPMInstDrafts,OwnerPosition->OwnerPositionID-開始***/
--建立OwnerPositionID列
if not exists(select * from syscolumns where name = 'OwnerPositionID' and id = object_id('BPMInstDrafts'))
BEGIN
ALTER TABLE BPMInstDrafts ADD [OwnerPositionID] [int]
END
GO

--將OwnerPosition的值轉化為OwnerPositionID
if exists(select * from syscolumns where name = 'OwnerPosition' and id = object_id('BPMInstDrafts'))
BEGIN
exec sp_executesql N'
--BPMSysMemberIDMap表更新
WITH
X AS(
SELECT DISTINCT OwnerPosition FROM BPMInstDrafts WHERE OwnerPosition IS NOT NULL AND OwnerPosition NOT IN(SELECT MemberFullName FROM BPMSysMemberIDMap)
)
INSERT INTO BPMSysMemberIDMap(MemberFullName) SELECT OwnerPosition FROM X;

--OwnerPositionID列更新
WITH
D AS(
SELECT A.*,B.ID NewMemberID FROM BPMInstDrafts A INNER JOIN BPMSysMemberIDMap B ON A.OwnerPosition=B.MemberFullName
)
UPDATE D SET OwnerPositionID=NewMemberID;

--刪除OwnerPosition列
ALTER TABLE BPMInstDrafts DROP COLUMN OwnerPosition
'
END
GO
/***BPMInstDrafts,OwnerPosition->OwnerPositionID-結束***/

--表改名
--BPMInstClickToProcessQuery->BPMInstClickToProcessQueue
if (object_id('BPMInstClickToProcessQuery') is not null)
BEGIN
EXEC dbo.sp_rename @objname = N'[dbo].[BPMInstClickToProcessQuery]', @newname = N'BPMInstClickToProcessQueue', @objtype = N'OBJECT'
END
GO

if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMInstClickToProcessQueue]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMInstClickToProcessQueue](
	[CreateDate] [datetime] NOT NULL,
	[ItemGUID] [uniqueidentifier] NOT NULL,
	[TaskID] [int] NOT NULL,
	[StepID] [int] NOT NULL,
	[RecipientAccount] [nvarchar](50) NOT NULL,
	[SystemAction] [bit] NOT NULL,
	[ActionName] [nvarchar](50) NOT NULL,
	[ExpireDate] [datetime] NULL
) ON [PRIMARY]
END
GO

--表刪除
--BPMInstTaskStepLinks
if (object_id('BPMInstTaskStepLinks') is not null)
BEGIN
DROP TABLE [dbo].[BPMInstTaskStepLinks]
END
GO

--表刪除
--BPMSysTrigger
if (object_id('BPMSysTrigger') is not null)
BEGIN
DROP TABLE [dbo].[BPMSysTrigger]
END
GO

--列修改
DECLARE @len INT;
SELECT @len=length FROM syscolumns WHERE name = 'RSID' and id = object_id('BPMSecurityACL')
if @len>900
BEGIN
ALTER TABLE [dbo].[BPMSecurityACL] ALTER COLUMN RSID nvarchar(450)
END
GO

--YZV_TaskList(待處理任務物化視圖)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'YZV_TaskList')
BEGIN
exec sp_executesql N'
CREATE VIEW YZV_TaskList
WITH SCHEMABINDING
AS
SELECT a.TaskID,a.StepID,b.ProcessName,b.OwnerPositionID,b.OwnerAccount,b.AgentAccount,b.CreateAt,b.Description,a.NodeName,a.ReceiveAt,a.Share,b.State,b.SerialNum,a.TimeoutFirstNotifyDate,a.TimeoutDeadline,a.TimeoutNotifyCount,a.NodePath,a.ExtRecipient
FROM dbo.BPMInstProcSteps a INNER JOIN dbo.BPMInstTasks b on a.TaskID=b.TaskID
WHERE a.FinishAt IS NULL AND a.HumanStep=1 AND a.ExtRecipient IS NOT NULL AND b.State=''Running''
'
END
GO

--YZV_ShareTask(共享任務物化視圖)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'YZV_ShareTask')
BEGIN
exec sp_executesql N'
CREATE VIEW YZV_ShareTask
WITH SCHEMABINDING
AS
SELECT a.TaskID,a.StepID,b.ProcessName,b.OwnerPositionID,b.OwnerAccount,b.AgentAccount,b.CreateAt,b.Description,a.NodeName,a.ReceiveAt,1 as Share,b.State,b.SerialNum,a.TimeoutFirstNotifyDate,a.TimeoutDeadline,a.TimeoutNotifyCount,c.UserAccount
FROM dbo.BPMInstProcSteps a INNER JOIN dbo.BPMInstTasks b ON a.TaskID = b.TaskID INNER JOIN dbo.BPMInstShare c ON a.StepID=c.StepID 
WHERE a.FinishAt IS NULL AND a.ExtRecipient IS NULL AND a.HumanStep=1 AND b.State=''Running''
'
END
GO
/*************************4.6資料庫表結構升級結束**************************/


/*************************4.6查詢通知功能升級開始**************************/
--建立BPMSysTableVersion表
if (object_id('BPMSysTableVersion') is null)
CREATE TABLE [dbo].[BPMSysTableVersion](
	[TableName] [nvarchar](50) NOT NULL,
	[Version] [int] NOT NULL,
	[LastUpdate] [datetime] NULL
) ON [PRIMARY]
GO

/*******建立BPMSysMessagesQueue表的觸發器********/
--刪除原觸發器
if (object_id('YZTR_BPMSysMessagesQueue', 'tr') is not null)
DROP TRIGGER YZTR_BPMSysMessagesQueue
GO

--新建觸發器
CREATE TRIGGER YZTR_BPMSysMessagesQueue
ON BPMSysMessagesQueue
FOR INSERT,UPDATE,DELETE
AS
UPDATE BPMSysTableVersion SET Version=Version+1,LastUpdate=GETDATE() WHERE TableName='BPMSysMessagesQueue'
if(@@ROWCOUNT=0)
INSERT BPMSysTableVersion(TableName,Version,LastUpdate) VALUES('BPMSysMessagesQueue',1,GETDATE())
GO

/*******建立BPMSysTimeoutQueue表的觸發器********/
--刪除原觸發器
if (object_id('YZTR_BPMSysTimeoutQueue', 'tr') is not null)
DROP TRIGGER YZTR_BPMSysTimeoutQueue
GO

--新建觸發器
CREATE TRIGGER YZTR_BPMSysTimeoutQueue
ON BPMSysTimeoutQueue
FOR INSERT,UPDATE,DELETE
AS
UPDATE BPMSysTableVersion SET Version=Version+1,LastUpdate=GETDATE() WHERE TableName='BPMSysTimeoutQueue'
if(@@ROWCOUNT=0)
INSERT BPMSysTableVersion(TableName,Version,LastUpdate) VALUES('BPMSysTimeoutQueue',1,GETDATE())
GO

/*******建立YZAppFileConvert表的觸發器********/
--刪除原觸發器
if (object_id('YZTR_YZAppFileConvert', 'tr') is not null)
DROP TRIGGER YZTR_YZAppFileConvert
GO

--新建觸發器
CREATE TRIGGER YZTR_YZAppFileConvert
ON YZAppFileConvert
FOR INSERT
AS
UPDATE BPMSysTableVersion SET Version=Version+1,LastUpdate=GETDATE() WHERE TableName='YZAppFileConvert'
if(@@ROWCOUNT=0)
INSERT BPMSysTableVersion(TableName,Version,LastUpdate) VALUES('YZAppFileConvert',1,GETDATE())
GO
/*************************4.6查詢通知功能升級結束**************************/


/*************************4.6建立索引開始**************************/
--刪除主鍵與索引
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstClickToProcessQueue_StepID')
BEGIN
	DECLARE @temptb TABLE  
	(
		ID int IDENTITY(1,1),
		TableName nvarchar(200)
	)

	--刪除以下表的索引
	INSERT INTO @temptb VALUES(N'BPMInstClickToProcessQueue')
	INSERT INTO @temptb VALUES(N'BPMInstConsign')
	INSERT INTO @temptb VALUES(N'BPMInstConsignUsers')
	INSERT INTO @temptb VALUES(N'BPMInstDrafts')
	INSERT INTO @temptb VALUES(N'BPMInstFormDataSetLinks')
	INSERT INTO @temptb VALUES(N'BPMInstFormDataSets')
	INSERT INTO @temptb VALUES(N'BPMInstProcSteps')
	INSERT INTO @temptb VALUES(N'BPMInstRouting')
	INSERT INTO @temptb VALUES(N'BPMInstShare')
	INSERT INTO @temptb VALUES(N'BPMInstTasks')
	INSERT INTO @temptb VALUES(N'BPMSecurityACL')
	INSERT INTO @temptb VALUES(N'BPMSecurityExtToken')
	INSERT INTO @temptb VALUES(N'BPMSecurityGroupMembers')
	INSERT INTO @temptb VALUES(N'BPMSecurityGroups')
	INSERT INTO @temptb VALUES(N'BPMSecurityRecordACL')
	INSERT INTO @temptb VALUES(N'BPMSecurityTACL')
	INSERT INTO @temptb VALUES(N'BPMSecurityUserResource')
	INSERT INTO @temptb VALUES(N'BPMSecurityUserResourceACL')
	INSERT INTO @temptb VALUES(N'BPMSecurityUserResourcePerm')
	INSERT INTO @temptb VALUES(N'BPMSysAppLog')
	INSERT INTO @temptb VALUES(N'BPMSysAppLogACL')
	INSERT INTO @temptb VALUES(N'BPMSysMessagesFailed')
	INSERT INTO @temptb VALUES(N'BPMSysMessagesQueue')
	INSERT INTO @temptb VALUES(N'BPMSysMessagesSucceed')
	INSERT INTO @temptb VALUES(N'BPMSysOUFGOUs')
	INSERT INTO @temptb VALUES(N'BPMSysOUFGYWs')
	INSERT INTO @temptb VALUES(N'BPMSysOUMembers')
	INSERT INTO @temptb VALUES(N'BPMSysOURoleMembers')
	INSERT INTO @temptb VALUES(N'BPMSysOURoles')
	INSERT INTO @temptb VALUES(N'BPMSysOUs')
	INSERT INTO @temptb VALUES(N'BPMSysOUSupervisorFGYWs')
	INSERT INTO @temptb VALUES(N'BPMSysOUSupervisors')
	--INSERT INTO @temptb VALUES(N'BPMSysSeeks')
	INSERT INTO @temptb VALUES(N'BPMSysSettings')
	INSERT INTO @temptb VALUES(N'BPMSysSnapshot')
	INSERT INTO @temptb VALUES(N'BPMSysSqlTrace')
	INSERT INTO @temptb VALUES(N'BPMSysTableVersion')
	INSERT INTO @temptb VALUES(N'BPMSysTaskRule')
	INSERT INTO @temptb VALUES(N'BPMSysTaskRuleProcess')
	INSERT INTO @temptb VALUES(N'BPMSysTimeoutFailed')
	INSERT INTO @temptb VALUES(N'BPMSysTimeoutQueue')
	INSERT INTO @temptb VALUES(N'BPMSysTimeoutSucceed')
	INSERT INTO @temptb VALUES(N'BPMSysUserCommonInfo')
	INSERT INTO @temptb VALUES(N'BPMSysUserElement')
	INSERT INTO @temptb VALUES(N'BPMSysUsers')
	INSERT INTO @temptb VALUES(N'YZAppAttachment')
	INSERT INTO @temptb VALUES(N'YZAppFileConvert')
	INSERT INTO @temptb VALUES(N'YZV_TaskList')
	INSERT INTO @temptb VALUES(N'YZV_ShareTask')

	DECLARE @currentIndex int
	DECLARE @totalRows int
	SET @currentIndex=1
	SELECT @totalRows=count(*) from @temptb 
	DECLARE @sql nvarchar(4000);

	WHILE(@currentIndex<=@totalRows)  
	BEGIN
		DECLARE @TableName nvarchar(200);
		SELECT @TableName=TableName FROM @temptb WHERE ID=@currentIndex  

		DECLARE @ltr nvarchar(4000);
		SELECT @ltr = (SELECT 'alter table '+o.name+' drop constraint '+i.name+';'+CHAR(10)
			FROM sys.indexes i join sys.objects o on  i.object_id=o.object_id
			WHERE o.type<>'S' and (is_primary_key=1 OR is_unique_constraint=1) and i.object_id=object_id(@TableName)
			FOR xml path(''));

		--PRINT @ltr;
		EXEC sp_executesql @ltr;

		SELECT @ltr = (SELECT 'drop index '+o.name+'.'+i.name+';'
			FROM sys.indexes i join sys.objects o on  i.object_id=o.object_id
			WHERE o.type<>'S' and is_primary_key<>1 AND is_unique_constraint<>1 and index_id>0 and i.object_id=object_id(@TableName)
			FOR xml path(''));
		--PRINT @ltr;
		EXEC sp_executesql @ltr;

		SET @currentIndex=@currentIndex+1;  
	END
END
GO

/***BPMInstClickToProcessQueue表的索引***/
--YZPK_BPMInstClickToProcessQueue
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMInstClickToProcessQueue')
BEGIN
	ALTER TABLE [dbo].[BPMInstClickToProcessQueue] ADD  CONSTRAINT [YZPK_BPMInstClickToProcessQueue] PRIMARY KEY CLUSTERED 
	(
		[ItemGUID] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMInstClickToProcessQueue_StepID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstClickToProcessQueue_StepID')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstClickToProcessQueue_StepID] ON [dbo].[BPMInstClickToProcessQueue] 
	(
		[StepID] ASC
	) ON [PRIMARY]
END
GO

/***BPMInstConsign表的索引***/
--YZPK_BPMInstConsign
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMInstConsign')
BEGIN
	ALTER TABLE [dbo].[BPMInstConsign] ADD  CONSTRAINT [YZPK_BPMInstConsign] PRIMARY KEY CLUSTERED 
	(
		[ConsignID] ASC
	) ON [PRIMARY]
END
GO

/***BPMInstConsignUsers表的索引***/
--YZIX_BPMInstConsignUsers_CondignID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstConsignUsers_CondignID')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstConsignUsers_CondignID] ON [dbo].[BPMInstConsignUsers] 
	(
		[ConsignID] ASC
	) ON [PRIMARY]
END
GO

/***BPMInstDrafts表的索引***/
--YZIX_BPMInstDrafts_DraftID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstDrafts_DraftID')
BEGIN
	CREATE UNIQUE NONCLUSTERED INDEX [YZIX_BPMInstDrafts_DraftID] ON [dbo].[BPMInstDrafts] 
	(
		[DraftID] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMInstDrafts_Account
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstDrafts_Account')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstDrafts_Account] ON [dbo].[BPMInstDrafts] 
	(
		[Account] ASC
	) ON [PRIMARY]
END
GO

/***BPMInstFormDataSetLinks表的索引***/
--YZIX_BPMInstFormDataSetLinks_FormDataSetID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstFormDataSetLinks_FormDataSetID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMInstFormDataSetLinks_FormDataSetID] ON [dbo].[BPMInstFormDataSetLinks] 
	(
		[FormDataSetID] ASC
	) ON [PRIMARY]
END
GO

/***BPMInstFormDataSets表的索引***/
--YZPK_BPMInstFormDataSets
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMInstFormDataSets')
BEGIN
	ALTER TABLE [dbo].[BPMInstFormDataSets] ADD  CONSTRAINT [YZPK_BPMInstFormDataSets] PRIMARY KEY CLUSTERED 
	(
		[FormDataSetID] ASC
	) ON [PRIMARY]
END
GO

/***BPMInstProcSteps表的索引***/
--YZPK_BPMInstProcSteps
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMInstProcSteps')
BEGIN
	ALTER TABLE [dbo].[BPMInstProcSteps] ADD  CONSTRAINT [YZPK_BPMInstProcSteps] PRIMARY KEY CLUSTERED 
	(
		[StepID] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMInstProcSteps_TaskID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstProcSteps_TaskID')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstProcSteps_TaskID] ON [dbo].[BPMInstProcSteps] 
	(
		[TaskID] ASC
	)
	INCLUDE ( [ProcessName],
	[NodeName],
	[OwnerAccount],
	[FinishAt],
	[HumanStep],
	[AgentAccount],
	[Posted]) ON [PRIMARY]
END
GO

--YZIX_BPMInstProcSteps
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstProcSteps')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstProcSteps] ON [dbo].[BPMInstProcSteps] 
	(
		[ExtStepYear] ASC,
		[HumanStep] ASC
	)
	INCLUDE ( [TaskID],
	[ProcessName],
	[NodeName],
	[OwnerAccount],
	[ReceiveAt],
	[FinishAt],
	[AutoProcess],
	[UsedMinutes],
	[UsedMinutesWork],
	[TimeoutNotifyCount],
	[StandardMinutesWork],
	[Posted],
	[ExtDeleted],
	[HandlerAccount],
	[TimeoutDeadline]) ON [PRIMARY]
END
GO

--YZIX_BPMInstProcSteps_BelongConsignID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstProcSteps_BelongConsignID')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstProcSteps_BelongConsignID] ON [dbo].[BPMInstProcSteps] 
	(
		[BelongConsignID] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMInstProcSteps_AgentAccount
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstProcSteps_AgentAccount')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstProcSteps_AgentAccount] ON [dbo].[BPMInstProcSteps] 
	(
		[AgentAccount] ASC,
		[ExtYear] ASC
	)
	INCLUDE ( [TaskID],
	[ExtDeleted]) ON [PRIMARY]
END
GO

--YZIX_BPMInstProcSteps_ConsignOwnerAccount
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstProcSteps_ConsignOwnerAccount')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstProcSteps_ConsignOwnerAccount] ON [dbo].[BPMInstProcSteps] 
	(
		[ConsignOwnerAccount] ASC,
		[ExtYear] ASC
	)
	INCLUDE ( [TaskID],
	[ExtDeleted]) ON [PRIMARY]
END
GO

--YZIX_BPMInstProcSteps_OwnerAccount
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstProcSteps_OwnerAccount')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstProcSteps_OwnerAccount] ON [dbo].[BPMInstProcSteps] 
	(
		[OwnerAccount] ASC,
		[ExtYear] ASC
	)
	INCLUDE ( [TaskID],
	[ExtDeleted]) ON [PRIMARY]
END
GO

--YZIX_BPMInstProcSteps_HandlerAccount
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstProcSteps_HandlerAccount')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstProcSteps_HandlerAccount] ON [dbo].[BPMInstProcSteps] 
	(
		[HandlerAccount] ASC,
		[ExtYear] ASC
	)
	INCLUDE ( [TaskID],
	[FinishAt],
	[Posted],
	[ExtDeleted]) ON [PRIMARY]
END
GO

--YZIX_BPMInstRouting_FromStepID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstRouting_FromStepID')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstRouting_FromStepID] ON [dbo].[BPMInstRouting] 
	(
		[FromStepID] ASC
	)
	INCLUDE ([ToStepID]) ON [PRIMARY]
END
GO

--YZIX_BPMInstRouting_ToStepID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstRouting_ToStepID')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstRouting_ToStepID] ON [dbo].[BPMInstRouting] 
	(
		[ToStepID] ASC
	)
	INCLUDE ([FromStepID]) ON [PRIMARY]
END
GO

/***BPMInstShare表的索引***/
--YZIX_BPMInstShare_StepID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstShare_StepID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMInstShare_StepID] ON [dbo].[BPMInstShare] 
	(
		[StepID] ASC
	) ON [PRIMARY]
END
GO

/***BPMInstTasks表的索引***/
--YZPK_BPMInstTasks
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMInstTasks')
BEGIN
	ALTER TABLE [dbo].[BPMInstTasks] ADD  CONSTRAINT [YZPK_BPMInstTasks] PRIMARY KEY CLUSTERED 
	(
		[TaskID] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMInstTasks
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstTasks')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstTasks] ON [dbo].[BPMInstTasks] 
	(
		[ExtYear] ASC
	)
	INCLUDE ( [ProcessName],
	[OwnerAccount],
	[Description],
	[AgentAccount],
	[SerialNum],
	[State],
	[ExtDeleted],
	[CreateAt]) ON [PRIMARY]
END
GO

--YZIX_BPMInstTasks_AgentAccount
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstTasks_AgentAccount')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstTasks_AgentAccount] ON [dbo].[BPMInstTasks] 
	(
		[AgentAccount] ASC,
		[ExtYear] ASC
	)
	INCLUDE ( [ExtDeleted],
	[ProcessName],
	[CreateAt],
	[Description],
	[State],
	[OwnerAccount],
	[SerialNum]) ON [PRIMARY]
END
GO

--YZIX_BPMInstTasks_OwnerAccount
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstTasks_OwnerAccount')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstTasks_OwnerAccount] ON [dbo].[BPMInstTasks] 
	(
		[OwnerAccount] ASC,
		[ExtYear] ASC
	)
	INCLUDE ( [ExtDeleted],
	[ProcessName],
	[CreateAt],
	[Description],
	[State],
	[SerialNum]) ON [PRIMARY]
END
GO

--YZIX_BPMInstTasks_SerialNum
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstTasks_SerialNum')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstTasks_SerialNum] ON [dbo].[BPMInstTasks] 
	(
		[SerialNum] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMInstTasks_ExtInitiator
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMInstTasks_ExtInitiator')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMInstTasks_ExtInitiator] ON [dbo].[BPMInstTasks] 
	(
		[ExtInitiator] ASC,
		[ExtYear] ASC
	)
	INCLUDE ( [ProcessName],
	[ExtDeleted]) ON [PRIMARY]
END
GO

/***BPMSecurityACL表的索引***/
--YZIX_BPMSecurityACL_RSID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSecurityACL_RSID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSecurityACL_RSID] ON [dbo].[BPMSecurityACL] 
	(
		[RSID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSecurityGroupMembers表的索引***/
--YZIX_BPMSecurityGroupMembers_GroupName
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSecurityGroupMembers_GroupName')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSecurityGroupMembers_GroupName] ON [dbo].[BPMSecurityGroupMembers] 
	(
		[GroupName] ASC
	) ON [PRIMARY]
END
GO

/***BPMSecurityGroups表的索引***/
--YZPK_BPMSecurityGroups
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSecurityGroups')
BEGIN
	ALTER TABLE [dbo].[BPMSecurityGroups] ADD  CONSTRAINT [YZPK_BPMSecurityGroups] PRIMARY KEY CLUSTERED 
	(
		[GroupName] ASC
	) ON [PRIMARY]
END
GO

/***BPMSecurityRecordACL表的索引***/
--YZPK_BPMSecurityRecordACL
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSecurityRecordACL')
BEGIN
	ALTER TABLE [dbo].[BPMSecurityRecordACL] ADD  CONSTRAINT [YZPK_BPMSecurityRecordACL] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMSecurityRecordACL_TableNameKeyValue
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSecurityRecordACL_TableNameKeyValue')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMSecurityRecordACL_TableNameKeyValue] ON [dbo].[BPMSecurityRecordACL] 
	(
		[TableName] ASC,
		[KeyValue] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMSecurityRecordACL_TableNamePermisionSID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSecurityRecordACL_TableNamePermisionSID')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMSecurityRecordACL_TableNamePermisionSID] ON [dbo].[BPMSecurityRecordACL] 
	(
		[TableName] ASC,
		[Permision] ASC,
		[SID] ASC
	)
	INCLUDE ( [KeyValue]) ON [PRIMARY]
END
GO

/***BPMSecurityTACL表的索引***/
--YZPK_BPMSecurityTACL
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSecurityTACL')
BEGIN
	ALTER TABLE [dbo].[BPMSecurityTACL] ADD  CONSTRAINT [YZPK_BPMSecurityTACL] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMSecurityTACL_TaskID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSecurityTACL_TaskID')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMSecurityTACL_TaskID] ON [dbo].[BPMSecurityTACL] 
	(
		[TaskID] DESC
	)
	INCLUDE ( [SID],
	[AllowAdmin]) ON [PRIMARY]
END
GO

--YZIX_BPMSecurityTACL_SID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSecurityTACL_SID')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMSecurityTACL_SID] ON [dbo].[BPMSecurityTACL] 
	(
		[SID] ASC,
		[ExtYear] ASC
	)
	INCLUDE ( [TaskID],
	[AllowRead],
	[AllowAdmin],
	[ExtDeleted]) ON [PRIMARY]
END
GO

/***BPMSecurityUserResource表的索引***/
--YZPK_BPMSecurityUserResource
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSecurityUserResource')
BEGIN
	ALTER TABLE [dbo].[BPMSecurityUserResource] ADD  CONSTRAINT [YZPK_BPMSecurityUserResource] PRIMARY KEY CLUSTERED 
	(
		[RSID] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMSecurityUserResource_ParentRSID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSecurityUserResource_ParentRSID')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMSecurityUserResource_ParentRSID] ON [dbo].[BPMSecurityUserResource] 
	(
		[ParentRSID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSecurityUserResourceACL表的索引***/
--YZIX_BPMSecurityUserResourceACL_RSID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSecurityUserResourceACL_RSID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSecurityUserResourceACL_RSID] ON [dbo].[BPMSecurityUserResourceACL] 
	(
		[RSID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSecurityUserResourcePerm表的索引***/
--YZIX_BPMSecurityUserResourcePerm_RSID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSecurityUserResourcePerm_RSID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSecurityUserResourcePerm_RSID] ON [dbo].[BPMSecurityUserResourcePerm] 
	(
		[RSID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysAppLog表的索引***/
--YZIX_BPMSysAppLog_ExtDate
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysAppLog_ExtDate')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysAppLog_ExtDate] ON [dbo].[BPMSysAppLog] 
	(
		[ExtDate] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysAppLogACL表的索引***/
--YZIX_BPMSysAppLogACL_ExtDate
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysAppLogACL_ExtDate')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysAppLogACL_ExtDate] ON [dbo].[BPMSysAppLogACL] 
	(
		[ExtDate] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysMessagesQueue表的索引***/
--YZPK_BPMSysMessagesQueue
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSysMessagesQueue')
BEGIN
	ALTER TABLE [dbo].[BPMSysMessagesQueue] ADD  CONSTRAINT [YZPK_BPMSysMessagesQueue] PRIMARY KEY CLUSTERED 
	(
		[MessageID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysOUFGOUs表的索引***/
--YZIX_BPMSysOUFGOUs_OUID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysOUFGOUs_OUID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysOUFGOUs_OUID] ON [dbo].[BPMSysOUFGOUs] 
	(
		[OUID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysOUFGYWs表的索引***/
--YZIX_BPMSysOUFGYWs_OUID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysOUFGYWs_OUID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysOUFGYWs_OUID] ON [dbo].[BPMSysOUFGYWs] 
	(
		[OUID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysOUMembers表的索引***/
--YZIX_BPMSysOUMembers_OUID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysOUMembers_OUID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysOUMembers_OUID] ON [dbo].[BPMSysOUMembers] 
	(
		[OUID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysOURoleMembers表的索引***/
--YZIX_BPMSysOURoleMembers_OUID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysOURoleMembers_OUID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysOURoleMembers_OUID] ON [dbo].[BPMSysOURoleMembers] 
	(
		[OUID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysOURoles表的索引***/
--YZIX_BPMSysOURoles_OUID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysOURoles_OUID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysOURoles_OUID] ON [dbo].[BPMSysOURoles] 
	(
		[OUID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysOUs表的索引***/
--YZPK_BPMSysOUs
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSysOUs')
BEGIN
	ALTER TABLE [dbo].[BPMSysOUs] ADD  CONSTRAINT [YZPK_BPMSysOUs] PRIMARY KEY CLUSTERED 
	(
		[OUID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysOUSupervisorFGYWs表的索引***/
--YZIX_BPMSysOUSupervisorFGYWs_LnkID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysOUSupervisorFGYWs_LnkID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysOUSupervisorFGYWs_LnkID] ON [dbo].[BPMSysOUSupervisorFGYWs] 
	(
		[LnkID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysOUSupervisors表的索引***/
--YZIX_BPMSysOUSupervisors_OUIDUserAccount
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysOUSupervisors_OUIDUserAccount')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysOUSupervisors_OUIDUserAccount] ON [dbo].[BPMSysOUSupervisors] 
	(
		[OUID] ASC,
		[UserAccount] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysSeeks表的索引***/
--YZIX_BPMSysSeeks
--if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysSeeks')
--BEGIN
--	CREATE CLUSTERED INDEX [YZIX_BPMSysSeeks] ON [dbo].[BPMSysSeeks] 
--	(
--		[DataSourceName] ASC,
--		[TableName] ASC,
--		[ColumnName] ASC,
--		[Prefix] ASC,
--		[Columns] ASC
--	) ON [PRIMARY]
--END
--GO

/***BPMSysSettings表的索引***/
--YZPK_BPMSysSettings
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSysSettings')
BEGIN
	ALTER TABLE [dbo].[BPMSysSettings] ADD  CONSTRAINT [YZPK_BPMSysSettings] PRIMARY KEY CLUSTERED 
	(
		[ItemName] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysSnapshot表的索引***/
--YZIX_BPMSysSnapshot_TaskID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysSnapshot_TaskID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysSnapshot_TaskID] ON [dbo].[BPMSysSnapshot] 
	(
		[TaskID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysSqlTrace表的索引***/
--YZIX_BPMSysSqlTrace_RunDate
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysSqlTrace_RunDate')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysSqlTrace_RunDate] ON [dbo].[BPMSysSqlTrace] 
	(
		[RunDate] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysTaskRule表的索引***/
--YZPK_BPMSysTaskRule
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSysTaskRule')
BEGIN
	ALTER TABLE [dbo].[BPMSysTaskRule] ADD  CONSTRAINT [YZPK_BPMSysTaskRule] PRIMARY KEY CLUSTERED 
	(
		[RuleID] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMTaskRule_Account
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMTaskRule_Account')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMTaskRule_Account] ON [dbo].[BPMSysTaskRule] 
	(
		[Account] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysTaskRuleProcess表的索引***/
--YZIX_BPMSysTaskRuleProcess_RuleID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysTaskRuleProcess_RuleID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysTaskRuleProcess_RuleID] ON [dbo].[BPMSysTaskRuleProcess] 
	(
		[RuleID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysTimeoutQueue表的索引***/
--YZPK_BPMSysTimeoutQueue
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSysTimeoutQueue')
BEGIN
	ALTER TABLE [dbo].[BPMSysTimeoutQueue] ADD  CONSTRAINT [YZPK_BPMSysTimeoutQueue] PRIMARY KEY CLUSTERED 
	(
		[ItemID] ASC
	) ON [PRIMARY]
END
GO

--YZIX_BPMSysTimeoutQueue_ExpireDate
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysTimeoutQueue_ExpireDate')
BEGIN
	CREATE NONCLUSTERED INDEX [YZIX_BPMSysTimeoutQueue_ExpireDate] ON [dbo].[BPMSysTimeoutQueue] 
	(
		[ExpireDate] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysUserCommonInfo表的索引***/
--YZPK_BPMSysUserCommonInfo
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSysUserCommonInfo')
BEGIN
	ALTER TABLE [dbo].[BPMSysUserCommonInfo] ADD  CONSTRAINT [YZPK_BPMSysUserCommonInfo] PRIMARY KEY CLUSTERED 
	(
		[Account] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysUserElement表的索引***/
--YZIX_BPMSysUserElement_ParentObjectID
if not exists (select * from dbo.sysindexes where name = 'YZIX_BPMSysUserElement_ParentObjectID')
BEGIN
	CREATE CLUSTERED INDEX [YZIX_BPMSysUserElement_ParentObjectID] ON [dbo].[BPMSysUserElement] 
	(
		[ParentObjectID] ASC
	) ON [PRIMARY]
END
GO

/***BPMSysUsers表的索引***/
--YZPK_BPMSysUsers
if not exists (select * from dbo.sysindexes where name = 'YZPK_BPMSysUsers')
BEGIN
	ALTER TABLE [dbo].[BPMSysUsers] ADD  CONSTRAINT [YZPK_BPMSysUsers] PRIMARY KEY CLUSTERED 
	(
		[Account] ASC
	) ON [PRIMARY]
END
GO

/***YZAppAttachment表的索引***/
--YZPK_YZAppAttachment
if not exists (select * from dbo.sysindexes where name = 'YZPK_YZAppAttachment')
BEGIN
	ALTER TABLE [dbo].[YZAppAttachment] ADD  CONSTRAINT [YZPK_YZAppAttachment] PRIMARY KEY CLUSTERED 
	(
		[FileID] ASC
	) ON [PRIMARY]
END
GO

/***YZAppFileConvert表的索引***/
--YZPK_YZAppFileConvert
if not exists (select * from dbo.sysindexes where name = 'YZPK_YZAppFileConvert')
BEGIN
	ALTER TABLE [dbo].[YZAppFileConvert] ADD  CONSTRAINT [YZPK_YZAppFileConvert] PRIMARY KEY CLUSTERED 
	(
		[ItemGuid] ASC
	) ON [PRIMARY]
END
GO

/***YZV_TaskList表的索引***/
--YZIX_TaskList
if not exists (select * from dbo.sysindexes where name = 'YZIX_TaskList')
BEGIN
	CREATE UNIQUE CLUSTERED INDEX [YZIX_TaskList] ON [dbo].[YZV_TaskList] 
	(
		[ExtRecipient] ASC,
		[StepID] ASC
	) ON [PRIMARY]
END
GO

/***YZV_ShareTask表的索引***/
--YZIX_ShareTask
if not exists (select * from dbo.sysindexes where name = 'YZIX_ShareTask')
BEGIN
	CREATE UNIQUE CLUSTERED INDEX [YZIX_ShareTask] ON [dbo].[YZV_ShareTask] 
	(
		[UserAccount] ASC,
		[StepID] ASC
	) ON [PRIMARY]
END
GO
/*************************4.6建立索引結束**************************/

if not exists(select * from syscolumns where name = 'Type' and id = object_id('BPMInstDrafts'))
BEGIN
ALTER TABLE BPMInstDrafts ADD Type [nvarchar] (30) DEFAULT('Draft') NOT NULL;
END
GO

UPDATE BPMInstDrafts SET Type='FormTemplate' WHERE Type='FormModel'

/********************************************* ver4.60d DBUpdate *********************************************/
--建立BPMSysSequence表與主鍵
if not exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[BPMSysSequence]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
BEGIN
CREATE TABLE [dbo].[BPMSysSequence](
	[Prefix] [nvarchar](50) NOT NULL,
	[CurValue] [int] NOT NULL,
	[ActiveDate] [datetime] NOT NULL
	CONSTRAINT [YZPK_BPMSysSequence] PRIMARY KEY CLUSTERED 
	(
		[Prefix] ASC
	) ON [PRIMARY]
) ON [PRIMARY]
END
GO

--1.轉換資料BPMSysSeeks->BPMSysSequence
--2.刪除表BPMSysSeeks
if (object_id('BPMSysSeeks') is not null)
BEGIN
INSERT INTO BPMSysSequence(Prefix,CurValue,ActiveDate) SELECT Prefix,max(CurrSeekValue),GETDATE() FROM BPMSysSeeks GROUP BY Prefix
DROP TABLE [dbo].[BPMSysSeeks]
END
GO