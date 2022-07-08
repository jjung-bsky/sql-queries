DROP VIEW IF EXISTS scenes_with_mult_sources CASCADE;
CREATE VIEW scenes_with_mult_sources AS
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
    COUNT(*) > 1;

select * from scenes_with_mult_sources;
   
   
DROP VIEW IF EXISTS scenes_with_mult_sources2 CASCADE;
CREATE VIEW scenes_with_mult_sources2 AS
select * 
from imagery_source 
where img_archive_id in (select img_archive_id from scenes_with_mult_sources);
--7000 sources

select * from scenes_with_mult_sources2;


DROP VIEW IF EXISTS scenes_with_mult_sources3 CASCADE;
CREATE VIEW scenes_with_mult_sources3 AS
select scenes_with_mult_sources2.*
from scenes_with_mult_sources2
where id in (select imagery_source_id from imagery_label);


select * from scenes_with_mult_sources3;
--3,647 sources


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

