CREATE PROCEDURE Load_All_Staging_Tables
    @LastSyncTime DATETIME = NULL  -- Optional: pass NULL for full load
AS
BEGIN
    DECLARE @BatchID UNIQUEIDENTIFIER = NEWID();
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @TotalInserted INT = 0;
    DECLARE @Error NVARCHAR(MAX) = NULL;

    BEGIN TRY
        BEGIN TRAN;

        -- Load Constituent
        INSERT INTO Stg_BBCRM_Mock_Constituent (BBCRM_ID, FirstName, LastName, Email, DateChanged, LoadTimestamp, LoadBatchID)
        SELECT BBCRM_ID, FirstName, LastName, Email, DateChanged, GETDATE(), @BatchID
        FROM dbo.BBCRM_Constituent
        WHERE @LastSyncTime IS NULL OR DateChanged > @LastSyncTime;
        SET @TotalInserted += @@ROWCOUNT;

        -- Load Address
        INSERT INTO Stg_BBCRM_Mock_Address (Address_ID, Constituent_ID, Street, City, [State], ZIP, Address_Type_Code, DateChanged, LoadTimestamp, LoadBatchID)
        SELECT Address_ID, Constituent_ID, Street, City, [State], ZIP, Address_Type_Code, DateChanged, GETDATE(), @BatchID
        FROM dbo.BBCRM_Address
        WHERE @LastSyncTime IS NULL OR DateChanged > @LastSyncTime;
        SET @TotalInserted += @@ROWCOUNT;

        -- Load Interaction
        INSERT INTO Stg_BBCRM_Mock_Interaction (Interaction_ID, Constituent_ID, Interaction_Date, Notes, Interaction_Type_Code, DateChanged, LoadTimestamp, LoadBatchID)
        SELECT Interaction_ID, Constituent_ID, Interaction_Date, Notes, Interaction_Type_Code, DateChanged, GETDATE(), @BatchID
        FROM dbo.BBCRM_Interaction
        WHERE @LastSyncTime IS NULL OR DateChanged > @LastSyncTime;
        SET @TotalInserted += @@ROWCOUNT;

        -- Load Address Type
        INSERT INTO Stg_BBCRM_Mock_Address_Type (ID, Type_Description, DateChanged, LoadTimestamp, LoadBatchID)
        SELECT ID, Type_Description, DateChanged, GETDATE(), @BatchID
        FROM dbo.BBCRM_Address_Type
        WHERE @LastSyncTime IS NULL OR DateChanged > @LastSyncTime;
        SET @TotalInserted += @@ROWCOUNT;

        -- Load Interaction Type
        INSERT INTO Stg_BBCRM_Mock_Interaction_Type (ID, Type_Description, DateChanged, LoadTimestamp, LoadBatchID)
        SELECT ID, Type_Description, DateChanged, GETDATE(), @BatchID
        FROM dbo.BBCRM_Interaction_Type
        WHERE @LastSyncTime IS NULL OR DateChanged > @LastSyncTime;
        SET @TotalInserted += @@ROWCOUNT;

        COMMIT;

        -- Log success
        INSERT INTO StagingLoadLog (LoadBatchID, LoadStartTime, LoadEndTime, Source, Status, RecordsInserted)
        VALUES (@BatchID, @StartTime, GETDATE(), 'BBCRM_All', 'Success', @TotalInserted);
    END TRY

    BEGIN CATCH
        ROLLBACK;
        SET @Error = ERROR_MESSAGE();

        -- Log failure
        INSERT INTO StagingLoadLog (LoadBatchID, LoadStartTime, LoadEndTime, Source, Status, RecordsInserted, ErrorMessage)
        VALUES (@BatchID, @StartTime, GETDATE(), 'BBCRM_All', 'Failed', @TotalInserted, @Error);
    END CATCH
END