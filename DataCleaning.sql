/*

Cleaning Data in SQL Queries

*/

SELECT * FROM NashvilleHousingDataCleaning

-- Standardize Date Format

SELECT SaleDate, CONVERT(date, SaleDate)
FROM NashvilleHousingDataCleaning

UPDATE NashvilleHousingDataCleaning
SET SaleDate = CONVERT(date, SaleDate)

-- If it doesn't Update properly

-- OR

ALTER TABLE NashvilleHousingDataCleaning
ADD SaleDateConverted date

UPDATE NashvilleHousingDataCleaning
SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDateConverted FROM NashvilleHousingDataCleaning

-- Populate Property Address data

Select PropertyAddress FROM NashvilleHousingDataCleaning
WHERE PropertyAddress is NULL

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingDataCleaning a
JOIN NashvilleHousingDataCleaning b
ON a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingDataCleaning a
JOIN NashvilleHousingDataCleaning b
ON a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))
FROM NashvilleHousingDataCleaning

ALTER TABLE NashvilleHousingDataCleaning
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousingDataCleaning
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousingDataCleaning
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousingDataCleaning
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM NashvilleHousingDataCleaning

SELECT OwnerAddress,PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousingDataCleaning

ALTER TABLE NashvilleHousingDataCleaning
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousingDataCleaning
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousingDataCleaning
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousingDataCleaning
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousingDataCleaning
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousingDataCleaning
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT distinct(SoldAsVacant)
FROM NashvilleHousingDataCleaning

SELECT SoldAsVacant,
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END
FROM NashvilleHousingDataCleaning

UPDATE NashvilleHousingDataCleaning
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END

-- Remove Duplicates

SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
    ORDER BY 
    UniqueID
) AS Row_Num
FROM NashvilleHousingDataCleaning
ORDER BY ParcelID

WITH RowNumCTE AS(
    SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
    ORDER BY 
    UniqueID
    ) AS Row_Num
    FROM NashvilleHousingDataCleaning
)
SELECT * FROM RowNumCTE
WHERE Row_Num > 1
ORDER BY PropertyAddress

WITH RowNumCTE AS(
    SELECT *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
    PropertyAddress,
    SalePrice,
    SaleDate,
    LegalReference
    ORDER BY 
    UniqueID
    ) AS Row_Num
    FROM NashvilleHousingDataCleaning
)
Delete FROM RowNumCTE
WHERE Row_Num > 1

-- Delete Unused Columns

ALTER TABLE NashvilleHousingDataCleaning
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE NashvilleHousingDataCleaning
DROP COLUMN SaleDate