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


-- Populate Property Address data --
-- Displays duplicate parcel id's, one of which is missing addresses
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



-- Breaking out Address into individual columns (Address, City, State) --

-- Change Y and N to Yes and No in "Sold as Vacant" field --

-- Remove Duplicates --

-- Delete unused columns --