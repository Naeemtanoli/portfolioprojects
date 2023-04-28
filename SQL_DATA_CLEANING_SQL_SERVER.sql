
--real estate data cleaning project

--selecting everthing to check the data is imported correctly or not

select * from Nashvillehouse
--by looking at date there are lot of date to clean just start by

--standarzing  sale date field/coloum 
select SaleDate,convert(date,SaleDate) as saledate_Converted
from Nashvillehouse
-- update the saledate coloum 
update Nashvillehouse
set SaleDate=CONVERT(date,SaleDate)

--it not working try another technique to change the saledate in standarf format
alter table nashvillehouse
add SaleDateConverted date;
--checking our coloum to see its creaated or not
select saleDateConverted 
from Nashvillehouse
-- great it is created and now we will update this coloum by inserting standard date format 
update Nashvillehouse
set SaleDateConverted=CONVERT(date,SaleDate)
--check again the coloum  by running above sql statemtnt so we dont have to repeat the
--code  

--populate the property adrees coloum to see and check the null recored by using
--where statement to limit the data and do necessary changes to clean the data

select PropertyAddress 
from Nashvillehouse
where PropertyAddress is null

--there of lot of null values but intersting thing like parcel id is there for null adress 
--and same parcel id is showing property adress as well in others rows and it showing a trends not for only some 
--values so let start to populate the data
select a.uniqueid,a.ParcelID,a.PropertyAddress,b.uniqueid,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,
b.PropertyAddress)
from Nashvillehouse as a
join Nashvillehouse as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress=isnull(a.PropertyAddress,
b.PropertyAddress)
from Nashvillehouse as a
join Nashvillehouse as b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- now we are done and populate the null field with data move ahead naeem

--breaking out adress into indvidual coloums(adress,city,states) they are in one column but it good to have in
--seperate coloum

select PropertyAddress from Nashvillehouse


select
SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) as adress,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) as city
from Nashvillehouse

--creating two new coloum and adding the adress and city to seperate adress in nice clean way

alter table Nashvillehouse
add propertysplitaddress nvarchar(255);

update Nashvillehouse
set propertysplitaddress =SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)



alter table Nashvillehouse
add propertysplitCity nvarchar(255);

update Nashvillehouse
set propertysplitCity =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))


select * from Nashvillehouse



select OwnerAddress
from Nashvillehouse

select PARSENAME(REPLACE(OwnerName,',','.'),3),
PARSENAME(REPLACE(OwnerName,',','.'),2),
PARSENAME(REPLACE(OwnerName,',','.'),1)
from Nashvillehouse

alter table Nashvillehouse
add ownersplitaddress nvarchar(255);

update Nashvillehouse
set ownersplitaddress =PARSENAME(REPLACE(OwnerName,',','.'),3)



alter table Nashvillehouse
add ownersplitCity nvarchar(255);

update Nashvillehouse
set ownersplitCity =PARSENAME(REPLACE(OwnerName,',','.'),2)

alter table Nashvillehouse
add ownersplitstates nvarchar(255);

update Nashvillehouse
set ownersplitstates =PARSENAME(REPLACE(OwnerName,',','.'),1)


--now owner adress field is cleaned  states city and adreess is in seperate coloum instead of one coloumn
select * from Nashvillehouse




--now soldasvacacnt field has four values y and n also yes and no so we will change y and n to yes and no  so there 
--will be only two values which have same meaning yes and no instead of y and n and yes and no

select distinct(SoldAsVacant),count(SoldAsVacant)
from Nashvillehouse
group by SoldAsVacant
order by 2

select SoldAsVacant
,case when SoldAsVacant ='Y' THEN 'YES'
      WHEN SoldAsVacant ='N' THEN 'NO'
	  ELSE SoldAsVacant
	  end
from Nashvillehouse

--in above we count how may y and n and yes and no are there and now we will update the coloum 


update Nashvillehouse
set SoldAsVacant=case when SoldAsVacant ='Y' THEN 'YES'
      WHEN SoldAsVacant ='N' THEN 'NO'
	  ELSE SoldAsVacant
	  end

--now we wil remove duplicates from data 

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

From Nashvillehouse
)
Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--now we dont have duplicate data  and we will remove unnessary coloumns
--as we cleaned the property adress owner adress and older coloum have no use now we will delete that ALSO SALEDATE
--BECAUSE WE HAVE CREATED A CLEAN AND STANDARD SALE DATA COLOUM 

alter table nashvillehouse
drop column PropertyAddress,OwnerAddress,SaleDate


SELECT * FROM Nashvillehouse