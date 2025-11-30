-- Run as:
--   psql -U postgres -d postgres -f create-tables.sql

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";      -- needed for uuid_generate_v4()
CREATE EXTENSION IF NOT EXISTS pgcrypto;         -- needed for gen_random_uuid()


-- Enums
CREATE TYPE exercise_type AS ENUM (
  'duration',
  'sets',
  'body_weight',
  'distance',
  'reps'
);

CREATE TYPE unit_enum AS ENUM (
  'kg',
  'lb',
  'm',
  'km',
  'yd',
  'mi',
  'sec',
  'min',
  'rep'
);


-- Users
CREATE TABLE users (
  id           VARCHAR(128) PRIMARY KEY,
  email        VARCHAR(255) NOT NULL UNIQUE,
  is_verified  BOOLEAN DEFAULT false,
  deleted_at   TIMESTAMPTZ,
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);

-- Coach Table
CREATE TABLE coach (
  coach_id     VARCHAR(128) PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  name         VARCHAR(255) NOT NULL,
  lastname     VARCHAR(255) NOT NULL,
  email        VARCHAR(255) NOT NULL UNIQUE,
  phone_number VARCHAR(50),
  created_at   TIMESTAMPTZ DEFAULT now(),
  updated_at   TIMESTAMPTZ DEFAULT now()
);



-- Profiles
CREATE TABLE profiles (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id             VARCHAR(128) NOT NULL REFERENCES users(id),
  birth_date          DATE,
  gender              VARCHAR(20),
  body_type           VARCHAR(20),
  goal                VARCHAR(20),
  body_fat_percentage INTEGER,
  area_problem        VARCHAR(20),
  height_cm           INTEGER,
  weight_kg           INTEGER,
  on_boarding_step    INTEGER DEFAULT 0 NOT NULL,
  activity_index      INTEGER,
  push_ups_range      TEXT,
  pull_ups_range      TEXT,
  place_training      TEXT,
  frequency_training  TEXT,
  time_training       TEXT,
  age_range           VARCHAR(255),
  name                VARCHAR(255),
  target_weight       INTEGER,
  created_at          TIMESTAMPTZ DEFAULT now(),
  updated_at          TIMESTAMPTZ DEFAULT now()
);


-- Exercise Reference
CREATE TABLE exercise_ref (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name        TEXT NOT NULL,
  description TEXT,
  type        exercise_type NOT NULL,
  picture_url TEXT,
  is_deleted  BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now(),
  meta        JSONB DEFAULT NULL
);


-- Session (template)
CREATE TABLE session (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     VARCHAR(128) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL,
  description TEXT,
  is_deleted  BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now(),
  meta        JSONB DEFAULT NULL
);


-- Session Exercises
CREATE TABLE session_exercise (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id       UUID NOT NULL REFERENCES session(id) ON DELETE CASCADE,
  exercise_ref_id  UUID NOT NULL REFERENCES exercise_ref(id) ON DELETE CASCADE,
  "order"          SMALLINT NOT NULL,
  notes            TEXT DEFAULT NULL,
  is_deleted       BOOLEAN DEFAULT false,
  created_at       TIMESTAMPTZ DEFAULT now(),
  updated_at       TIMESTAMPTZ DEFAULT now(),
  meta             JSONB DEFAULT NULL
);


-- Program
CREATE TABLE program (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,
  description   TEXT,
  duration_days SMALLINT CHECK (duration_days > 0),
  difficulty    TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  tags          TEXT[] DEFAULT NULL,
  picture_url   TEXT,
  is_public     BOOLEAN DEFAULT false,
  is_deleted    BOOLEAN DEFAULT false,
  start_date    TIMESTAMPTZ DEFAULT now(),
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now(),
  created_by    TEXT NOT NULL,
  meta          JSONB DEFAULT '{}'
);


-- Program Session
CREATE TABLE program_session (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  program_id  UUID NOT NULL REFERENCES program(id) ON DELETE CASCADE,
  session_id  UUID NOT NULL REFERENCES session(id) ON DELETE CASCADE,
  day_number  SMALLINT NOT NULL,
  is_deleted  BOOLEAN DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now(),
  meta        JSONB DEFAULT NULL
);


-- Set (template)
CREATE TABLE set (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  set_number       SMALLINT NOT NULL,
  reps             INTEGER,
  weight           NUMERIC,
  weight_unit      unit_enum,
  distance         NUMERIC,
  distance_unit    unit_enum,
  duration_sec     INTEGER,
  rest_sec         INTEGER,
  rpe              NUMERIC,
  tempo            TEXT,
  is_deleted       BOOLEAN NOT NULL DEFAULT false,
  created_at       TIMESTAMPTZ DEFAULT now(),
  updated_at       TIMESTAMPTZ DEFAULT now(),
  meta             JSONB DEFAULT NULL,
  session_exercise_id UUID NOT NULL REFERENCES session_exercise(id) ON DELETE CASCADE
);


