-- ==========================================================
-- NIRVANA BACKEND HARDENING MIGRATION 01
-- Server-Verified Attempt Scoring & Protection
-- ==========================================================

-- 1. TRIGGER TO PREVENT DIRECT ATTEMPT SCORE MANIPULATION BY USERS
CREATE OR REPLACE FUNCTION public.prevent_direct_score_tampering()
RETURNS TRIGGER AS $$
BEGIN
  -- If invoked by a non-admin client attempting to manually insert or alter score fields:
  IF NOT public.is_admin() THEN
    -- If updating score directly or attempting manual insert:
    IF TG_OP = 'UPDATE' AND (
      OLD.score IS DISTINCT FROM NEW.score OR
      OLD.correct_answers IS DISTINCT FROM NEW.correct_answers OR
      OLD.wrong_answers IS DISTINCT FROM NEW.wrong_answers
    ) THEN
      RAISE EXCEPTION 'Unauthorized: Attempt scores are calculated server-side and cannot be manually modified.';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS enforce_attempt_score_protection ON public.attempts;
CREATE TRIGGER enforce_attempt_score_protection
  BEFORE UPDATE ON public.attempts
  FOR EACH ROW EXECUTE FUNCTION public.prevent_direct_score_tampering();

-- 2. SECURE SERVER-SIDE ATTEMPT SUBMISSION RPC FUNCTION
CREATE OR REPLACE FUNCTION public.submit_attempt_rpc(
  p_attempt_type TEXT,
  p_quiz_id UUID DEFAULT NULL,
  p_mock_test_id UUID DEFAULT NULL,
  p_answers JSONB DEFAULT '[]'::jsonb
)
RETURNS JSONB AS $$
DECLARE
  v_user_id UUID;
  v_attempt_id UUID;
  v_total_questions INT;
  v_correct_count INT := 0;
  v_wrong_count INT := 0;
  v_score NUMERIC := 0;
  v_elem JSONB;
  v_question_id UUID;
  v_selected_option_id UUID;
  v_is_correct BOOLEAN;
BEGIN
  -- Identify caller identity from Supabase Auth token
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Unauthenticated attempt submission rejected.';
  END IF;

  v_total_questions := jsonb_array_length(p_answers);
  IF v_total_questions = 0 THEN
    RAISE EXCEPTION 'No answer payload provided.';
  END IF;

  -- Create attempt record
  INSERT INTO public.attempts (
    user_id, attempt_type, quiz_id, mock_test_id, started_at, submitted_at, score, total_questions, correct_answers, wrong_answers
  ) VALUES (
    v_user_id, p_attempt_type, p_quiz_id, p_mock_test_id, NOW(), NOW(), 0, v_total_questions, 0, 0
  ) RETURNING id INTO v_attempt_id;

  -- Process answers and evaluate correctness using server-verified database options
  FOR v_elem IN SELECT * FROM jsonb_array_elements(p_answers)
  LOOP
    v_question_id := (v_elem->>'question_id')::UUID;
    v_selected_option_id := (v_elem->>'selected_option_id')::UUID;

    -- Verify option correctness directly against question_options table
    SELECT is_correct INTO v_is_correct
    FROM public.question_options
    WHERE id = v_selected_option_id AND question_id = v_question_id;

    IF v_is_correct IS TRUE THEN
      v_correct_count := v_correct_count + 1;
    ELSE
      v_wrong_count := v_wrong_count + 1;
      v_is_correct := FALSE;
    END IF;

    -- Insert individual answer log
    INSERT INTO public.attempt_answers (
      attempt_id, question_id, selected_option_id, is_correct
    ) VALUES (
      v_attempt_id, v_question_id, v_selected_option_id, v_is_correct
    );
  END LOOP;

  -- Calculate final percentage score
  v_score := ROUND((v_correct_count::NUMERIC / v_total_questions::NUMERIC) * 100.0, 2);

  -- Update score on attempt row safely via internal SECURITY DEFINER function
  UPDATE public.attempts
  SET score = v_score,
      correct_answers = v_correct_count,
      wrong_answers = v_wrong_count
  WHERE id = v_attempt_id;

  RETURN jsonb_build_object(
    'attempt_id', v_attempt_id,
    'score', v_score,
    'total_questions', v_total_questions,
    'correct_answers', v_correct_count,
    'wrong_answers', v_wrong_count
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
