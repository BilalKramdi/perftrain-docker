-- Clear existing data
TRUNCATE TABLE swipes, matches, messages, profile_photos, profiles, users CASCADE;


-- Insert 10 comprehensive users
INSERT INTO users (id, email, is_verified)
VALUES 
    ('user_001', 'alice.martin@example.com', true),
    ('user_002', 'bob.dupont@example.com', true),
    ('user_003', 'claire.rousseau@example.com', true),
    ('user_004', 'david.bernard@example.com', true),
    ('user_005', 'emma.lefevre@example.com', true),
    ('user_006', 'felix.moreau@example.com', true),
    ('user_007', 'gabrielle.simon@example.com', true),
    ('user_008', 'hugo.laurent@example.com', true),
    ('user_009', 'isabelle.michel@example.com', true),
    ('user_010', 'julien.garcia@example.com', true);

-- Insert 10 comprehensive profiles
INSERT INTO profiles (
    id, user_id, first_name, bio, date_of_birth, gender, sexual_orientation, 
    interested_in_genders, interests, location_city, location_country, latitude, longitude,
    max_distance, min_age, max_age, drinks_level, smoke_level, looking_for,
    onboarding_completed
)
VALUES
    (
        '11111111-1111-1111-1111-111111111111', 
        'user_001', 
        'Alice', 
        'Passionnée de voyage et de photographie. J''adore découvrir de nouveaux endroits et capturer des moments uniques. Toujours partante pour une nouvelle aventure ! 📸✈️',
        '1995-03-15', 
        'female', 
        'straight', 
        ARRAY['male'], 
        ARRAY['photography', 'travel', 'adventure', 'nature', 'culture'], 
        'Paris', 
        'France', 
        48.8566, 
        2.3522,
        50,
        23,
        35,
        'i_drink_socially',
        'i_dont_smoke',
        'serious',
        true
    ),
    (
        '22222222-2222-2222-2222-222222222222', 
        'user_002', 
        'Bob', 
        'Chef cuisinier passionné. J''aime créer de nouveaux plats et partager de bons moments autour d''un repas. La cuisine est mon langage d''amour ! 👨‍🍳🍝',
        '1992-07-22', 
        'male', 
        'straight', 
        ARRAY['female'], 
        ARRAY['cooking', 'food', 'wine', 'restaurants', 'gastronomy'], 
        'Lyon', 
        'France', 
        45.7640, 
        4.8357,
        80,
        25,
        40,
        'i_drink_often',
        'i_dont_smoke',
        'serious',
        true
    ),
    (
        '33333333-3333-3333-3333-333333333333', 
        'user_003', 
        'Claire', 
        'Artiste peintre et amoureuse de la nature. Je trouve mon inspiration dans les couchers de soleil et les paysages urbains. Créons ensemble de beaux souvenirs ! 🎨🌅',
        '1997-11-08', 
        'female', 
        'bisexual', 
        ARRAY['male', 'female'], 
        ARRAY['art', 'painting', 'nature', 'sunsets', 'creativity'], 
        'Marseille', 
        'France', 
        43.2965, 
        5.3698,
        60,
        22,
        32,
        'i_drink_socially',
        'i_smoke_occasionally',
        'casual',
        true
    ),
    (
        '44444444-4444-4444-4444-444444444444', 
        'user_004', 
        'David', 
        'Développeur passionné de technologie et amateur de jeux vidéo. Quand je ne code pas, je lis ou je fais du sport. Toujours curieux d''apprendre ! 💻🎮',
        '1990-05-03', 
        'male', 
        'straight', 
        ARRAY['female'], 
        ARRAY['technology', 'gaming', 'programming', 'reading', 'sports'], 
        'Toulouse', 
        'France', 
        43.6047, 
        1.4442,
        100,
        24,
        35,
        'i_dont_drink',
        'i_dont_smoke',
        'friendship',
        true
    ),
    (
        '55555555-5555-5555-5555-555555555555', 
        'user_005', 
        'Emma', 
        'Professeure de yoga et danseuse. Je crois au pouvoir de la méditation et du mouvement pour transformer nos vies. Zen attitude ! 🧘‍♀️💃',
        '1994-09-18', 
        'female', 
        'straight', 
        ARRAY['male'], 
        ARRAY['yoga', 'meditation', 'dance', 'wellness', 'spirituality'], 
        'Nice', 
        'France', 
        43.7102, 
        7.2620,
        70,
        26,
        38,
        'i_dont_drink',
        'i_dont_smoke',
        'serious',
        true
    ),
    (
        '66666666-6666-6666-6666-666666666666', 
        'user_006', 
        'Félix', 
        'Musicien et producteur de musique électronique. Je compose dans mon home studio et j''adore les festivals. La musique connecte les âmes ! 🎧🎵',
        '1993-12-10', 
        'male', 
        'straight', 
        ARRAY['female'], 
        ARRAY['music', 'electronic', 'festivals', 'production', 'dj'], 
        'Bordeaux', 
        'France', 
        44.8378, 
        -0.5792,
        120,
        22,
        35,
        'i_drink_often',
        'i_dont_smoke',
        'casual',
        true
    ),
    (
        '77777777-7777-7777-7777-777777777777', 
        'user_007', 
        'Gabrielle', 
        'Architecte passionnée par le design durable. Je rêve de créer des espaces qui respectent l''environnement. Construisons un avenir plus vert ! 🏗️🌱',
        '1991-06-25', 
        'female', 
        'bisexual', 
        ARRAY['male', 'female'], 
        ARRAY['architecture', 'sustainability', 'design', 'environment', 'green'], 
        'Nantes', 
        'France', 
        47.2184, 
        -1.5536,
        90,
        25,
        40,
        'i_drink_socially',
        'i_dont_smoke',
        'serious',
        true
    ),
    (
        '88888888-8888-8888-8888-888888888888', 
        'user_008', 
        'Hugo', 
        'Vétérinaire et amoureux des animaux. Entre les consultations, je fais de la randonnée avec mon chien. Les animaux sont ma passion ! 🐕‍🦺🏔️',
        '1989-04-17', 
        'male', 
        'gay', 
        ARRAY['male'], 
        ARRAY['animals', 'veterinary', 'hiking', 'dogs', 'nature'], 
        'Strasbourg', 
        'France', 
        48.5734, 
        7.7521,
        60,
        25,
        45,
        'i_dont_drink',
        'i_dont_smoke',
        'serious',
        true
    ),
    (
        '99999999-9999-9999-9999-999999999999', 
        'user_009', 
        'Isabelle', 
        'Journaliste freelance et globe-trotteuse. J''écris sur les cultures du monde et j''adore raconter des histoires. Chaque rencontre est une aventure ! ✍️🌍',
        '1996-01-30', 
        'female', 
        'straight', 
        ARRAY['male'], 
        ARRAY['journalism', 'writing', 'travel', 'culture', 'storytelling'], 
        'Lille', 
        'France', 
        50.6292, 
        3.0573,
        80,
        24,
        38,
        'i_drink_socially',
        'i_smoke_occasionally',
        'casual',
        true
    ),
    (
        'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 
        'user_010', 
        'Julien', 
        'Kinésithérapeute et passionné de sport. Je pratique l''escalade et le surf. J''aime aider les gens à retrouver leur bien-être physique ! 🧗‍♂️🏄‍♂️',
        '1988-08-14', 
        'male', 
        'straight', 
        ARRAY['female'], 
        ARRAY['physiotherapy', 'climbing', 'surfing', 'sports', 'wellness'], 
        'Montpellier', 
        'France', 
        43.6108, 
        3.8767,
        70,
        26,
        42,
        'i_drink_socially',
        'i_dont_smoke',
        'friendship',
        true
    );

