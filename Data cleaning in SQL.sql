SELECT * FROM housing.`nashville housing`;
USE housing;


-- Standardize Date Format
SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %e, %Y') FROM housing.`nashville housing`;
UPDATE `nashville housing`
SET SaleDate=STR_TO_DATE(SaleDate, '%M %e, %Y');

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT * FROM housing.`nashville housing`;

SELECT PropertyAddress,SUBSTRING_INDEX(PropertyAddress, ",",1) AS Address1,
						SUBSTRING_INDEX(PropertyAddress, ",",-1) AS Address2
 FROM housing.`nashville housing`;
 
        -- Now we need to create two columns to store these splitted address
			 ALTER TABLE housing.`nashville housing`
			Add PropertySplitAddress Nvarchar(255);
			Update housing.`nashville housing`
			SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ",",1) ;


			ALTER TABLE housing.`nashville housing`
			Add PropertySplitCity Nvarchar(255);
			Update housing.`nashville housing`
			SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ",",-1);
            
         -- We have similar problem in  OwnerAddress table  but this time we have two delimeters.
							 SELECT 
						OwnerAddress,
						SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address1,
						SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) AS Address2,
						SUBSTRING_INDEX(OwnerAddress, ',', -1) AS Address3
					FROM housing.`nashville housing`;
                    
                    -- Now we need to create three columns to store these splitted address
								ALTER TABLE housing.`nashville housing`
					Add OwnerSplitAddress Nvarchar(255);

					Update housing.`nashville housing`
					SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);


					ALTER TABLE housing.`nashville housing`
					Add OwnerSplitCity Nvarchar(255);

					Update housing.`nashville housing`
					SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) ;



					ALTER TABLE housing.`nashville housing`
					Add OwnerSplitState Nvarchar(255);

					Update housing.`nashville housing`
					SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

					SELECT * FROM housing.`nashville housing`;			
		
            
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM housing.`nashville housing`
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
    ELSE SoldAsVacant
END 
FROM housing.`nashville housing`;

Update housing.`nashville housing`
SET SoldAsVacant=
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'No'
    ELSE SoldAsVacant
END ;





-- Remove Duplicates
SELECT *
FROM housing.`nashville housing`;






DELETE housing.`nashville housing`
FROM housing.`nashville housing`
JOIN (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelId,
                         PropertyAddress, 
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM housing.`nashville housing`
) AS RowNumCTE
ON housing.`nashville housing`.UniqueID = RowNumCTE.UniqueID
WHERE row_num > 1;



WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER
    (PARTITION BY ParcelId,
					PropertyAddress, 
                    SalePrice,
                    SaleDate,
                    LegalReference
						ORDER BY 
						UniqueID
						) row_num
		
FROM housing.`nashville housing`)
SELECT *
FROM RowNumCTE
WHERE row_num>1
Order by PropertyAddress;


-- Delete Unused Columns
Select *
FROM housing.`nashville housing`;


ALTER TABLE  housing.`nashville housing`
DROP COLUMN OwnerAddress,
DROP COLUMN  TaxDistrict, 
DROP COLUMN PropertyAddress, 
DROP COLUMN SaleDate;

