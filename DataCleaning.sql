select *
from DemoDB..[HouseCleaning!]
where PropertyAddress is null

-- Standardizing the date format 
select SaledateConverted, convert(Date,SaleDate) 
from DemoDB..[HouseCleaning!]

Alter table [HouseCleaning!]
Add SaleDateConverted date;

Update [HouseCleaning!]
Set SaleDateConverted = CONVERT(Date,SaleDate)

-- We look at the property address--


select *
from DemoDB..[HouseCleaning!]
--where PropertyAddress is null
order by ParcelID

--Populating the null values of PropertyAddress--

select Table1.ParcelID, Table1.PropertyAddress,Table2.ParcelID,Table2.PropertyAddress, isnull(Table1.PropertyAddress,Table2.PropertyAddress)
from DemoDB..[HouseCleaning!] Table1
join DemoDB..[HouseCleaning!] Table2
  on Table1.ParcelID = Table2.ParcelID
and Table1.[UniqueID ] <> table2.[UniqueID ]
where Table1.PropertyAddress is null


update Table1
set PropertyAddress = isnull(Table1.PropertyAddress,Table2.PropertyAddress)
from DemoDB..[HouseCleaning!] Table1
join DemoDB..[HouseCleaning!] Table2
  on Table1.ParcelID = Table2.ParcelID
and Table1.[UniqueID ] <> table2.[UniqueID ]
where Table1.PropertyAddress is null



select PropertyAddress
from DemoDB..[HouseCleaning!]

select substring(Propertyaddress, 1, charindex(',', Propertyaddress) -1) as address
, substring(Propertyaddress, charindex(',', Propertyaddress) +1, len(Propertyaddress)) as address
from DemoDB..[HouseCleaning!]


Alter table [HouseCleaning!]
Add PropertyAddressStreet nvarchar(255);

Update [HouseCleaning!]
Set PropertyAddressStreet = substring(Propertyaddress, 1, charindex(',', Propertyaddress) -1)


Alter table [HouseCleaning!]
Add PropertyAddressCity nvarchar(255);

Update [HouseCleaning!]
Set PropertyAddressCity  = substring(Propertyaddress, charindex(',', Propertyaddress) +1, len(Propertyaddress))




-- Now we look at the owner address

Select OwnerAddress
from DemoDB..[HouseCleaning!]


select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from DemoDB..[HouseCleaning!]



Alter table [HouseCleaning!]
Add OwnerPropertyStreet nvarchar(255);

Update [HouseCleaning!]
Set OwnerPropertyStreet  = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


Alter table [HouseCleaning!]
Add OwnerPropertyCity nvarchar(255);

Update [HouseCleaning!]
Set OwnerPropertyCity  = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


Alter table [HouseCleaning!]
Add OwnerPropertyState nvarchar(255);

Update [HouseCleaning!]
Set OwnerPropertyState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)



-- We look at the sold as vacant column-- 

select distinct( SoldAsVacant), count(SoldAsVacant)
from DemoDB..[HouseCleaning!]
Group by SoldAsVacant
Order by 2



select SoldAsVacant, 
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from DemoDB..[HouseCleaning!]

update [HouseCleaning!]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

-- Removal of Duplicates if there are in the current dataset--

	With NUMROWCTE AS(
	select *,
		 ROW_NUMBER() 
		 over (Partition by  ParcelID,
							 SalePrice,
							 PropertyAddress,
							 SaleDate,
							 LegalReference
							 Order by UniqueID) row_num

	from DemoDB..[HouseCleaning!]
	)

	Select * 
	from  NUMROWCTE
	where row_num > 1
	--order by PropertyAddress



-- We delete the unused columns--

select * from 
DemoDB..[HouseCleaning!]


Alter Table DemoDB..[HouseCleaning!]
Drop column PropertyAddress, TaxDistrict, OwnerAddress

Alter Table DemoDB..[HouseCleaning!]
Drop column SaleDate



