--TABLE NAMES:
--point_of_interest
--imagery_source
--imagery_chip
--imagery_label
--{large,airport}
-- {medium,airport}
--labelbox project
--groundtruth

CREATE VIEW mult_sources_labels AS
SELECT
    img_archive_id,
    COUNT(*) AS total_sources,
    SUM(source_is_labeled) AS total_labeled_sources
FROM
    scenes_labeled_or_not
GROUP BY
    img_archive_id
ORDER BY
    COUNT(*) DESC,
    SUM(source_is_labeled) DESC;

--2,948 scenes