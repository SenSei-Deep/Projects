SELECT
    'Gross Revenue (Lacs)' AS name,
    br.monthcol,
    ROUND(
        SUM(
            COALESCE(
                br.grossbillamount::numeric(18, 0),
                0::numeric(18, 0)
            )
        ) / NULLIF(100000::numeric(18, 0), 0),
        2
    ) AS actual,
    br.facility,
    br.financial_months,
    br.lastdate,
    1 AS pos,
    (
        'Gross Revenue (Lacs)'::character varying
        || br.facility::text
        || br.lastdate::character varying
    ) AS helper
FROM
    bidata.billregisterreport br
WHERE
    br.ab = 1

GROUP BY
    br.monthcol,
    br.facility,
    br.financial_months,
    br.lastdate


UNION ALL
SELECT
  'ALOS - Cash' AS name,
  a.monthcol,
  round(
    a.actual:: numeric:: numeric(18, 0) / b.actual:: numeric:: numeric(18, 0),
    2
  ) AS actual,
  a.facility,
  a.financial_months,
  a.lastdate,
  8 AS pos,
  (
    'ALOS - Cash':: character varying:: text + a.facility:: text + a.lastdate:: character varying:: text
  ):: character varying AS helper
FROM
  (
    SELECT
      'Occupied Bed Days':: character varying AS name,
      billregisterreport.monthcol,
      sum(billregisterreport.lengthofstay) AS actual,
      billregisterreport.facility,
      billregisterreport.financial_months,
      billregisterreport.lastdate
    FROM
      bidata.billregisterreport
    WHERE
      billregisterreport.patientclass:: text = 'IP':: character varying:: text
      AND billregisterreport.ab = 1 
      AND "actual payor category" = 'CASH'
 
GROUP BY
      billregisterreport.monthcol,
      billregisterreport.facility,
      billregisterreport.financial_months,
      billregisterreport.lastdate
  ) a
  JOIN (
    SELECT
      'IPD Patients (Volume) : Discharges':: character varying AS name,
      a.monthcol,
      count(a.uhid) - COALESCE(b.ipv, 0:: bigint) AS actual,
      a.facility,
      a.financial_months,
      a.lastdate
    FROM
      bidata.billregisterreport a
      LEFT JOIN (
        SELECT
          count(billregisterreport.uhid) * 2 AS ipv,
          billregisterreport.monthcol,
          billregisterreport.facility,
          billregisterreport.financial_months,
          billregisterreport.lastdate
        FROM
          bidata.billregisterreport
        WHERE
          lower(billregisterreport.patientclass:: text) = 'ip':: character varying:: text
          AND upper(billregisterreport.status:: text) = 'IP CANCELLED INVOICE':: character varying:: text
          AND billregisterreport.ab = 1
          AND "actual payor category" = 'CASH'
      
        GROUP BY
          billregisterreport.monthcol,
          billregisterreport.facility,
          billregisterreport.financial_months,
          billregisterreport.lastdate
      ) b ON a.monthcol = b.monthcol
      AND a.facility:: text = b.facility:: text
      AND a.lastdate = b.lastdate
    WHERE
      lower(a.patientclass:: text) = 'ip':: character varying:: text
      AND a.ab = 1
      AND "actual payor category" = 'CASH'
      
    GROUP BY
      a.monthcol,
      a.facility,
      a.financial_months,
      b.ipv,
      a.lastdate
  ) b ON a.facility:: text = b.facility:: text
  AND a.monthcol = b.monthcol
  AND a.lastdate = b.lastdate

  UNION ALL

  SELECT
  'ALOS - Insurance' AS name,
  a.monthcol,
  CASE WHEN b.actual = 0 Then 0 ELSE
  round(
    a.actual:: numeric:: numeric(18, 0) / b.actual:: numeric:: numeric(18, 0),
    2
  ) END AS actual,
  a.facility,
  a.financial_months,
  a.lastdate,
  8 AS pos,
  (
    'ALOS - Insurance':: character varying:: text + a.facility:: text + a.lastdate:: character varying:: text
  ):: character varying AS helper
FROM
  (
    SELECT
      'Occupied Bed Days':: character varying AS name,
      billregisterreport.monthcol,
      sum(billregisterreport.lengthofstay) AS actual,
      billregisterreport.facility,
      billregisterreport.financial_months,
      billregisterreport.lastdate
    FROM
      bidata.billregisterreport
    WHERE
      billregisterreport.patientclass:: text = 'IP':: character varying:: text
      AND billregisterreport.ab = 1 
      AND "actual payor category" = 'INSURANCE'
 
GROUP BY
      billregisterreport.monthcol,
      billregisterreport.facility,
      billregisterreport.financial_months,
      billregisterreport.lastdate
  ) a
  JOIN (
    SELECT
      'IPD Patients (Volume) : Discharges':: character varying AS name,
      a.monthcol,
      count(a.uhid) - COALESCE(b.ipv, 0:: bigint) AS actual,
      a.facility,
      a.financial_months,
      a.lastdate
    FROM
      bidata.billregisterreport a
      LEFT JOIN (
        SELECT
          count(billregisterreport.uhid) * 2 AS ipv,
          billregisterreport.monthcol,
          billregisterreport.facility,
          billregisterreport.financial_months,
          billregisterreport.lastdate
        FROM
          bidata.billregisterreport
        WHERE
          lower(billregisterreport.patientclass:: text) = 'ip':: character varying:: text
          AND upper(billregisterreport.status:: text) = 'IP CANCELLED INVOICE':: character varying:: text
          AND billregisterreport.ab = 1
          AND "actual payor category" = 'INSURANCE'
      
        GROUP BY
          billregisterreport.monthcol,
          billregisterreport.facility,
          billregisterreport.financial_months,
          billregisterreport.lastdate
      ) b ON a.monthcol = b.monthcol
      AND a.facility:: text = b.facility:: text
      AND a.lastdate = b.lastdate
    WHERE
      lower(a.patientclass:: text) = 'ip':: character varying:: text
      AND a.ab = 1
      AND "actual payor category" = 'INSURANCE'
      
    GROUP BY
      a.monthcol,
      a.facility,
      a.financial_months,
      b.ipv,
      a.lastdate
  ) b ON a.facility:: text = b.facility:: text
  AND a.monthcol = b.monthcol
  AND a.lastdate = b.lastdate

  UNION ALL

