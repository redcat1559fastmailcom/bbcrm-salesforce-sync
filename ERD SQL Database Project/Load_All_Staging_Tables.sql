CREATE PROCEDURE Load_All_Staging_Tables
AS
BEGIN
    DECLARE @BatchID UNIQUEIDENTIFIER = NEWID();
    DECLARE @StartTime DATETIME = GETDATE();
    DECLARE @TotalInserted INT = 0;
    DECLARE @Error NVARCHAR(MAX) = NULL;

    BEGIN TRY
        -- Load Constituent
        INSERT INTO Stg_BBCRM_Mock_Constituent (BBCRM_ID, FirstName, LastName, Email, DateChanged, LoadTimestamp, LoadBatchID)
        SELECT BBCRM_ID, FirstName, LastName, Email, DateChanged, GETDATE(), @BatchID
        FROM dbo.BBCRM_Constituent;
        SET @TotalInserted += @@ROWCOUNT;

        -- Load Address
        INSERT INTO Stg_BBCRM_Mock_Address (BBCRM_ID, AddressLine1, City, State, Zip, DateChanged, LoadTimestamp, LoadBatchID)
        SELECT BBCRM_ID, AddressLine1, City, State, Zip, DateChanged, GETDATE(), @BatchID
        FROM dbo.BBCRM_Address;
        SET @TotalInserted += @@ROWCOUNT;

        -- Load Interaction
        INSERT INTO Stg_BBCRM_Mock_Interaction (BBCRM_ID, InteractionDate, InteractionTypeID, Notes, DateChanged, LoadTimestamp, LoadBatchID)
        SELECT BBCRM_ID, InteractionDate, InteractionTypeID, Notes, DateChanged, GETDATE(), @BatchID
        FROM dbo.BBCRM_Interaction;
        SET @TotalInserted += @@ROWCOUNT;

        -- Load Address Type
        INSERT INTO Stg_BBCRM_Mock_Address_Type (AddressTypeID, Description, DateChanged, LoadTimestamp, LoadBatchID)
        SELECT AddressTypeID, Description, DateChanged, GETDATE(), @BatchID
        FROM dbo.BBCRM_Address_Type;
        SET @TotalInserted += @@ROWCOUNT;

        -- Load Interaction Type
        INSERT INTO Stg_BBCRM_Mock_Interaction_Type (InteractionTypeID, Description, DateChanged, LoadTimestamp, LoadBatchID)
        SELECT InteractionTypeID, Description, DateChanged, GETDATE(), @BatchID
        FROM dbo.BBCRM_Interaction_Type;
        SET @TotalInserted += @@ROWCOUNT;

        -- Log success
        INSERT INTO StagingLoadLog (LoadBatchID, LoadStartTime, LoadEndTime, Source, Status, RecordsInserted)
        VALUES (@BatchID, @StartTime, GETDATE(), 'BBCRM_All', 'Success', @TotalInserted);
    END TRY

    BEGIN CATCH
        SET @Error = ERROR_MESSAGE();

        -- Log failure
        INSERT INTO StagingLoadLog (LoadBatchID, LoadStartTime, LoadEndTime, Source, Status, RecordsInserted, ErrorMessage)
        VALUES (@BatchID, @StartTime, GETDATE(), 'BBCRM_All', 'Failed', @TotalInserted, @Error);
    END CATCH
END

--exec Load_All_Staging_Tables