-- Workout Session (performed by user)
CREATE TABLE workout_session (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     VARCHAR(128) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  session_id  UUID REFERENCES session(id),         -- optional
  program_id  UUID REFERENCES program(id),         -- optional
  started_at  TIMESTAMPTZ DEFAULT now(),
  finished_at TIMESTAMPTZ,
  is_completed BOOLEAN DEFAULT false,
  meta        JSONB DEFAULT NULL
);


-- Workout Exercise
CREATE TABLE workout_exercise (
  id                 UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_session_id UUID NOT NULL REFERENCES workout_session(id) ON DELETE CASCADE,
  session_exercise_id UUID REFERENCES session_exercise(id),
  exercise_ref_id    UUID NOT NULL REFERENCES exercise_ref(id),   -- secure copy
  is_done            BOOLEAN DEFAULT false,
  notes              TEXT,
  created_at         TIMESTAMPTZ DEFAULT now(),
  updated_at         TIMESTAMPTZ DEFAULT now(),
  meta               JSONB DEFAULT NULL
);


-- Workout Set
CREATE TABLE workout_set (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  workout_exercise_id UUID NOT NULL REFERENCES workout_exercise(id) ON DELETE CASCADE,
  set_number          SMALLINT NOT NULL,
  reps                INTEGER,
  weight              NUMERIC,
  weight_unit         unit_enum,
  distance            NUMERIC,
  distance_unit       unit_enum,
  duration_sec        INTEGER,
  rpe                 NUMERIC,
  is_done             BOOLEAN DEFAULT false,
  created_at          TIMESTAMPTZ DEFAULT now(),
  updated_at          TIMESTAMPTZ DEFAULT now(),
  meta                JSONB DEFAULT NULL
);


-- Nutrition Program
CREATE TABLE nutrition_program (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       VARCHAR(128) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name          TEXT NOT NULL,
  description   TEXT,
  duration_days SMALLINT CHECK (duration_days > 0),
  picture_url   TEXT,
  tags          TEXT[] DEFAULT NULL,
  is_public     BOOLEAN DEFAULT false,
  start_date    TIMESTAMPTZ DEFAULT now(),
  is_deleted    BOOLEAN DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now(),
  meta          JSONB DEFAULT '{}'   -- calories/day, macros, etc.
);


-- Nutrition Day
CREATE TABLE nutrition_day (
  id                  UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nutrition_program_id UUID NOT NULL REFERENCES nutrition_program(id) ON DELETE CASCADE,
  day_number          SMALLINT NOT NULL,
  notes               TEXT,
  is_deleted          BOOLEAN DEFAULT false,
  created_at          TIMESTAMPTZ DEFAULT now(),
  updated_at          TIMESTAMPTZ DEFAULT now(),
  meta                JSONB DEFAULT NULL
);


-- Meal
CREATE TABLE meal (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nutrition_day_id UUID NOT NULL REFERENCES nutrition_day(id) ON DELETE CASCADE,
  name             TEXT NOT NULL,      -- breakfast, lunch, snack, dinner...
  notes            TEXT,
  created_at       TIMESTAMPTZ DEFAULT now(),
  updated_at       TIMESTAMPTZ DEFAULT now(),
  meta             JSONB DEFAULT '{}'  -- calories, macros, restrictions...
);
CREATE TABLE meal_ref (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          TEXT NOT NULL,
  description   TEXT,
  picture_url   TEXT,
  is_deleted    BOOLEAN DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now(),
  meta          JSONB DEFAULT '{}'   -- macros, allergens, tags, etc.
);

CREATE TABLE meal_ref_item (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  meal_ref_id UUID NOT NULL REFERENCES meal_ref(id) ON DELETE CASCADE,
  food_name   TEXT NOT NULL,
  quantity    NUMERIC,
  unit        TEXT,
  calories    NUMERIC,
  protein_g   NUMERIC,
  carbs_g     NUMERIC,
  fat_g       NUMERIC,
  meta        JSONB DEFAULT NULL,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);



-- Meal Item
CREATE TABLE meal_item (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  meal_id    UUID NOT NULL REFERENCES meal(id) ON DELETE CASCADE,
  food_name  TEXT NOT NULL,
  quantity   NUMERIC,
  unit       TEXT,     -- g, ml, piece, tbsp…
  calories   NUMERIC,
  protein_g  NUMERIC,
  carbs_g    NUMERIC,
  fat_g      NUMERIC,
  meta       JSONB DEFAULT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
