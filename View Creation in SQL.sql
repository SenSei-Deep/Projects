-- Create a view to consolidate manpower and budget-related data for various roles.
CREATE VIEW bidata.manpower_budget AS

-- Nursing Data
SELECT
    'Nursing Number' AS Name,                             -- Descriptive label for the record
    LAST_DAY(date) AS month_year,                         -- Last day of the month for date grouping
    "Nursing Numbers" AS Budget,                          -- Budget type for nursing numbers
    'Headcount' AS Category,                              -- Category of the data (e.g., headcount, cost, etc.)
    facility,                                             -- Facility identifier
    'Nurse' AS Type,                                      -- Role type (Nurse)
    1 AS pos,                                             -- Position placeholder (could be used for sorting)
    'Nursing Number' || month_year || facility AS helper  -- Unique helper column for record identification
FROM bidata.hrms_budget

UNION

SELECT
    'Nursing Cost' AS Name,                               -- Label for nursing cost
    LAST_DAY(date) AS month_year,
    "Nursing Cost" AS Budget,                             -- Budget type for nursing cost
    'Cost' AS Category,                                   -- Category is cost
    facility,
    'Nurse' AS Type,
    1 AS pos,
    'Nursing Cost' || month_year || facility AS helper
FROM bidata.hrms_budget

UNION

SELECT
    'Nursing Average Cost' AS Name,                      -- Label for nursing average cost
    LAST_DAY(date) AS month_year,
    "Nursing Average Cost" AS Budget,                    -- Budget type for nursing average cost
    'Average Cost' AS Category,                          -- Category is average cost
    facility,
    'Nurse' AS Type,
    1 AS pos,
    'Nursing Average Cost' || month_year || facility AS helper
FROM bidata.hrms_budget

UNION

SELECT
    'Nursing Headcount per Occupied Bed' AS Name,        -- Label for nursing headcount per bed
    LAST_DAY(date) AS month_year,
    "Nursing Ratio / Bed" AS Budget,                     -- Budget type for nursing ratio per bed
    'Manpower Ratio' AS Category,                        -- Category is manpower ratio
    facility,
    'Nurse' AS Type,
    1 AS pos,
    'Nursing Headcount per Occupied Bed' || month_year || facility AS helper
FROM bidata.hrms_budget

-- Repeated for Technicians
UNION

SELECT
    'Technician Number' AS Name,                         -- Label for technician headcount
    LAST_DAY(date) AS month_year,
    "Technician Numbers" AS Budget,
    'Headcount' AS Category,
    facility,
    'Technician' AS Type,
    1 AS pos,
    'Technician Number' || month_year || facility AS helper
FROM bidata.hrms_budget
  
UNION

 SELECT
            'Technician Cost' AS Name,
            LAST_DAY(date) AS month_year,
            "Technician Cost" AS Budget, 
            'Cost' AS Category,
            facility,
            'Technician' AS Type,
	    1 AS pos,
            'Technician Cost' || month_year || facility AS helper

            From bidata.hrms_budget
UNION

 SELECT
            'Technician Average Cost' AS Name,
            LAST_DAY(date) AS month_year,
            "Technician Average Cost" AS Budget, 
            'Average Cost' AS Category,
            facility,
            'Technician' AS Type,
	    1 AS pos,
            'Technician Average Cost' || month_year || facility AS helper

            From bidata.hrms_budget

UNION
 
  SELECT
            'Technician Headcount per Occupied Bed' AS Name,
            LAST_DAY(date) AS month_year,
            "Technician Ratio / Bed" AS Budget, 
            'Manpower Ratio' AS Category,
            facility,
            'Technician' AS Type,
	    1 AS pos,
            'Technician Headcount per Occupied Bed' || month_year || facility AS helper

            From bidata.hrms_budget

UNION

 SELECT
            'Administration Number' AS Name,
            LAST_DAY(date) AS month_year,
            "Administration Numbers" AS Budget, 
            'Headcount' AS Category,
            facility,
            'Administration' AS Type,
	    1 AS pos,
            'Administration Number' || month_year || facility AS helper

            From bidata.hrms_budget
  
UNION

 SELECT
            'Administration Cost' AS Name,
            LAST_DAY(date) AS month_year,
            "Administration Cost" AS Budget, 
            'Cost' AS Category,
            facility,
            'Administration' AS Type,
	    1 AS pos,
            'Administration Cost' || month_year || facility AS helper

            From bidata.hrms_budget
UNION

 SELECT
            'Administration Average Cost' AS Name,
            LAST_DAY(date) AS month_year,
            "Administration Average Cost" AS Budget, 
            'Average Cost' AS Category,
            facility,
            'Administration' AS Type,
	    1 AS pos,
            'Administration Average Cost' || month_year || facility AS helper

            From bidata.hrms_budget

