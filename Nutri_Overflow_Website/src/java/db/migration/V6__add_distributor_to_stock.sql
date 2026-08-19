IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Stock') AND name = 'distributor_name')
BEGIN
    ALTER TABLE Stock ADD distributor_name NVARCHAR(255) NULL;
END
