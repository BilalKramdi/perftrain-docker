
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    id VARCHAR(128) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    free_likes_used INTEGER DEFAULT 0,
    free_likes_reset_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User profiles table
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    first_name VARCHAR(100) DEFAULT NULL,
    bio TEXT DEFAULT NULL,
    date_of_birth DATE DEFAULT NULL,
    gender VARCHAR(20) NOT NULL CHECK (gender IN ('male', 'female', 'non_binary', 'other')),
    display_gender BOOLEAN DEFAULT FALSE,
    sexual_orientation VARCHAR(20) CHECK (sexual_orientation IN ('straight', 'gay', 'lesbian', 'bisexual', 'pansexual', 'asexual', 'queer', 'other') OR sexual_orientation IS NULL),
    display_orientation BOOLEAN DEFAULT FALSE,
    interested_in_genders TEXT[] DEFAULT NULL,
    interests TEXT[] DEFAULT NULL,
    location_city VARCHAR(100) DEFAULT NULL,
    location_country VARCHAR(100) DEFAULT NULL,
    latitude DECIMAL(10, 8) DEFAULT NULL,
    longitude DECIMAL(11, 8) DEFAULT NULL,
    astro_sign VARCHAR(20) CHECK (astro_sign IN ('aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces') OR astro_sign IS NULL),
    height_cm INTEGER DEFAULT NULL,
    weight_kg INTEGER DEFAULT NULL,
    distance_updated_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    distance INTEGER DEFAULT NULL,
    max_distance INTEGER DEFAULT 80,
    min_age INTEGER DEFAULT 18,
    max_age INTEGER DEFAULT 99,
    CONSTRAINT check_age_range CHECK (min_age <= max_age),
    CONSTRAINT check_valid_latitude CHECK (latitude >= -90 AND latitude <= 90),
    CONSTRAINT check_valid_longitude CHECK (longitude >= -180 AND longitude <= 180),
    CONSTRAINT check_valid_distance CHECK (max_distance > 0 AND max_distance <= 500),
    drinks_level VARCHAR(20) CHECK (drinks_level IN ('no_thank_you', 'i_dont_drink', 'i_drink_socially', 'i_drink_often', 'i_drink_daily') OR drinks_level IS NULL),
    smoke_level VARCHAR(20) CHECK (smoke_level IN ('no_thank_you', 'i_dont_smoke', 'i_smoke_occasionally', 'i_smoke_daily') OR smoke_level IS NULL),
    sport_level VARCHAR(20) CHECK (sport_level IN ('none', 'occasionally', 'regularly', 'intensively') OR sport_level IS NULL),
    looking_for VARCHAR(50) CHECK (looking_for IN ('serious', 'casual', 'friendship', 'chat','community', 'selfDiscovery','networking','polyamory','other') OR looking_for IS NULL),
    is_active BOOLEAN DEFAULT TRUE,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    onboarding_step INTEGER DEFAULT 0,
    onboarding_completed BOOLEAN DEFAULT FALSE
);

-- Profile photos table
CREATE TABLE profile_photos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    photo_url VARCHAR(500) NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    photo_order INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Swipes table (likes/passes)
CREATE TABLE swipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    swiper_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    swiped_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    is_like BOOLEAN NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(swiper_id, swiped_id)
);

-- Matches table
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile1_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    profile2_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    matched_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'notified', 'conversation_started')),
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(profile1_id, profile2_id)
);

-- Messages table
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'gif', 'sticker')),
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Reports table
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    reporter_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    reported_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    reason VARCHAR(100) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Blocks table
CREATE TABLE blocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    blocker_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    blocked_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(blocker_id, blocked_id)
);



