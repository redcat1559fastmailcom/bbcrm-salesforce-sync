CREATE TABLE Stg_BBCRM_Mock_Constituent (
    BBCRM_ID UNIQUEIDENTIFIER PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    DateChanged DATETIME,
    LoadTimestamp DATETIME DEFAULT GETDATE()
);

CREATE TABLE Stg_BBCRM_Mock_Address (
    Address_ID UNIQUEIDENTIFIER PRIMARY KEY,
    Constituent_ID UNIQUEIDENTIFIER,
    Street NVARCHAR(100),
    City NVARCHAR(50),
    [State] NVARCHAR(50),
    ZIP NVARCHAR(20),
    Address_Type_Code UNIQUEIDENTIFIER,
    DateChanged DATETIME,
    LoadTimestamp DATETIME DEFAULT GETDATE()
);

CREATE TABLE Stg_BBCRM_Mock_Interaction (
    Interaction_ID UNIQUEIDENTIFIER PRIMARY KEY,
    Constituent_ID UNIQUEIDENTIFIER,
    Interaction_Date DATETIME,
    Notes NVARCHAR(MAX),
    Interaction_Type_Code UNIQUEIDENTIFIER,
    DateChanged DATETIME,
    LoadTimestamp DATETIME DEFAULT GETDATE()
);

CREATE TABLE Stg_BBCRM_Mock_Address_Type (
    ID UNIQUEIDENTIFIER PRIMARY KEY,
    Type_Description NVARCHAR(100),
    DateChanged DATETIME,
    LoadTimestamp DATETIME DEFAULT GETDATE()
);

CREATE TABLE Stg_BBCRM_Mock_Interaction_Type (
    ID UNIQUEIDENTIFIER PRIMARY KEY,
    Type_Description NVARCHAR(100),
    DateChanged DATETIME,
    LoadTimestamp DATETIME DEFAULT GETDATE()
);

-- In StagingDB
--CREATE SYNONYM BBCRM_Interaction_Type FOR BBCRM.dbo.BBCRM_Interaction_Type;