/*
Cleaning Data in SQL Queries
*/

select * 
from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
add SaleDate2 date

update NashvilleHousing
set SaleDate2 = CONVERT(Date, SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b 
on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b 
on a.ParcelID = b.ParcelID 
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from NashvilleHousing


Alter Table NashvilleHousing
add PropertyAdressSplit nvarchar(250)

update NashvilleHousing
set PropertyAdressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

Alter Table NashvilleHousing
add PropertyAddressCity nvarchar(250)

update NashvilleHousing
set PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing


Alter Table NashvilleHousing
add OwnerAdressSplit nvarchar(250)

update NashvilleHousing
set OwnerAdressSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
 

Alter Table NashvilleHousing
add OwnerAddressCity nvarchar(250)

update NashvilleHousing
set OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
add OwnerAddressState nvarchar(250)

update NashvilleHousing
set OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
when SoldAsVacant = 'N' then 'No'
Else SoldAsVacant
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


With RowNumCTE as(
select *
, ROW_NUMBER() Over(Partition by ParcelID, PropertyAdressSplit, SalePrice, SaleDate2, LegalReference 
	Order by [UniqueID ]) RN
from NashvilleHousing)

select * 
from RowNumCTE
where RN > 1

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Dropping Unused columns


alter table NashvilleHousing
drop column TaxDistrict, OwnerAddress, PropertyAddress, SaleDate

