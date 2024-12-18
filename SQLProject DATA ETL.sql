-- Cleaning Data in SQL Queries

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing


----------------------------------------------------------

-- Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------

-- Populate Property Address Data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress  -- a.P.ADRESS IS MISSING, so we MATCH = a & b.ParcelID with = b.PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) AS 'a.PropertyAddress'
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a  --- NO MORE NULL PropertyAddress
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

----------------------------------------------------------

--- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
-- WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
    CASE 
        WHEN CHARINDEX(',', PropertyAddress) > 0 
        THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 
        ELSE PropertyAddress 
    END AS PropertySplitAddress,
    CASE 
        WHEN CHARINDEX(',', PropertyAddress) > 0 
        THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 
        ELSE NULL 
    END AS PropertySplitCity 
FROM PortfolioProject.dbo.NashvilleHousing;


SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = 
	CASE 
        WHEN CHARINDEX(',', PropertyAddress) > 0 
        THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 
        ELSE PropertyAddress 
    END 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------

---Breaking out OWNER Address into Individual Columns

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.') ,3) AS 'Address',
PARSENAME(REPLACE(OwnerAddress,',', '.') ,2) AS 'City',
PARSENAME(REPLACE(OwnerAddress,',', '.') ,1) AS 'State'
FROM PortfolioProject.dbo.NashvilleHousing



ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

---CHECK
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
------------------------------ SAME AS (NO NEED TO EXECUTE)-->
ALTER TABLE NashvilleHousing
Add 
	OwnerSplitAddress Nvarchar(255),
	OwnerSplitCity Nvarchar(255),
	OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET 
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Checking 1=No & 0=Yes
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
WHERE SoldAsVacant = 1;

---Change bit value to VARCHAR for 'Yes' & 'No'
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(50);

---Change VALUE '0'-->'Yes' & '1'-->'No'
SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = '0' THEN 'Yes'
	WHEN SoldAsVacant = '1' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject.dbo.NashvilleHousing

----REFLECT CHANGES ON THE TABLE
UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = '0' THEN 'Yes'
	WHEN SoldAsVacant = '1' THEN 'No'
	ELSE SoldAsVacant
	END

--CHECK RESULTS
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT*
FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------

-- REMOVING DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY 
				ParcelID,	
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1 -- THIS WILL SHOW ALL THE DUPLICATED ROWS 
--ORDER BY PropertyAddress 

--- NOW WE MUST DELETE THE DUPLICATED DATA
--- SUBSTITUTE SELECT with DELETE 1st
-- CHECKING -->
SELECT *
FROM RowNumCTE
WHERE row_num > 1 
ORDER BY PropertyAddress -- THIS MUST BE DONE ON THE CODE BELOW (READIBILITY PURPOSES)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------

-- DELETE UNUSED COLUMNS (FOR CREATED VISUALS)

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress  --- SPLITED AMONG PARTS PREVIOUSLY AS SHOWN IN THE DATABASE



--- THIS IS THE END OF THE SQL ETL DATA CLEANING