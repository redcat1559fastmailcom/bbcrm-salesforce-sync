/*
- Add filters by date range, status, or object type
- Create a view (vw_ETL_SyncDashboard) for easy reporting
- Use this as a source for Power BI or SSRS dashboards
*/


SELECT
    sll.LoadBatchID,
    sll.LoadStartTime,
    sll.LoadEndTime,
    sll.Source,
    sll.Status AS StagingStatus,
    sll.RecordsInserted,
    ss.SyncStartTime,
    ss.SyncEndTime,
    ss.ObjectType,
    ss.RecordsSynced,
    ss.Status AS SalesforceStatus,
    ISNULL(sll.ErrorMessage, '') AS StagingError,
    ISNULL(ss.ErrorMessage, '') AS SalesforceError
FROM StagingLoadLog sll
LEFT JOIN SalesforceSyncLog ss ON sll.LoadBatchID = ss.LoadBatchID
ORDER BY sll.LoadStartTime DESC;
Go

/*
This view gives you a unified snapshot of staging and sync activity. You can query it directly or use it in reports.
*/
--create a view
CREATE VIEW vw_ETL_SyncDashboard AS
SELECT
    sll.LoadBatchID,
    sll.LoadStartTime,
    sll.LoadEndTime,
    sll.Source,
    sll.Status AS StagingStatus,
    sll.RecordsInserted,
    ss.SyncStartTime,
    ss.SyncEndTime,
    ss.ObjectType,
    ss.RecordsSynced,
    ss.Status AS SalesforceStatus,
    ISNULL(sll.ErrorMessage, '') AS StagingError,
    ISNULL(ss.ErrorMessage, '') AS SalesforceError
FROM StagingLoadLog sll
LEFT JOIN SalesforceSyncLog ss ON sll.LoadBatchID = ss.LoadBatchID;

Go
/*
Stored Procedure with Filter
*/
CREATE PROCEDURE usp_GetETLSyncSummary
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StatusFilter NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM vw_ETL_SyncDashboard
    WHERE
        (@StartDate IS NULL OR LoadStartTime >= @StartDate)
        AND (@EndDate IS NULL OR LoadEndTime <= @EndDate)
        AND (
            @StatusFilter IS NULL OR
            StagingStatus = @StatusFilter OR
            SalesforceStatus = @StatusFilter
        )
    ORDER BY LoadStartTime DESC;
END;

GO

--usage

/*
This returns all failed batches between August 1–10, whether the failure occurred in staging or Salesforce sync.

*/

EXEC usp_GetETLSyncSummary 
    @StartDate = '2025-08-01', 
    @EndDate = '2025-08-10', 
    @StatusFilter = 'Failed';

Go

/*

 Enhanced Stored Procedure: Paging & Filters + Duration

*/

CREATE PROCEDURE usp_GetETLSyncSummary
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StatusFilter NVARCHAR(50) = NULL,
    @ObjectType NVARCHAR(100) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    WITH FilteredResults AS (
        SELECT
            *,
            DATEDIFF(SECOND, SyncStartTime, SyncEndTime) AS SyncDurationSeconds,
            ROW_NUMBER() OVER (ORDER BY LoadStartTime DESC) AS RowNum
        FROM vw_ETL_SyncDashboard
        WHERE
            (@StartDate IS NULL OR LoadStartTime >= @StartDate)
            AND (@EndDate IS NULL OR LoadEndTime <= @EndDate)
            AND (
                @StatusFilter IS NULL OR
                StagingStatus = @StatusFilter OR
                SalesforceStatus = @StatusFilter
            )
            AND (@ObjectType IS NULL OR ObjectType = @ObjectType)
    )
    SELECT *
    FROM FilteredResults
    WHERE RowNum BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize);
END;

GO

--usage

