--auto purge logs by older than 90 days age

CREATE PROCEDURE Purge_StagingLoadLog_By_Age
    @RetentionDays INT = 90
AS
BEGIN
    BEGIN TRY
        DELETE FROM StagingLoadLog
        WHERE LoadEndTime < DATEADD(DAY, -@RetentionDays, GETDATE());

        -- Optional: log purge event
        INSERT INTO StagingLoadLog (
            LoadBatchID, LoadStartTime, LoadEndTime, Source, Status, RecordsInserted, ErrorMessage
        )
        VALUES (
            NEWID(), GETDATE(), GETDATE(), 'LogRetention', 'Purged', 0, NULL
        );
    END TRY
    BEGIN CATCH
        DECLARE @Error NVARCHAR(MAX) = ERROR_MESSAGE();

        INSERT INTO StagingLoadLog (
            LoadBatchID, LoadStartTime, LoadEndTime, Source, Status, RecordsInserted, ErrorMessage
        )
        VALUES (
            NEWID(), GETDATE(), GETDATE(), 'LogRetention', 'Failed', 0, @Error
        );
    END CATCH
END