SELECT 'IP ARR - Cash' AS name, a.monthcol, round(a.actual / b.actual::numeric::numeric(18,0), 2) AS actual, a.facility, a.financial_months, a.lastdate, 17 AS pos, ('IP ARR - Cash'::character varying::text + a.facility::text + a.lastdate::character varying::text)::character varying AS helper
  FROM ( SELECT 'IP ARR - Cash'::character varying AS name, billregisterreport.monthcol, round(sum(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric::numeric(18,0))) - (sum(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric::numeric(18,0))) + sum(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric::numeric(18,0)))), 2) AS actual, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate, 11 AS pos, 'IP Revenue (in lacs)'::character varying::text + billregisterreport.facility::text + billregisterreport.lastdate::character varying::text AS helper
          FROM bidata.billregisterreport
          WHERE billregisterreport.patientclass::text = 'IP'::character varying::text AND billregisterreport.ab = 1 and "actual payor category" = 'CASH'
          GROUP BY billregisterreport.monthcol, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate) a
  JOIN ( SELECT 'IPD Patients (Volume) : Discharges'::character varying AS name, a.monthcol, count(a.uhid) - COALESCE(b.ipv, 0::bigint) AS actual, a.facility, a.financial_months, a.lastdate, 10 AS pos, 'IPD Patients (Volume) : Discharges'::character varying::text + a.facility::text + a.lastdate::character varying::text AS helper
          FROM bidata.billregisterreport a
      LEFT JOIN ( SELECT count(billregisterreport.uhid) * 2 AS ipv, billregisterreport.monthcol, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate
                  FROM bidata.billregisterreport
                  WHERE lower(billregisterreport.patientclass::text) = 'ip'::character varying::text AND upper(billregisterreport.status::text) = 'IP CANCELLED INVOICE'::character varying::text AND billregisterreport.ab = 1 and "actual payor category" = 'CASH'
                  GROUP BY billregisterreport.monthcol, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate) b ON a.monthcol = b.monthcol AND a.facility::text = b.facility::text AND a.lastdate = b.lastdate
    WHERE lower(a.patientclass::text) = 'ip'::character varying::text AND a.ab = 1 and "actual payor category" = 'CASH'
    GROUP BY a.monthcol, a.facility, a.financial_months, b.ipv, a.lastdate) b ON a.facility::text = b.facility::text AND a.monthcol = b.monthcol AND a.lastdate = b.lastdate
    
UNION ALL

SELECT 'IP ARR - Insurance' AS name, a.monthcol,CASE WHEN b.actual = 0 THEN NULL ELSE round(a.actual / b.actual::numeric::numeric(18,0), 2) END AS actual,  a.facility, a.financial_months, a.lastdate, 17 AS pos, ('IP ARR - Insurance'::character varying::text + a.facility::text + a.lastdate::character varying::text)::character varying AS helper
  FROM ( SELECT 'IP ARR - Insurance'::character varying AS name, billregisterreport.monthcol, round(sum(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric::numeric(18,0))) - (sum(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric::numeric(18,0))) + sum(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric::numeric(18,0)))), 2) AS actual, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate, 11 AS pos, 'IP Revenue (in lacs)'::character varying::text + billregisterreport.facility::text + billregisterreport.lastdate::character varying::text AS helper
          FROM bidata.billregisterreport
          WHERE billregisterreport.patientclass::text = 'IP'::character varying::text AND billregisterreport.ab = 1 and "actual payor category" = 'INSURANCE'
          GROUP BY billregisterreport.monthcol, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate) a
  JOIN ( SELECT 'IPD Patients (Volume) : Discharges'::character varying AS name, a.monthcol, count(a.uhid) - COALESCE(b.ipv, 0::bigint) AS actual, a.facility, a.financial_months, a.lastdate, 10 AS pos, 'IPD Patients (Volume) : Discharges'::character varying::text + a.facility::text + a.lastdate::character varying::text AS helper
          FROM bidata.billregisterreport a
      LEFT JOIN ( SELECT count(billregisterreport.uhid) * 2 AS ipv, billregisterreport.monthcol, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate
                  FROM bidata.billregisterreport
                  WHERE lower(billregisterreport.patientclass::text) = 'ip'::character varying::text AND upper(billregisterreport.status::text) = 'IP CANCELLED INVOICE'::character varying::text AND billregisterreport.ab = 1 and "actual payor category" = 'INSURANCE'
                  GROUP BY billregisterreport.monthcol, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate) b ON a.monthcol = b.monthcol AND a.facility::text = b.facility::text AND a.lastdate = b.lastdate
    WHERE lower(a.patientclass::text) = 'ip'::character varying::text AND a.ab = 1 and "actual payor category" = 'INSURANCE'
    GROUP BY a.monthcol, a.facility, a.financial_months, b.ipv, a.lastdate) b ON a.facility::text = b.facility::text AND a.monthcol = b.monthcol AND a.lastdate = b.lastdate

UNION ALL


SELECT
    'OP ARR (INSURANCE)' AS name,
    a.monthcol,
    ROUND(
        a.actual / NULLIF(b.actual::numeric(18,0), 0),
        2
    ) AS actual,
    a.facility,
    a.financial_months,
    a.lastdate,
    17 AS pos,
    (
        'OP ARR / Patient (Rs.)'::character varying
        || a.facility::text
        || a.lastdate::character varying
    ) AS helper
FROM
    (
        SELECT
            'IP Revenue (in lacs)'::character varying AS name,
            br.monthcol,
            ROUND(
                SUM(COALESCE(
                    br.grossbillamount::numeric(18,0),
                    0::numeric(18,0)
                )) - (
                    SUM(COALESCE(
                        br.moudiscount::numeric(18,0),
                        0::numeric(18,0)
                    )) + SUM(COALESCE(
                        br.addondiscount::numeric(18,0),
                        0::numeric(18,0)
                    ))
                ),
                2
            ) AS actual,
            br.facility,
            br.financial_months,
            br.lastdate,
            11 AS pos,
            (
                'IP Revenue (in lacs)'::character varying
                || br.facility::text
                || br.lastdate::character varying
            ) AS helper
        FROM
            bidata.billregisterreport br
        WHERE
            br.patientclass::text = 'OP'::character varying
            AND br.ab = 1
            AND "actual payor category" = 'INSURANCE'
            
        GROUP BY
            br.monthcol,
            br.facility,
            br.financial_months,
            br.lastdate
    ) a
