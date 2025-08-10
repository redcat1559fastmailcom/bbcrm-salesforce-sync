-- 1. Constituent Table
CREATE TABLE BBCRM_Constituent (
    BBCRM_ID UNIQUEIDENTIFIER PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Email NVARCHAR(100),
    DateChanged DATETIME
);

-- 2. Address Table
CREATE TABLE BBCRM_Address (
    Address_ID UNIQUEIDENTIFIER PRIMARY KEY,
    Constituent_ID UNIQUEIDENTIFIER FOREIGN KEY REFERENCES BBCRM_Constituent(BBCRM_ID),
    Street NVARCHAR(100),
    City NVARCHAR(50),
    [State] NVARCHAR(50),
    ZIP NVARCHAR(20),
    Address_Type_Code UNIQUEIDENTIFIER,
    DateChanged DATETIME
);

-- 3. Interaction Table
CREATE TABLE BBCRM_Interaction (
    Interaction_ID UNIQUEIDENTIFIER PRIMARY KEY,
    Constituent_ID UNIQUEIDENTIFIER FOREIGN KEY REFERENCES BBCRM_Constituent(BBCRM_ID),
    Interaction_Date DATETIME,
    Notes NVARCHAR(MAX),
    Interaction_Type_Code UNIQUEIDENTIFIER,
    DateChanged DATETIME
);

-- 4. Address Type Code Table
CREATE TABLE BBCRM_Address_Type (
    ID UNIQUEIDENTIFIER PRIMARY KEY,
    Type_Description NVARCHAR(100),
    DateChanged DATETIME
);

-- 5. Interaction Type Code Table
CREATE TABLE BBCRM_Interaction_Type (
    ID UNIQUEIDENTIFIER PRIMARY KEY,
    Type_Description NVARCHAR(100),
    DateChanged DATETIME
);
