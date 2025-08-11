CREATE PROCEDURE Get_Last_Successful_SyncTime
    @Source NVARCHAR(100),  -- e.g., 'BBCRM_All'
    @LastSyncTime DATETIME OUTPUT
AS
BEGIN
    SELECT @LastSyncTime = MAX(LoadEndTime)
    FROM StagingLoadLog
    WHERE Source = @Source AND Status = 'Success';
END