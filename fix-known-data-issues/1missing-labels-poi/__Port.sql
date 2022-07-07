--select distinct tags from point_of_interest where type='port';
--large ports
DROP VIEW IF EXISTS scenes_with_mult_sources CASCADE;
CREATE VIEW scenes_with_mult_sources AS
SELECT
    imagery_source.id,
    imagery_source.geometry_wkb,
    poi.tags,
    poi.type,
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
            type = 'port' and tags='{large}'
    ) AS poi
    INNER JOIN imagery_source ON ST_Intersects(poi.geometry, imagery_source.geometry_wkb)
    INNER JOIN imagery_label ON imagery_source.id = imagery_label.imagery_source_id
GROUP BY
    imagery_source.id,
    imagery_source.geometry_wkb,
    poi.tags,
    poi.type
ORDER BY
    COUNT(*) ASC
HAVING COUNT(*) < 30;


--medium ports
DROP VIEW IF EXISTS scenes_with_mult_sources CASCADE;
CREATE VIEW scenes_with_mult_sources AS
SELECT
    imagery_source.id,
    imagery_source.geometry_wkb,
    poi.tags,
    poi.type,
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
            type = 'port' and tags='{medium}'
    ) AS poi
    INNER JOIN imagery_source ON ST_Intersects(poi.geometry, imagery_source.geometry_wkb)
    INNER JOIN imagery_label ON imagery_source.id = imagery_label.imagery_source_id
GROUP BY
    imagery_source.id,
    imagery_source.geometry_wkb,
    poi.tags,
    poi.type
ORDER BY
    COUNT(*) ASC
HAVING COUNT(*) < 30;