EXEC usp_GetETLSyncSummary 
    @StartDate = '2025-08-01',
    @EndDate = '2025-08-10',
    @StatusFilter = 'Success',
    @ObjectType = 'Contact',
    @PageNumber = 2,
    @PageSize = 25;
GO

/*

 Optional Add-ons
- Add TotalPages output using COUNT(*) over the filtered set
- Include LoadDurationSeconds from staging start to end
- Add IsPartialSync flag if RecordsSynced < RecordsInserted
*/

--Final Stored Procedure: Full Dashboard Logic

CREATE PROCEDURE usp_GetETLSyncSummary
    @StartDate DATETIME = NULL,
    @EndDate DATETIME = NULL,
    @StatusFilter NVARCHAR(50) = NULL,
    @ObjectType NVARCHAR(100) = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 50
AS
BEGIN
    SET NOCOUNT ON;

    -- Total record count for paging
    DECLARE @TotalRecords INT;

    SELECT @TotalRecords = COUNT(*)
    FROM vw_ETL_SyncDashboard
    WHERE
        (@StartDate IS NULL OR LoadStartTime >= @StartDate)
        AND (@EndDate IS NULL OR LoadEndTime <= @EndDate)
        AND (
            @StatusFilter IS NULL OR
            StagingStatus = @StatusFilter OR
            SalesforceStatus = @StatusFilter
        )
        AND (@ObjectType IS NULL OR ObjectType = @ObjectType);

    DECLARE @TotalPages INT = CEILING(@TotalRecords * 1.0 / @PageSize);

    WITH FilteredResults AS (
        SELECT
            *,
            DATEDIFF(SECOND, LoadStartTime, LoadEndTime) AS LoadDurationSeconds,
            DATEDIFF(SECOND, SyncStartTime, SyncEndTime) AS SyncDurationSeconds,
            CASE 
                WHEN RecordsSynced < RecordsInserted THEN 1 
                ELSE 0 
            END AS IsPartialSync,
            ROW_NUMBER() OVER (ORDER BY LoadStartTime DESC) AS RowNum
        FROM vw_ETL_SyncDashboard
        WHERE
            (@StartDate IS NULL OR LoadStartTime >= @StartDate)
            AND (@EndDate IS NULL OR LoadEndTime <= @EndDate)
            AND (
                @StatusFilter IS NULL OR
                StagingStatus = @StatusFilter OR
                SalesforceStatus = @StatusFilter
            )
            AND (@ObjectType IS NULL OR ObjectType = @ObjectType)
    )
    SELECT 
        *,
        @TotalPages AS TotalPages,
        @TotalRecords AS TotalRecords
    FROM FilteredResults
    WHERE RowNum BETWEEN ((@PageNumber - 1) * @PageSize + 1) AND (@PageNumber * @PageSize);
END;

GO

/*

Power BI Integration Options
1. Direct Query Mode
- Connect Power BI to your SQL Server database
- Use usp_GetETLSyncSummary as a stored procedure via a parameterized query
- Add slicers for StartDate, EndDate, Status, ObjectType, and paging controls
- Pros: Real-time data, no refresh needed
- Cons: Slower performance on large datasets
2. Import Mode with Scheduled Refresh
- Use Power BI to import from vw_ETL_SyncDashboard or a filtered version of the stored procedure
- Schedule refreshes (e.g., every hour or daily)
- Pros: Fast visuals, good for dashboards
- Cons: Not real-time unless refreshed frequently

Bonus Tip: Power BI Parameters
You can define Power BI parameters for:
- StartDate, EndDate
- StatusFilter, ObjectType
- PageNumber, PageSize
Then use Power Query to call the stored procedure like:

*/

EXEC usp_GetETLSyncSummary 
    @StartDate = @StartDateParam,
    @EndDate = @EndDateParam,
    @StatusFilter = @StatusParam,
    @ObjectType = @ObjectTypeParam,
    @PageNumber = @PageParam,
    @PageSize = @SizeParam;

GO

