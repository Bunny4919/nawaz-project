-- ==========================================================
-- SUPABASE POSTGRESQL DATABASE SCHEMA & ROW LEVEL SECURITY
-- Mobile Personal Study and Mock Test Application
-- ==========================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. DOMAIN TYPES / CHECKS
-- Profile role: 'ADMIN' | 'USER'
-- Question difficulty: 'Easy' | 'Medium' | 'Hard'
-- Attempt type: 'QUIZ' | 'MOCK_TEST' | 'PRACTICE'
-- Bookmark item type: 'NOTE' | 'QUESTION'

-- 3. TABLES DEFINITION

-- PROFILES
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role TEXT NOT NULL DEFAULT 'USER' CHECK (role IN ('ADMIN', 'USER')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- SUBJECTS
CREATE TABLE IF NOT EXISTS public.subjects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- TOPICS
CREATE TABLE IF NOT EXISTS public.topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_subject_topic_name UNIQUE (subject_id, name)
);

-- NOTES
CREATE TABLE IF NOT EXISTS public.notes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    topic_id UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    file_path TEXT NOT NULL,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- QUESTIONS
CREATE TABLE IF NOT EXISTS public.questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    topic_id UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    explanation TEXT,
    difficulty TEXT NOT NULL DEFAULT 'Medium' CHECK (difficulty IN ('Easy', 'Medium', 'Hard')),
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- QUESTION OPTIONS
CREATE TABLE IF NOT EXISTS public.question_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE
);

-- QUIZZES
CREATE TABLE IF NOT EXISTS public.quizzes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    subject_id UUID NOT NULL REFERENCES public.subjects(id) ON DELETE CASCADE,
    topic_id UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- QUIZ QUESTIONS (M2M)
CREATE TABLE IF NOT EXISTS public.quiz_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quiz_id UUID NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
    CONSTRAINT unique_quiz_question UNIQUE (quiz_id, question_id)
);

-- MOCK TESTS
CREATE TABLE IF NOT EXISTS public.mock_tests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    total_marks INTEGER NOT NULL DEFAULT 100 CHECK (total_marks > 0),
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- MOCK TEST QUESTIONS (M2M)
CREATE TABLE IF NOT EXISTS public.mock_test_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mock_test_id UUID NOT NULL REFERENCES public.mock_tests(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
    marks NUMERIC NOT NULL DEFAULT 1.0 CHECK (marks >= 0),
    CONSTRAINT unique_mock_test_question UNIQUE (mock_test_id, question_id)
);

-- ATTEMPTS
CREATE TABLE IF NOT EXISTS public.attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    attempt_type TEXT NOT NULL CHECK (attempt_type IN ('QUIZ', 'MOCK_TEST', 'PRACTICE')),
    quiz_id UUID REFERENCES public.quizzes(id) ON DELETE SET NULL,
    mock_test_id UUID REFERENCES public.mock_tests(id) ON DELETE SET NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    submitted_at TIMESTAMPTZ,
    score NUMERIC NOT NULL DEFAULT 0,
    total_questions INTEGER NOT NULL DEFAULT 0,
    correct_answers INTEGER NOT NULL DEFAULT 0,
    wrong_answers INTEGER NOT NULL DEFAULT 0
);

-- ATTEMPT ANSWERS
CREATE TABLE IF NOT EXISTS public.attempt_answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id UUID NOT NULL REFERENCES public.attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES public.questions(id) ON DELETE CASCADE,
    selected_option_id UUID NOT NULL REFERENCES public.question_options(id) ON DELETE CASCADE,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT unique_attempt_question UNIQUE (attempt_id, question_id)
);

-- BOOKMARKS
CREATE TABLE IF NOT EXISTS public.bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL CHECK (item_type IN ('NOTE', 'QUESTION')),
    item_id UUID NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_user_bookmark UNIQUE (user_id, item_type, item_id)
);

-- NOTE PROGRESS
CREATE TABLE IF NOT EXISTS public.note_progress (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    note_id UUID NOT NULL REFERENCES public.notes(id) ON DELETE CASCADE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT unique_user_note_progress UNIQUE (user_id, note_id)
);

-- 4. PERFORMANCE INDEXES
CREATE INDEX IF NOT EXISTS idx_topics_subject_id ON public.topics(subject_id);
CREATE INDEX IF NOT EXISTS idx_notes_subject_id ON public.notes(subject_id);
CREATE INDEX IF NOT EXISTS idx_notes_topic_id ON public.notes(topic_id);
CREATE INDEX IF NOT EXISTS idx_questions_subject_id ON public.questions(subject_id);
CREATE INDEX IF NOT EXISTS idx_questions_topic_id ON public.questions(topic_id);
CREATE INDEX IF NOT EXISTS idx_question_options_question_id ON public.question_options(question_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_subject_id ON public.quizzes(subject_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_topic_id ON public.quizzes(topic_id);
CREATE INDEX IF NOT EXISTS idx_attempts_user_id ON public.attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_attempts_quiz_id ON public.attempts(quiz_id);
CREATE INDEX IF NOT EXISTS idx_attempts_mock_test_id ON public.attempts(mock_test_id);
CREATE INDEX IF NOT EXISTS idx_attempt_answers_attempt_id ON public.attempt_answers(attempt_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_user_id ON public.bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_note_progress_user_id ON public.note_progress(user_id);

-- 5. HELPER SECURITY FUNCTIONS

-- Helper function to check if current authenticated user is ADMIN
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'ADMIN'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Trigger to auto-create profile entry when auth user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, email, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'Student User'),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'role', 'USER')
  )
  ON CONFLICT (id) DO UPDATE
  SET full_name = EXCLUDED.full_name,
      email = EXCLUDED.email;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Bind user creation trigger to auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger to prevent users from updating their own role
