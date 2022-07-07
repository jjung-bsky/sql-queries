--Find how many sources were preped for labeling but never labeled and are also old
--(we know they are old b/c parse uri gets labelbox or groundtruth)
DROP VIEW IF EXISTS sources_by_num_labels CASCADE;
CREATE VIEW sources_by_num_labels AS
SELECT
    is2.id,
    is2.uri,
    SUM(
        CASE
            WHEN il.imagery_source_id IS NULL THEN 0
            ELSE 1
        END
    ) AS num_times_labeled
FROM
    imagery_source AS is2
    LEFT JOIN imagery_label AS il ON is2.id = il.imagery_source_id
GROUP BY
    is2.id,
    is2.uri;

--18922 records in sources_by_num_labels; 5,475 of them were labeled 0 times;
--582 of them have uri that contains "labelbox"; 
--2,416 of them have uri that contains "labelbox"
SELECT
    *
FROM
    sources_by_num_labels
WHERE
    num_times_labeled = 0 
    AND (uri LIKE '%labelbox%' OR uri LIKE '%groundtruth%')