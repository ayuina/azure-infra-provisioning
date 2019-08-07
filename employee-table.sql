CREATE TABLE [dbo].[employee](
	[employeeid] [int] NOT NULL,
	[firstname] [nvarchar](50) NOT NULL,
	[lastname] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_employee] PRIMARY KEY CLUSTERED 
(
	[employeeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


insert into [dbo].[employee] values (1, N'Hironobu', N'Ikoma')
GO
insert into [dbo].[employee] values (2, N'Ayumu', N'Inaba')
GO
insert into [dbo].[employee] values (3, N'Masaaki', N'Makino')
GO
insert into [dbo].[employee] values (4, N'Masaki', N'Kato')
GO
