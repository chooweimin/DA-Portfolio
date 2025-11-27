/*

Cleaning Data in SQL Queries

*/

Select *
From PortfolioProject..NashvilleHousing

EXEC sp_help 'NashvilleHousing';

--------------------------------------------------------------------------------------------------------------------------


-- Standardize Date Format


-- Add the column
ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted DATE;

-- Populate the column
UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CONVERT(DATE, SaleDate);

-- Verify
SELECT SaleDate, SaleDateConverted
FROM PortfolioProject..NashvilleHousing
ORDER BY SaleDate;


--------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data


-- Preview the table
Select *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID

-- Check rows to fill
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Update missing addresses
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Step 4: Verify if any rows that still have NULL for PropertyAddress
SELECT ParcelID, PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;


--------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)


-- PropertyAddress

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

-- Extracts the first part of the address
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

-- Add the PropertySplitAddress to the table
ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- Add the PropertySplitCity to the table
ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 ,  LEN(PropertyAddress) )

-- Verify if the column PropertySplitAddress & PropertySplitCity added successfully or not
Select *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID


-- OwnerAddress

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

-- PARSENAME() splits values based on dots, so we REPLACE commas with dots
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Verify if the column added successfully or not
Select *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


-- Contains mixed values Y, N, Yes, No in "Sold as Vacant"
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing

-- If the current value is Y, change it to Yes
-- If the current value is N, change it to No
-- All other values remain unchanged
Update PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;

-- Used for checking the duplicate values
-- Select *
-- From RowNumCTE
-- Where row_num > 1
-- Order by PropertyAddress

Select *
From PortfolioProject.dbo.NashvilleHousing


---------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

