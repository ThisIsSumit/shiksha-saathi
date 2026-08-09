-- ═══════════════════════════════════════════════════════════
-- SHIKSHA SAATHI — Complete Database Schema
-- ═══════════════════════════════════════════════════════════

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─── ENUMS ────────────────────────────────────────────────
CREATE TYPE user_role AS ENUM ('teacher', 'student', 'parent', 'admin');
CREATE TYPE gender_type AS ENUM ('male', 'female', 'other');
CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'late', 'excused');
CREATE TYPE language_code AS ENUM ('en', 'hi', 'pa', 'mr', 'bn', 'ta', 'te', 'kn', 'gu', 'or');
CREATE TYPE notification_type AS ENUM ('attendance', 'homework', 'exam', 'progress', 'announcement');
CREATE TYPE quiz_status AS ENUM ('draft', 'published', 'archived');

-- ─── SCHOOLS ──────────────────────────────────────────────
CREATE TABLE schools (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name          VARCHAR(255) NOT NULL,
  name_hindi    VARCHAR(255),
  udise_code    VARCHAR(20) UNIQUE,
  district      VARCHAR(100),
  state         VARCHAR(100) NOT NULL DEFAULT 'Himachal Pradesh',
  block         VARCHAR(100),
  cluster       VARCHAR(100),
  address       TEXT,
  pincode       VARCHAR(10),
  phone         VARCHAR(15),
  principal_name VARCHAR(255),
  has_internet  BOOLEAN DEFAULT FALSE,
  total_rooms   INT DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ─── USERS (base table for all roles) ────────────────────
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  school_id       UUID REFERENCES schools(id) ON DELETE SET NULL,
  name            VARCHAR(255) NOT NULL,
  email           VARCHAR(255) UNIQUE,
  phone           VARCHAR(15) UNIQUE,
  password_hash   TEXT NOT NULL,
  role            user_role NOT NULL,
  gender          gender_type,
  date_of_birth   DATE,
  avatar_url      TEXT,
  preferred_lang  language_code DEFAULT 'hi',
  is_active       BOOLEAN DEFAULT TRUE,
  is_verified     BOOLEAN DEFAULT FALSE,
  otp_code        VARCHAR(6),
  otp_expires_at  TIMESTAMPTZ,
  reset_token     TEXT,
  reset_token_expires TIMESTAMPTZ,
  last_login_at   TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_users_school ON users(school_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_phone ON users(phone);

-- ─── TEACHERS ─────────────────────────────────────────────
CREATE TABLE teachers (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  school_id       UUID REFERENCES schools(id) ON DELETE CASCADE,
  employee_id     VARCHAR(50) UNIQUE,
  qualification   VARCHAR(255),
  subjects        TEXT[],            -- ['Mathematics', 'Science']
  grades          INT[],             -- [3, 4, 5]
  joining_date    DATE,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_teachers_school ON teachers(school_id);

-- ─── CLASSES ──────────────────────────────────────────────
CREATE TABLE classes (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  school_id   UUID REFERENCES schools(id) ON DELETE CASCADE,
  teacher_id  UUID REFERENCES teachers(id) ON DELETE SET NULL,
  grade       INT NOT NULL CHECK (grade BETWEEN 1 AND 12),
  section     VARCHAR(5) DEFAULT 'A',
  name        VARCHAR(100),         -- e.g. "Class 4-A"
  academic_year VARCHAR(10) DEFAULT '2024-25',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_classes_school ON classes(school_id);
CREATE INDEX idx_classes_teacher ON classes(teacher_id);

-- ─── STUDENTS ─────────────────────────────────────────────
CREATE TABLE students (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  school_id     UUID REFERENCES schools(id) ON DELETE CASCADE,
  class_id      UUID REFERENCES classes(id) ON DELETE SET NULL,
  roll_number   VARCHAR(20),
  admission_no  VARCHAR(50) UNIQUE,
  category      VARCHAR(20),        -- GEN, OBC, SC, ST
  bpl_card      BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_students_class ON students(class_id);
CREATE INDEX idx_students_school ON students(school_id);

-- ─── PARENTS ──────────────────────────────────────────────
CREATE TABLE parents (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  occupation    VARCHAR(100),
  annual_income VARCHAR(50),
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE parent_student_links (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  parent_id   UUID REFERENCES parents(id) ON DELETE CASCADE,
  student_id  UUID REFERENCES students(id) ON DELETE CASCADE,
  relation    VARCHAR(50),          -- father, mother, guardian
  is_primary  BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(parent_id, student_id)
);

-- ─── SUBJECTS ─────────────────────────────────────────────
CREATE TABLE subjects (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name      VARCHAR(100) NOT NULL,
  name_hi   VARCHAR(100),
  code      VARCHAR(20),
  grades    INT[],
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── LESSON PLANS ─────────────────────────────────────────
CREATE TABLE lesson_plans (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  teacher_id      UUID REFERENCES teachers(id) ON DELETE CASCADE,
  class_id        UUID REFERENCES classes(id) ON DELETE CASCADE,
  subject_id      UUID REFERENCES subjects(id),
  title           VARCHAR(255) NOT NULL,
  topic           VARCHAR(255) NOT NULL,
  topic_hindi     VARCHAR(255),
  ncf_chapter_code VARCHAR(50),
  content_json    JSONB NOT NULL,   -- structured plan with sections
  duration_mins   INT DEFAULT 45,
  language        language_code DEFAULT 'hi',
  ai_generated    BOOLEAN DEFAULT TRUE,
  is_shared       BOOLEAN DEFAULT FALSE,  -- shared in cluster
  likes_count     INT DEFAULT 0,
  date_for        DATE,
  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_lesson_teacher ON lesson_plans(teacher_id);
CREATE INDEX idx_lesson_class ON lesson_plans(class_id);
CREATE INDEX idx_lesson_date ON lesson_plans(date_for);

-- ─── WORKSHEETS ───────────────────────────────────────────
CREATE TABLE worksheets (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  teacher_id    UUID REFERENCES teachers(id) ON DELETE CASCADE,
  class_id      UUID REFERENCES classes(id) ON DELETE CASCADE,
  subject_id    UUID REFERENCES subjects(id),
  title         VARCHAR(255) NOT NULL,
  topic         VARCHAR(255),
  questions_json JSONB NOT NULL,    -- array of {type, question, options, answer}
  language      language_code DEFAULT 'hi',
  ai_generated  BOOLEAN DEFAULT TRUE,
  pdf_url       TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ─── ATTENDANCE ───────────────────────────────────────────
CREATE TABLE attendance (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  class_id    UUID REFERENCES classes(id) ON DELETE CASCADE,
  student_id  UUID REFERENCES students(id) ON DELETE CASCADE,
  teacher_id  UUID REFERENCES teachers(id),
  date        DATE NOT NULL,
  status      attendance_status NOT NULL DEFAULT 'present',
  note        TEXT,
  marked_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, date)
);
CREATE INDEX idx_attendance_class_date ON attendance(class_id, date);
CREATE INDEX idx_attendance_student ON attendance(student_id);

-- ─── QUIZZES ──────────────────────────────────────────────
CREATE TABLE quizzes (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  teacher_id      UUID REFERENCES teachers(id) ON DELETE CASCADE,
  class_id        UUID REFERENCES classes(id) ON DELETE CASCADE,
  subject_id      UUID REFERENCES subjects(id),
  title           VARCHAR(255) NOT NULL,
  topic           VARCHAR(255),
  questions_json  JSONB NOT NULL,
  total_marks     INT DEFAULT 10,
  duration_mins   INT DEFAULT 20,
  status          quiz_status DEFAULT 'draft',
  ai_generated    BOOLEAN DEFAULT TRUE,
  language        language_code DEFAULT 'hi',
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE quiz_attempts (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  quiz_id       UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  student_id    UUID REFERENCES students(id) ON DELETE CASCADE,
  answers_json  JSONB,
  score         NUMERIC(5,2),
  total_marks   INT,
  percentage    NUMERIC(5,2),
  time_taken_secs INT,
  submitted_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(quiz_id, student_id)
);
CREATE INDEX idx_quiz_attempts_student ON quiz_attempts(student_id);

-- ─── STUDENT PROGRESS ─────────────────────────────────────
CREATE TABLE student_progress (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id    UUID REFERENCES students(id) ON DELETE CASCADE,
  subject_id    UUID REFERENCES subjects(id),
  week_start    DATE NOT NULL,
  avg_score     NUMERIC(5,2),
  attendance_pct NUMERIC(5,2),
  quizzes_taken INT DEFAULT 0,
  strong_topics TEXT[],
  weak_topics   TEXT[],
  ai_suggestion TEXT,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(student_id, subject_id, week_start)
);
CREATE INDEX idx_progress_student ON student_progress(student_id);

-- ─── STREAKS ──────────────────────────────────────────────
CREATE TABLE student_streaks (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  student_id      UUID UNIQUE REFERENCES students(id) ON DELETE CASCADE,
  current_streak  INT DEFAULT 0,
  longest_streak  INT DEFAULT 0,
  last_active_date DATE,
  total_points    INT DEFAULT 0,
  badges          TEXT[] DEFAULT '{}',
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── NOTIFICATIONS ────────────────────────────────────────
CREATE TABLE notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  type        notification_type NOT NULL,
  title       VARCHAR(255) NOT NULL,
  body        TEXT NOT NULL,
  data_json   JSONB,
  is_read     BOOLEAN DEFAULT FALSE,
  sent_via    TEXT[],               -- ['push','sms','whatsapp']
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_notif_user ON notifications(user_id, is_read);

-- ─── AI QUERY LOG ─────────────────────────────────────────
CREATE TABLE ai_queries (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID REFERENCES users(id),
  user_role     user_role,
  query_text    TEXT NOT NULL,
  response_text TEXT,
  language      language_code DEFAULT 'hi',
  tokens_used   INT,
  model         VARCHAR(100),
  latency_ms    INT,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ─── REFRESH TOKENS ───────────────────────────────────────
CREATE TABLE refresh_tokens (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID REFERENCES users(id) ON DELETE CASCADE,
  token_hash  TEXT NOT NULL UNIQUE,
  expires_at  TIMESTAMPTZ NOT NULL,
  revoked     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX idx_refresh_user ON refresh_tokens(user_id);

-- ─── SEED: SUBJECTS ───────────────────────────────────────
INSERT INTO subjects (name, name_hi, code, grades) VALUES
  ('Mathematics', 'गणित',     'MATH', '{1,2,3,4,5,6,7,8}'),
  ('Hindi',       'हिंदी',    'HINDI','{1,2,3,4,5,6,7,8}'),
  ('English',     'अंग्रेज़ी','ENG',  '{3,4,5,6,7,8}'),
  ('Science',     'विज्ञान',  'SCI',  '{3,4,5,6,7,8}'),
  ('Social Science','सामाजिक विज्ञान','SST','{3,4,5,6,7,8}'),
  ('Environmental Studies','पर्यावरण अध्ययन','EVS','{1,2,3}');

-- ─── UPDATED_AT TRIGGER ───────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated     BEFORE UPDATE ON users          FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_schools_updated   BEFORE UPDATE ON schools         FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_lessons_updated   BEFORE UPDATE ON lesson_plans    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