JOIN
    (
        SELECT
            'IPD Patients (Volume) : Discharges'::character varying AS name,
            a.monthcol,
            COUNT(a.uhid) - COALESCE(b.ipv, 0::bigint) AS actual,
            a.facility,
            a.financial_months,
            a.lastdate,
            10 AS pos,
            (
                'IPD Patients (Volume) : Discharges'::character varying
                || a.facility::text
                || a.lastdate::character varying
            ) AS helper
        FROM
            bidata.billregisterreport a
        LEFT JOIN
            (
                SELECT
                    COUNT(br.uhid) * 2 AS ipv,
                    br.monthcol,
                    br.facility,
                    br.financial_months,
                    br.lastdate
                FROM
                    bidata.billregisterreport br
                WHERE
                    LOWER(br.patientclass::text) = 'op'::character varying
                    AND UPPER(br.status::text) = 'OP CANCELLED INVOICE'::character varying
                    AND br.ab = 1
                    AND "actual payor category" = 'INSURANCE'
                    
                GROUP BY
                    br.monthcol,
                    br.facility,
                    br.financial_months,
                    br.lastdate
            ) b
        ON
            a.monthcol = b.monthcol
            AND a.facility::text = b.facility::text
            AND a.lastdate = b.lastdate
        WHERE
            LOWER(a.patientclass::text) = 'op'::character varying
            AND a.ab = 1
            AND "actual payor category" = 'INSURANCE'
            
        GROUP BY
            a.monthcol,
            a.facility,
            a.financial_months,
            b.ipv,
            a.lastdate
    ) b
ON
    a.facility::text = b.facility::text
    AND a.monthcol = b.monthcol
    AND a.lastdate = b.lastdate
UNION
SELECT
    'OP ARR - Insurance' AS name,
    a.monthcol,
    ROUND(
        a.actual / NULLIF(b.actual::numeric(18,0), 0),
        2
    ) AS actual,
    a.facility,
    a.financial_months,
    a.lastdate,
    17 AS pos,
    (
        'OP ARR - Insurance'::character varying
        || a.facility::text
        || a.lastdate::character varying
    ) AS helper
FROM
    (
        SELECT
            'IP Revenue (in lacs)'::character varying AS name,
            br.monthcol,
            ROUND(
                SUM(COALESCE(
                    br.grossbillamount::numeric(18,0),
                    0::numeric(18,0)
                )) - (
                    SUM(COALESCE(
                        br.moudiscount::numeric(18,0),
                        0::numeric(18,0)
                    )) + SUM(COALESCE(
                        br.addondiscount::numeric(18,0),
                        0::numeric(18,0)
                    ))
                ),
                2
            ) AS actual,
            br.facility,
            br.financial_months,
            br.lastdate,
            11 AS pos,
            (
                'IP Revenue (in lacs)'::character varying
                || br.facility::text
                || br.lastdate::character varying
            ) AS helper
        FROM
            bidata.billregisterreport br
        WHERE
            br.patientclass::text = 'OP'::character varying
            AND br.ab = 1
            AND "actual payor category" = 'INSURANCE'
            
        GROUP BY
            br.monthcol,
            br.facility,
            br.financial_months,
            br.lastdate
    ) a
JOIN
    (
        SELECT
            'IPD Patients (Volume) : Discharges'::character varying AS name,
            a.monthcol,
            COUNT(a.uhid) - COALESCE(b.ipv, 0::bigint) AS actual,
            a.facility,
            a.financial_months,
            a.lastdate,
            10 AS pos,
            (
                'IPD Patients (Volume) : Discharges'::character varying
                || a.facility::text
                || a.lastdate::character varying
            ) AS helper
        FROM
            bidata.billregisterreport a
        LEFT JOIN
            (
                SELECT
                    COUNT(br.uhid) * 2 AS ipv,
                    br.monthcol,
                    br.facility,
                    br.financial_months,
                    br.lastdate
                FROM
                    bidata.billregisterreport br
                WHERE
                    LOWER(br.patientclass::text) = 'op'::character varying
                    AND UPPER(br.status::text) = 'OP CANCELLED INVOICE'::character varying
                    AND br.ab = 1
                    AND "actual payor category" = 'INSURANCE'
                    
                GROUP BY
                    br.monthcol,
                    br.facility,
                    br.financial_months,
                    br.lastdate
            ) b
        ON
            a.monthcol = b.monthcol
            AND a.facility::text = b.facility::text
            AND a.lastdate = b.lastdate
        WHERE
            LOWER(a.patientclass::text) = 'op'::character varying
            AND a.ab = 1
            AND "actual payor category" = 'INSURANCE'
            
        GROUP BY
            a.monthcol,
            a.facility,
            a.financial_months,
            b.ipv,
            a.lastdate
    ) b
ON
    a.facility::text = b.facility::text
    AND a.monthcol = b.monthcol
    AND a.lastdate = b.lastdate

UNION

SELECT
    'OP ARR - Cash' AS name,
    a.monthcol,
    ROUND(
        a.actual / NULLIF(b.actual::numeric(18,0), 0),
        2
    ) AS actual,
    a.facility,
    a.financial_months,
    a.lastdate,
    17 AS pos,
    (
        'OP ARR - Cash'::character varying
        || a.facility::text
        || a.lastdate::character varying
    ) AS helper
FROM
    (
        SELECT
            'IP Revenue (in lacs)'::character varying AS name,
            br.monthcol,
            ROUND(
                SUM(COALESCE(
                    br.grossbillamount::numeric(18,0),
                    0::numeric(18,0)
                )) - (
                    SUM(COALESCE(
                        br.moudiscount::numeric(18,0),
                        0::numeric(18,0)
                    )) + SUM(COALESCE(
                        br.addondiscount::numeric(18,0),
                        0::numeric(18,0)
                    ))
                ),
                2
            ) AS actual,
            br.facility,
            br.financial_months,
            br.lastdate,
            11 AS pos,
            (
                'IP Revenue (in lacs)'::character varying
                || br.facility::text
                || br.lastdate::character varying
            ) AS helper
        FROM
            bidata.billregisterreport br
        WHERE
            br.patientclass::text = 'OP'::character varying
            AND br.ab = 1
            AND "actual payor category" = 'CASH'
            
        GROUP BY
            br.monthcol,
            br.facility,
            br.financial_months,
            br.lastdate
    ) a
JOIN
    (
        SELECT
            'IPD Patients (Volume) : Discharges'::character varying AS name,
            a.monthcol,
            COUNT(a.uhid) - COALESCE(b.ipv, 0::bigint) AS actual,
            a.facility,
            a.financial_months,
            a.lastdate,
            10 AS pos,
            (
                'IPD Patients (Volume) : Discharges'::character varying
                || a.facility::text
                || a.lastdate::character varying
            ) AS helper
        FROM
            bidata.billregisterreport a
        LEFT JOIN
            (
                SELECT
                    COUNT(br.uhid) * 2 AS ipv,
                    br.monthcol,
                    br.facility,
                    br.financial_months,
                    br.lastdate
                FROM
                    bidata.billregisterreport br
                WHERE
                    LOWER(br.patientclass::text) = 'op'::character varying
                    AND UPPER(br.status::text) = 'OP CANCELLED INVOICE'::character varying
                    AND br.ab = 1
                    AND "actual payor category" = 'CASH'
                    
                GROUP BY
                    br.monthcol,
                    br.facility,
                    br.financial_months,
                    br.lastdate
            ) b
        ON
            a.monthcol = b.monthcol
            AND a.facility::text = b.facility::text
            AND a.lastdate = b.lastdate
        WHERE
            LOWER(a.patientclass::text) = 'op'::character varying
            AND a.ab = 1
            AND "actual payor category" = 'CASH'
            
        GROUP BY
            a.monthcol,
            a.facility,
            a.financial_months,
            b.ipv,
            a.lastdate
    ) b