-- Insert multiple profile photos for each user
INSERT INTO profile_photos (profile_id, photo_url, is_primary, photo_order)
VALUES
    -- Alice's photos
    ('11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1494790108755-2616b612b829', true, 1),
    ('11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1', false, 2),
    ('11111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0', false, 3),
    
    -- Bob's photos
    ('22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d', true, 1),
    ('22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64', false, 2),
    ('22222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136', false, 3),
    
    -- Claire's photos
    ('33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80', true, 1),
    ('33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e', false, 2),
    ('33333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1506863530036-1efeddceb993', false, 3),
    
    -- David's photos
    ('44444444-4444-4444-4444-444444444444', 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e', true, 1),
    ('44444444-4444-4444-4444-444444444444', 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7', false, 2),
    
    -- Emma's photos
    ('55555555-5555-5555-5555-555555555555', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2', true, 1),
    ('55555555-5555-5555-5555-555555555555', 'https://images.unsplash.com/photo-1517841905240-472988babdf9', false, 2),
    ('55555555-5555-5555-5555-555555555555', 'https://images.unsplash.com/photo-1502823403499-6ccfcf4fb453', false, 3),
    
    -- Félix's photos
    ('66666666-6666-6666-6666-666666666666', 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e', true, 1),
    ('66666666-6666-6666-6666-666666666666', 'https://images.unsplash.com/photo-1493666438817-866a91353ca9', false, 2),
    ('66666666-6666-6666-6666-666666666666', 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b', false, 3),
    
    -- Gabrielle's photos
    ('77777777-7777-7777-7777-777777777777', 'https://images.unsplash.com/photo-1531123897727-8f129e1688ce', true, 1),
    ('77777777-7777-7777-7777-777777777777', 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f', false, 2),
    ('77777777-7777-7777-7777-777777777777', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb', false, 3),
    
    -- Hugo's photos
    ('88888888-8888-8888-8888-888888888888', 'https://images.unsplash.com/photo-1463453091185-61582044d556', true, 1),
    ('88888888-8888-8888-8888-888888888888', 'https://images.unsplash.com/photo-1542909168-82c3e7fdca5c', false, 2),
    
    -- Isabelle's photos
    ('99999999-9999-9999-9999-999999999999', 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91', true, 1),
    ('99999999-9999-9999-9999-999999999999', 'https://images.unsplash.com/photo-1525134479668-1bee5c7c6845', false, 2),
    ('99999999-9999-9999-9999-999999999999', 'https://images.unsplash.com/photo-1489424731084-a5d8b219a5bb', false, 3),
    
    -- Julien's photos
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d', true, 1),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1552058544-f2b08422138a', false, 2),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e', false, 3);




-- Insert various swipes to create realistic interactions
INSERT INTO swipes (swiper_id, swiped_id, is_like)
VALUES
    -- Alice likes Bob, Félix and passes on David
    ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', true),
    ('11111111-1111-1111-1111-111111111111', '66666666-6666-6666-6666-666666666666', true),
    ('11111111-1111-1111-1111-111111111111', '44444444-4444-4444-4444-444444444444', false),
    
    -- Bob likes Alice, Emma and passes on Claire
    ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', true),
    ('22222222-2222-2222-2222-222222222222', '55555555-5555-5555-5555-555555555555', true),
    ('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333', false),
    
    -- Claire likes Gabrielle and David
    ('33333333-3333-3333-3333-333333333333', '77777777-7777-7777-7777-777777777777', true),
    ('33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', true),
    
    -- David likes Claire and Isabelle
    ('44444444-4444-4444-4444-444444444444', '33333333-3333-3333-3333-333333333333', true),
    ('44444444-4444-4444-4444-444444444444', '99999999-9999-9999-9999-999999999999', true),
    
    -- Emma likes Bob and Julien  
    ('55555555-5555-5555-5555-555555555555', '22222222-2222-2222-2222-222222222222', true),
    ('55555555-5555-5555-5555-555555555555', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', true),
    
    -- Félix likes Alice and Gabrielle
    ('66666666-6666-6666-6666-666666666666', '11111111-1111-1111-1111-111111111111', true),
    ('66666666-6666-6666-6666-666666666666', '77777777-7777-7777-7777-777777777777', true),
    
    -- Gabrielle likes Claire, Félix and Isabelle
    ('77777777-7777-7777-7777-777777777777', '33333333-3333-3333-3333-333333333333', true),
    ('77777777-7777-7777-7777-777777777777', '66666666-6666-6666-6666-666666666666', true),
    ('77777777-7777-7777-7777-777777777777', '99999999-9999-9999-9999-999999999999', true),
    
    -- Hugo likes other male profiles
    ('88888888-8888-8888-8888-888888888888', '22222222-2222-2222-2222-222222222222', true),
    ('88888888-8888-8888-8888-888888888888', '66666666-6666-6666-6666-666666666666', true),
    
    -- Isabelle likes David and Gabrielle
    ('99999999-9999-9999-9999-999999999999', '44444444-4444-4444-4444-444444444444', true),
    ('99999999-9999-9999-9999-999999999999', '77777777-7777-7777-7777-777777777777', true),
    
    -- Julien likes Emma and Alice
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '55555555-5555-5555-5555-555555555555', true),
    ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', '11111111-1111-1111-1111-111111111111', false);

-- Insert matches based on mutual likes
INSERT INTO matches (profile1_id, profile2_id)
VALUES 
    ('11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222'),
    ('11111111-1111-1111-1111-111111111111', '66666666-6666-6666-6666-666666666666'),
    ('22222222-2222-2222-2222-222222222222', '55555555-5555-5555-5555-555555555555'),
    ('33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444'),
    ('33333333-3333-3333-3333-333333333333', '77777777-7777-7777-7777-777777777777'),
    ('44444444-4444-4444-4444-444444444444', '99999999-9999-9999-9999-999999999999'),
    ('55555555-5555-5555-5555-555555555555', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'),
    ('66666666-6666-6666-6666-666666666666', '77777777-7777-7777-7777-777777777777'),
    ('77777777-7777-7777-7777-777777777777', '99999999-9999-9999-9999-999999999999');

-- Insert realistic conversation messages
INSERT INTO messages (match_id, sender_id, content)
SELECT m.id, '11111111-1111-1111-1111-111111111111', 'Salut Bob ! J''ai vu que tu es chef, ça doit être passionnant ! 👨‍🍳'
FROM matches m WHERE m.profile1_id = '11111111-1111-1111-1111-111111111111' AND m.profile2_id = '22222222-2222-2222-2222-222222222222';

INSERT INTO messages (match_id, sender_id, content)
SELECT m.id, '22222222-2222-2222-2222-222222222222', 'Salut Alice ! Oui j''adore ça, et toi la photographie c''est ton métier ou ta passion ?'
FROM matches m WHERE m.profile1_id = '11111111-1111-1111-1111-111111111111' AND m.profile2_id = '22222222-2222-2222-2222-222222222222';

INSERT INTO messages (match_id, sender_id, content)
SELECT m.id, '11111111-1111-1111-1111-111111111111', 'C''est ma passion ! J''aimerais beaucoup photographier tes créations culinaires un jour 📸'
FROM matches m WHERE m.profile1_id = '11111111-1111-1111-1111-111111111111' AND m.profile2_id = '22222222-2222-2222-2222-222222222222';

INSERT INTO messages (match_id, sender_id, content)
SELECT m.id, '66666666-6666-6666-6666-666666666666', 'Salut Alice ! J''ai vu qu''on avait match, j''adore ton style photo ! 🎵📸'
FROM matches m WHERE m.profile1_id = '11111111-1111-1111-1111-111111111111' AND m.profile2_id = '66666666-6666-6666-6666-666666666666';

INSERT INTO messages (match_id, sender_id, content)
SELECT m.id, '22222222-2222-2222-2222-222222222222', 'Salut Emma ! Ton profil yoga m''intrigue, tu donnes des cours ?'
FROM matches m WHERE m.profile1_id = '22222222-2222-2222-2222-222222222222' AND m.profile2_id = '55555555-5555-5555-5555-555555555555';

INSERT INTO messages (match_id, sender_id, content)
SELECT m.id, '55555555-5555-5555-5555-555555555555', 'Salut Bob ! Oui je donne des cours à Nice, et toi tu cuisines végétarien parfois ? 🧘‍♀️'
FROM matches m WHERE m.profile1_id = '22222222-2222-2222-2222-222222222222' AND m.profile2_id = '55555555-5555-5555-5555-555555555555';

INSERT INTO messages (match_id, sender_id, content)
SELECT m.id, '77777777-7777-7777-7777-777777777777', 'Coucou Claire ! Ton art m''inspire beaucoup, tu exposes tes œuvres quelque part ? 🎨'
FROM matches m WHERE m.profile1_id = '33333333-3333-3333-3333-333333333333' AND m.profile2_id = '77777777-7777-7777-7777-777777777777';

INSERT INTO messages (match_id, sender_id, content)
SELECT m.id, '44444444-4444-4444-4444-444444444444', 'Salut Isabelle ! Journaliste c''est fascinant, tu écris sur quoi en ce moment ?'
FROM matches m WHERE m.profile1_id = '44444444-4444-4444-4444-444444444444' AND m.profile2_id = '99999999-9999-9999-9999-999999999999';

-- Done
SELECT 'Complete seed with 10 detailed users executed successfully' AS status;
