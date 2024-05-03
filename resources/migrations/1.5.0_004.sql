-- --------------------------------------
-- CREATE NEW VIEWS / DROP OLD VIEWS
-- --------------------------------------
DROP VIEW vw_roms;

CREATE VIEW IF NOT EXISTS vw_roms AS SELECT 
    r.id AS id, 
    r.metadata_id,
    r.name AS m_name,
    r.num_of_players AS nplayers,
    r.num_of_players_online AS nplayers_online,
    r.esrb_rating AS esrb,
    r.pegi_rating AS pegi,
    r.nointro_status AS nointro_status,
    r.pclone_status AS pclone_status,
    r.cloneof AS cloneof,
    r.platform AS platform,
    r.box_size AS box_size,
    r.scanned_by_id AS scanned_by_id,
    m.year AS m_year, 
    m.genre AS m_genre,
    m.developer AS m_developer,
    m.rating AS m_rating,
    m.plot AS m_plot,
    m.extra AS extra,
    m.finished,
    r.rom_status,
    (SELECT COUNT(*) FROM roms_in_romcollection AS rr WHERE rr.rom_id = r.id) AS collections_count,
    r.is_favourite,
    r.launch_count,
    r.last_launch_timestamp,
    r.created_on,
    r.updated_on,
    (
        SELECT group_concat(t.tag) AS rom_tags
        FROM tags AS t 
        INNER JOIN metatags AS mt ON t.id = mt.tag_id
        WHERE mt.metadata_id = r.metadata_id
        GROUP BY mt.metadata_id
    ) AS rom_tags
FROM roms AS r 
    INNER JOIN metadata AS m ON r.metadata_id = m.id;
