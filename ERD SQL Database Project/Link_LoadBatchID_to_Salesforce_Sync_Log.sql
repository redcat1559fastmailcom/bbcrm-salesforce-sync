/*
 Assuming you have a SalesforceSyncLog table, you can add a LoadBatchID column to tie each sync back to its staging source:

*/

ALTER TABLE SalesforceSyncLog
ADD LoadBatchID UNIQUEIDENTIFIER NULL;

/*
Then, during sync execution, pass the same LoadBatchID used in staging to the Salesforce sync logic. This gives you full lineage from BBCRM → staging → Salesforce, with rollback and auditability across the pipeline.
*/

-- Example insert during sync
INSERT INTO SalesforceSyncLog (
    SyncStartTime, SyncEndTime, ObjectType, RecordsSynced, Status, LoadBatchID
)
VALUES (
    GETDATE(), GETDATE(), 'Contact', 1200, 'Success', @LoadBatchID
);