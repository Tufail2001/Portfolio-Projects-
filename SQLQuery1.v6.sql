/*
Cleaning Data In SQL
*/

Select *
From PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate) 

ALTER  TABLE NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate) 


-----------------------------------------------------------------------------------------------------------------

-- Populate Property Address 

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

Update a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


--------------------------------------------------------------------------------------------------------------------------

--Breaking Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) As Address
	
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET  PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

Select *
From PortfolioProject.dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From  PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N into Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing

Select SoldAsVacant
,CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant =CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


--------------------------------------------------------------------------------------------------------------------------------


--Remove Duplicate

WITH RowNumCTE As(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,
				LegalReference
				ORDER BY
				UniqueID
				) row_num

From PortfolioProject.dbo.NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order By PropertyAddress


----------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SalePrice