ON
    a.facility::text = b.facility::text
    AND a.monthcol = b.monthcol
    AND a.lastdate = b.lastdate
UNION
SELECT
    'OP ARR (INSURANCE)' AS name,
    a.monthcol,
    ROUND(
        a.actual / NULLIF(b.actual::numeric(18,0), 0),
        2
    ) AS actual,
    a.facility,
    a.financial_months,
    a.lastdate,
    17 AS pos,
    (
        'OP ARR / Patient (Rs.)'::character varying
        || a.facility::text
        || a.lastdate::character varying
    ) AS helper
FROM
    (
        SELECT
            'IP Revenue (in lacs)'::character varying AS name,
            br.monthcol,
            ROUND(
                SUM(COALESCE(
                    br.grossbillamount::numeric(18,0),
                    0::numeric(18,0)
                )) - (
                    SUM(COALESCE(
                        br.moudiscount::numeric(18,0),
                        0::numeric(18,0)
                    )) + SUM(COALESCE(
                        br.addondiscount::numeric(18,0),
                        0::numeric(18,0)
                    ))
                ),
                2
            ) AS actual,
            br.facility,
            br.financial_months,
            br.lastdate,
            11 AS pos,
            (
                'IP Revenue (in lacs)'::character varying
                || br.facility::text
                || br.lastdate::character varying
            ) AS helper
        FROM
            bidata.billregisterreport br
        WHERE
            br.patientclass::text = 'OP'::character varying
            AND br.ab = 1
            AND "actual payor category" = 'INSURANCE'
            
        GROUP BY
            br.monthcol,
            br.facility,
            br.financial_months,
            br.lastdate
    ) a
JOIN
    (
        SELECT
            'IPD Patients (Volume) : Discharges'::character varying AS name,
            a.monthcol,
            COUNT(a.uhid) - COALESCE(b.ipv, 0::bigint) AS actual,
            a.facility,
            a.financial_months,
            a.lastdate,
            10 AS pos,
            (
                'IPD Patients (Volume) : Discharges'::character varying
                || a.facility::text
                || a.lastdate::character varying
            ) AS helper
        FROM
            bidata.billregisterreport a
        LEFT JOIN
            (
                SELECT
                    COUNT(br.uhid) * 2 AS ipv,
                    br.monthcol,
                    br.facility,
                    br.financial_months,
                    br.lastdate
                FROM
                    bidata.billregisterreport br
                WHERE
                    LOWER(br.patientclass::text) = 'op'::character varying
                    AND UPPER(br.status::text) = 'OP CANCELLED INVOICE'::character varying
                    AND br.ab = 1
                    AND "actual payor category" = 'INSURANCE'
                    
                GROUP BY
                    br.monthcol,
                    br.facility,
                    br.financial_months,
                    br.lastdate
            ) b
        ON
            a.monthcol = b.monthcol
            AND a.facility::text = b.facility::text
            AND a.lastdate = b.lastdate
        WHERE
            LOWER(a.patientclass::text) = 'op'::character varying
            AND a.ab = 1
            AND "actual payor category" = 'INSURANCE'
            
        GROUP BY
            a.monthcol,
            a.facility,
            a.financial_months,
            b.ipv,
            a.lastdate
    ) b
ON
    a.facility::text = b.facility::text
    AND a.monthcol = b.monthcol
    AND a.lastdate = b.lastdate
UNION
SELECT
    'Total Admissions (Insurance)' AS name,
    admissionreport.monthcol,
    ROUND(COUNT(admissionreport.uhid)) AS actual,
    admissionreport.facility,
    admissionreport.financial_months,
    admissionreport.last_date,
    13 AS pos,
    (
        'Total Admissions (Insurance)'::character varying
        || admissionreport.facility::text
        || admissionreport.last_date::character varying
    )::character varying AS helper
FROM
    bidata.admissionreport
WHERE
    admissionreport.ab = 1
    AND "actual payor category" = 'INSURANCE'
  
GROUP BY
    admissionreport.monthcol,
    admissionreport.facility,
    admissionreport.financial_months,
    admissionreport.last_date
UNION
SELECT
    'Total Admissions (Cash)' AS name,
    admissionreport.monthcol,
    COUNT(admissionreport.uhid) AS actual,
    admissionreport.facility,
    admissionreport.financial_months,
    admissionreport.last_date,
    13 AS pos,
    (
        'Total Admissions (Cash)'::character varying
        || admissionreport.facility::text
        || admissionreport.last_date::character varying
    )::character varying AS helper
FROM
    bidata.admissionreport
WHERE
    admissionreport.ab = 1
    AND "actual payor category" = 'CASH'
GROUP BY
    admissionreport.monthcol,
    admissionreport.facility,
    admissionreport.financial_months,
    admissionreport.last_date
UNION
SELECT
    'Total OPD Net Revenue' AS name,
    billregisterreport.monthcol,
    ROUND(
        SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric(18,0))) / 100000::numeric(18,0),
        2
    ) AS actual,
    billregisterreport.facility,
    billregisterreport.financial_months,
    billregisterreport.lastdate,
    13 AS pos,
    (
        'Total OPD Net Revenue'::character varying
        || billregisterreport.facility::text
        || billregisterreport.lastdate::character varying
    )::character varying AS helper
FROM
    bidata.billregisterreport
WHERE
    (billregisterreport.patientclass::text = 'PH'::character varying
    OR billregisterreport.patientclass::text = 'OP'::character varying
    OR billregisterreport.patientclass::text = 'ER'::character varying)
    AND billregisterreport.ab = 1

GROUP BY
    billregisterreport.monthcol,
    billregisterreport.facility,
    billregisterreport.financial_months,
    billregisterreport.lastdate
UNION
SELECT
    'MOU discount only Gross Revenue (Lacs)' AS name,
    billregisterreport.monthcol,
    ROUND(
        SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric(18,0))) / 100000::numeric(18,0),
        2
    ) AS actual,
    billregisterreport.facility,
    billregisterreport.financial_months,
    billregisterreport.lastdate,
    2 AS pos,
    (
        'MOU discount only Gross Revenue (Lacs)' || billregisterreport.facility || billregisterreport.lastdate
    )::character varying AS helper
