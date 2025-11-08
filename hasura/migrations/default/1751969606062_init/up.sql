SET check_function_bodies = false;
CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;
COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';
CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;
CREATE TABLE public.blocks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    blocker_id uuid,
    blocked_id uuid,
    created_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.interests (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(100) NOT NULL,
    category character varying(50),
    created_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.matches (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    profile1_id uuid,
    profile2_id uuid,
    matched_at timestamp with time zone DEFAULT now(),
    is_active boolean DEFAULT true
);
CREATE TABLE public.messages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    match_id uuid,
    sender_id uuid,
    content text NOT NULL,
    message_type character varying(20) DEFAULT 'text'::character varying,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT messages_message_type_check CHECK (((message_type)::text = ANY ((ARRAY['text'::character varying, 'image'::character varying, 'gif'::character varying, 'sticker'::character varying])::text[])))
);
CREATE TABLE public.profile_interests (
    profile_id uuid NOT NULL,
    interest_id uuid NOT NULL
);
CREATE TABLE public.profile_photos (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    profile_id uuid,
    photo_url character varying(500) NOT NULL,
    is_primary boolean DEFAULT false,
    photo_order integer DEFAULT 1,
    created_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.profiles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    first_name character varying(100) NOT NULL,
    last_name character varying(100),
    bio text,
    date_of_birth date NOT NULL,
    gender character varying(20) NOT NULL,
    location_city character varying(100),
    location_country character varying(100),
    latitude numeric(10,8),
    longitude numeric(11,8),
    max_distance integer DEFAULT 50,
    min_age integer DEFAULT 18,
    max_age integer DEFAULT 99,
    looking_for character varying(50) DEFAULT 'relationship'::character varying,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    onboarding_step integer DEFAULT 1,
    CONSTRAINT profiles_gender_check CHECK (((gender)::text = ANY ((ARRAY['male'::character varying, 'female'::character varying, 'non-binary'::character varying, 'other'::character varying])::text[]))),
    CONSTRAINT profiles_looking_for_check CHECK (((looking_for)::text = ANY ((ARRAY['relationship'::character varying, 'casual'::character varying, 'friendship'::character varying, 'networking'::character varying])::text[])))
);
CREATE TABLE public.reports (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    reporter_id uuid,
    reported_id uuid,
    reason character varying(100) NOT NULL,
    description text,
    status character varying(20) DEFAULT 'pending'::character varying,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT reports_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'reviewed'::character varying, 'resolved'::character varying, 'dismissed'::character varying])::text[])))
);
CREATE TABLE public.subscriptions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id uuid,
    plan_type character varying(20) NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT subscriptions_plan_type_check CHECK (((plan_type)::text = ANY ((ARRAY['basic'::character varying, 'premium'::character varying, 'gold'::character varying])::text[])))
);
CREATE TABLE public.super_likes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    sender_id uuid,
    receiver_id uuid,
    created_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.swipes (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    swiper_id uuid,
    swiped_id uuid,
    is_like boolean NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);
CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    is_verified boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);
ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocker_id_blocked_id_key UNIQUE (blocker_id, blocked_id);
ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.interests
    ADD CONSTRAINT interests_name_key UNIQUE (name);
ALTER TABLE ONLY public.interests
    ADD CONSTRAINT interests_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_profile1_id_profile2_id_key UNIQUE (profile1_id, profile2_id);
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.profile_interests
    ADD CONSTRAINT profile_interests_pkey PRIMARY KEY (profile_id, interest_id);
ALTER TABLE ONLY public.profile_photos
    ADD CONSTRAINT profile_photos_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.super_likes
    ADD CONSTRAINT super_likes_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.super_likes
    ADD CONSTRAINT super_likes_sender_id_receiver_id_key UNIQUE (sender_id, receiver_id);
ALTER TABLE ONLY public.swipes
    ADD CONSTRAINT swipes_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.swipes
    ADD CONSTRAINT swipes_swiper_id_swiped_id_key UNIQUE (swiper_id, swiped_id);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
CREATE INDEX idx_blocks_blocked_id ON public.blocks USING btree (blocked_id);
CREATE INDEX idx_blocks_blocker_id ON public.blocks USING btree (blocker_id);
CREATE INDEX idx_matches_profile1_id ON public.matches USING btree (profile1_id);
CREATE INDEX idx_matches_profile2_id ON public.matches USING btree (profile2_id);
CREATE INDEX idx_messages_created_at ON public.messages USING btree (created_at);
CREATE INDEX idx_messages_match_id ON public.messages USING btree (match_id);
CREATE INDEX idx_messages_sender_id ON public.messages USING btree (sender_id);
CREATE INDEX idx_profiles_age_range ON public.profiles USING btree (min_age, max_age);
CREATE INDEX idx_profiles_location ON public.profiles USING btree (latitude, longitude);
CREATE INDEX idx_profiles_user_id ON public.profiles USING btree (user_id);
CREATE INDEX idx_swipes_swiped_id ON public.swipes USING btree (swiped_id);
CREATE INDEX idx_swipes_swiper_id ON public.swipes USING btree (swiper_id);
CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON public.messages FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_reports_updated_at BEFORE UPDATE ON public.reports FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON public.subscriptions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_blocker_id_fkey FOREIGN KEY (blocker_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_profile1_id_fkey FOREIGN KEY (profile1_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.matches
    ADD CONSTRAINT matches_profile2_id_fkey FOREIGN KEY (profile2_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_match_id_fkey FOREIGN KEY (match_id) REFERENCES public.matches(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.profile_interests
    ADD CONSTRAINT profile_interests_interest_id_fkey FOREIGN KEY (interest_id) REFERENCES public.interests(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.profile_interests
    ADD CONSTRAINT profile_interests_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.profile_photos
    ADD CONSTRAINT profile_photos_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_reported_id_fkey FOREIGN KEY (reported_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.super_likes
    ADD CONSTRAINT super_likes_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.super_likes
    ADD CONSTRAINT super_likes_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.swipes
    ADD CONSTRAINT swipes_swiped_id_fkey FOREIGN KEY (swiped_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE ONLY public.swipes
    ADD CONSTRAINT swipes_swiper_id_fkey FOREIGN KEY (swiper_id) REFERENCES public.profiles(id) ON DELETE CASCADE;
