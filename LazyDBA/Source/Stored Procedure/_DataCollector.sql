CREATE PROCEDURE [dbo].[DataCollector]
AS
BEGIN

SET NOCOUNT ON;

EXEC GetPossibleBadIndexesList;

EXEC GetPossibleNewIndexesList;

END