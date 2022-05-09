SELECT *
FROM Portfolio_Project..NashvilleHData


--Standardize Date Format
SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM Portfolio_Project..NashvilleHData

UPDATE NashvilleHData
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHData
Add SaleDateConverted Date;

UPDATE NashvilleHData
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property address data
SELECT *
FROM Portfolio_Project..NashvilleHData
ORDER BY ParcelID


SELECT A.ParcelID, B.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM Portfolio_Project..NashvilleHData AS A
JOIN Portfolio_Project..NashvilleHData AS B
   ON A.ParcelID = B.ParcelID
   AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM Portfolio_Project..NashvilleHData AS A
JOIN Portfolio_Project..NashvilleHData AS B
   ON A.ParcelID = B.ParcelID
   AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL

-- Breaking out Address into individual columns (Address, City, State)
SELECT PropertyAddress 
FROM Portfolio_Project..NashvilleHData


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Portfolio_Project..NashvilleHData

ALTER TABLE NashvilleHData
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHData
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM Portfolio_Project..NashvilleHData

SELECT OwnerAddress
FROM Portfolio_Project..NashvilleHData


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Project..NashvilleHData

ALTER TABLE NashvilleHData
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHData
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER TABLE NashvilleHData
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM Portfolio_Project..NashvilleHData


-- Change Y and N to YES and NO in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio_Project..NashvilleHData
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant 
	 END
FROM Portfolio_Project..NashvilleHData


UPDATE NashvilleHData
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END


-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY 
			     UniqueID
				 ) row_num
FROM Portfolio_Project..NashvilleHData
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
Order by PropertyAddress



-- Delete Unused Columns

SELECT *
FROM Portfolio_Project..NashvilleHData

ALTER TABLE  Portfolio_Project..NashvilleHData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



