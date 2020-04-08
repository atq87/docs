SET NOCOUNT ON; 

IF OBJECT_ID('tempdb..#MD') IS NOT NULL DROP TABLE #MD;
CREATE TABLE #MD (
  [SettingDisplayGrouping] NVARCHAR(50),
  [SettingDisplayOrder] INT,
  [md] NVARCHAR(MAX)
)

DECLARE	@displayGrouping NVARCHAR(50)

DECLARE @groupings TABLE(
  [SettingDisplayGrouping] NVARCHAR(50)
)

INSERT		INTO @groupings
SELECT		DISTINCT [SettingDisplayGrouping]
FROM		[app].[Settings]
ORDER BY	[SettingDisplayGrouping]

WHILE (SELECT COUNT([SettingDisplayGrouping]) FROM @groupings) > 0
BEGIN  
	SELECT @displayGrouping = MIN([SettingDisplayGrouping]) FROM @groupings

	IF OBJECT_ID('tempdb..#SETTING') IS NOT NULL DROP TABLE #SETTING;
	SELECT	[SettingDisplayGrouping], [SettingDisplayOrder], [SettingKey], [Description]
	INTO	#SETTING
	FROM	[app].[Settings]
	WHERE	[CustomerUID] = '00000000-0000-0000-0000-000000000000' 
		AND [VersionUID] = '00000000-0000-0000-0000-000000000000'
		AND	[SettingDisplayGrouping] = @displayGrouping
		AND [IsDeleted] = 0
	ORDER BY [SettingDisplayGrouping], [SettingDisplayOrder]

	IF EXISTS(Select * FROM #SETTING)
	BEGIN
		INSERT INTO #MD ([SettingDisplayGrouping], [SettingDisplayOrder], [md])
		SELECT	@displayGrouping AS [SettingDisplayGrouping], -10, '### ' + @displayGrouping AS [md]
		UNION ALL
		SELECT	@displayGrouping AS [SettingDisplayGrouping], -9, '' AS [md]
		UNION ALL
		SELECT	@displayGrouping AS [SettingDisplayGrouping], -8, '| Setting Key                              | Setting Description                                                              |'  AS [md]
		UNION ALL
		SELECT	@displayGrouping AS [SettingDisplayGrouping], -7, '| ---------------------------------------- | -------------------------------------------------------------------------------- |' AS [md]
		UNION ALL
		SELECT  @displayGrouping [SettingDisplayGrouping], [SettingDisplayOrder], '| ' + COALESCE(CAST([SettingKey] AS CHAR(40)),'') +
				' | ' + REPLACE(REPLACE(COALESCE(CAST([Description] AS VARCHAR(2000)),''), '"', '`'), '  ', ' ') +
				' |' AS [md]
		FROM	#SETTING
		UNION ALL 
		SELECT	@displayGrouping AS [SettingDisplayGrouping], 1000, '' AS [md]
	END

	DELETE FROM @groupings WHERE [SettingDisplayGrouping] = @displayGrouping
END

SELECT md
FROM #MD
order by [SettingDisplayGrouping], [SettingDisplayOrder]