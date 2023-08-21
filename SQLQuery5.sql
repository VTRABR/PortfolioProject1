/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioP1.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date, SaleDate) 
From PortfolioP1.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate) 




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioP1.dbo.NashvilleHousing AS a
ORDER BY ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioP1.dbo.NashvilleHousing AS a
JOIN PortfolioP1.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioP1.dbo.NashvilleHousing AS a
JOIN PortfolioP1.dbo.NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioP1.dbo.NashvilleHousing AS a

SELECT 
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS AddressPart1,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS AddressPart2
FROM PortfolioP1.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD PropertySplitAdress Nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 


SELECT * 
FROM PortfolioP1.dbo.NashvilleHousing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioP1.dbo.NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD OwnerSplitAdress nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioP1.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE	
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioP1.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE	
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY	ParcelID, 
					PropertyAddress, 
					SalePrice, 
					SaleDate, 
					LegalReference 
					ORDER BY UniqueID) row_num

FROM PortfolioP1.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY	ParcelID, 
					PropertyAddress, 
					SalePrice, 
					SaleDate, 
					LegalReference 
					ORDER BY UniqueID) row_num

FROM PortfolioP1.dbo.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT * 
FROM PortfolioP1.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate















