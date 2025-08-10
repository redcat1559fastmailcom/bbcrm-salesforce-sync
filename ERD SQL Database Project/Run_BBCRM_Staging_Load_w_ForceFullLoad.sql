CREATE PROCEDURE Run_BBCRM_Staging_Load
    @ForceFullLoad BIT = 0  -- Default is incremental
AS
BEGIN
    DECLARE @LastSync DATETIME;
    DECLARE @Source NVARCHAR(100) = 'BBCRM_All';
    DECLARE @Error NVARCHAR(MAX) = NULL;

    BEGIN TRY
        -- Step 1: Determine sync time
        IF @ForceFullLoad = 1
        BEGIN
            SET @LastSync = NULL;  -- triggers full load in downstream logic
        END
        ELSE
        BEGIN
            EXEC Get_Last_Successful_SyncTime @Source = @Source, @LastSyncTime = @LastSync;

            -- Optional fallback
            IF @LastSync IS NULL
                SET @LastSync = '2000-01-01';
        END

        -- Step 2: Run staging load
        EXEC Load_All_Staging_Tables @LastSyncTime = @LastSync;
    END TRY

    BEGIN CATCH
        SET @Error = ERROR_MESSAGE();

        -- Optional: log master-level error
        INSERT INTO StagingLoadLog (LoadBatchID, LoadStartTime, LoadEndTime, Source, Status, RecordsInserted, ErrorMessage)
        VALUES (NEWID(), GETDATE(), GETDATE(), @Source, 'MasterFailed', 0, @Error);
    END CATCH
END