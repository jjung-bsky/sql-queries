--Found 133 sources where the geometry is just a point. An example of this
--phenomenon is the label with id = 896de91e-965e-5432-9a8b-f0a77565c7db
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