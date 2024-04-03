PRAGMA foreign_keys=off;
BEGIN TRANSACTION;

ALTER TABLE roms RENAME TO _roms_old;

CREATE TABLE IF NOT EXISTS roms(
    id TEXT PRIMARY KEY, 
    name TEXT NOT NULL,
    num_of_players INTEGER DEFAULT 1 NOT NULL,
    num_of_players_online INTEGER DEFAULT 0 NOT NULL,
    esrb_rating TEXT,
    pegi_rating TEXT,
    nointro_status TEXT, 
    pclone_status TEXT,
    cloneof TEXT,
    platform TEXT,
    box_size TEXT,
    rom_status TEXT,
    is_favourite INTEGER DEFAULT 0 NOT NULL,
    launch_count INTEGER DEFAULT 0 NOT NULL,
    last_launch_timestamp TIMESTAMP,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata_id TEXT,
    scanned_by_id TEXT NULL,
    FOREIGN KEY (metadata_id) REFERENCES metadata (id) 
        ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (scanned_by_id) REFERENCES sources (id) 
        ON DELETE CASCADE ON UPDATE NO ACTION
);

INSERT INTO roms (
    id,name,num_of_players,num_of_players_online,esrb_rating,pegi_rating,nointro_status,pclone_status,cloneof,
    platform,box_size,rom_status,is_favourite, launch_count, last_launch_timestamp, metadata_id, scanned_by_id
) SELECT 
    id,name,num_of_players,num_of_players_online,esrb_rating,pegi_rating,nointro_status,pclone_status,cloneof,
    platform,box_size,rom_status,is_favourite, launch_count, last_launch_timestamp, metadata_id, scanned_by_id
 FROM _roms_old;

DROP TABLE _roms_old;

COMMIT;
PRAGMA foreign_keys=on;

-- --------------------------------------
-- CREATE NEW VIEWS / DROP OLD VIEWS
-- --------------------------------------
DROP VIEW vw_categories;
DROP VIEW vw_romcollections;
DROP VIEW vw_sources;
DROP VIEW vw_roms;
DROP VIEW vw_rom_assets;
DROP VIEW vw_rom_asset_paths;
DROP VIEW vw_rom_tags;
DROP VIEW vw_rom_launchers;

CREATE VIEW IF NOT EXISTS vw_categories AS SELECT 
    c.id AS id, 
    c.parent_id AS parent_id,
    c.metadata_id,
    c.name AS m_name,
    m.year AS m_year, 
    m.genre AS m_genre,
    m.developer AS m_developer,
    m.rating AS m_rating,
    m.plot AS m_plot,
    m.extra AS extra,
    m.finished AS finished,
    (SELECT COUNT(*) FROM categories AS sc WHERE sc.parent_id = c.id) AS num_categories,
    (SELECT COUNT(*) FROM romcollections AS sr WHERE sr.parent_id = c.id) AS num_collections,
    (SELECT COUNT(*) FROM roms AS rms INNER JOIN roms_in_category AS rc ON rms.id = rc.rom_id AND rc.category_id = c.id) as num_roms,
    (SELECT MAX(rms.changed_on) FROM roms AS rms INNER JOIN roms_in_category AS rc ON rms.id = rc.rom_id AND rc.category_id = c.id) as last_change_on
FROM categories AS c 
    INNER JOIN metadata AS m ON c.metadata_id = m.id;

CREATE VIEW IF NOT EXISTS vw_sources AS SELECT 
    s.id AS id, 
    s.name AS name,
    s.platform AS platform,
    s.box_size AS box_size,
    s.assets_path AS assets_path,
    s.last_scan_timestamp AS last_scan_timestamp,
    s.settings AS settings,
    a.id AS associated_addon_id,
    a.name,
    a.addon_id,
    a.version,
    a.addon_type,
    a.extra_settings,
    (SELECT COUNT(*) FROM roms AS rms WHERE rms.scanned_by_id = s.id) as num_roms
    (SELECT MAX(rms.changed_on) FROM roms AS rms WHERE rms.scanned_by_id = s.id) as last_change_on
FROM sources AS s
    INNER JOIN akl_addon AS a ON s.akl_addon_id = a.id;

CREATE VIEW IF NOT EXISTS vw_romcollections AS SELECT 
    r.id AS id, 
    r.parent_id AS parent_id,
    r.metadata_id,
    r.name AS m_name,
    m.year AS m_year, 
    m.genre AS m_genre,
    m.developer AS m_developer,
    m.rating AS m_rating,
    m.plot AS m_plot,
    m.extra AS extra,
    m.finished AS finished,
    r.platform AS platform,
    r.box_size AS box_size,
    (SELECT COUNT(*) FROM roms AS rms INNER JOIN roms_in_romcollection AS rrs ON rms.id = rrs.rom_id AND rrs.romcollection_id = r.id) as num_roms,
    (SELECT MAX(rms.changed_on) FROM roms AS rms INNER JOIN roms_in_romcollection AS rrs ON rms.id = rrs.rom_id AND rrs.romcollection_id = r.id) as last_change_on
FROM romcollections AS r 
    INNER JOIN metadata AS m ON r.metadata_id = m.id;

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

CREATE VIEW IF NOT EXISTS vw_rom_assets AS SELECT
    a.id as id,
    r.id as rom_id, 
    a.filepath,
    a.asset_type
FROM assets AS a
 INNER JOIN rom_assets AS ra ON a.id = ra.asset_id 
 INNER JOIN roms AS r ON ra.rom_id = r.id;

CREATE VIEW IF NOT EXISTS vw_rom_asset_paths AS SELECT
    a.id as id,
    r.id as rom_id, 
    a.path,
    a.asset_type
FROM assetpaths AS a
 INNER JOIN rom_assetpaths AS ra ON a.id = ra.assetpaths_id 
 INNER JOIN roms AS r ON ra.rom_id = r.id;

CREATE VIEW IF NOT EXISTS vw_rom_tags AS SELECT
    t.id as id,
    r.id as rom_id, 
    t.tag
FROM tags AS t
 INNER JOIN metatags AS mt ON t.id = mt.tag_id
 INNER JOIN roms AS r ON mt.metadata_id = r.metadata_id;
 
CREATE VIEW IF NOT EXISTS vw_rom_launchers AS SELECT
    l.id AS id,
    l.name AS name,
    rl.rom_id,
    a.id AS associated_addon_id,
    a.name,
    a.addon_id,
    a.version,
    a.addon_type,
    a.extra_settings,
    l.settings,
    rl.is_default
FROM rom_launchers AS rl
    INNER JOIN launchers AS l ON rl.launcher_id = l.id
    INNER JOIN akl_addon AS a ON l.akl_addon_id = a.id;