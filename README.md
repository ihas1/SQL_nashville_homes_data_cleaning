🏡 **Nashville Home Sale Data Cleaning Project** 🧹

Welcome to the Nashville Home Sale Data Cleaning Project! 🎉 This project focuses on transforming and cleaning up a raw dataset of Nashville home sales to make it more structured and ready for analysis.

🎯 Objective
The goal of this project is to clean and organize messy data related to home sales in Nashville by:

Filling in missing data 📝
Breaking down full addresses into separate components (address, city, state) 🌍
Standardizing values for consistency ⚖️
Removing duplicate entries ⚠️
Dropping unnecessary columns for better usability 🗑️

🛠️ How It Works
1. Database Setup
First, we create a new database to work in. Think of it like setting up a new file folder where we can store and organize our data.


-- Create a new database for the project--

CREATE DATABASE Nashville_Housing;
USE Nashville_Housing;

2. Cleaning Property Address Data 🏠
We begin by identifying and fixing rows with missing or empty addresses.


-- Find rows with empty or missing property addresses --

SELECT *
FROM Nashville_Housing.nashville_housing
WHERE PropertyAddress = '' OR PropertyAddress IS NULL;
Then, we update those missing addresses using valid data from other rows with the same ParcelID.


-- Fill missing property addresses with valid data--

UPDATE Nashville_Housing.nashville_housing a
JOIN Nashville_Housing.nashville_housing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = IFNULL(b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress = '' OR a.PropertyAddress IS NULL;

3. Breaking Down the Full Address 📍

We separate the full address into smaller, more manageable parts: Address, City, and State. This makes it easier to analyze specific components of the address.


-- Split PropertyAddress into Address and City--

ALTER TABLE nashville_housing
ADD PropertySplitAddress VARCHAR(255),
ADD PropertySplitCity VARCHAR(255);

UPDATE nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, INSTR(PropertyAddress, ',') + 1, LENGTH(PropertyAddress));

4. Cleaning Owner Address Data 🏡🔑
Similarly, we split the Owner Address into smaller components like OwnerSplitAddress, OwnerSplitState, and OwnerSplitCity to make it easier to analyze.


-- Split OwnerAddress into components--

ALTER TABLE nashville_housing
ADD OwnerSplitAddress VARCHAR(255),
ADD OwnerSplitState VARCHAR(255),
ADD OwnerSplitCity VARCHAR(255);

UPDATE nashville_housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

UPDATE nashville_housing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

UPDATE nashville_housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1);
5. Standardizing 'Sold as Vacant' Values 💼🏠
We standardize the values in the Sold as Vacant field by changing 'Y' to 'Yes' and 'N' to 'No'. This ensures that the data is consistent.


-- Update Sold as Vacant values from 'Y' and 'N' to 'Yes' and 'No'--

UPDATE nashville_housing
SET soldasvacant = 'Yes'
WHERE soldasvacant = 'Y';

UPDATE nashville_housing
SET soldasvacant = 'No'
WHERE soldasvacant = 'N';

6. Removing Duplicate Entries 🛑
Duplicates can cause issues when analyzing data. We use a RowNumCTE (Common Table Expression) to assign row numbers to identical records and remove any duplicates.


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

7. Dropping Unnecessary Columns 🗑️
Finally, we remove columns that are no longer needed, like owneraddress, taxdistrict, and propertyaddress, to streamline the dataset.


-- Drop unused columns--

ALTER TABLE nashville_housing
DROP COLUMN owneraddress,
DROP COLUMN taxdistrict,
DROP COLUMN propertyaddress;

✅ Results

After running these queries, the Nashville home sale data will be:

Cleaned up: Missing and inconsistent data will be fixed.
Organized: Addresses will be split into individual components (Address, City, State).
Standardized: 'Y' and 'N' values will be converted to 'Yes' and 'No' for clarity.
Free of duplicates: Identical records will be removed.

