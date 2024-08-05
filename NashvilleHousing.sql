/* 
	Cleaning Data in SQL Queries 
*/

Select * 
 From PortfolioProject.dbo.NashvilleHousing

-- Standardize Data Format

Select SaleDateConverted, Convert(Date,SaleDate)
 From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
 Set SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousing
 Add SaleDateConverted Date

Update NashvilleHousing
 Set SaleDateConverted = Convert(Date, SaleDate)

-- Populate Property Address data

Select *
 From PortfolioProject.dbo.NashvilleHousing
 Where PropertyAddress is null

Select nh1.ParcelID, nh1.PropertyAddress , nh2.ParcelID, nh2.PropertyAddress, ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
 From PortfolioProject.dbo.NashvilleHousing nh1
 Join PortfolioProject.dbo.NashvilleHousing nh2
	On nh1.ParcelID = nh2.ParcelID
	And nh1.[UniqueID ] <> nh2.[UniqueID ]
 Where nh1.PropertyAddress is null

Update nh1 
 Set PropertyAddress = ISNULL(nh1.PropertyAddress, nh2.PropertyAddress)
 From PortfolioProject.dbo.NashvilleHousing nh1
 Join PortfolioProject.dbo.NashvilleHousing nh2
	On nh1.ParcelID = nh2.ParcelID
	And nh1.[UniqueID ] <> nh2.[UniqueID ]
 Where nh1.PropertyAddress is null


-- Breaking out Address into Individual columns (Address, City, State)

Select PropertyAddress
 From PortfolioProject.dbo.NashvilleHousing
 --Where PropertyAddress is null
 Order By ParcelID

Select 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
 From PortfolioProject.dbo.NashvilleHousing


 Alter Table NashvilleHousing
 Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
 Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Alter Table NashvilleHousing
 Add PropertySplitCity nvarchar(255)

Update NashvilleHousing
 Set PropertySplitCity= SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select * 
 From PortfolioProject.dbo.NashvilleHousing

Select OwnerAddress
 From PortfolioProject.dbo.NashvilleHousing

Select 
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
 From PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
 Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
 Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
 Add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
 Set OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
 Add OwnerSplitState nvarchar(255)

Update NashvilleHousing
 Set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select * 
 From PortfolioProject.dbo.NashvilleHousing

 -- Change Y and N to Yes and No in Sold as Vacant field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
 From PortfolioProject.dbo.NashvilleHousing
 Group By SoldAsVacant
 Order By 2

Select SoldAsVacant,
	Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
 Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsVacant = 'N' Then 'No'
		 Else SoldAsVacant
		 End


-- Remove Duplicate

With RowNumCTE As(
Select *,
	ROW_NUMBER() Over(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 LegalReference
					 Order By
						UniqueID
						) row_num
 From PortfolioProject.dbo.NashvilleHousing
)
Select *
 From RowNumCTE 
 Where row_num >  1
 Order By PropertyAddress


-- Delete Unused Columns

Select *
 From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
 Drop Column OwnerAddress, taxDistrict, PropertyAddress, SaleDate