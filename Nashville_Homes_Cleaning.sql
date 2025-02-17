/*

Cleaning Data in SQL Queries

*/

Create Database Nashville_Housing;
Use Nashville_Housing; 

Select *
From Nashville_Housing.nashville_housing;
-------------------------------------------------------------------------------------------------

-- Populate Property Address data--

Select *
From Nashville_Housing.nashville_housing
Where PropertyAddress = '' or PropertyAddress is null;



Select *
From Nashville_Housing.nashville_housing
Order by ParcelID;


SELECT a.ParcelID, 
		a.PropertyAddress, 
		b.ParcelID, 
        b.PropertyAddress, 
        --ifnull(b.PropertyAddress,a.PropertyAddress) 
FROM Nashville_Housing.nashville_housing a
JOIN Nashville_Housing.nashville_housing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE (a.PropertyAddress = '' OR a.PropertyAddress IS NULL);

UPDATE Nashville_Housing.nashville_housing a
JOIN Nashville_Housing.nashville_housing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress = '' OR a.PropertyAddress IS NULL;

Select *
From Nashville_Housing.nashville_housing;

----------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Nashville_Housing.nashville_housing;


SELECT 
  SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address,
  SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress)) AS RestOfAddress
FROM Nashville_Housing.nashville_housing;


ALTER TABLE nashville_housing
ADD PropertySplitAddress VARCHAR(255);

ALTER TABLE nashville_housing
ADD PropertySplitCity VARCHAR(255);


UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);


UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress));


SELECT 
  
  SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerSplitAddress,


  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS OwnerSplitState,

 
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1) AS OwnerSplitCity
FROM Nashville_Housing.nashville_housing;


ALTER TABLE nashville_housing
ADD OwnerSplitAddress VARCHAR(255);

ALTER TABLE nashville_housing
ADD OwnerSplitState VARCHAR(255);

ALTER TABLE nashville_housing
ADD OwnerSplitCity VARCHAR(255);


UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

UPDATE nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

UPDATE nashville_housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);

Select * 
From nashville_housing;

--------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field -- 

Select distinct(soldasvacant), count(soldasvacant)
From nashville_housing
group by soldasvacant
order by 2;

Select soldasvacant
, Case When soldasvacant = 'Y' Then 'Yes'
	   When soldasvacant = 'N' Then 'No'
       Else soldasvacant
       End
From nashville_housing;

UPDATE nashville_housing
SET soldasvacant = 'Yes'
WHERE soldasvacant = 'Y';

UPDATE nashville_housing
SET soldasvacant = 'No'
WHERE soldasvacant = 'N';

Select distinct(soldasvacant), count(soldasvacant)
From nashville_housing
group by soldasvacant
order by 2;
----------------------------------------------------------

-- Remove Duplicates --

WITH RowNumCTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM Nashville_Housing.nashville_housing
)
DELETE n
FROM Nashville_Housing n
JOIN RowNumCTE r
    ON n.UniqueID = r.UniqueID
WHERE r.row_num > 1;

-------------------------------------------------------------------------------

-- Delete Unused Columns -- 

Select * 
From nashville_housing;

ALTER TABLE nashville_housing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;