UNION
 
  SELECT
            'Administration Headcount per Occupied Bed' AS Name,
            LAST_DAY(date) AS month_year,
            "Administration Ratio / Bed" AS Budget, 
            'Manpower Ratio' AS Category,
            facility,
            'Administration' AS Type,
	    1 AS pos,
            'Administration Headcount per Occupied Bed' || month_year || facility AS helper

            From bidata.hrms_budget

UNION

     SELECT
            'Support Number' AS Name,
            LAST_DAY(date) AS month_year,
            "Support Numbers" AS Budget, 
            'Headcount' AS Category,
            facility,
            'Support' AS Type,
	    1 AS pos,
            'Support Number' || month_year || facility AS helper

            From bidata.hrms_budget
  
UNION

 SELECT
            'Support Cost' AS Name,
            LAST_DAY(date) AS month_year,
            "Support Cost" AS Budget, 
            'Cost' AS Category,
            facility,
            'Support' AS Type,
	    1 AS pos,
            'Support Cost' || month_year || facility AS helper

            From bidata.hrms_budget
UNION

 SELECT
            'Support Average Cost' AS Name,
            LAST_DAY(date) AS month_year,
            "Support Average Cost" AS Budget, 
            'Average Cost' AS Category,
            facility,
            'Support' AS Type,
	    1 AS pos,
            'Support Average Cost' || month_year || facility AS helper

            From bidata.hrms_budget

UNION
 
  SELECT
            'Support Headcount per Occupied Bed' AS Name,
            LAST_DAY(date) AS month_year,
            "Support Ratio / Bed" AS Budget, 
            'Manpower Ratio' AS Category,
            facility,
            'Support' AS Type,
	    1 AS pos,
            'Support Headcount per Occupied Bed' || month_year || facility AS helper

            From bidata.hrms_budget

UNION

     SELECT
            'Support Doctors Number' AS Name,
            LAST_DAY(date) AS month_year,
            "Support Doctors Numbers" AS Budget, 
            'Headcount' AS Category,
            facility,
            'Support Doctors' AS Type,
	    1 AS pos,
            'Support Doctors Number' || month_year || facility AS helper

            From bidata.hrms_budget
  
UNION

 SELECT
            'Support Doctors Cost' AS Name,
            LAST_DAY(date) AS month_year,
            "Support Doctors Cost" AS Budget, 
            'Cost' AS Category,
            facility,
            'Support Doctors' AS Type,
	    1 AS pos,
            'Support Doctors Cost' || month_year || facility AS helper

            From bidata.hrms_budget
UNION

 SELECT
            'Support Doctors Average Cost' AS Name,
            LAST_DAY(date) AS month_year,
            "Support Doctors Average Cost" AS Budget, 
            'Average Cost' AS Category,
            facility,
            'Support Doctors' AS Type,
	    1 AS pos,
            'Support Doctors Average Cost' || month_year || facility AS helper

            From bidata.hrms_budget

UNION
 
  SELECT
            'Support Doctors Headcount per Occupied Bed' AS Name,
            LAST_DAY(date) AS month_year,
            "Support Doctors Ratio / Bed" AS Budget, 
            'Manpower Ratio' AS Category,
            facility,
            'Support Doctors' AS Type,
	    1 AS pos,
            'Support Doctors Headcount per Occupied Bed' || month_year || facility AS helper

            From bidata.hrms_budget

UNION

     SELECT
            'Revenue Doctors Number' AS Name,
            LAST_DAY(date) AS month_year,
            "Total Revenue Doctors Numbers" AS Budget, 
            'Headcount' AS Category,
            facility,
            'Revenue Doctors' AS Type,
	    1 AS pos,
            'Revenue Doctors Number' || month_year || facility AS helper

            From bidata.hrms_budget
  
UNION

 SELECT
            'Revenue Doctors Cost' AS Name,
            LAST_DAY(date) AS month_year,
            "Total Revenue Doctors Cost" AS Budget, 
            'Cost' AS Category,
            facility,
            'Revenue Doctors' AS Type,
	    1 AS pos,
            'Revenue Doctors Cost' || month_year || facility AS helper

            From bidata.hrms_budget
UNION

 SELECT
            'Revenue Doctors Average Cost' AS Name,
            LAST_DAY(date) AS month_year,
            "Revenue Doctors Average Cost" AS Budget, 
            'Average Cost' AS Category,
            facility,
            'Revenue Doctors' AS Type,
	    1 AS pos,
            'Revenue Doctors Average Cost' || month_year || facility AS helper

            From bidata.hrms_budget

UNION
 
  SELECT
            'Revenue Doctors Headcount per Occupied Bed' AS Name,
            LAST_DAY(date) AS month_year,
            "Revenue Doctors Ratio / Bed" AS Budget, 
            'Manpower Ratio' AS Category,
            facility,
            'Revenue Doctors' AS Type,
	    1 AS pos,
            'Revenue Doctors Headcount per Occupied Bed' || month_year || facility AS helper

            From bidata.hrms_budget


    