FROM
    bidata.billregisterreport
WHERE
    billregisterreport.ab = 1

    AND COALESCE(billregisterreport.moudiscount, 0::double precision) <> 0
GROUP BY
    billregisterreport.monthcol,
    billregisterreport.facility,
    billregisterreport.financial_months,
    billregisterreport.lastdate

UNION

SELECT
    'OP ARR' AS name,
    a.monthcol,
    ROUND((a.actual + b.actual) / NULLIF(c.actual, 0), 2) AS actual,
    a.facility,
    a.financial_months,
    a.lastdate,
    19 AS pos,
    (
        'OP ARR / Patient (Rs.)' || a.facility || a.lastdate
    )::character varying AS helper
FROM
    (
        SELECT
            'OPD Revenue' AS name,
            billregisterreport.monthcol,
            ROUND(
                SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric(18,0))) - 
                (SUM(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric(18,0))) + 
                SUM(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric(18,0)))),
                2
            ) AS actual,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate,
            13 AS pos,
            (
                'OPD Revenue' || billregisterreport.facility || billregisterreport.lastdate
            )::character varying AS helper
        FROM
            bidata.billregisterreport
        WHERE
            (billregisterreport.patientclass::text IN ('OP', 'ER'))
            AND billregisterreport.ab = 1
        
        GROUP BY
            billregisterreport.monthcol,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate
    ) a
JOIN
    (
        SELECT
            'OP Pharmacy Revenue' AS name,
            billregisterreport.monthcol,
            ROUND(
                SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric(18,0))) - 
                (SUM(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric(18,0))) + 
                SUM(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric(18,0)))),
                2
            ) AS actual,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate,
            14 AS pos,
            (
                'OP Pharmacy Revenue' || billregisterreport.facility || billregisterreport.lastdate
            )::character varying AS helper
        FROM
            bidata.billregisterreport
        WHERE
            billregisterreport.patientclass::text = 'PH'
            AND billregisterreport.ab = 1
        
        GROUP BY
            billregisterreport.monthcol,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate
    ) b
ON
    a.facility = b.facility
    AND a.monthcol = b.monthcol
    AND a.lastdate = b.lastdate
JOIN
    (
        SELECT
            'OPD Consults (Volume)' AS name,
            opvisitreport.monthcol,
            SUM(opvisitreport.unit) AS actual,
            opvisitreport.facility,
            opvisitreport.financial_months,
            opvisitreport.lastdate,
            18 AS pos,
            (
                'OPD Consults (Volume)' || opvisitreport.facility || opvisitreport.lastdate
            )::character varying AS helper
        FROM
            bidata.opvisitreport
        WHERE
            opvisitreport.ab = 1
            
            AND opvisitreport.visittype IN (
                'New Visit', 'First Visit', 'OP FIRST CONSULTATION', 'Followup Visit',
                'Follow-Up Visit', 'Free Visit', 'OP FOLLOWUP CONSULTATION',
                'OP FREE CONSULTATION', 'Paid Followup'
            )
        GROUP BY
            opvisitreport.monthcol,
            opvisitreport.facility,
            opvisitreport.financial_months,
            opvisitreport.lastdate
    ) c
ON
    a.facility = c.facility
    AND a.monthcol = c.monthcol
    AND a.lastdate = c.lastdate
UNION
SELECT
    'MOU Disc%' AS name,
    a.monthcol,
    CASE WHEN b.actual <> 0 THEN ROUND(a.actual / NULLIF(b.actual, 0), 2) ELSE NULL END AS actual,
    a.facility,
    a.financial_months,
    a.lastdate,
    4 AS pos,
    (
        'MOU Disc%' || a.facility || a.lastdate
    )::character varying AS helper
FROM
    (
        SELECT
            'MOU Discount' AS name,
            billregisterreport.monthcol,
            ROUND(
                SUM(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric(18,0))) / 100000::numeric(18,0),
                2
            ) AS actual,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate
        FROM
            bidata.billregisterreport
        WHERE
            billregisterreport.ab = 1
        
        GROUP BY
            billregisterreport.monthcol,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate
    ) a
JOIN
    (
        SELECT
            'MOU discount only Gross Revenue (Lacs)' AS name,
            billregisterreport.monthcol,
            ROUND(
                SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric(18,0))) / 100000::numeric(18,0),
                2
            ) AS actual,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate
        FROM
            bidata.billregisterreport
        WHERE
            billregisterreport.ab = 1
        
            AND COALESCE(billregisterreport.moudiscount, 0::double precision) <> 0
        GROUP BY
            billregisterreport.monthcol,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate
    ) b
ON
    a.facility = b.facility
    AND a.monthcol = b.monthcol
    AND a.lastdate = b.lastdate
UNION
SELECT
    'Add-on Discount' AS name,
    billregisterreport.monthcol,
    ROUND(
        SUM(COALESCE(billregisterreport.addondiscount::numeric, 0)) / 100000,
        2
    ) AS actual,
    billregisterreport.facility,
    billregisterreport.financial_months,
    billregisterreport.lastdate,
    5 AS pos,
    (
        'Add-on Discount' || billregisterreport.facility || billregisterreport.lastdate
    )::character varying AS helper
FROM
    bidata.billregisterreport
WHERE
    billregisterreport.ab = 1

GROUP BY
    billregisterreport.monthcol,
    billregisterreport.facility,
    billregisterreport.financial_months,
    billregisterreport.lastdate
UNION
SELECT
    'Discounts (Lacs)' AS name,
    billregisterreport.monthcol,
    ROUND(
        (
            SUM(COALESCE(billregisterreport.moudiscount::numeric, 0)) +
            SUM(COALESCE(billregisterreport.addondiscount::numeric, 0))
        ) / 100000,
        2
    ) AS actual,
    billregisterreport.facility,
    billregisterreport.financial_months,
    billregisterreport.lastdate,
    6 AS pos,
    (
        'Discounts (Lacs)' || billregisterreport.facility || billregisterreport.lastdate
    )::character varying AS helper
FROM
    bidata.billregisterreport
WHERE
    billregisterreport.ab = 1

GROUP BY
    billregisterreport.monthcol,
    billregisterreport.facility,
    billregisterreport.financial_months,
    billregisterreport.lastdate

UNION

SELECT
    'Discount %' AS name,
    a.monthcol,
    ROUND(
        NULLIF(b.actual, 0) / NULLIF(a.actual, 0), 
        4
    ) AS actual,
    a.facility,
    a.financial_months,
    a.lastdate,
    7 AS pos,
    (
        'Discount %' || a.facility || a.lastdate
    )::character varying AS helper
