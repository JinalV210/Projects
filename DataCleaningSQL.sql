select * from portfolio_projects..NashvilleHousing


--------------------Standardize Date Format-------------------------------------------------

select saledate , convert(date,saledate)
from portfolio_projects..NashvilleHousing


update NashvilleHousing 
set saledate = convert(date, saledate)

alter table nashvillehousing
add SaledateConverted date;

update Nashvillehousing
set saleDateconverted = convert(date, saledate)




------------------------------------------------------------------------------------------------------------------------------------


--------Populate property Address data -------------------------------
  select *
  from Portfolio_projects..NashvilleHousing
  where propertyaddress is null


  select  a.parcelid , a.propertyaddress , b.parcelid , b.propertyaddress , ISNULL (a.propertyaddress ,b.propertyaddress)
  from  Portfolio_projects..NashvilleHousing a
  join Portfolio_projects..NashvilleHousing b
		on a.parcelid = b.parcelid
		and a.uniqueid <> b.uniqueid
  where a.propertyaddress is null

  update a
  set a.propertyaddress = ISNULL (a.propertyaddress ,b.propertyaddress)
  from  Portfolio_projects..NashvilleHousing a
  join Portfolio_projects..NashvilleHousing b
		on a.parcelid = b.parcelid
		and a.uniqueid <> b.uniqueid
  where a.propertyaddress is null


  --------------------------------------Breaking out  property Address into individual coloumn (Address , city )--------------------------------------------------------------------------------------------------------

    select *
    from Portfolio_projects..NashvilleHousing

	select
	SUBSTRING (propertyaddress , 1 , CHARINDEX (',' , propertyaddress) -1 ) as address ,
	SUBSTRING (propertyaddress , CHARINDEX (',' , propertyaddress) + 1  , len(propertyaddress)) as city
	from Portfolio_projects..NashvilleHousing


alter table nashvillehousing
add propertysplitaddress nvarchar(255);

update Nashvillehousing
set propertysplitaddress = SUBSTRING (propertyaddress , 1 , CHARINDEX (',' , propertyaddress) -1 )


alter table nashvillehousing
add propertysplitcity nvarchar(255);

update Nashvillehousing
set propertysplitcity = SUBSTRING (propertyaddress , CHARINDEX (',' , propertyaddress) + 1  , len(propertyaddress))




select *
    from Portfolio_projects..NashvilleHousing

	----------------Splitting owner Address------------------------------------------------------------------------------------

select 
PARSENAME (Replace(owneraddress , ',', '.') ,3),
PARSENAME (Replace(owneraddress , ',', '.') ,2),
PARSENAME (Replace(owneraddress , ',', '.') ,1)
    from Portfolio_projects..NashvilleHousing


	alter table nashvillehousing
add ownersplitaddress nvarchar(255);

update Nashvillehousing
set ownersplitaddress = PARSENAME (Replace(owneraddress , ',', '.') ,3)

alter table nashvillehousing
add ownersplitcity nvarchar(255);

update Nashvillehousing
set ownersplitcity = PARSENAME (Replace(owneraddress , ',', '.') ,2)

alter table nashvillehousing
add ownersplitstate nvarchar(255);

update Nashvillehousing
set ownersplitstate = PARSENAME (Replace(owneraddress , ',', '.') ,1)

select * from Nashvillehousing


-------------------------------Change Y and N to yes and no in sold as vacant field------------------------------------------------------------------------------------------------

select distinct soldasvacant , count(*)
from Nashvillehousing
group by SoldAsVacant
order by SoldAsVacant desc


select soldasvacant ,
case when soldasvacant ='Y' then 'Yes'
	 when soldasvacant ='N' then 'No'
	 Else soldasvacant
	 END
from Nashvillehousing


update Nashvillehousing
set SoldAsVacant = case when soldasvacant ='Y' then 'Yes'
	 when soldasvacant ='N' then 'No'
	 Else soldasvacant
	 END

	 --------------------Remove Duplicates--------------------------------------------------------------------------------
	 with rownumcte as(
	 select *,
	 ROW_NUMBER() over (
	 partition by parcelid,
				  propertyaddress,
				  saleprice,
				  saledate,
				  legalreference
				  order by 
					uniqueid
	 ) row_num
	 from Nashvillehousing

	 )
	 select * from rownumcte
	 where row_num >1

	 ---------------------To delete Duplicat Record--------------------------------------------------

	 with rownumcte as(
	 select *,
	 ROW_NUMBER() over (
	 partition by parcelid,
				  propertyaddress,
				  saleprice,
				  saledate,
				  legalreference
				  order by 
					uniqueid
	 ) row_num
	 from Nashvillehousing

	 )
	 delete from rownumcte
	 where row_num >1


	 -------------------------Delete unused coloumn-----------------------------------------------------------------------------

	 select * from Nashvillehousing

	 alter table Nashvillehousing
	 drop column propertyaddress , owneraddress , saledate , taxdistrict