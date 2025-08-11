CREATE PROCEDURE Purge_Staging_By_Batch
    @LoadBatchID UNIQUEIDENTIFIER
AS
BEGIN
    BEGIN TRY
        -- Example: purge from multiple staging tables
        DELETE FROM Staging_Constituent WHERE LoadBatchID = @LoadBatchID;
        DELETE FROM Staging_Interactions WHERE LoadBatchID = @LoadBatchID;
        DELETE FROM Staging_Addresses WHERE LoadBatchID = @LoadBatchID;

        -- Log purge event
        INSERT INTO StagingLoadLog (
            LoadBatchID, LoadStartTime, LoadEndTime, Source, Status, RecordsInserted, ErrorMessage
        )
        VALUES (
            @LoadBatchID, GETDATE(), GETDATE(), 'Purge', 'Purged', 0, NULL
        );
    END TRY
    BEGIN CATCH
        DECLARE @Error NVARCHAR(MAX) = ERROR_MESSAGE();

        INSERT INTO StagingLoadLog (
            LoadBatchID, LoadStartTime, LoadEndTime, Source, Status, RecordsInserted, ErrorMessage
        )
        VALUES (
            @LoadBatchID, GETDATE(), GETDATE(), 'Purge', 'Failed', 0, @Error
        );
    END CATCH
END