FROM
    (
        SELECT
            'Gross Revenue (Lacs)' AS name,
            billregisterreport.monthcol,
            ROUND(
                SUM(COALESCE(billregisterreport.grossbillamount::numeric, 0)) / 100000,
                2
            ) AS actual,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate,
            1 AS pos,
            (
                'Gross Revenue (Lacs)' || billregisterreport.facility || billregisterreport.lastdate
            )::character varying AS helper
        FROM
            bidata.billregisterreport
        WHERE
            billregisterreport.ab = 1
        
        GROUP BY
            billregisterreport.monthcol,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate
    ) a
JOIN
    (
        SELECT
            'Discounts (Lacs)' AS name,
            billregisterreport.monthcol,
            ROUND(
                (
                    SUM(COALESCE(billregisterreport.moudiscount::numeric, 0)) +
                    SUM(COALESCE(billregisterreport.addondiscount::numeric, 0))
                ) / 100000,
                2
            ) AS actual,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate,
            6 AS pos,
            (
                'Discounts (Lacs)' || billregisterreport.facility || billregisterreport.lastdate
            )::character varying AS helper
        FROM
            bidata.billregisterreport
        WHERE
            billregisterreport.ab = 1
        
        GROUP BY
            billregisterreport.monthcol,
            billregisterreport.facility,
            billregisterreport.financial_months,
            billregisterreport.lastdate
    ) b
ON
    a.facility = b.facility
    AND a.monthcol = b.monthcol
    AND a.lastdate = b.lastdate
UNION
SELECT 'Net Revenue (Lacs)' AS name, 
       billregisterreport.monthcol, 
       ROUND(
         (SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric)) 
          - (SUM(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric)) 
             + SUM(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric))
           )
         ) / 100000::numeric, 2
       ) AS actual, 
       billregisterreport.facility, 
       billregisterreport.financial_months, 
       billregisterreport.lastdate,
       8 AS pos, 
       ('Net Revenue (Lacs)'::text || billregisterreport.facility || billregisterreport.lastdate::text)::text AS helper
FROM bidata.billregisterreport
WHERE billregisterreport.ab = 1

GROUP BY billregisterreport.monthcol, 
         billregisterreport.facility, 
         billregisterreport.financial_months, 
         billregisterreport.lastdate
UNION
SELECT 'IP Revenue (in lacs)' AS name, 
       billregisterreport.monthcol, 
       ROUND(SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric)) / 100000::numeric, 2) AS actual, 
       billregisterreport.facility, 
       billregisterreport.financial_months, 
       billregisterreport.lastdate,
       11 AS pos, 
       ('IP Revenue (in lacs)'::text || billregisterreport.facility || billregisterreport.lastdate::text)::text AS helper
FROM bidata.billregisterreport
WHERE billregisterreport.patientclass = 'IP' 
AND billregisterreport.ab = 1 

GROUP BY billregisterreport.monthcol, 
         billregisterreport.facility, 
         billregisterreport.financial_months, 
         billregisterreport.lastdate
UNION 
SELECT 'IP Net Revenue' AS name, 
       billregisterreport.monthcol, 
       ROUND(
         (SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric)) 
          - (SUM(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric)) 
             + SUM(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric))
           )
         ) / 100000::numeric, 2
       ) AS actual, 
       billregisterreport.facility, 
       billregisterreport.financial_months, 
       billregisterreport.lastdate,
       12 AS pos, 
       ('IP Net Revenue'::text || billregisterreport.facility || billregisterreport.lastdate::text)::text AS helper
FROM bidata.billregisterreport
WHERE billregisterreport.patientclass = 'IP' 
AND billregisterreport.ab = 1 

GROUP BY billregisterreport.monthcol, 
         billregisterreport.facility, 
         billregisterreport.financial_months, 
         billregisterreport.lastdate
UNION 
SELECT 'OPD Revenue' AS name, 
       billregisterreport.monthcol, 
       ROUND(SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric)) / 100000::numeric, 2) AS actual, 
       billregisterreport.facility, 
       billregisterreport.financial_months, 
       billregisterreport.lastdate,
       13 AS pos, 
       ('OPD Revenue'::text || billregisterreport.facility || billregisterreport.lastdate::text)::text AS helper
FROM bidata.billregisterreport
WHERE billregisterreport.patientclass IN ('OP', 'ER') 
AND billregisterreport.ab = 1 

GROUP BY billregisterreport.monthcol, 
         billregisterreport.facility, 
         billregisterreport.financial_months, 
         billregisterreport.lastdate
UNION
SELECT 'OP Pharmacy Revenue' AS name, 
       billregisterreport.monthcol, 
       ROUND(SUM(COALESCE(billregisterreport.netamount::numeric(18,0), 0::numeric)) / 100000::numeric, 2) AS actual, 
       billregisterreport.facility, 
       billregisterreport.financial_months, 
       billregisterreport.lastdate,
       14 AS pos, 
       ('OP Pharmacy Revenue'::text || billregisterreport.facility || billregisterreport.lastdate::text)::text AS helper
FROM bidata.billregisterreport
WHERE billregisterreport.patientclass::text = 'PH'::character varying::text AND billregisterreport.ab = 1 
GROUP BY billregisterreport.monthcol, 
         billregisterreport.facility, 
         billregisterreport.financial_months, 
         billregisterreport.lastdate
UNION 
SELECT 'OPD Net Revenue' AS name, 
       billregisterreport.monthcol, 
       ROUND(
         (SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric)) 
          - (SUM(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric)) 
             + SUM(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric))
           )
         ) / 100000::numeric, 2
       ) AS actual, 
       billregisterreport.facility, 
       billregisterreport.financial_months, 
       billregisterreport.lastdate,
       15 AS pos, 
       ('OPD Net Revenue'::text || billregisterreport.facility || billregisterreport.lastdate::text)::text AS helper
FROM bidata.billregisterreport
WHERE billregisterreport.patientclass IN ('OP', 'ER') 
AND billregisterreport.ab = 1 

GROUP BY billregisterreport.monthcol, 
         billregisterreport.facility, 
         billregisterreport.financial_months, 
         billregisterreport.lastdate

UNION 
select 
        'Total Admissions' AS name,
        admissionreport.monthcol,
        round(
        count (uhid) 
        )AS actual,
        admissionreport.facility,
        admissionreport.financial_months,
        admissionreport.last_date,
        1 AS pos,
        (
        'Total Admissions':: character varying:: text + admissionreport.facility:: text + admissionreport.last_date:: character varying:: text
        ):: character varying AS helper
        FROM
         bidata.admissionreport
        WHERE
         ab = 1 and status = 'Active' 
            GROUP BY
              admissionreport.monthcol,
              admissionreport.facility,
              admissionreport.financial_months,
              admissionreport.last_date
