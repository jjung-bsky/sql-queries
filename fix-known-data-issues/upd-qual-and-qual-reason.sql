--1. Make View for Large Airports:
DROP VIEW IF EXISTS large_airport_few_labels CASCADE;
CREATE VIEW large_airport_few_labels AS
SELECT
    imagery_source.id,
    imagery_source.geometry_wkb,
    poi.tags,
    poi.type,
    imagery_source.img_archive_id,
    imagery_source.object_of_interest,
    imagery_source.dataset_name,
    imagery_source.uri,
    COUNT(*)
FROM
    (
        SELECT
            geometry,
            tags,
            type
        FROM
            point_of_interest
        WHERE
            type = 'airport' and tags='{large,airport}'
    ) AS poi
    INNER JOIN imagery_source ON ST_Intersects(poi.geometry, imagery_source.geometry_wkb)
    INNER JOIN imagery_label ON imagery_source.id = imagery_label.imagery_source_id
GROUP BY
    imagery_source.id,
    imagery_source.geometry_wkb,
    poi.tags,
    poi.type,
    imagery_source.img_archive_id,
    imagery_source.object_of_interest,
    imagery_source.dataset_name,
    imagery_source.uri
HAVING COUNT(*) < 30 and (object_of_interest='aircraft' or object_of_interest is null);



--2. Make View for Medium Airports:
DROP VIEW IF EXISTS medium_airport_few_labels CASCADE;
CREATE VIEW medium_airport_few_labels AS
SELECT
    imagery_source.id,
    imagery_source.geometry_wkb,
    poi.tags,
    poi.type,
    imagery_source.img_archive_id,
    imagery_source.object_of_interest,
    imagery_source.dataset_name,
    imagery_source.uri,
    COUNT(*)
FROM
    (
        SELECT
            geometry,
            tags,
            type
        FROM
            point_of_interest
        WHERE
            type = 'airport' and tags='{medium,airport}'
    ) AS poi
    INNER JOIN imagery_source ON ST_Intersects(poi.geometry, imagery_source.geometry_wkb)
    INNER JOIN imagery_label ON imagery_source.id = imagery_label.imagery_source_id
GROUP BY
    imagery_source.id,
    imagery_source.geometry_wkb,
    poi.tags,
    poi.type,
    imagery_source.img_archive_id,
    imagery_source.object_of_interest,
    imagery_source.dataset_name,
    imagery_source.uri
HAVING COUNT(*) < 10 and (object_of_interest='aircraft' or object_of_interest is null);



--3. Make View for Scenes With Multiple Sources:
DROP VIEW IF EXISTS scenes_with_mult_sources CASCADE;

CREATE VIEW scenes_with_mult_sources AS
SELECT
    img_archive_id,
    COUNT(DISTINCT object_of_interest)
FROM
    (
        SELECT
            cntsrc. *,
            ims.id AS img_source_id,
            ims.object_of_interest
        FROM
            (
                SELECT
                    img_archive_id,
                    COUNT(*) AS sources_cnt
                FROM
                    imagery_source
                WHERE
                    img_archive_id IS NOT NULL
                GROUP BY
                    img_archive_id
                HAVING
                    COUNT(*) > 1
            ) AS cntsrc
            INNER JOIN imagery_source AS ims ON cntsrc.img_archive_id = ims.img_archive_id
    ) as src_cnt
GROUP BY
    img_archive_id
HAVING
    COUNT(DISTINCT object_of_interest) = 1;


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




--6. TAG QUALITY/REASON OF AIRPORTS WITH MISSING LABELS
UPDATE
    imagery_source
SET
    quality = 'NEEDS_CORRECTION', quality_reason = ARRAY['missing_labels']
WHERE
    id IN (
        SELECT
            id
        FROM
            large_airport_few_labels
        UNION ALL
        SELECT
            id
        FROM
            medium_airport_few_labels
    );


--7. TAG QUALITY/REASON OF SCENES LABELED MORE THAN ONCE
--6723
UPDATE
    imagery_source
SET
    quality = 'NEEDS_CORRECTION', quality_reason = ARRAY['duplicate_labels']
WHERE
    id IN (
        SELECT
            img_archive_id
        FROM
            scenes_with_mult_sources
            

--8. TAG QUALITY/REASON OF OLD AND NEVER LABELED SOURCES
UPDATE
    imagery_source
SET
    quality = 'NEEDS_CORRECTION', quality_reason = ARRAY['missing_labels']
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
    quality = 'NEEDS_CORRECTION', quality_reason = ARRAY['invalid_geometries']
WHERE
    id IN (
        SELECT
            id
        FROM
            geom_is_a_point
    );
    