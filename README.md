# DA-Nashville-Housing

/*
Skills Demonstrated:
- Data Cleaning
- Filled in missing data
- Made data more useable
- Standardize column
- Remove Duplicates
*/

-- Boilerplate --
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

---
-- Populate Property Address data -- <br>
-- Displays duplicate parcel id's, one of which is missing addresses <br>
-- Filled in missing data <br>
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

-- Updates missing address in duplicate parcel id's
update a
set a.property_address = b.property_address
	from [dbo].[NashvilleHousing] a
	join [dbo].[NashvilleHousing] b
	on a.parcel_id = b.parcel_id and a.unique_id != b.unique_id
	where a.[property_address] is null
---------------------------------------------------------------------------------------------
-- Splitting property_address into individual columns (Address, City) --
-- Made data more useable

-- Adding [split_property_address] column
alter table [dbo].[NashvilleHousing]
add [split_property_address] nvarchar(35)
-- Adding [split_property_city] column
alter table [dbo].[NashvilleHousing]
add [split_property_city] nvarchar(18)

-- Setting values into split_address column
update [dbo].[NashvilleHousing]
set [split_property_address] = substring([property_address], 1, charindex(',', [property_address])-1)
-- Setting values into [split_property_city] column
update [dbo].[NashvilleHousing]
set [split_property_city] = substring([property_address],
					charindex(',', [property_address])+2,
					len([property_address]) - (charindex(',', [property_address]) + 1))
---------------------------------------------------------------------------------------------
-- Splitting owner_address into individual columns (Address, City, State) --
-- Made data more useable

-- Adding split_owner_address column --
alter table [dbo].[NashvilleHousing]
add split_owner_address nvarchar(35)
-- Adding split_owner_city column --
alter table [dbo].[NashvilleHousing]
add split_owner_city nvarchar(18)
-- Adding split_owner_state column --
alter table [dbo].[NashvilleHousing]
add split_owner_state nvarchar(3)

-- Setting values into split_owner_address column
update [dbo].[NashvilleHousing]
set split_owner_address = parsename(replace([owner_address], ',', '.'), 3)
-- Setting values into split_owner_city column
update [dbo].[NashvilleHousing]
set split_owner_city = parsename(replace([owner_address], ',', '.'), 2)
-- Setting values into split_owner_state column
update [dbo].[NashvilleHousing]
set split_owner_state = parsename(replace([owner_address], ',', '.'), 1)

-- Trimming --
update [dbo].[NashvilleHousing]
set split_owner_city = trim(split_owner_city)
-- Trimming --
update [dbo].[NashvilleHousing]
set split_owner_state = trim(split_owner_state)

select
	  [owner_address]
	, [split_owner_address]
	, [split_owner_city]
	, [split_owner_state]
from [dbo].[NashvilleHousing]
---------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "sold_as_vacant" field --
-- Standardize column

-- Option 1:
	-- Update Y to Yes
	update [dbo].[NashvilleHousing]
	set [sold_as_vacant] = replace([sold_as_vacant], 'Y', 'Yes')
	where [sold_as_vacant] = 'Y'

	-- Update N to No
	update [dbo].[NashvilleHousing]
	set [sold_as_vacant] = replace([sold_as_vacant], 'N', 'No')
	where [sold_as_vacant] = 'N'


-- Option 2:
	-- Update Y to Yes and N to No
	update [dbo].[NashvilleHousing]
	set [sold_as_vacant] = case
							when [sold_as_vacant] = 'Y' then 'Yes'
							when [sold_as_vacant] = 'N' then 'No'
							else [sold_as_vacant]
						   end
		  

select distinct
	  [sold_as_vacant]
from [dbo].[NashvilleHousing]
---------------------------------------------------------------------------------------------
-- Remove Duplicates --

-- CTE
with RowNumCTE as(
	select
		  *
		, row_number() over (
			partition by
				  parcel_id
				, property_address
				, sale_price
				, sale_date
				, legal_reference
			order by
				  unique_id) row_num
	from [dbo].[NashvilleHousing]
)

delete from RowNumCTE
where row_num > 1
