--find all labeled medium ports with fewer than 10 labels
--found 1,010
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