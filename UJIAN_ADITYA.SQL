--Basic
-- NO. 1
INSERT INTO dbo.Item_Master
(
    item_nama,
    item_kode,
    stsrc,
    created_by,
    date_created,
    modified_by,
    date_modified
)
VALUES
(   'MINYAK GORENG',        -- item_nama - varchar(100)
    'ITEM05',        -- item_kode - varchar(10)
    'A',        -- stsrc - char(1)
    'admin',        -- created_by - varchar(20)
    GETDATE(), -- date_created - datetime
    NULL,        -- modified_by - varchar(20)
    NULL  -- date_modified - datetime
    )


-- NO. 1
    INSERT INTO dbo.Stock_Master
    (
        item_id,
        stock_qty,
        ordd_id,
        stock_ket,
        stsrc,
        created_by,
        date_created,
        modified_by,
        date_modified
    )
    VALUES
    (   5,         -- item_id - bigint
        25,         -- stock_qty - int
        NULL,         -- ordd_id - bigint
        'Stok Awal',        -- stock_ket - varchar(500)
        'A',        -- stsrc - char(1)
        'admin',        -- created_by - varchar(20)
        GETDATE(), -- date_created - datetime
        NULL,        -- modified_by - varchar(20)
        NULL-- date_modified - datetime
        )

--NO. 2
UPDATE dbo.Item_Master
SET item_kode = 'ITEM06', modified_by = 'Adit', date_modified= GETDATE()
WHERE item_kode = 'ITEM05'

--NO. 3
UPDATE dbo.Item_Master
SET stsrc = 'D', modified_by = 'Adit', date_modified= GETDATE()

-------------------------------------------------------------------------------

--A
--NO. 1
SELECT oh.ordh_date, cm.cust_nama, oh.ordh_kode
FROM dbo.Order_Header oh
LEFT JOIN dbo.Customer_Master cm ON cm.cust_id = oh.cust_id
WHERE YEAR(oh.ordh_date)=2018
ORDER BY cm.cust_nama DESC

--NO. 2
SELECT oh.ordh_kode, SUM(od.ordd_qty*od.ordd_harga) AS Total_Penjualan
FROM dbo.Order_Header oh
LEFT JOIN dbo.Order_Detail od ON od.ordh_id = oh.ordh_id
GROUP BY oh.ordh_kode

--NO.3
SELECT item_kode, item_nama
FROM dbo.Item_Master
WHERE item_id NOT IN(SELECT item_id FROM dbo.Order_Detail)

--No. 4
INSERT INTO dbo.Stock_Master (item_id, stock_qty,ordd_id, stock_ket,stsrc, created_by, date_created)
SELECT item_id, ordd_qty*-1, ordd_id, 'Penjualan', 'A', 'admin', GETDATE() FROM dbo.Order_Detail
WHERE ordd_qty > 1

--No. 5
UPDATE dbo.Order_Header
SET ordh_date =
DATEFROMPARTS(YEAR(ordh_date),
CONVERT (INT, (SUBSTRING(cust_kode ,5,2))),
DAY(ordh_date))
FROM dbo.Order_Header oh
INNER JOIN dbo.Customer_Master cm ON cm.cust_id = oh.cust_id
SELECT oh.ordh_id, oh.ordh_date, cm.cust_kode
FROM dbo.Order_Header oh
INNER JOIN dbo.Customer_Master cm ON cm.cust_id = oh.cust_id

--No. 6
SELECT oh.ordh_kode, MAX(oh.ordh_date) AS ordh_date, im.item_kode, im.item_nama, od.ordd_qty, od.ordd_harga
FROM dbo.Item_Master im
INNER JOIN dbo.Order_Detail od ON od.item_id = im.item_id
INNER JOIN dbo.Order_Header oh ON oh.ordh_id = od.ordh_id
GROUP BY oh.ordh_date,
oh.ordh_kode,
im.item_kode,
im.item_nama,
od.ordd_qty, od.ordd_harga
having oh.ordh_date IN (SELECT MAX(ordh_date) FROM dbo.Order_Header)

