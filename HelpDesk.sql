##EASY
-- #1
/*
There are three issues that include the words "index" and "Oracle". Find the call_date for each of them
*/
SELECT call_date, call_ref
FROM Issue
WHERE
(detail LIKE '%index%')
 AND (detail LIKE '%Oracle%');

-- #2
/*
Samantha Hall made three calls on 2017-08-14. Show the date and time for each
*/
SELECT
	i.call_date,
	c.first_name,
	c.last_name
FROM
	Issue AS i
	JOIN
		Caller AS c
		ON (c.caller_id = i.caller_id)
WHERE
	c.first_name = 'Samantha'
	AND c.last_name = 'Hall'
	AND i.call_date LIKE '%2017-08-14%';

-- #3
/*
There are 500 calls in the system (roughly). Write a query that shows the number that have each status.
*/
SELECT
	status, Count(*) AS Volume
FROM Issue
GROUP BY status;

-- #4
/*
Calls are not normally assigned to a manager but it does happen. How many calls have been assigned to staff who are at Manager Level?
*/
SELECT COUNT(*) AS mlcc
FROM Issue i
JOIN Staff sf
ON (i.Assigned_to = sf.Staff_code)
JOIN Level l
ON (sf.Level_code = l.Level_code)
WHERE Level.Manager = 'Y';

-- #5
/*
Show the manager for each shift. Your output should include the shift date and type; also the first and last name of the manager.
*/
SELECT
	s.Shift_date,
	s.Shift_type,
	sf.first_name,
	sf.last_name
FROM
	Shift s
	JOIN
		Staff sf
		ON (s.Manager = sf.Staff_Code)
ORDER BY
	sf.Shift_date;

-- #6
/*
List the Company name and the number of calls for those companies with more than 18 calls.
*/
SELECT
	ct.Company_name,
	c.COUNT(*)
FROM
	Customer ct
	JOIN
		Caller c
		ON (ct.Company_ref = c.Company_ref)
	JOIN
		Issue i
		ON (c.Caller_id = i.Caller_id)
GROUP BY
	ct.Company_name
HAVING
	c.COUNT(*) > 18;

-- #7
/*
Find the callers who have never made a call. Show first name and last name
*/
SELECT
	first_name,
	last_name
FROM
	Caller
  WHERE caller_id NOT IN (SELECT caller_id FROM Issue)

-- #8
/*
For each customer show: Company name, contact name, number of calls where the number of calls is fewer than 5
*/
SELECT
	a.Company_name,
	b.first_name,
	b.last_name,
	a.nc
FROM
	(
		SELECT
			Customer.Company_name,
			Customer.Contact_id,
			COUNT(*) AS nc
		FROM
			Customer
			JOIN
				Caller
				ON (Customer.Company_ref = Caller.Company_ref)
			JOIN
				Issue
				ON (Caller.Caller_id = Issue.Caller_id)
		GROUP BY
			Customer.Company_name,
			Customer.Contact_id
		HAVING
			COUNT(*) < 5
	)
	AS a
	JOIN
		(
			SELECT
				*
			FROM
				Caller
		)
		AS b
		ON (a.Contact_id = b.Caller_id);

-- #9
/*
For each shift show the number of staff assigned. Beware that some roles may be NULL and that the same person might have been assigned to multiple roles (The roles are 'Manager', 'Operator', 'Engineer1', 'Engineer2').
*/
SELECT
	a.Shift_date,
	a.Shift_type,
	COUNT(DISTINCT role) AS cw
FROM
	(
		SELECT
			shift_date,
			shift_type,
			Manager AS role
		FROM
			Shift
		UNION ALL
		SELECT
			shift_date,
			shift_type,
			Operator AS role
		FROM
			Shift
		UNION ALL
		SELECT
			shift_date,
			shift_type,
			Engineer1 AS role
		FROM
			Shift
		UNION ALL
		SELECT
			shift_date,
			shift_type,
			Engineer2 AS role
		FROM
			Shift
	)
	AS a
GROUP BY
	a.Shift_date,
	a.Shift_type;

-- #10
/*
Caller 'Harry' claims that the operator who took his most recent call was abusive and insulting. Find out who took the call (full name) and when.
*/
SELECT
	Staff.first_name,
	Staff.last_name,
	Issue_Max.call_date
FROM
	(
		SELECT
			b.call_date,
			b.Taken_by,
			b.Caller_id
		FROM
			(
				SELECT
					Issue.Caller_id,
					MAX(Issue.call_date) AS call_date
				FROM
					Issue
				GROUP BY
					Issue.Caller_id
			)
			AS a
			JOIN
				Issue AS b
				ON a.Caller_id = b.Caller_id
				AND a.call_date = b.call_date
	)
	AS Issue_Max
	JOIN
		Staff
		ON (Staff.Staff_code = Issue_Max.Taken_By)
	JOIN
		Caller
		ON (Issue_Max.Caller_id = Caller.Caller_id)
WHERE
	Caller.first_name = 'Harry';
