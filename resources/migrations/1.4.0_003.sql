-- UPDATE EXISTING TABLES AND VIEWS
PRAGMA foreign_keys=OFF;
PRAGMA legacy_alter_table=ON;

DROP VIEW IF EXiSTS vw_romcollections;
DROP VIEW IF EXiSTS vw_categories;

ALTER TABLE categories RENAME TO categories_temp;

CREATE TABLE IF NOT EXISTS categories(
    id TEXT PRIMARY KEY, 
    name TEXT NOT NULL,
    parent_id TEXT NULL,
    metadata_id TEXT,
    FOREIGN KEY (parent_id) REFERENCES categories (id) 
        ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (metadata_id) REFERENCES metadata (id) 
        ON DELETE CASCADE ON UPDATE NO ACTION
);

INSERT INTO categories (id, name, parent_id, metadata_id)
    SELECT id, name, parent_id, metadata_id FROM categories_temp;

DROP TABLE categories_temp;

ALTER TABLE romcollections RENAME TO romcollections_temp;

CREATE TABLE IF NOT EXISTS romcollections(
    id TEXT PRIMARY KEY, 
    name TEXT NOT NULL,
    platform TEXT,
    box_size TEXT,
    parent_id TEXT NULL,
    metadata_id TEXT,
    FOREIGN KEY (parent_id) REFERENCES categories (id) 
        ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (metadata_id) REFERENCES metadata (id) 
        ON DELETE CASCADE ON UPDATE NO ACTION
);

INSERT INTO romcollections (id, name, platform, box_size, parent_id, metadata_id)
    SELECT id, name, platform, box_size, parent_id, metadata_id FROM romcollections_temp;

DROP TABLE romcollections_temp;

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
    m.finished AS finished,
    m.assets_path AS assets_path,
    (SELECT COUNT(*) FROM categories AS sc WHERE sc.parent_id = c.id) AS num_categories,
    (SELECT COUNT(*) FROM romcollections AS sr WHERE sr.parent_id = c.id) AS num_collections
FROM categories AS c 
    INNER JOIN metadata AS m ON c.metadata_id = m.id;
       
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
    m.finished AS finished,
    m.assets_path AS assets_path,
    r.platform AS platform,
    r.box_size AS box_size,
    (SELECT COUNT(*) FROM roms AS rms INNER JOIN roms_in_romcollection AS rrs ON rms.id = rrs.rom_id AND rrs.romcollection_id = r.id) as num_roms
FROM romcollections AS r 
    INNER JOIN metadata AS m ON r.metadata_id = m.id;    

INSERT INTO akl_migrations (migration_file, applied_version, execution_date, applied)
     VALUES('1.2.0.sql','1.4.0',CURRENT_TIMESTAMP,1)

PRAGMA foreign_keys=ON;
PRAGMA legacy_alter_table=OFF;