-- Create indexes for performance
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_location ON profiles(latitude, longitude);
CREATE INDEX idx_profiles_age_range ON profiles(min_age, max_age);
CREATE INDEX idx_profiles_active ON profiles(is_active) WHERE is_active = true;
CREATE INDEX idx_profiles_deleted ON profiles(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_verified ON users(is_verified) WHERE is_verified = true;
CREATE INDEX idx_users_deleted ON users(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX idx_swipes_swiper_id ON swipes(swiper_id);
CREATE INDEX idx_swipes_swiped_id ON swipes(swiped_id);
CREATE INDEX idx_swipes_composite ON swipes(swiper_id, swiped_id, is_like);
CREATE INDEX idx_matches_profile1_id ON matches(profile1_id);
CREATE INDEX idx_matches_profile2_id ON matches(profile2_id);
CREATE INDEX idx_matches_active ON matches(is_active) WHERE is_active = true;
CREATE INDEX idx_matches_composite ON matches(profile1_id, profile2_id, is_active);
CREATE INDEX idx_messages_match_id ON messages(match_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_messages_unread ON messages(is_read) WHERE is_read = false;
CREATE INDEX idx_blocks_blocker_id ON blocks(blocker_id);
CREATE INDEX idx_blocks_blocked_id ON blocks(blocked_id);
CREATE INDEX idx_blocks_composite ON blocks(blocker_id, blocked_id);
CREATE INDEX idx_profile_photos_profile ON profile_photos(profile_id, is_primary);

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_reports_updated_at BEFORE UPDATE ON reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- User activity tracking table
CREATE TABLE user_activities (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    activity_type VARCHAR(50) NOT NULL CHECK (activity_type IN ('login', 'logout', 'profile_view', 'swipe', 'match', 'message', 'photo_upload', 'profile_update')),
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit log table for tracking changes
CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    table_name VARCHAR(50) NOT NULL,
    record_id VARCHAR(128) NOT NULL,
    operation VARCHAR(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(128) REFERENCES users(id) ON DELETE SET NULL,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('match', 'message', 'like', 'super_like', 'profile_view', 'system')),
    title VARCHAR(255) NOT NULL,
    message TEXT,
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    is_pushed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    read_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- Moderation actions table
CREATE TABLE moderation_actions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    moderator_id VARCHAR(128) REFERENCES users(id) ON DELETE SET NULL,
    target_user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL CHECK (action_type IN ('warn', 'suspend', 'ban', 'unban', 'delete_content', 'approve_content')),
    reason TEXT,
    duration_hours INTEGER,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- User flags/sanctions table
CREATE TABLE user_sanctions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    sanction_type VARCHAR(50) NOT NULL CHECK (sanction_type IN ('warning', 'shadow_ban', 'temp_ban', 'permanent_ban')),
    reason TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    created_by VARCHAR(128) REFERENCES users(id) ON DELETE SET NULL
);

-- Content moderation queue
CREATE TABLE content_moderation (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_type VARCHAR(50) NOT NULL CHECK (content_type IN ('profile', 'photo', 'message', 'report')),
    content_id VARCHAR(128) NOT NULL,
    reported_by VARCHAR(128) REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'escalated')),
    priority VARCHAR(10) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    reason TEXT,
    moderator_notes TEXT,
    reviewed_by VARCHAR(128) REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- Analytics events table
CREATE TABLE analytics_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(128) REFERENCES users(id) ON DELETE SET NULL,
    event_name VARCHAR(100) NOT NULL,
    event_properties JSONB,
    session_id VARCHAR(128),
    device_info JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for new tables
CREATE INDEX idx_user_activities_user_id ON user_activities(user_id);
CREATE INDEX idx_user_activities_type ON user_activities(activity_type);
CREATE INDEX idx_user_activities_created_at ON user_activities(created_at);
CREATE INDEX idx_audit_logs_table_record ON audit_logs(table_name, record_id);
CREATE INDEX idx_audit_logs_changed_at ON audit_logs(changed_at);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(is_read) WHERE is_read = false;
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_moderation_actions_target ON moderation_actions(target_user_id);
CREATE INDEX idx_moderation_actions_moderator ON moderation_actions(moderator_id);
CREATE INDEX idx_user_sanctions_user_id ON user_sanctions(user_id);
CREATE INDEX idx_user_sanctions_active ON user_sanctions(is_active) WHERE is_active = true;
CREATE INDEX idx_content_moderation_status ON content_moderation(status);
CREATE INDEX idx_content_moderation_priority ON content_moderation(priority);
CREATE INDEX idx_analytics_events_user_id ON analytics_events(user_id);
CREATE INDEX idx_analytics_events_name ON analytics_events(event_name);
CREATE INDEX idx_analytics_events_created_at ON analytics_events(created_at);

-- Create function for soft delete
CREATE OR REPLACE FUNCTION soft_delete_user(user_id_param VARCHAR(128))
RETURNS VOID AS $$
BEGIN
    UPDATE users SET deleted_at = NOW() WHERE id = user_id_param;
    UPDATE profiles SET deleted_at = NOW() WHERE user_id = user_id_param;
END;
$$ LANGUAGE plpgsql;

-- Create function to check if user is blocked
CREATE OR REPLACE FUNCTION is_user_blocked(user1_id UUID, user2_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM blocks 
        WHERE (blocker_id = user1_id AND blocked_id = user2_id) 
           OR (blocker_id = user2_id AND blocked_id = user1_id)
    );
END;
$$ LANGUAGE plpgsql;


