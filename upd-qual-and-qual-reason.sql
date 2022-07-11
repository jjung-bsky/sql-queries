--4. Make View for Old & Never Labeled Sources:
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

--5. Make View for Labels that are a Point:
DROP VIEW IF EXISTS geom_is_a_point CASCADE;
CREATE VIEW geom_is_a_point AS
SELECT
    imagery_source.id
FROM
    (
        SELECT
            *
        FROM
            imagery_label
        WHERE
            ST_GeometryType(geometry_wkb) = 'ST_Point'
    ) AS point_labels
    INNER JOIN imagery_source ON point_labels.imagery_source_id = imagery_source.id 



            

--8. TAG QUALITY/REASON OF OLD AND NEVER LABELED SOURCES
UPDATE
    imagery_source
SET
    quality = 'NEEDS_CORRECTION', quality_reason = array_append(quality_reason,'missing_labels')
WHERE
    id IN (
        SELECT
            id
        FROM
            old_never_labeled_sources
    );

--9. TAG QUALITY/REASON OF SOURCES WHERE GEOMETRY IS JUST A POINT
UPDATE
    imagery_source
SET
    quality = 'NEEDS_CORRECTION', quality_reason = array_append(quality_reason,'invalid_geometries')
WHERE
    id IN (
        SELECT
            id
        FROM
            geom_is_a_point
    );
    