CREATE TABLE StagingLoadLog (
    LoadBatchID UNIQUEIDENTIFIER NOT NULL PRIMARY KEY,
    LoadStartTime DATETIME NOT NULL,
    LoadEndTime DATETIME NOT NULL,
    Source NVARCHAR(100) NOT NULL,
    Status NVARCHAR(50) NOT NULL,  -- e.g., 'Success', 'Failed', 'MasterFailed'
    RecordsInserted INT NOT NULL DEFAULT 0,
    ErrorMessage NVARCHAR(MAX) NULL
);