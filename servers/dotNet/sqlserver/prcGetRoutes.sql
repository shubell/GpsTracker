USE [GPSTracker]
GO
/****** Object:  StoredProcedure [dbo].[prcGetRoutes]    Script Date: 5.5.2015 11:36:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[prcGetRoutes]
AS

SET NOCOUNT ON

CREATE TABLE #tempRoutes 
( 
     sessionID NVARCHAR(50) COLLATE DATABASE_DEFAULT NULL, 
    userName NVARCHAR(50) COLLATE DATABASE_DEFAULT NULL, 
    startTime DATETIME NULL,
	endTime DATETIME NULL 
)

-- get the distinct routes
INSERT #tempRoutes (sessionID, userName)
SELECT DISTINCT sessionID, userName
FROM gpslocations

-- get the route start times
UPDATE #tempRoutes
SET startTime = (SELECT MIN(gpsTime) FROM gpslocations gl
WHERE gl.sessionID = tr.sessionID
AND gl.userName = tr.userName)
FROM #tempRoutes tr

-- get the route end times
UPDATE #tempRoutes
SET endTime = (SELECT MAX(gpsTime) FROM gpslocations gl
WHERE gl.sessionID = tr.sessionID
AND gl.userName = tr.userName)
FROM #tempRoutes tr

-- format dates and then send it out as json

SELECT '{ "sessionID": "' + CAST(sessionID AS NVARCHAR(50)) 
+ '", "userName": "' + userName
+  '", "times": "(' + CONVERT(NVARCHAR(25), startTime, 100) 
+ ' - ' + CONVERT(NVARCHAR(25), endTime, 100) + ')" }' json
FROM #tempRoutes
ORDER BY startTime DESC

DROP TABLE #tempRoutes



