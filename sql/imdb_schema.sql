CREATE TABLE IF NOT EXISTS title (
  tid VARCHAR(16),

  primary_title VARCHAR(512) NOT NULL,
  original_title VARCHAR(512) NOT NULL,
  title_type VARCHAR(32),

  start_year SMALLINT,
  end_year SMALLINT,
  runtime INTEGER CHECK (runtime >= 0),

  is_adult_title BOOLEAN,
  genres ARRAY,

  PRIMARY KEY (tid)
);

CREATE TABLE IF NOT EXISTS detail (
  tid VARCHAR(16),
  ordering INTEGER CHECK (ordering >= 0),

  title VARCHAR(1024),
  is_original_title BOOLEAN,

  region VARCHAR(8),
  language VARCHAR(8),

  types ARRAY,
  attrs ARRAY,

  PRIMARY KEY (tid, ordering),
  FOREIGN KEY (tid) REFERENCES imdb.title(tid)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS episode (
  tid VARCHAR(16),
  parent_tid VARCHAR(10),
  season_num INTEGER,
  episode_num INTEGER,
  PRIMARY KEY (tid, parent_tid),
  FOREIGN KEY (tid) REFERENCES imdb.title(tid)
    ON DELETE CASCADE,
  FOREIGN KEY (parent_tid) REFERENCES imdb.title(tid)
    ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS rating (
  tid VARCHAR(16),
  avg_rating FLOAT CHECK (avg_rating >= 0 AND avg_rating <= 10),
  num_votes INTEGER CHECK (num_votes >= 0),
  PRIMARY KEY tid,
  FOREIGN KEY (tid) REFERENCES imdb.title(tid)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS person (
  pid VARCHAR(16),
  name VARCHAR(255) NOT NULL,
  birth_year SMALLINT,
  death_year SMALLINT,
  main_professions ARRAY,
  PRIMARY KEY pid
);

CREATE TABLE IF NOT EXISTS role (
  tid VARCHAR(16),
  ordering INTEGER CHECK (ordering >= 0),
  pid VARCHAR(16),
  category VARCHAR(512) NOT NULL,
  specific VARCHAR(512),
  characters VARCHAR(512),
  PRIMARY KEY (tid, ordering, pid),
  FOREIGN KEY (tid) REFERENCES imdb.title(tid)
    ON DELETE CASCADE,
  FOREIGN KEY (pid) REFERENCES imdb.person(pid)
    ON DELETE SET NULL
);