UNION
SELECT 'Midnight Occupancy' AS name, 
       bedoccupancywithpatientdetail.monthcol, 
       count(ipno) AS actual, 
       bedoccupancywithpatientdetail.facility, 
       bedoccupancywithpatientdetail.financial_months, 
       bedoccupancywithpatientdetail.lastdate,
       19 AS pos, 
       ('Midnight Occupancy'::text || bedoccupancywithpatientdetail.facility || bedoccupancywithpatientdetail.lastdate::text)::text AS helper
FROM bidata.bedoccupancywithpatientdetail
WHERE bedoccupancywithpatientdetail.ab = 1 

GROUP BY bedoccupancywithpatientdetail.monthcol, 
         bedoccupancywithpatientdetail.facility, 
         bedoccupancywithpatientdetail.financial_months, 
         bedoccupancywithpatientdetail.lastdate
UNION
SELECT
  'ALOS' AS name,
  a.monthcol,
  round(
    a.actual:: numeric:: numeric(18, 0) / b.actual:: numeric:: numeric(18, 0),
    2
  ) AS actual,
  a.facility,
  a.financial_months,
  a.lastdate,
  8 AS pos,
  (
    'ALOS':: character varying:: text + a.facility:: text + a.lastdate:: character varying:: text
  ):: character varying AS helper
FROM
  (
    SELECT
      'Occupied Bed Days':: character varying AS name,
      billregisterreport.monthcol,
      sum(billregisterreport.lengthofstay) AS actual,
      billregisterreport.facility,
      billregisterreport.financial_months,
      billregisterreport.lastdate
    FROM
      bidata.billregisterreport
    WHERE
      billregisterreport.patientclass:: text = 'IP':: character varying:: text
      AND billregisterreport.ab = 1 
 
GROUP BY
      billregisterreport.monthcol,
      billregisterreport.facility,
      billregisterreport.financial_months,
      billregisterreport.lastdate
  ) a
  JOIN (
    SELECT
      'IPD Patients (Volume) : Discharges':: character varying AS name,
      a.monthcol,
      count(a.uhid) - COALESCE(b.ipv, 0:: bigint) AS actual,
      a.facility,
      a.financial_months,
      a.lastdate
    FROM
      bidata.billregisterreport a
      LEFT JOIN (
        SELECT
          count(billregisterreport.uhid) * 2 AS ipv,
          billregisterreport.monthcol,
          billregisterreport.facility,
          billregisterreport.financial_months,
          billregisterreport.lastdate
        FROM
          bidata.billregisterreport
        WHERE
          lower(billregisterreport.patientclass:: text) = 'ip':: character varying:: text
          AND upper(billregisterreport.status:: text) = 'IP CANCELLED INVOICE':: character varying:: text
          AND billregisterreport.ab = 1
      
        GROUP BY
          billregisterreport.monthcol,
          billregisterreport.facility,
          billregisterreport.financial_months,
          billregisterreport.lastdate
      ) b ON a.monthcol = b.monthcol
      AND a.facility:: text = b.facility:: text
      AND a.lastdate = b.lastdate
    WHERE
      lower(a.patientclass:: text) = 'ip':: character varying:: text
      AND a.ab = 1
      
    GROUP BY
      a.monthcol,
      a.facility,
      a.financial_months,
      b.ipv,
      a.lastdate
  ) b ON a.facility:: text = b.facility:: text
  AND a.monthcol = b.monthcol
  AND a.lastdate = b.lastdate
UNION
SELECT 'IP ARR / Patient (Rs.)' AS name, a.monthcol, round(a.actual / b.actual::numeric::numeric(18,0), 2) AS actual, a.facility, a.financial_months, a.lastdate, 17 AS pos, ('IP ARR / Patient (Rs.)'::character varying::text + a.facility::text + a.lastdate::character varying::text)::character varying AS helper
  FROM ( SELECT 'IP Revenue (in lacs)'::character varying AS name, billregisterreport.monthcol, round(sum(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric::numeric(18,0))) - (sum(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric::numeric(18,0))) + sum(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric::numeric(18,0)))), 2) AS actual, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate, 11 AS pos, 'IP Revenue (in lacs)'::character varying::text + billregisterreport.facility::text + billregisterreport.lastdate::character varying::text AS helper
          FROM bidata.billregisterreport
          WHERE billregisterreport.patientclass::text = 'IP'::character varying::text AND billregisterreport.ab = 1 
          GROUP BY billregisterreport.monthcol, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate) a
  JOIN ( SELECT 'IPD Patients (Volume) : Discharges'::character varying AS name, a.monthcol, count(a.uhid) - COALESCE(b.ipv, 0::bigint) AS actual, a.facility, a.financial_months, a.lastdate, 10 AS pos, 'IPD Patients (Volume) : Discharges'::character varying::text + a.facility::text + a.lastdate::character varying::text AS helper
          FROM bidata.billregisterreport a
      LEFT JOIN ( SELECT count(billregisterreport.uhid) * 2 AS ipv, billregisterreport.monthcol, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate
                  FROM bidata.billregisterreport
                  WHERE lower(billregisterreport.patientclass::text) = 'ip'::character varying::text AND upper(billregisterreport.status::text) = 'IP CANCELLED INVOICE'::character varying::text AND billregisterreport.ab = 1
                  GROUP BY billregisterreport.monthcol, billregisterreport.facility, billregisterreport.financial_months, billregisterreport.lastdate) b ON a.monthcol = b.monthcol AND a.facility::text = b.facility::text AND a.lastdate = b.lastdate
    WHERE lower(a.patientclass::text) = 'ip'::character varying::text AND a.ab = 1 
    GROUP BY a.monthcol, a.facility, a.financial_months, b.ipv, a.lastdate) b ON a.facility::text = b.facility::text AND a.monthcol = b.monthcol AND a.lastdate = b.lastdate
    UNION