CREATE OR REPLACE FUNCTION public.prevent_role_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.role IS DISTINCT FROM NEW.role AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'Unauthorized: Users cannot alter their own system role.';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS enforce_role_immutability ON public.profiles;
CREATE TRIGGER enforce_role_immutability
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.prevent_role_change();

-- 6. ROW LEVEL SECURITY (RLS) POLICIES

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.question_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mock_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mock_test_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attempt_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.note_progress ENABLE ROW LEVEL SECURITY;

-- PROFILES POLICIES
CREATE POLICY "Users can read own profile or admins read all"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id OR public.is_admin());

CREATE POLICY "Users can update own profile name"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id OR public.is_admin());

-- SUBJECTS POLICIES (All auth users can view; only ADMIN can modify)
CREATE POLICY "Authenticated users can read subjects"
    ON public.subjects FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can insert subjects"
    ON public.subjects FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "Only admins can update subjects"
    ON public.subjects FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "Only admins can delete subjects"
    ON public.subjects FOR DELETE
    USING (public.is_admin());

-- TOPICS POLICIES
CREATE POLICY "Authenticated users can read topics"
    ON public.topics FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can insert topics"
    ON public.topics FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "Only admins can update topics"
    ON public.topics FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "Only admins can delete topics"
    ON public.topics FOR DELETE
    USING (public.is_admin());

-- NOTES POLICIES
CREATE POLICY "Authenticated users can read notes"
    ON public.notes FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can manage notes"
    ON public.notes FOR ALL
    USING (public.is_admin());

-- QUESTIONS & OPTIONS POLICIES
CREATE POLICY "Authenticated users can read questions"
    ON public.questions FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can manage questions"
    ON public.questions FOR ALL
    USING (public.is_admin());

CREATE POLICY "Authenticated users can read question options"
    ON public.question_options FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can manage question options"
    ON public.question_options FOR ALL
    USING (public.is_admin());

-- QUIZZES & MOCK TESTS POLICIES
CREATE POLICY "Authenticated users can read quizzes"
    ON public.quizzes FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can manage quizzes"
    ON public.quizzes FOR ALL
    USING (public.is_admin());

CREATE POLICY "Authenticated users can read quiz questions"
    ON public.quiz_questions FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can manage quiz questions"
    ON public.quiz_questions FOR ALL
    USING (public.is_admin());

CREATE POLICY "Authenticated users can read mock tests"
    ON public.mock_tests FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can manage mock tests"
    ON public.mock_tests FOR ALL
    USING (public.is_admin());

CREATE POLICY "Authenticated users can read mock test questions"
    ON public.mock_test_questions FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Only admins can manage mock test questions"
    ON public.mock_test_questions FOR ALL
    USING (public.is_admin());

-- ATTEMPTS POLICIES
CREATE POLICY "Users read own attempts or admins read all"
    ON public.attempts FOR SELECT
    USING (auth.uid() = user_id OR public.is_admin());

CREATE POLICY "Users insert own attempts"
    ON public.attempts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users update own active attempts"
    ON public.attempts FOR UPDATE
    USING (auth.uid() = user_id);

-- ATTEMPT ANSWERS POLICIES
CREATE POLICY "Users read own attempt answers"
    ON public.attempt_answers FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.attempts a
            WHERE a.id = attempt_answers.attempt_id AND (a.user_id = auth.uid() OR public.is_admin())
        )
    );

CREATE POLICY "Users insert own attempt answers"
    ON public.attempt_answers FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.attempts a
            WHERE a.id = attempt_answers.attempt_id AND a.user_id = auth.uid()
        )
    );

-- BOOKMARKS POLICIES
CREATE POLICY "Users manage own bookmarks"
    ON public.bookmarks FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- NOTE PROGRESS POLICIES
CREATE POLICY "Users manage own note progress"
    ON public.note_progress FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 7. SUPABASE STORAGE POLICIES SETUP
-- Storage bucket 'study_notes'
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'study_notes',
    'study_notes',
    false, -- Private bucket: access via signed URLs or authenticated API
    20971520, -- 20MB Max limit
    ARRAY['application/pdf']
)
ON CONFLICT (id) DO UPDATE
SET public = false,
    file_size_limit = 20971520,
    allowed_mime_types = ARRAY['application/pdf'];

-- Storage bucket RLS policies
CREATE POLICY "Admins can upload note PDFs"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (bucket_id = 'study_notes' AND public.is_admin());

CREATE POLICY "Admins can update note PDFs"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (bucket_id = 'study_notes' AND public.is_admin());

CREATE POLICY "Admins can delete note PDFs"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (bucket_id = 'study_notes' AND public.is_admin());

CREATE POLICY "Authenticated users can read note PDFs"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (bucket_id = 'study_notes');
