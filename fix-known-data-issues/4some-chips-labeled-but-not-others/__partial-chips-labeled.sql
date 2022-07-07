DROP VIEW IF EXISTS chips_by_num_labels CASCADE;
CREATE VIEW chips_by_num_labels AS     
SELECT imagery_chip.id, sum(
        CASE WHEN imagery_label.imagery_chip_id IS NULL 
            THEN 0
        ELSE 1
        END
    ) AS num_times_labeled
FROM imagery_chip
LEFT JOIN imagery_label
ON imagery_chip.id = imagery_label.imagery_chip_id
group by imagery_chip.id;


select * from chips_by_num_labels order by num_times_labeled asc;
--65k labels found