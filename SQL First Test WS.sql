--Soal No 1
CREATE TABLE Customer_Type 
(
	[type_id] bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[type_nama] varchar(50) NOT NULL,
	[stsrc] char(1) NOT NULL,
	[created_by] varchar(20) NULL,
	[date_created] datetime NULL,
	[modified_by] varchar(20) NULL,
	[date_modified] datetime NULL
)

CREATE TABLE Customer
(
	[cust_id] bigint IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[cust_nama] varchar(50) NOT NULL,
	[cust_alamat] varchar(100) NOT NULL,
	[cust_telp] varchar(15) NULL,
	[type_id] bigint NOT NULL,
	[stsrc] char(1) NOT NULL,
	[created_by] varchar(20) NULL,
	[date_created] datetime NULL,
	[modified_by] varchar(20) NULL,
	[date_modified] datetime NULL,
	CONSTRAINT FK_Customer_Customer_Type FOREIGN KEY ([type_id])
    REFERENCES dbo.Customer_Type([type_id])
)

--Soal No 2
INSERT INTO dbo.Customer_Type
        ( type_nama ,
          stsrc ,
          created_by ,
          date_created        )
VALUES  ('VIP', 'A', 'SYSTEM', GETDATE()), 
	('Premium', 'A', 'SYSTEM', GETDATE()),
	('Gold', 'A', 'SYSTEM', GETDATE()),
	('Silver', 'A', 'SYSTEM', GETDATE())

INSERT INTO dbo.Customer
        ( cust_nama ,
          cust_alamat ,
          cust_telp ,
          type_id ,
          stsrc ,
          created_by ,
          date_created        )
VALUES  ('Adika', 'Jl. Setiabudi No.2', '08988877162', 1, 'A', 'SYSTEM', GETDATE()),
	('Adinda', 'Jl. Raya Kebon Jeruk No.1', '08998877162', 2, 'A', 'SYSTEM', GETDATE()),
	('Dheabella', 'Jl. Mt Haryono No.25', '08978877162', 3, 'A', 'SYSTEM', GETDATE()),
	('Budi', 'Jl. Gatot Subroto No.3', '08968877162', 3, 'A', 'SYSTEM', GETDATE()),
	('Ana', 'Jl. Ketapang Indah No.2', '08958877162', 4, 'A', 'SYSTEM', GETDATE())

INSERT INTO dbo.Customer
        ( cust_nama ,
          cust_alamat ,
          cust_telp ,
          type_id ,
          stsrc ,
          created_by ,
          date_created        )
SELECT 'Alfa', 'Jl. Gatot Subroto No.5', '08958877162', type_id, 'A', 'SYSTEM', GETDATE()
FROM dbo.Customer_Type
WHERE type_nama = 'Premium'

--Soal No 3
UPDATE dbo.Customer
SET cust_nama = 'Customer VIP edited', date_modified = GETDATE(), modified_by = 'SYSTEM'
WHERE TYPE_ID = 1
UPDATE a
SET a.peng_entrier = b.sup_nama
FROM dbo.Pengadaan_Header a
INNER JOIN dbo.Supplier b ON a.supplier_id = b.sup_id

-- Soal No 4
UPDATE dbo.Customer
SET stsrc = 'D', modified_by = 'SYSTEM', date_modified = GETDATE()
WHERE TYPE_ID = 2

-- Soal No 5
SELECT a.peng_date, b.sup_nama, a.peng_kode
FROM dbo.Pengadaan_Header a
INNER JOIN dbo.Supplier b ON a.supplier_id = b.sup_id
WHERE MONTH(a.peng_date) = 8
ORDER BY b.sup_nama DESC

--Soal No 6
SELECT peng_kode, SUM(b.pengd_jumlah * b.pengd_harga) AS total_nilai_pengadaan
FROM dbo.Pengadaan_Header a
INNER JOIN dbo.Pengadaan_Detail b ON a.peng_id = b.peng_id
GROUP BY a.peng_kode, a.peng_date, a.stsrc
HAVING MONTH(a.peng_date) < 8 AND a.stsrc = 'A' 

--Soal No 7
SELECT item_nama
FROM dbo.Item_Master
WHERE item_id NOT IN (SELECT item_id FROM dbo.Pengadaan_Detail)

-- Soal No 8
SELECT b.item_nama, SUM(a.pengd_jumlah) AS jumlah_pembelian
FROM dbo.Pengadaan_Detail a
INNER JOIN dbo.Item_Master b ON a.item_id = b.item_id
GROUP BY b.item_nama, a.item_id
HAVING SUM(a.pengd_jumlah) < 100

-- Soal No 9
SELECT a.peng_id, d.item_nama, c.sup_nama
FROM dbo.Pengadaan_Header a
INNER JOIN dbo.Pengadaan_Detail b ON a.peng_id = b.peng_id
INNER JOIN dbo.Supplier c ON a.supplier_id = c.sup_id
INNER JOIN dbo.Item_Master d ON b.item_id = d.item_id
GROUP BY a.peng_id, d.item_nama, c.sup_nama, a.peng_date
HAVING MONTH(a.peng_date) < 8 AND SUM(b.pengd_jumlah) > 20 AND c.sup_nama LIKE '%1%'

-- Soal No 10
SELECT c.sup_nama, MAX(b.pengd_jumlah * b.pengd_harga) AS nilai_total_terbesar
FROM dbo.Pengadaan_Header a
INNER JOIN dbo.Pengadaan_Detail b ON a.peng_id = b.pengd_id
INNER JOIN dbo.Supplier c ON a.supplier_id = c.sup_id
GROUP BY c.sup_nama
ORDER BY sup_nama ASC


-- Begin tran dan Rollback penting.
-- stsrc yang a.
-- update ditambahkan juga modified date dan modified by.
-- having digunakan hanya untuk sum, count, selebihnya pakai where aja.
-- INsert kalo ada field yang di foreign key, pake select aja.
