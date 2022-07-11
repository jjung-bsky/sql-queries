--1. Find list of img_archive_id for duplicate sources by grouping on img_archive_id.
----7000 sources in total.
DROP VIEW IF EXISTS scenes_with_mult_sources CASCADE;

CREATE VIEW scenes_with_mult_sources AS
SELECT img_archive_id,
    COUNT(*) AS sources_cnt
FROM imagery_source
WHERE img_archive_id IS NOT NULL
GROUP BY img_archive_id
HAVING COUNT(*) > 1;

   
DROP VIEW IF EXISTS scenes_with_mult_sources2 CASCADE;

CREATE VIEW scenes_with_mult_sources2 AS
select * 
from imagery_source 
where img_archive_id in (select img_archive_id from scenes_with_mult_sources);

select * from scenes_with_mult_sources2;


--2. We only want those sources that have been labeled. In other words, we don't want those
--that were sent back for relabeling.
DROP VIEW IF EXISTS scenes_with_mult_sources3 CASCADE;

CREATE VIEW scenes_with_mult_sources3 AS
select scenes_with_mult_sources2.*
from scenes_with_mult_sources2
where id in (select imagery_source_id from imagery_label);

select * from scenes_with_mult_sources3;
--3,647 sources


--3. Filter out records where there were multiple objects of interest.
DROP VIEW IF EXISTS mult_ooi CASCADE;

CREATE VIEW mult_ooi AS
select img_archive_id, COUNT(DISTINCT object_of_interest) as num_ooi
from scenes_with_mult_sources3
group by img_archive_id
having COUNT(DISTINCT object_of_interest) > 1;

select * from mult_ooi;


DROP VIEW IF EXISTS scenes_with_mult_sources_final CASCADE;
CREATE VIEW scenes_with_mult_sources_final AS
select *
from scenes_with_mult_sources3
where img_archive_id not in (select img_archive_id from mult_ooi);

select * from scenes_with_mult_sources_final;
--3,380 sources


--4. TAG QUALITY/REASON OF SCENES LABELED MORE THAN ONCE
UPDATE
    imagery_source
SET
    quality = 'NEEDS_CORRECTION', quality_reason = array_append(quality_reason,'duplicate_labels')
WHERE
    img_archive_id IN (
        SELECT
            img_archive_id
        FROM
            scenes_with_mult_sources
    );