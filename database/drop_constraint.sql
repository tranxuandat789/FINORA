DECLARE @ConstraintName nvarchar(200)
SELECT @ConstraintName = Name 
FROM sys.check_constraints 
WHERE parent_object_id = object_id('GoalContributions')

IF @ConstraintName IS NOT NULL
BEGIN
    EXEC('ALTER TABLE GoalContributions DROP CONSTRAINT ' + @ConstraintName)
END
