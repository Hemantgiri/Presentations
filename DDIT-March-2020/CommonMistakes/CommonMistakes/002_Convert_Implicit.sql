USE MASTER;
EXECUTE 
(
    'CREATE DATABASE DustBin
        ON 
        ( NAME = DustBin_dat,
            FILENAME = ''C:\SQLDATA\DEMODBS\DustBin_data.mdf'',
            SIZE = 10,
            MAXSIZE = 5000MB,
            FILEGROWTH = 5MB 
        )
        LOG ON
        ( NAME = DustBin_log,
            FILENAME = ''C:\SQLDATA\DEMODBS\DustBin_log.ldf'',
            SIZE = 5MB,
            MAXSIZE = 2500MB,
            FILEGROWTH = 5MB 
        )'
);
USE DustBin
GO

-- Let's create a test table
CREATE TABLE dbo.ConvertTest 
(
	BigIntColumn BIGINT NOT NULL,
	IntColumn INT NOT NULL,
	DateColumn VARCHAR(30)
);

--Let's create a few indexes
CREATE INDEX BigIntIndex  ON dbo.ConvertTest (BigIntColumn);

CREATE INDEX IntIndex ON dbo.ConvertTest (IntColumn);

CREATE INDEX DateIndex ON dbo.ConvertTest(DateColumn);

-- Okay, let's insert a few values into a table now
WITH    Nums
AS (SELECT TOP (1000000)
ROW_NUMBER() OVER (ORDER BY (SELECT 1
)) AS n
FROM      master.sys.all_columns ac1
CROSS JOIN master.sys.all_columns ac2
)
INSERT  INTO dbo.ConvertTest
(BigIntColumn,
IntColumn,
DateColumn
)
SELECT  Nums.n,
Nums.n,
DATEADD(HOUR, Nums.n, '1/1/1900')
FROM    Nums

-- Since we need to see if implicit conversion is costly or not, let's set option to check CPU time
-- Let's check the Execution Plan as well
SET SHOWPLAN_XML ON 
set statistics time on

-- Let's run Query 1 that uses the different data type to compare a value
DECLARE @param DATETIME;
SET @param = '4/01/1900 5:00:00';
SELECT  ct.DateColumn
FROM    dbo.ConvertTest AS ct
WHERE   ct.DateColumn = @param;

-- Let's run Query 2 that uses the same data type to compare a value
DECLARE @param1 VARCHAR(30);
SET @param1 = '4/01/1900 5:00:00';
SELECT  ct.DateColumn
FROM    dbo.ConvertTest AS ct
WHERE   ct.DateColumn = @param1

DROP DATABASE DustBin