/*

Cleaning Data in SQL Queries

*/
USE SQL_Portfolio
select * 
from SQL_Portfolio..NashvilleHousing

-- Standardize Date Format
-- we only want date not the time

select SaleDateConverted, CAST(SaleDate as date)
from SQL_Portfolio..NashvilleHousing
order by SaleDateConverted 

UPDATE NashvilleHousing /* this query does'nt work. So we have to add new column for date and then update it again*/ 
SET SaleDate=CAST(SaleDate as date)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing  
SET SaleDateConverted=CAST(SaleDate as date)


-------------------------------------------------------

-- Populate "PropertyAddress" data

select *
from SQL_Portfolio..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
		,ISNULL(a.PropertyAddress,b.PropertyAddress) -- its mean where a.PropertyAddress is NULL fill these cells with values from b.PropertyAddress because parcelID is same
from SQL_Portfolio..NashvilleHousing as a
Join SQL_Portfolio..NashvilleHousing as b
	ON a.ParcelID =  b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- we wrote upper query to fill null PropertyAddress having same parcelID
-- so now we can update PropertyAddress column with these addresses

Update a
set PropertyAddress =ISNULL(a.PropertyAddress,b.PropertyAddress)
from SQL_Portfolio..NashvilleHousing as a
Join SQL_Portfolio..NashvilleHousing as b
	ON a.ParcelID =  b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-----------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

select PropertyAddress
from SQL_Portfolio..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address -- its mean its starts from 1st letter and go on till ',' and then minus 1 because we dont want ',' in result
,SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address -- its mean its starts from next to ',' and go on till the length of address we use LEN because every row has different length of address

from SQL_Portfolio..NashvilleHousing

-- We have separated the address in two parts, Now we have to add to different columns to store these two separated addresses

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing  
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing  
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))



-- Now we have to separate the OwnerAddress into Address, City, State
-- We are not using Substring in it (we can use substring but we try different way)

select OwnerAddress
from SQL_Portfolio..NashvilleHousing


select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) -- AS PARSENAME did'nt work with ',' it only work with period '.' so we replaced ',' with '.' and '3' tells that fetch 3rd part and in parsename it fetch form the left. It fetch Address
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)-- AS PARSENAME did'nt work with ',' it only work with period '.' so we replaced ',' with '.' and '2' tells that fetch 2nd part and in parsename it fetch form the left. It fetch City
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)-- AS PARSENAME did'nt work with ',' it only work with period '.' so we replaced ',' with '.' and '2' tells that fetch 1st part and in parsename it fetch form the left. It fetch State
from SQL_Portfolio..NashvilleHousing

-- We have separated the address in three parts, Now we have to add to different columns to store these Three separated addresses.

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing  
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing  
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing  
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * 
from SQL_Portfolio..NashvilleHousing


---------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from SQL_Portfolio..NashvilleHousing
group by SoldAsVacant
order by 2 

-- we change it using Case statement

select SoldAsVacant
, CASE When SoldAsVacant ='Y' then 'Yes'
	   when SoldAsVacant ='N' then 'No'
	   Else SoldAsVacant
	   End
from SQL_Portfolio..NashvilleHousing

-- Now we have to update this

update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant ='Y' then 'Yes'
	   when SoldAsVacant ='N' then 'No'
	   Else SoldAsVacant
	   End

-------------------------------------------------------------------------------------

-- Remove Duplicates

With RowNumCTE AS(
select *,
		ROW_NUMBER() Over(
		PARTITION BY ParcelId,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by
					      UniqueID
						  ) as row_num
from SQL_Portfolio..NashvilleHousing
--order by ParcelID
)

-- Now delete the duplicate rows

--Delete
--from RowNumCTE
--where row_num>1

select * 
from RowNumCTE
where row_num>1

-----------------------------------------------------------------------------------------------------

-- Delete Unused Columns


select * 
from SQL_Portfolio..NashvilleHousing

Alter Table SQL_Portfolio..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table SQL_Portfolio..NashvilleHousing
drop column SaleDate