--No. 7
SELECT im.item_nama, MAX(sm.stock_qty- ISNULL(od.ordd_qty,0)) qty
FROM dbo.Item_Master im
LEFT JOIN dbo.Stock_Master sm ON sm.item_id = im.item_id
LEFT JOIN dbo.Order_Detail od ON od.item_id = sm.item_id
WHERE im.item_kode != 'ITEM06'
GROUP BY im.item_nama

--No. 8
SELECT im.item_nama, od.ordd_qty AS qty
FROM dbo.Item_Master im
LEFT JOIN dbo.Order_Detail od ON od.item_id = im.item_id
GROUP BY im.item_nama, od.ordd_qty
having od.ordd_qty IN (SELECT MAX(ordd_qty) FROM dbo.Order_Detail)

-------------------------------------------------------------------------------

--B
--No. 1
GO
CREATE PROCEDURE
[dbo].[usp_insertDataToOHOD]
@ord_kode varchar(20),
@cust_kode varchar(20),
@kode_item varchar (20),
@ordd_harga bigint
AS
BEGIN
	INSERT INTO dbo.Order_Header
	(
	    ordh_date,
	    cust_id,
	    ordh_kode,
	    stsrc,
	    created_by,
	    date_created,
	    modified_by,
	    date_modified
	)
	VALUES
	(   GETDATE(), -- ordh_date - datetime
	    1,         -- cust_id - bigint
	    @ord_kode,        -- ordh_kode - varchar(10)
	    'A',        -- stsrc - char(1)
	    'admin',        -- created_by - varchar(20)
	    GETDATE(), -- date_created - datetime
	    NULL,        -- modified_by - varchar(20)
	    NULL  -- date_modified - datetime
	    )

INSERT INTO dbo.Order_Detail
(
    ordh_id,
    item_id,
    ordd_qty,
    ordd_harga,
    stsrc,
    created_by,
    date_created,
    modified_by,
    date_modified
)
VALUES
(   (SELECT ordh_id FROM dbo.Order_Header),         -- ordh_id - bigint
    2,         -- item_id - bigint
    1,         -- ordd_qty - int
    @ordd_harga,      -- ordd_harga - decimal(18, 2)
    'A',        -- stsrc - char(1)
    'Adit',        -- created_by - varchar(20)
    GETDATE(), -- date_created - datetime
    NULL,        -- modified_by - varchar(20)
    NULL-- date_modified - datetime
    )
END

--No. 2
GO
CREATE PROCEDURE
[dbo].[usp_showDataOHOD]
@item_kode VARCHAR(20),
@ord_kode VARCHAR(20),
@cust_kode VARCHAR(20),
@bulan BIGINT,
@tahun BIGINT
AS
BEGIN
DECLARE @sql nvarchar (2000)
SELECT @sql =
'SELECT oh.ordh_kode, oh.ordh_date, im.item_nama, cm.cust_nama, od.ordd_harga
FROM dbo.Order_Header oh
LEFT JOIN dbo.Order_Detail od ON od.ordh_id = oh.ordh_id
LEFT JOIN dbo.Item_Master im ON im.item_id = od.item_id
LEFT JOIN dbo.Customer_Master cm ON cm.cust_id = oh.cust_id
WHERE oh.ordh_kode = @ord_kode AND MONTH(oh.ordh_date) = @bulan
AND YEAR(oh.ordh_date) = @tahun
AND cm.cust_kode = @cust_kode
AND im.item_kode = @item_kode'
EXEC sp_executesql @sql,N'@bulan BIGINT, @tahun BIGINT, @item_kode varchar(20),
@ord_kode varchar(20),@cust_kode varchar(20)', @bulan, @tahun, @item_kode, @ord_kode, @cust_kode
END
--Cek Output
EXEC dbo.usp_showDataOHOD @item_kode = 'ITEM01', -- varchar(20)
                          @ord_kode = 'ORD01',  -- varchar(20)
                          @cust_kode = 'CUST01', -- varchar(20)
                          @bulan = 3,      -- bigint
                          @tahun = 2018       -- bigint
