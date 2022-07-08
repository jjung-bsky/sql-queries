--Find scenes that were labeled more than once and with the exact same
--object of interest each time it was labeled (i.e. always airport or always port).
--The scenes_with_mult_sources view contains 2,948 scenes comprising of 7,025 
--sources, and 2,845 of these scenes were labeled multiple times with the same object
--of interest.
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