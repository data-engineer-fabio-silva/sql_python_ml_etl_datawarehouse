-- Validate if date have white spaces
-- Expect no results
SELECT *
FROM ingest_me
WHERE LOWER("date") != TRIM(LOWER("date"));

-- Validate if have the correct date (year and month) inside the respective folder
-- Expect date corresponde to the file name
SELECT *
FROM ingest_me
WHERE LOWER("date") != 'nat' 
    AND "path" LIKE '%5\\table_me_07%'

-- Validate if have date out of the file range
-- Expect no results
SELECT *
FROM ingest_me
WHERE LOWER("date") != 'nat'
    AND TO_DATE(LOWER(TRIM("date")), 'YYYY-MM-DD') > '2026-01-01'
    AND TO_DATE(LOWER(TRIM("date")), 'YYYY-MM-DD') < '2024-01-01'

-- Expect no results
SELECT DISTINCT atv_natv 
FROM ingest_me
WHERE TRIM(LOWER(atv_natv)) NOT IN ('0.0', '1.0', 'nan');

-- Expect no results
SELECT *  
FROM ingest_me
WHERE LOWER("date") != 'nat' 
  AND TRIM(LOWER(category_nm)) = 'nan';

-- Expect no results
SELECT *  
FROM ingest_me
WHERE LOWER("date") != 'nat' 
  AND (
    TRIM(LOWER(total)) IN ('nan', '') 
    OR total IS NULL
  );