SELECT
      'Discharges' AS name,
      a.monthcol,
      count(a.uhid) - COALESCE(b.ipv, 0:: bigint) AS actual,
      a.facility,
      a.financial_months,
      a.lastdate,
      6 AS pos,
      (
        'Discharges':: character varying:: text + a.facility:: text + a.lastdate:: character varying:: text
      ):: character varying AS helper
    FROM
      bidata.billregisterreport a
      LEFT JOIN (
        SELECT
          count(billregisterreport.uhid) * 2 AS ipv,
          billregisterreport.monthcol,
          billregisterreport.facility,
          billregisterreport.financial_months,
          billregisterreport.lastdate
        FROM
          bidata.billregisterreport
        WHERE
          lower(billregisterreport.patientclass:: text) = 'ip':: character varying:: text
          AND upper(billregisterreport.status:: text) = 'IP CANCELLED INVOICE':: character varying:: text
          AND billregisterreport.ab = 1 
        GROUP BY
          billregisterreport.monthcol,
          billregisterreport.facility,
          billregisterreport.financial_months,
          billregisterreport.lastdate
      ) b ON a.monthcol = b.monthcol
      AND a.facility:: text = b.facility:: text
      AND a.lastdate = b.lastdate
    WHERE
      lower(a.patientclass:: text) = 'ip':: character varying:: text
      AND a.ab = 1 
    GROUP BY
      a.monthcol,
      a.facility,
      a.financial_months,
      b.ipv,
      a.lastdate
  UNION
SELECT 'ARPOB /day (Rs.)' AS name, 
       a.monthcol, 
       CASE
         WHEN b.actual = 0 THEN NULL
         ELSE (a.actual / b.actual)
       END AS actual, 
       a.facility, 
       a.financial_months, 
       a.lastdate,
       10 AS pos, 
       ('ARPOB /day (Rs.)'::text || a.facility || a.lastdate::text)::text AS helper
FROM (
    SELECT 'Net Revenue (Lacs)'::text AS name, 
           billregisterreport.monthcol, 
           SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric)) 
           - (SUM(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric)) 
              + SUM(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric))
            ) AS actual, 
           billregisterreport.facility, 
           billregisterreport.financial_months, 
           billregisterreport.lastdate,
           8 AS pos, 
           ('Net Revenue (Lacs)'::text || billregisterreport.facility || billregisterreport.lastdate::text)::text AS helper
    FROM bidata.billregisterreport
    WHERE billregisterreport.ab = 1

    GROUP BY billregisterreport.monthcol, 
             billregisterreport.facility, 
             billregisterreport.financial_months, 
             billregisterreport.lastdate
) a
JOIN (
    SELECT 'Occupied Bed Days'::text AS name, 
           billregisterreport.monthcol, 
           SUM(billregisterreport.lengthofstay) AS actual, 
           billregisterreport.facility, 
           billregisterreport.financial_months, 
           billregisterreport.lastdate
    FROM bidata.billregisterreport
    WHERE billregisterreport.patientclass = 'IP' 
    AND billregisterreport.ab = 1 

    GROUP BY billregisterreport.monthcol, 
             billregisterreport.facility, 
             billregisterreport.financial_months, 
             billregisterreport.lastdate
) b 
ON a.facility = b.facility 
AND a.monthcol = b.monthcol 
AND a.lastdate = b.lastdate

UNION ALL

SELECT 'ARPOB - Cash' AS name, 
       a.monthcol, 
       CASE
         WHEN b.actual = 0 THEN NULL
         ELSE (a.actual / b.actual)
       END AS actual, 
       a.facility, 
       a.financial_months, 
       a.lastdate,
       10 AS pos, 
       ('ARPOB - Cash'::text || a.facility || a.lastdate::text)::text AS helper
FROM (
    SELECT 'Net Revenue (Lacs)'::text AS name, 
           billregisterreport.monthcol, 
           SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric)) 
           - (SUM(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric)) 
              + SUM(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric))
            ) AS actual, 
           billregisterreport.facility, 
           billregisterreport.financial_months, 
           billregisterreport.lastdate,
           8 AS pos, 
           ('Net Revenue (Lacs)'::text || billregisterreport.facility || billregisterreport.lastdate::text)::text AS helper
    FROM bidata.billregisterreport
    WHERE billregisterreport.ab = 1 and "actual payor category" = 'CASH'

    GROUP BY billregisterreport.monthcol, 
             billregisterreport.facility, 
             billregisterreport.financial_months, 
             billregisterreport.lastdate
) a
JOIN (
    SELECT 'Occupied Bed Days'::text AS name, 
           billregisterreport.monthcol, 
           SUM(billregisterreport.lengthofstay) AS actual, 
           billregisterreport.facility, 
           billregisterreport.financial_months, 
           billregisterreport.lastdate
    FROM bidata.billregisterreport
    WHERE billregisterreport.patientclass = 'IP' 
    AND billregisterreport.ab = 1 and "actual payor category" = 'CASH'

    GROUP BY billregisterreport.monthcol, 
             billregisterreport.facility, 
             billregisterreport.financial_months, 
             billregisterreport.lastdate
) b 
ON a.facility = b.facility 
AND a.monthcol = b.monthcol 
AND a.lastdate = b.lastdate

UNION ALL
SELECT 'ARPOB - Insurance' AS name, 
       a.monthcol, 
       CASE
         WHEN b.actual = 0 THEN NULL
         ELSE (a.actual / b.actual)
       END AS actual, 
       a.facility, 
       a.financial_months, 
       a.lastdate,
       10 AS pos, 
       ('ARPOB - Insurance'::text || a.facility || a.lastdate::text)::text AS helper
FROM (
    SELECT 'Net Revenue (Lacs)'::text AS name, 
           billregisterreport.monthcol, 
           SUM(COALESCE(billregisterreport.grossbillamount::numeric(18,0), 0::numeric)) 
           - (SUM(COALESCE(billregisterreport.moudiscount::numeric(18,0), 0::numeric)) 
              + SUM(COALESCE(billregisterreport.addondiscount::numeric(18,0), 0::numeric))
            ) AS actual, 
           billregisterreport.facility, 
           billregisterreport.financial_months, 
           billregisterreport.lastdate,
           8 AS pos, 
           ('Net Revenue (Lacs)'::text || billregisterreport.facility || billregisterreport.lastdate::text)::text AS helper
    FROM bidata.billregisterreport
    WHERE billregisterreport.ab = 1 and "actual payor category" = 'INSURANCE'

    GROUP BY billregisterreport.monthcol, 
             billregisterreport.facility, 
             billregisterreport.financial_months, 
             billregisterreport.lastdate
) a
JOIN (
    SELECT 'Occupied Bed Days'::text AS name, 
           billregisterreport.monthcol, 
           SUM(billregisterreport.lengthofstay) AS actual, 
           billregisterreport.facility, 
           billregisterreport.financial_months, 
           billregisterreport.lastdate
    FROM bidata.billregisterreport
    WHERE billregisterreport.patientclass = 'IP' 
    AND billregisterreport.ab = 1 and "actual payor category" = 'INSURANCE'

    GROUP BY billregisterreport.monthcol, 
             billregisterreport.facility, 
             billregisterreport.financial_months, 
             billregisterreport.lastdate
) b 
ON a.facility = b.facility 
AND a.monthcol = b.monthcol 
AND a.lastdate = b.lastdate
