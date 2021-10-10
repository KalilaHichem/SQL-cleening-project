/* Data cleaning project*/
--------------------------------------------------------------------
/* take a loke of the dataste */
select top 100 * from sheet;
-------------------------------------------------------------------
/* change the saledate type */
update sheet
set SaleDate =convert(date,SaleDate);
alter table sheet
add SaleDateconvert date;
update sheet
set SaleDateconvert =convert(date,SaleDate);
select SaleDateconvert from sheet;
alter table sheet
drop column saledate;
--------------------------------------------------------------------
/* populate proprety adress data*/
select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from sheet a
join sheet b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from sheet a
join sheet b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
select * from sheet
order by ParcelID
--------------------------------------------------------------------
/* Breaking adress in to indevudiel columns (address,city,stat) */
select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as adress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as adress
from sheet

alter table sheet
add PropertsplityAddress nvarchar(250)

update sheet
set PropertsplityAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table sheet
add Propertsplitcity nvarchar(250)

update sheet
set Propertsplitcity =SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress))

select PropertsplityAddress,Propertsplitcity from sheet
--------------------------------------------------------------------
/* Breaking owneradress in to indevudiel columns */
select OwnerAddress from sheet

select
PARSENAME(replace(OwnerAddress, ',','.'),3)as Owner_adress,
PARSENAME(replace(OwnerAddress, ',','.'),2)as Owner_city,
PARSENAME(replace(OwnerAddress, ',','.'),1)as Owner_stat
from sheet

alter table sheet
add Owner_adress  nvarchar (250)
alter table sheet
add Owner_city  nvarchar (250)
alter table sheet
add Owner_stat nvarchar (250)

update sheet
set Owner_adress = PARSENAME(replace(OwnerAddress, ',','.'),3)
update sheet
set Owner_city = PARSENAME(replace(OwnerAddress, ',','.'),2)
update sheet
set Owner_stat  = PARSENAME(replace(OwnerAddress, ',','.'),1)

select Owner_adress,Owner_city,Owner_stat from sheet

alter table sheet
drop column OwnerAddress
--------------------------------------------------------------------
/* replace the Y and N bya Yes and No*/
select SoldAsVacant from sheet
select SoldAsVacant,
	   case when SoldAsVacant = 'Y' Then 'Yes'
            when SoldAsVacant = 'n' Then 'no'
			else SoldAsVacant
			end
 from sheet
 update sheet
 set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
					when SoldAsVacant = 'n' Then 'no'
					else SoldAsVacant
					end
--------------------------------------------------------------------
/* remove duplicates*/
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From sheet)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


Select *
From sheet
--------------------------------------------------------------------