/*

Create Parameters for Filtering
Go to Transform Data > Manage Parameters and create:
| Parameter Name | Type | Example Value | 
| StartDateParam | Date/Time | 2025-08-01 | 
| EndDateParam | Date/Time | 2025-08-10 | 
| StatusParam | Text | Success | 
| ObjectTypeParam | Text | Contact | 
| PageParam | Whole Num | 1 | 
| SizeParam | Whole Num | 50 | 


Then update your SQL query in Power Query to use:

EXEC usp_GetETLSyncSummary 
    @StartDate = @StartDateParam,
    @EndDate = @EndDateParam,
    @StatusFilter = @StatusParam,
    @ObjectType = @ObjectTypeParam,
    @PageNumber = @PageParam,
    @PageSize = @SizeParam;

*/

/*

 Build Visuals
✅ Summary Cards
- Total Records
- Total Pages
- Average Sync Duration
- % Partial Syncs
📈 Charts
- Bar chart: RecordsInserted vs RecordsSynced by ObjectType
- Line chart: SyncDurationSeconds over time
- Pie chart: StagingStatus distribution
📋 Table View
- Paginated table showing:
- LoadBatchID, LoadStartTime, ObjectType, StagingStatus, SalesforceStatus, SyncDurationSeconds, IsPartialSync

🧭 4. Add Slicers
- Date range slicer (bind to LoadStartTime)
- Status slicer (multi-select)
- ObjectType slicer
- Page number dropdown (optional)

🔁 5. Refresh Strategy
- If using Import Mode, set scheduled refresh in Power BI Service
- If using Direct Query, visuals update live but may be slower



*/

/*

Dashboard Layout: “ETL + Sync Monitor”
🧭 Top Section: Filters & Controls
| Element | Type | Notes | 
| Date Range | Slicer | Bound to LoadStartTime | 
| Status Filter | Slicer | Multi-select: Success, Failed | 
| Object Type | Slicer | From ObjectType | 
| Page Number | Dropdown | Optional for paging | 



📊 Middle Section: KPI Cards
| Card Title | DAX Measure Example | 
| Total Records | TotalRecords = MAX('ETLSync'[TotalRecords]) | 
| Total Pages | TotalPages = MAX('ETLSync'[TotalPages]) | 
| Avg Sync Duration (sec) | AvgSyncDuration = AVERAGE('ETLSync'[SyncDurationSeconds]) | 
| Partial Sync % | PartialSyncPct = DIVIDE(COUNTROWS(FILTER('ETLSync', [IsPartialSync] = 1)), COUNTROWS('ETLSync')) | 



📈 Bottom Section: Visuals
1. Bar Chart: Object Type vs Sync Volume
- Axis: ObjectType
- Values: RecordsInserted, RecordsSynced
- Tooltip: IsPartialSync, SyncDurationSeconds
2. Line Chart: Sync Duration Over Time
- Axis: LoadStartTime
- Value: SyncDurationSeconds
- Legend: ObjectType or SalesforceStatus
3. Pie Chart: Status Distribution
- Values: Count of StagingStatus or SalesforceStatus
4. Table: Batch Details
| Column | Notes | 
| LoadBatchID | Unique batch ID | 
| LoadStartTime | Timestamp | 
| ObjectType | Synced object | 
| StagingStatus | ETL result | 
| SalesforceStatus | Sync result | 
| SyncDurationSeconds | Performance metric | 
| IsPartialSync | Flag for incomplete sync | 



 Bonus DAX Measures
FailedSyncs = COUNTROWS(FILTER('ETLSync', [SalesforceStatus] = "Failed"))

AvgLoadDuration = AVERAGE('ETLSync'[LoadDurationSeconds])

SyncEfficiency = DIVIDE(SUM('ETLSync'[RecordsSynced]), SUM('ETLSync'[RecordsInserted]))




*/

/*
Would you like help building this in Power BI Desktop or exporting it to a template?



*/
