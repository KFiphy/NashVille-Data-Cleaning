--Viewing all columns in NashVile Table
SELECT * FROM [NashVille Housing]

--1.Viewing and Standardizing the Sales Date Column (removing date from time)

SELECT [NashVille Housing].SaleDate FROM [NashVille Housing]
SELECT [NashVille Housing].SaleDate, CONVERT(DATE, SaleDate) FROM [NashVille Housing]

UPDATE [NashVille Housing]
SET SaleDate = CONVERT(DATE, SaleDate) --This query writes successful but the column contents do not change. Therefore, I will add new column for Date.

ALTER TABLE [NashVille Housing]
ADD SaleDateConverted DATE;

UPDATE [NashVille Housing]
SET SaleDateConverted = CONVERT(DATE, SaleDate)

--ProofChecking; Added columns are the end
SELECT SaleDateConverted FROM [NashVille Housing]



--2.Viewing & populating the property Address
SELECT PropertyAddress FROM [NashVille Housing]
SELECT * FROM [NashVille Housing] WHERE PropertyAddress IS NULL

--Self joining NashVille Housing table

 SELECT A.[UniqueID ] ,A.ParcelID, B.ParcelID, A.PropertyAddress, B.PropertyAddress FROM [NashVille Housing] A 
JOIN [NashVille Housing] B ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ] WHERE A.PropertyAddress IS NULL

--filling the property address of Table A

SELECT A.[UniqueID ] ,A.ParcelID, B.ParcelID, A.PropertyAddress, B.PropertyAddress, 
ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [NashVille Housing] A JOIN [NashVille Housing] B ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ] 
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [NashVille Housing] A JOIN [NashVille Housing] B ON A.ParcelID = B.ParcelID AND A.[UniqueID ] <> B.[UniqueID ] 
WHERE A.PropertyAddress IS NULL

--ProofChecking; THis should bring nothing.
SELECT * FROM [NashVille Housing] WHERE PropertyAddress IS NULL


--3. Breaking out Address into individual Column (Adresss, City, State)
SELECT PropertyAddress FROM [NashVille Housing]

-- using substring to pull out wanted characters. Charindex helps to point to end position as ',' since we cant use a general number for all as end position.
--1 indicates the character before ,

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN (PropertyAddress)) AS City FROM [NashVille Housing]

ALTER TABLE[NashVille Housing]
ADD PropertySplitAddress NVARCHAR (200)

UPDATE [NashVille Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1)

ALTER TABLE[NashVille Housing]
ADD PropertyCitySplit NVARCHAR (200)

UPDATE [NashVille Housing]
SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN (PropertyAddress))

--ProofChecking : Added Columns are the end.
SELECT * FROM [NashVille Housing]



--4. Viewing and Splitting OwnerAddress into Street, City, State
SELECT OwnerAddress FROM [NashVille Housing]

--Here, we are using Parsename instead of Substring. It only recoggnizes '.', we will need to replace our , with .
--it also returns outputs in backward manner or reads from right to left 1.e State City Street, and not street city state as written. so, we will number its functions as 3 2 1 and not 1 2 3.

SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'), 3), PARSENAME(REPLACE(OwnerAddress,',','.'), 2), PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM [NashVille Housing]

ALTER TABLE [NashVille Housing]
ADD OwnerStreet NVARCHAR (100);

UPDATE [NashVille Housing]
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE [NashVille Housing]
ADD OwnerCity NVARCHAR (100);

UPDATE [NashVille Housing]
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [NashVille Housing]
ADD OwnerState NVARCHAR (100);

UPDATE [NashVille Housing]
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--ProofChecking : Added Columns are the end.
SELECT * FROM [NashVille Housing]



--5.Viewing & Changing 'Y' to Yes and 'N' to NO in SoldAsVacant Column
SELECT DISTINCT SoldAsVacant , COUNT(SoldAsVacant) AS num_of_events  FROM [NashVille Housing] GROUP BY SoldAsVacant --distinct to enable views other than Yes and No

SELECT SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END
FROM [NashVille Housing]

UPDATE [NashVille Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' WHEN SoldAsVacant = 'N' THEN 'No' ELSE SoldAsVacant END

--ProofChecking; We should see only Yes and No
SELECT DISTINCT SoldAsVacant FROM [NashVille Housing]


--6.Removing Duplicates*** (Not Advisable removing data in your database)

WITH row_numS AS(
                SELECT *, ROW_NUMBER () OVER (PARTITION BY PropertyAddress,LegalReference,SaleDate,SalePrice ORDER BY  [UniqueID ]) AS row_num
              FROM [NashVille Housing])

DELETE FROM row_numS WHERE row_num > 1 

--ProofChecking: We should see nothing
WITH row_numS AS(
                SELECT *, ROW_NUMBER () OVER (PARTITION BY PropertyAddress,LegalReference,SaleDate,SalePrice ORDER BY  [UniqueID ]) AS row_num
              FROM [NashVille Housing])

SELECT * FROM row_numS WHERE row_num > 1 


---7.Deleting unused columns. ***Do not do this to the raw data that comes into your database.

ALTER TABLE [NashVille Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--ProofChecking
SELECT * FROM [NashVille Housing]

