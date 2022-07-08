--Find how many sources were preped for labeling but never labeled and are also old
--(we know they are old b/c parse uri gets labelbox or groundtruth)
--5,475 sources were labeled 0 times;
--582 of them have uri that contains "labelbox"; 
--2,416 of them have uri that also contains "labelbox"
DROP VIEW IF EXISTS old_never_labeled_sources CASCADE;


CREATE VIEW old_never_labeled_sources AS
SELECT
    *
FROM
    (
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
            is2.uri
    ) AS src_by_num_labels
WHERE
    num_times_labeled = 0
    AND (
        uri LIKE '%labelbox%'
        OR uri LIKE '%groundtruth%'
    );