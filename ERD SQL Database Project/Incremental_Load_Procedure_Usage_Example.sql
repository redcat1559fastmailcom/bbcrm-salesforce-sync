--Default
EXEC Run_BBCRM_Staging_Load;

--Fource full load
EXEC Run_BBCRM_Staging_Load @ForceFullLoad = 1;