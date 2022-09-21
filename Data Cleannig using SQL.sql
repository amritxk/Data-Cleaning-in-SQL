
Select * from [Portfolio Project]..NashvilleHousing


-----------------------------------Standardize Date Format-------------------------------------
--Adding a new date column
ALter Table NashvilleHousing
Add SalesDateConverted Date;

Update NashvilleHousing
Set SalesDateConverted = Convert(Date, SaleDate)

-- Dropping Sales Date column 

Alter Table NashvilleHousing
Drop Column SaleDate;

Select SalesDateConverted from [Portfolio Project]..NashvilleHousing




------------------------------------------Populate property address---------------------------------------------------------------------------------------------------
 Select a.ParcelID , a.PropertyAddress ,b.ParcelID , b.PropertyAddress , ISNULL(a.PropertyAddress , b.PropertyAddress) from [Portfolio Project]..NashvilleHousing a 
 Join  [Portfolio Project]..NashvilleHousing b 
 on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
 where b.PropertyAddress is null

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress) from [Portfolio Project]..NashvilleHousing a 
 Join  [Portfolio Project]..NashvilleHousing b 
 on a.ParcelID = b.ParcelID and a.[UniqueID ] <> b.[UniqueID ]
 
 Select PropertyAddress From [Portfolio Project]..NashvilleHousing
 where PropertyAddress is Null

 ---------------------------Breaking out Address into Indiividual Columns (Address , city , State)------------------------------------------------------------------------
 
 Select SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1) as Address,
 SUBSTRING(PropertyAddress , CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
 From [Portfolio Project]..NashvilleHousing

Alter TABLE   [Portfolio Project]..NashvilleHousing
ADD NewAddress Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
set NewAddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX(',',PropertyAddress)-1)

Alter TABLE [Portfolio Project]..NashvilleHousing
ADD City Nvarchar(255);

Update [Portfolio Project]..NashvilleHousing
set City = SUBSTRING(PropertyAddress , (CHARINDEX(',',PropertyAddress)+1),LEN(PropertyAddress))

Select * from [Portfolio Project]..NashvilleHousing

---------------------------Breaking out Owner Address into Indiividual Columns (Address , city , State)------------------------------------------------------------------------

Select OwnerAddress from [Portfolio Project]..NashvilleHousing

Select PARSENAME(Replace(OwnerAddress ,',','.'), 3), 
PARSENAME(Replace(OwnerAddress ,',','.'), 2), 
PARSENAME(Replace(OwnerAddress ,',','.'), 1)
from [Portfolio Project]..NashvilleHousing

Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerNewAddress Nvarchar(255)

Update [Portfolio Project]..NashvilleHousing
Set OwnerNewAddress= PARSENAME(Replace(OwnerAddress ,',','.'), 3)


Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerCity Nvarchar(255)

Update [Portfolio Project]..NashvilleHousing
Set OwnerCity= PARSENAME(Replace(OwnerAddress ,',','.'), 2)

Alter Table [Portfolio Project]..NashvilleHousing
Add OwnerState Nvarchar(255)

Update [Portfolio Project]..NashvilleHousing
Set OwnerState= PARSENAME(Replace(OwnerAddress ,',','.'), 1)

Select OwnerNewAddress , OwnerCity , OwnerState from [Portfolio Project]..NashvilleHousing

---------------------------Changing Y and N to YES and NO is SoldAsVacant Column------------------------------------------------------------------------

Select Distinct(SoldAsVacant) from [Portfolio Project]..NashvilleHousing

Select SoldAsVacant ,
Case when SoldAsVacant = 'Y' then 'Yes'    
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
from [Portfolio Project]..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 END
from [Portfolio Project]..NashvilleHousing

--------------------------------------------------------Removing Duplicates----------------------------------
With CTE  AS ( 
Select *,
 row_number() over(
 Partition by ParcelID, PropertyAddress,SalePrice, SalesDateConverted, LegalReference
  Order by UniqueID) as row_num
 From [Portfolio Project]..NashvilleHousing )

Delete from CTE 
 where row_num>1