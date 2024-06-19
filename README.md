# DA-Nashville-Housing
### Skills Demonstrated
- Data Cleaning
- Filled in missing data
- Made data more useable
- Standardize column
- Remove Duplicates

<br>
<br>

**Boilerplate**
```sql
select
	  [unique_id]
    , [parcel_id]
    , [land_use_id]
    , [property_address]
    , [sale_date]
    , [sale_price]
    , [legal_reference]
    , [sold_as_vacant]
    , [owner_name]
    , [owner_address]
    , [acreage]
    , [tax_district]
    , [land_value]
    , [building_value]
    , [total_value]
    , [year_built]
    , [bedrooms]
    , [full_bath]
    , [half_bath]
from
	  [NASHVILLE_HOUSING].[dbo].[NashvilleHousing]
```

---

### 1. Populate Property Address data
**Displays duplicate parcel id's, one of which is missing addresses**<br>
**Filled in missing data**
```sql
select
	  a.parcel_id
	, a.property_address
	, a.unique_id
	, b.unique_id
	, b.parcel_id
	, b.property_address
	, isnull(a.property_address, b.property_address) as a_property_address
from [dbo].[NashvilleHousing] a
join [dbo].[NashvilleHousing] b
on a.parcel_id = b.parcel_id and a.unique_id != b.unique_id
where a.[property_address] is null
order by a.parcel_id
```
---

**Updates missing address in duplicate parcel id's**
```sql
update a
set a.property_address = b.property_address
	from [dbo].[NashvilleHousing] a
	join [dbo].[NashvilleHousing] b
	on a.parcel_id = b.parcel_id and a.unique_id != b.unique_id
	where a.[property_address] is null
```

---

**Splitting property_address into individual columns (Address, City)** <br>
**Made data more useable**

**Adding [split_property_address] column**
```sql
alter table [dbo].[NashvilleHousing]
add [split_property_address] nvarchar(35)
```
**Adding [split_property_city] column**
```sql
alter table [dbo].[NashvilleHousing]
add [split_property_city] nvarchar(18)
```

**Setting values into split_address column**
```sql
update [dbo].[NashvilleHousing]
set [split_property_address] = substring([property_address], 1, charindex(',', [property_address])-1)
```
**Setting values into [split_property_city] column**
```sql
update [dbo].[NashvilleHousing]
set [split_property_city] = substring([property_address],
					charindex(',', [property_address])+2,
					len([property_address]) - (charindex(',', [property_address]) + 1))
```
---
**Splitting owner_address into individual columns (Address, City, State)**<br>
**Made data more useable**<br>

**Adding split_owner_address column**
```sql
alter table [dbo].[NashvilleHousing]
add split_owner_address nvarchar(35)
```
-- Adding split_owner_city column --<br>
alter table [dbo].[NashvilleHousing]<br>
add split_owner_city nvarchar(18)<br>
-- Adding split_owner_state column --<br>
alter table [dbo].[NashvilleHousing]<br>
add split_owner_state nvarchar(3)<br>
<br><br>
-- Setting values into split_owner_address column<br>
update [dbo].[NashvilleHousing]<br>
set split_owner_address = parsename(replace([owner_address], ',', '.'), 3)<br>
-- Setting values into split_owner_city column<br>
update [dbo].[NashvilleHousing]<br>
set split_owner_city = parsename(replace([owner_address], ',', '.'), 2)<br>
-- Setting values into split_owner_state column<br>
update [dbo].[NashvilleHousing]<br>
set split_owner_state = parsename(replace([owner_address], ',', '.'), 1)<br>
<br><br>
-- Trimming --<br>
update [dbo].[NashvilleHousing]<br>
set split_owner_city = trim(split_owner_city)<br>
-- Trimming --<br>
update [dbo].[NashvilleHousing]<br>
set split_owner_state = trim(split_owner_state)<br>
<br><br>
select<br>
	  [owner_address]<br>
	, [split_owner_address]<br>
	, [split_owner_city]<br>
	, [split_owner_state]<br>
from [dbo].[NashvilleHousing]<br>
---<br><br>
-- Change Y and N to Yes and No in "sold_as_vacant" field --<br>
-- Standardize column<br>
<br><br>
-- Option 1:<br>
	-- Update Y to Yes<br>
	update [dbo].[NashvilleHousing]<br>
	set [sold_as_vacant] = replace([sold_as_vacant], 'Y', 'Yes')<br>
	where [sold_as_vacant] = 'Y'<br>
<br><br>
	-- Update N to No<br>
	update [dbo].[NashvilleHousing]<br>
	set [sold_as_vacant] = replace([sold_as_vacant], 'N', 'No')<br>
	where [sold_as_vacant] = 'N'<br>
<br><br>

-- Option 2:<br>
	-- Update Y to Yes and N to No<br>
	update [dbo].[NashvilleHousing]<br>
	set [sold_as_vacant] = case<br>
							when [sold_as_vacant] = 'Y' then 'Yes'<br>
							when [sold_as_vacant] = 'N' then 'No'<br>
							else [sold_as_vacant]<br>
						   end<br>
		  
<br><br><br>
select distinct<br>
	  [sold_as_vacant]<br>
from [dbo].[NashvilleHousing]<br>
---<br><br>
-- Remove Duplicates --<br>
-- CTE<br>
with RowNumCTE as(<br>
	select<br>
		  *<br>
		, row_number() over (<br>
			partition by<br>
				  parcel_id<br>
				, property_address<br>
				, sale_price<br>
				, sale_date<br>
				, legal_reference<br>
			order by<br>
				  unique_id) row_num<br>
	from [dbo].[NashvilleHousing]<br>
)<br>
<br><br>
delete from RowNumCTE<br>
where row_num > 1<br>
