-- CREATE NEW TABLES
CREATE TABLE IF NOT EXISTS akl_migrations(
    migration_file TEXT UNIQUE, 
    at_version TEXT,
    execution_data TIMESTAMP,
    applied INTEGER DEFAULT 0 
);

CREATE TABLE IF NOT EXISTS assetmappings (
    id TEXT PRIMARY KEY,
    mapped_asset_type TEXT NOT NULL,
    to_asset_type TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS metadata_assetmappings(
    metadata_id TEXT,
    assetmapping_id TEXT,
    FOREIGN KEY (metadata_id) REFERENCES metadata (id) 
        ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (assetmapping_id) REFERENCES assetmappings (id) 
        ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE TABLE IF NOT EXISTS romcollection_roms_assetmappings(
    romcollection_id TEXT,
    assetmapping_id TEXT,
    FOREIGN KEY (romcollection_id) REFERENCES romcollections (id) 
        ON DELETE CASCADE ON UPDATE NO ACTION,
    FOREIGN KEY (assetmapping_id) REFERENCES assetmappings (id) 
        ON DELETE CASCADE ON UPDATE NO ACTION
);