
-- =================================================================
-- Script de restauración PostgreSQL
-- Base de datos: accommodations_tourism
-- Extraído del dump binario (custom format v1.16, PG 18.3)
-- Compatible con PostgreSQL 14+
-- =================================================================

-- INSTRUCCIONES:
-- psql -U postgres -c "CREATE DATABASE accommodations_tourism
--   WITH TEMPLATE=template0 ENCODING='UTF8'
--   LOCALE_PROVIDER=libc LOCALE='en_US.UTF-8';"
-- psql -U postgres -d accommodations_tourism -f accommodation_database_restore.sql

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET search_path TO public;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

-- ----------------------------------------------------------------
-- 1. SCHEMA
-- ----------------------------------------------------------------

-- ----------------------------------------------------------------
-- 2. FUNCIONES
-- ----------------------------------------------------------------

CREATE FUNCTION set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- ----------------------------------------------------------------
-- 3. SECUENCIAS
-- ----------------------------------------------------------------

CREATE SEQUENCE accommodation_types_accommodation_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE accommodations_accommodation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE amenities_amenity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE booking_guests_booking_guest_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE booking_statuses_booking_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE bookings_booking_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE guests_guest_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE locations_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE owners_owner_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE reviews_review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE rooms_room_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE staff_users_staff_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- ----------------------------------------------------------------
-- 4. TABLAS
-- ----------------------------------------------------------------

CREATE TABLE accommodation_amenities (
    accommodation_id bigint NOT NULL,
    amenity_id integer NOT NULL
);

CREATE TABLE accommodation_types (
    accommodation_type_id integer NOT NULL,
    type_name character varying(50) NOT NULL,
    description text
);

CREATE TABLE accommodations (
    accommodation_id bigint NOT NULL,
    owner_id bigint NOT NULL,
    accommodation_type_id integer NOT NULL,
    location_id bigint NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    max_guests integer NOT NULL,
    bedroom_count integer DEFAULT 1 NOT NULL,
    bathroom_count integer DEFAULT 1 NOT NULL,
    base_price_per_night numeric(10,2) NOT NULL,
    currency_code character(3) DEFAULT 'USD'::bpchar NOT NULL,
    check_in_time time without time zone,
    check_out_time time without time zone,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT accommodations_base_price_per_night_check CHECK ((base_price_per_night >= (0)::numeric)),
    CONSTRAINT accommodations_bathroom_count_check CHECK ((bathroom_count >= 0)),
    CONSTRAINT accommodations_bedroom_count_check CHECK ((bedroom_count >= 0)),
    CONSTRAINT accommodations_max_guests_check CHECK ((max_guests > 0))
);

CREATE TABLE amenities (
    amenity_id integer NOT NULL,
    amenity_name character varying(100) NOT NULL,
    description text
);

CREATE TABLE booking_guests (
    booking_guest_id bigint NOT NULL,
    booking_id bigint NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    age integer,
    document_number character varying(50),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT booking_guests_age_check CHECK ((age >= 0))
);

CREATE TABLE booking_statuses (
    booking_status_id integer NOT NULL,
    status_name character varying(50) NOT NULL,
    description text
);

CREATE TABLE bookings (
    booking_id bigint NOT NULL,
    guest_id bigint NOT NULL,
    accommodation_id bigint NOT NULL,
    room_id bigint,
    booking_status_id integer NOT NULL,
    check_in_date date NOT NULL,
    check_out_date date NOT NULL,
    adult_count integer DEFAULT 1 NOT NULL,
    child_count integer DEFAULT 0 NOT NULL,
    total_nights integer GENERATED ALWAYS AS ((check_out_date - check_in_date)) STORED,
    subtotal_amount numeric(10,2) NOT NULL,
    tax_amount numeric(10,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(10,2) DEFAULT 0 NOT NULL,
    total_amount numeric(10,2) NOT NULL,
    special_requests text,
    booking_reference character varying(50) NOT NULL,
    booked_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT bookings_adult_count_check CHECK ((adult_count >= 1)),
    CONSTRAINT bookings_child_count_check CHECK ((child_count >= 0)),
    CONSTRAINT bookings_discount_amount_check CHECK ((discount_amount >= (0)::numeric)),
    CONSTRAINT bookings_subtotal_amount_check CHECK ((subtotal_amount >= (0)::numeric)),
    CONSTRAINT bookings_tax_amount_check CHECK ((tax_amount >= (0)::numeric)),
    CONSTRAINT bookings_total_amount_check CHECK ((total_amount >= (0)::numeric)),
    CONSTRAINT chk_booking_dates CHECK ((check_out_date > check_in_date))
);

CREATE TABLE guests (
    guest_id bigint NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    phone character varying(30),
    date_of_birth date,
    nationality character varying(100),
    passport_number character varying(50),
    emergency_contact_name character varying(150),
    emergency_contact_phone character varying(30),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE locations (
    location_id bigint NOT NULL,
    country character varying(100) NOT NULL,
    state character varying(100),
    city character varying(100) NOT NULL,
    district character varying(100),
    address_line1 character varying(150) NOT NULL,
    address_line2 character varying(150),
    postal_code character varying(20),
    latitude numeric(9,6),
    longitude numeric(9,6),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE owners (
    owner_id bigint NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    company_name character varying(150),
    email character varying(150) NOT NULL,
    phone character varying(30),
    tax_id character varying(50),
    address_line1 character varying(150),
    address_line2 character varying(150),
    city character varying(100),
    state character varying(100),
    country character varying(100),
    postal_code character varying(20),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE payments (
    payment_id bigint NOT NULL,
    booking_id bigint NOT NULL,
    payment_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    amount numeric(10,2) NOT NULL,
    payment_method character varying(50) NOT NULL,
    payment_status character varying(50) NOT NULL,
    transaction_reference character varying(100),
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT payments_amount_check CHECK ((amount >= (0)::numeric))
);

CREATE TABLE reviews (
    review_id bigint NOT NULL,
    booking_id bigint NOT NULL,
    guest_id bigint NOT NULL,
    accommodation_id bigint NOT NULL,
    rating integer NOT NULL,
    review_title character varying(150),
    review_text text,
    review_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT reviews_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);

CREATE TABLE rooms (
    room_id bigint NOT NULL,
    accommodation_id bigint NOT NULL,
    room_name character varying(100) NOT NULL,
    room_code character varying(50),
    floor_number integer,
    capacity integer NOT NULL,
    bed_count integer DEFAULT 1 NOT NULL,
    room_price_per_night numeric(10,2),
    is_available boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT rooms_bed_count_check CHECK ((bed_count >= 0)),
    CONSTRAINT rooms_capacity_check CHECK ((capacity > 0)),
    CONSTRAINT rooms_room_price_per_night_check CHECK ((room_price_per_night >= (0)::numeric))
);

CREATE TABLE staff_users (
    staff_user_id bigint NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    password_hash text NOT NULL,
    role_name character varying(50) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- ----------------------------------------------------------------
-- 5. DEFAULTS DE SECUENCIA
-- ----------------------------------------------------------------

ALTER TABLE ONLY accommodation_types ALTER COLUMN accommodation_type_id SET DEFAULT nextval('accommodation_types_accommodation_type_id_seq'::regclass);

ALTER TABLE ONLY accommodations ALTER COLUMN accommodation_id SET DEFAULT nextval('accommodations_accommodation_id_seq'::regclass);

ALTER TABLE ONLY amenities ALTER COLUMN amenity_id SET DEFAULT nextval('amenities_amenity_id_seq'::regclass);

ALTER TABLE ONLY booking_guests ALTER COLUMN booking_guest_id SET DEFAULT nextval('booking_guests_booking_guest_id_seq'::regclass);

ALTER TABLE ONLY booking_statuses ALTER COLUMN booking_status_id SET DEFAULT nextval('booking_statuses_booking_status_id_seq'::regclass);

ALTER TABLE ONLY bookings ALTER COLUMN booking_id SET DEFAULT nextval('bookings_booking_id_seq'::regclass);

ALTER TABLE ONLY guests ALTER COLUMN guest_id SET DEFAULT nextval('guests_guest_id_seq'::regclass);

ALTER TABLE ONLY locations ALTER COLUMN location_id SET DEFAULT nextval('locations_location_id_seq'::regclass);

ALTER TABLE ONLY owners ALTER COLUMN owner_id SET DEFAULT nextval('owners_owner_id_seq'::regclass);

ALTER TABLE ONLY payments ALTER COLUMN payment_id SET DEFAULT nextval('payments_payment_id_seq'::regclass);

ALTER TABLE ONLY reviews ALTER COLUMN review_id SET DEFAULT nextval('reviews_review_id_seq'::regclass);

ALTER TABLE ONLY rooms ALTER COLUMN room_id SET DEFAULT nextval('rooms_room_id_seq'::regclass);

ALTER TABLE ONLY staff_users ALTER COLUMN staff_user_id SET DEFAULT nextval('staff_users_staff_user_id_seq'::regclass);

-- ----------------------------------------------------------------
-- 6. SECUENCIAS OWNED BY
-- ----------------------------------------------------------------

ALTER SEQUENCE accommodation_types_accommodation_type_id_seq OWNED BY accommodation_types.accommodation_type_id;

ALTER SEQUENCE accommodations_accommodation_id_seq OWNED BY accommodations.accommodation_id;

ALTER SEQUENCE amenities_amenity_id_seq OWNED BY amenities.amenity_id;

ALTER SEQUENCE booking_guests_booking_guest_id_seq OWNED BY booking_guests.booking_guest_id;

ALTER SEQUENCE booking_statuses_booking_status_id_seq OWNED BY booking_statuses.booking_status_id;

ALTER SEQUENCE bookings_booking_id_seq OWNED BY bookings.booking_id;

ALTER SEQUENCE guests_guest_id_seq OWNED BY guests.guest_id;

ALTER SEQUENCE locations_location_id_seq OWNED BY locations.location_id;

ALTER SEQUENCE owners_owner_id_seq OWNED BY owners.owner_id;

ALTER SEQUENCE payments_payment_id_seq OWNED BY payments.payment_id;

ALTER SEQUENCE reviews_review_id_seq OWNED BY reviews.review_id;

ALTER SEQUENCE rooms_room_id_seq OWNED BY rooms.room_id;

ALTER SEQUENCE staff_users_staff_user_id_seq OWNED BY staff_users.staff_user_id;

-- ----------------------------------------------------------------
-- 7. DATOS
-- ----------------------------------------------------------------

-- accommodation_types
-- Data for accommodation_types
INSERT INTO accommodation_types (accommodation_type_id, type_name, description) VALUES ('1', 'Hotel', 'Traditional hotel accommodation');
INSERT INTO accommodation_types (accommodation_type_id, type_name, description) VALUES ('2', 'Hostel', 'Shared budget accommodation');
INSERT INTO accommodation_types (accommodation_type_id, type_name, description) VALUES ('3', 'Apartment', 'Private apartment for short stays');
INSERT INTO accommodation_types (accommodation_type_id, type_name, description) VALUES ('4', 'House', 'Entire residential house');
INSERT INTO accommodation_types (accommodation_type_id, type_name, description) VALUES ('5', 'Villa', 'Luxury private villa');
INSERT INTO accommodation_types (accommodation_type_id, type_name, description) VALUES ('6', 'Cabin', 'Small rural or nature-based lodging');
INSERT INTO accommodation_types (accommodation_type_id, type_name, description) VALUES ('7', 'Resort', 'Full-service vacation resort');
INSERT INTO accommodation_types (accommodation_type_id, type_name, description) VALUES ('8', 'Guesthouse', 'Small privately owned lodging');


-- amenities
-- Data for amenities
INSERT INTO amenities (amenity_id, amenity_name, description) VALUES ('1', 'WiFi', 'Wireless internet access');
INSERT INTO amenities (amenity_id, amenity_name, description) VALUES ('2', 'Pool', 'Swimming pool');
INSERT INTO amenities (amenity_id, amenity_name, description) VALUES ('3', 'Parking', 'Private or public parking');
INSERT INTO amenities (amenity_id, amenity_name, description) VALUES ('4', 'AirConditioning', 'Air conditioning system');
INSERT INTO amenities (amenity_id, amenity_name, description) VALUES ('5', 'Kitchen', 'Cooking facilities');
INSERT INTO amenities (amenity_id, amenity_name, description) VALUES ('6', 'Breakfast', 'Breakfast included');
INSERT INTO amenities (amenity_id, amenity_name, description) VALUES ('7', 'PetFriendly', 'Pets are allowed');
INSERT INTO amenities (amenity_id, amenity_name, description) VALUES ('8', 'Gym', 'Fitness center');
INSERT INTO amenities (amenity_id, amenity_name, description) VALUES ('9', 'Spa', 'Spa and wellness services');
INSERT INTO amenities (amenity_id, amenity_name, description) VALUES ('10', 'BeachAccess', 'Direct beach access');


-- owners
-- Data for owners
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('1', 'Angel', 'Hierro', 'Laboratorios Canales-Trejo', 'fjohnson@example.org', '908-386-3794x0265', 'wM-23511615', 'Paseo de Edelmiro Pinedo 9', NULL, 'Ourense', 'Coahuila de Zaragoza', 'Panama', '13164-7525', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('2', 'Hugo', 'Bellido', NULL, 'antoinettevollbrecht@example.org', '1-648-350-3056x413', 'pV-53767242', 'Säuberlichstraße 93/82', NULL, 'Port Danielburgh', 'Berlin', 'Irak', '84801', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('3', 'Karolina', 'Nieto', 'Graham-Chavez', 'anunciacioncamino@example.net', '+34982 932 528', 'pd-09570154', 'Peatonal Barrientos 227 Edif. 824 , Depto. 896', 'Apt. 465', 'SauvageBourg', 'México', 'Guadeloupe', '77611', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('4', 'Hermann-Josef', 'Hartmann', 'Zimmerman Inc', 'aparicioalma@example.org', '+49(0) 473829973', 'DU-63116566', '65133 Amanda Dam', NULL, 'Lopes', 'Mecklenburg-Vorpommern', 'Kenya', '08013', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('5', 'Cristina', 'Leduc', 'Bahena, de Anda y Ojeda', 'ybaker@example.com', '+34 949872343', 'GH-98050097', 'Callejón Barrientos 136 Edif. 193 , Depto. 990', NULL, 'Lüdenscheid', 'Córdoba', 'Suriname', '16642', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('6', 'Ruy', 'Macías', NULL, 'odette10@example.com', '(01183) 842513', 'QJ-42784980', 'Callejón David Campo 524', NULL, 'Weißenfels', 'Castellón', 'Pakistán', '32966', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('7', 'Christopher', 'Baron', NULL, 'cookdavid@example.com', '786.801.1280x59826', 'wX-04505331', 'Stephanie-Hellwig-Platz 360', NULL, 'Zaragoza', 'Nayarit', 'Túnez', '50641', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('8', 'Michele', 'Feliciano', 'Schneider', 'alvaroespinoza@example.com', '+34886 145 868', 'MB-01429401', 'Pasadizo de David Plaza 134 Puerta 6 ', NULL, 'West Ryan', 'Salamanca', 'Suecia', '94840', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('9', 'Anunciación', 'Real', NULL, 'jmarques@example.org', '(629)946-8044x369', 'Qf-57773872', 'Urbanización Hortensia Menéndez 33 Apt. 03 ', NULL, 'Lecoq-sur-Legrand', 'Sachsen-Anhalt', 'Dänemark', '63509', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('10', 'Ignacio', 'Stafford', 'Robinson-Brock', 'jbinner@example.org', '927.488.9579x868', 'Ce-74348734', 'Alameda de Miguel Berrocal 42', NULL, 'Munoz', 'Coahuila de Zaragoza', 'Japon', '36560', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('11', 'Arnaude', 'Clark', 'Pires', 'wielochchristine@example.com', '+33 (0)4 89 46 68 89', 'QR-73467065', '37, boulevard de Michel', '901 Edif. 627 , Depto. 204', 'Lecomte', 'Rheinland-Pfalz', 'Letonia', '50283', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('12', 'Philippe', 'Ruiz', NULL, 'killerhelmut@example.net', '001-900-633-0923x27193', 'bt-29912419', 'Trubinplatz 49', NULL, 'Melissaville', 'Minnesota', 'Kuwait', '05519', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('13', 'Friedericke', 'Alberola', 'Gautier', 'luce72@example.com', '849.877.6945x31473', 'Fn-99650752', 'Callejón de Silvia Llorente 408 Apt. 36 ', NULL, 'Thierry-sur-Mer', 'Thüringen', 'Swaziland', '12697', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('14', 'Ismael', 'Jacquot', NULL, 'victoria95@example.com', '05685 57444', 'VE-13518233', 'Glorieta Manu Gordillo 52 Apt. 82 ', NULL, 'Almería', 'Tarragona', 'Singapur', '14993', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('15', 'Audrey', 'Voisin', 'Gonzalez', 'shelley71@example.org', '02 21 90 22 94', 'XH-31869993', '74, boulevard Laure Lopez', 'Puerta 1', 'Vieja Suecia', 'Hawaii', 'Cuba', '20679', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('16', 'Stéphane', 'Hall', 'Calisto Guillen Lamas S.L.', 'silviodrewes@example.net', '242-102-4994x71746', 'Vu-88771906', 'Dirk-Hein-Allee 4', 'Apt. 27', 'Görlitz', 'Tamaulipas', 'Benin', '44518', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('17', 'Miguel Ángel', 'Hodge', 'Valbuena y Maldonado S.L.', 'de-sousaemmanuel@example.com', '+34 921168087', 'nr-03859770', 'Mangoldweg 41-30', '086 Edif. 131 , Depto. 712', 'Grégoire', 'La Rioja', 'Luxembourg', '82639-8214', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('18', 'Zacharie', 'Hethur', NULL, 'jessica99@example.net', '+33 6 08 75 58 86', 'uV-53396360', '36, rue Gilbert Gaudin', NULL, 'Burgdorf', 'Brandenburg', 'Vereinigte Arabische Emirate', '02839', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('19', 'Cynthia', 'Benavídez', 'Maillot', 'fseip@example.com', '0578091343', 'uY-61172400', '5623 Knight Turnpike Apt. 221', 'Piso 9', 'San Nancy de la Montaña', 'Veracruz de Ignacio de la Llave', 'Montenegro', '44702', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO owners (owner_id, first_name, last_name, company_name, email, phone, tax_id, address_line1, address_line2, city, state, country, postal_code, created_at, updated_at) VALUES ('20', 'Rachel', 'Hervé', 'Briemer GmbH & Co. KG', 'feliciana64@example.com', '+34872 67 13 69', 'RX-94406409', '3953 Christine Springs Apt. 104', NULL, 'Sainte Nath', 'Colima', 'Islandia', '22305', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');


-- locations
-- Data for locations
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('1', 'Reino Unido de Gran Bretaña e Irlanda del Norte', 'Melilla', 'Eckernförde', 'Ville', 'Pasaje Carlos Chico 96 Piso 1 ', NULL, '02370', '-56.824402', '17.882919', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('2', 'República Popular Democrática de Corea', 'Saarland', 'South Angel', NULL, 'Friedericke-Bolnbach-Allee 24-36', NULL, '05378', '42.237914', '-127.820442', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('3', 'Qatar', 'Sinaloa', 'Leconte', NULL, 'Reinhilde-Liebelt-Allee 77', NULL, '03144', '-31.677114', '58.744268', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('4', 'Kenya', 'Utah', 'Almería', NULL, '81, rue Clerc', NULL, '05329', '-71.582603', '-68.783234', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('5', 'Fidschi', 'Querétaro', 'Vieja Chipre', 'los altos', 'Plaza Eleuterio Alcolea 63', NULL, '23339', '-75.934245', '46.001479', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('6', 'Botsuana', 'New Mexico', 'Blanchet', NULL, 'Paffrathplatz 8', NULL, '31018', '-73.672306', '35.616622', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('7', 'Rwanda', 'New York', 'Saint Tristan-les-Bains', NULL, '9985 Vang Pines', '896 Interior 118', '73657-6615', '-6.107593', '20.951329', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('8', 'Timor-Leste', 'Berlin', 'North Ryanstad', 'los altos', '165 Parrish Stravenue Apt. 494', '983 273', '46391', '8.666418', '-30.444829', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('9', 'Frankreich', 'Baden-Württemberg', 'Augsburg', NULL, 'Continuación Quintana Roo 229 612', 'Puerta 0', '98295', '-32.250707', '45.395852', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('10', 'Géorgie', 'San Luis Potosí', 'Vizcaya', NULL, 'Gerold-Franke-Weg 1', NULL, '30039', '40.368822', '57.320664', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('11', 'Finlande', 'Chihuahua', 'Baleares', 'Ville', 'Heinz-Werner-Kroker-Weg 0', 'Suite 324', '22503', '-87.925020', '51.206151', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('12', 'Canadá', 'Mecklenburg-Vorpommern', 'Bernburg', 'Ville', 'rue Thomas Bruneau', '664 Edif. 160 , Depto. 529', '88470', '27.228926', '-49.370463', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('13', 'Niue', 'Berlin', 'Vallet', 'Ville', 'Pasadizo Evita Carbonell 683', '231 Edif. 243 , Depto. 292', '23719', '34.541454', '131.099561', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('14', 'Russie', 'Santa Cruz de Tenerife', 'León', NULL, '4490 Romero Inlet Suite 700', NULL, '19813', '83.051337', '150.180112', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('15', 'Mauritius', 'Schleswig-Holstein', 'Meppen', NULL, 'Schleichstraße 207', NULL, '47813', '45.438842', '-158.985730', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('16', 'Turquía', 'Schleswig-Holstein', 'Kassel', NULL, 'Ronda de Matilde Neira 205 Piso 1 ', 'Puerta 6', '17514', '-49.634468', '-136.243956', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('17', 'Republik Moldau', 'Quintana Roo', 'Barcelona', 'Ville', 'Vial de Herminia Zurita 7 Puerta 5 ', NULL, '48027', '-41.611042', '3.466155', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('18', 'Corée du Nord', 'Distrito Federal', 'Vieja Brasil', 'Ville', 'Vial de Fermín Escrivá 127', NULL, '46792', '29.238683', '-27.030483', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('19', 'El Salvador', 'Oaxaca', 'Tessier', 'Ville', '98, rue Thérèse Bourgeois', NULL, '40758', '48.488371', '-26.957958', '2026-04-15 01:23:25.356206');
INSERT INTO locations (location_id, country, state, city, district, address_line1, address_line2, postal_code, latitude, longitude, created_at) VALUES ('20', 'Serbia', 'Nayarit', 'Caronnec', NULL, '5060 Shaw Freeway', NULL, '11483', '-82.433464', '-126.805153', '2026-04-15 01:23:25.356206');


-- accommodations
-- Data for accommodations
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('1', '9', '7', '19', 'Rustic Lodge Ville', 'Asimismo mes principios peso joven.', '4', '2', '4', '354.37', 'USD', '12:00:00', '10:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('2', '14', '2', '13', 'Rustic Hideaway Ville', 'Democratic change vote participant institution.', '9', '3', '1', '129.59', 'USD', '16:00:00', '11:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('3', '10', '7', '6', 'Boutique Retreat Ville', 'Eran buenos natural. General victoria rey su.', '12', '6', '3', '230.50', 'BRL', '13:00:00', '12:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('4', '10', '4', '5', 'Modern Escape Ville', 'La m civil he existencia recursos. Donde próximo sociales vuelve palabra niños.', '9', '5', '1', '527.49', 'BRL', '14:00:00', '11:00:00', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('5', '10', '4', '2', 'Panoramic Stay Ville', 'Quinze exiger auquel déposer personne. Rejoindre puissant escalier approcher. Est patron sauvage politique visage je confier.', '2', '6', '4', '560.30', 'USD', '16:00:00', '10:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('6', '18', '3', '9', 'Rustic Getaway de la Montaña', 'Couper respect soutenir enfoncer encore.', '9', '6', '2', '306.16', 'MXN', '15:00:00', '12:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('7', '17', '8', '4', 'Panoramic Getaway dan', 'María pregunta hasta siete esos.', '2', '3', '1', '285.34', 'BRL', '16:00:00', '10:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('8', '2', '4', '3', 'Cozy Lodge Ville', 'Et considérer poste fait retomber disparaître. Prononcer avenir observer saint. École bonheur environ écrire hiver printemps combat.', '2', '5', '2', '44.03', 'MXN', '15:00:00', '10:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('9', '19', '8', '8', 'Boutique Nest boeuf', 'Oser habiter passage respecter assez planche.', '4', '1', '1', '445.08', 'GBP', '14:00:00', '11:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('10', '2', '2', '2', 'Rustic Lodge boeuf', 'Denken nimmt später. Darauf Ferien plötzlich.', '2', '2', '2', '523.75', 'EUR', '16:00:00', '11:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('11', '15', '4', '3', 'Boutique Stay Ville', 'Dick kennen heißen Katze Berg dein Haus gerade.', '1', '6', '1', '142.75', 'USD', '13:00:00', '10:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('12', '13', '1', '6', 'Rustic Retreat Ville', 'Material hit no energy.', '7', '3', '4', '309.56', 'MXN', '15:00:00', '12:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('13', '18', '8', '5', 'Panoramic Suite Ville', 'Acciones términos nuestro están cada. Pp imagen durante acto. Existencia sabía resto cabeza cierto pasado. Cuadro militar casa punto.', '4', '1', '1', '597.44', 'MXN', '12:00:00', '10:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('14', '17', '3', '2', 'Luxury Escape de la Montaña', 'Midi falloir revenir mesure or bas.', '2', '5', '1', '321.60', 'EUR', '15:00:00', '10:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('15', '19', '1', '20', 'Luxury Nest Ville', 'Règle saint autrefois vie patron hôtel. Étendre soudain renoncer passé confier vers guerre. Sauver lune emmener classe.', '11', '5', '3', '359.02', 'MXN', '13:00:00', '12:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('16', '13', '3', '10', 'Boutique Lodge los bajos', 'Flasche Onkel Milch darauf. Nur Boden Papa nehmen nah.', '2', '1', '4', '173.66', 'BRL', '16:00:00', '10:00:00', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('17', '9', '3', '12', 'Luxury Getaway los altos', 'Unten Musik trinken Angst aus Pferd. Freude erzählen müde nämlich antworten warten Mensch. Las suchen schlafen geben beißen. Dir ihr Kopf Glück.', '6', '3', '2', '159.37', 'GBP', '16:00:00', '12:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('18', '17', '1', '18', 'Charming Stay los bajos', 'Momento acción cuales tuvo niño mujeres. Nacional mi deseo entrar base. Aspectos corte valores manera.', '3', '3', '1', '590.96', 'USD', '16:00:00', '10:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('19', '11', '4', '9', 'Boutique Suite los bajos', 'Wagen Lehrerin bleiben hinein klein Feuer Name. Baden legen Wald. Fünf Affe Buch davon Freude hat Hunger.', '1', '1', '4', '378.70', 'MXN', '12:00:00', '10:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO accommodations (accommodation_id, owner_id, accommodation_type_id, location_id, name, description, max_guests, bedroom_count, bathroom_count, base_price_per_night, currency_code, check_in_time, check_out_time, is_active, created_at, updated_at) VALUES ('20', '9', '3', '15', 'Rustic Retreat furt', 'Crime network available mean share evidence writer. Budget window hour some fund voice sense current. Husband American although require sound mind chance.', '2', '1', '2', '113.26', 'BRL', '12:00:00', '11:00:00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');


-- accommodation_amenities
-- Data for accommodation_amenities
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('12', '4');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('4', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('5', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('5', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('8', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('10', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('2', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('7', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('18', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('7', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('4', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('3', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('5', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('8', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('17', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('9', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('19', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('2', '4');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('13', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('15', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('6', '4');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('7', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('14', '8');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('5', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('8', '4');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('17', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('13', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('15', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('6', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('7', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('20', '8');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('3', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('5', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('14', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('17', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('11', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('1', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('13', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('15', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('16', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('20', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('12', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('3', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('14', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('5', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('11', '4');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('1', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('6', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('16', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('20', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('3', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('5', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('4', '4');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('14', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('9', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('10', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('10', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('2', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('7', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('18', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('20', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('12', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('3', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('5', '4');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('4', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('14', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('8', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('13', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('1', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('2', '8');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('6', '8');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('20', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('12', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('3', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('5', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('4', '8');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('14', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('8', '8');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('10', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('2', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('2', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('16', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('6', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('20', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('12', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('14', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('4', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('4', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('8', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('10', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('11', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('2', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('6', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('20', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('14', '4');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('17', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('8', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('2', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('16', '4');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('6', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('20', '4');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('12', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('14', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('4', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('17', '8');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('8', '5');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('11', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('11', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('15', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('6', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('20', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('7', '6');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('12', '2');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('4', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('17', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('5', '8');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('8', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('17', '10');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('1', '1');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('19', '7');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('2', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('15', '3');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('6', '9');
INSERT INTO accommodation_amenities (accommodation_id, amenity_id) VALUES ('7', '8');


-- booking_statuses
-- Data for booking_statuses
INSERT INTO booking_statuses (booking_status_id, status_name, description) VALUES ('1', 'Pending', 'Booking created but not yet confirmed');
INSERT INTO booking_statuses (booking_status_id, status_name, description) VALUES ('2', 'Confirmed', 'Booking confirmed');
INSERT INTO booking_statuses (booking_status_id, status_name, description) VALUES ('3', 'CheckedIn', 'Guest has checked in');
INSERT INTO booking_statuses (booking_status_id, status_name, description) VALUES ('4', 'CheckedOut', 'Guest has checked out');
INSERT INTO booking_statuses (booking_status_id, status_name, description) VALUES ('5', 'Cancelled', 'Booking cancelled');
INSERT INTO booking_statuses (booking_status_id, status_name, description) VALUES ('6', 'NoShow', 'Guest did not arrive');


-- guests
-- Data for guests
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('1', 'Fredy', 'Montalbán', 'lluna@example.com', '08794 70551', '1985-01-01', 'Uruguay', NULL, 'Deborah Rios', '(03097) 289623', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('2', 'Ashley', 'Lee', 'astrid26@example.net', '(897)028-3857x865', '1976-07-24', 'Italien', 'to54973348', 'Pastor Cristóbal Torrijos Molins', '0426419866', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('3', 'María Teresa', 'López', 'stephanie15@example.com', '+34977338484', '1952-09-18', 'Slowenien', NULL, NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('4', 'Igor', 'Arteaga', 'fatimaheintze@example.org', '(657)212-0826x77345', '1989-09-02', 'Französisch-Polynesien', NULL, 'Urs Gertz', '+33 1 64 67 24 00', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('5', 'Clementina', 'Döring', 'walter88@example.com', '743-152-7420x5493', '1986-11-10', 'Territoires français du sud', 'up85161227', NULL, '563-274-5499x045', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('6', 'Steven', 'Palomino', 'helena14@example.com', '+49(0) 327279568', '1996-10-27', 'Swasiland', 'Kh39187851', NULL, '+1-983-398-2258', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('7', 'Nancy', 'Robin', 'dbluemel@example.org', '0790874064', '1996-01-14', 'República Federal Democrática de Nepal', 'cs06518017', 'Daniel Gosselin', '0524766182', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('8', 'Diego', 'Terrazas', 'nathaliehubert@example.org', '378-268-6337x5243', '1987-02-16', 'Dominican Republic', NULL, NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('9', 'Daniel', 'Wheeler', 'moulinnicole@example.org', '03 73 83 02 84', '2000-10-18', 'Irak', NULL, 'Edeltrud Jacobi Jäckel', '(836)440-8926x87056', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('10', 'Marcel', 'Lejeune', 'blanca28@example.com', '427.086.6882', '1961-10-23', 'Eritrea', NULL, 'Íñigo Sandoval Peláez', '+1-530-546-9901', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('11', 'Marc', 'Mateo', 'sharonhayden@example.org', '+33 3 58 63 85 46', '1981-08-06', 'India', 'xu58771753', NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('12', 'Benjamin', 'Hartung', 'ibarramaria-luisa@example.net', '0423536937', '1989-10-30', 'Gambia', 'lI77252287', NULL, '701.200.6231x20387', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('13', 'Fatima', 'Nette', 'robertelisabeth@example.net', '+33 (0)1 45 84 84 08', '2000-02-22', 'Bulgaria', NULL, 'Daisy Harvey', '+34 926 46 15 67', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('14', 'Ingmar', 'Macías', 'davisnicholas@example.net', '+33 (0)1 41 21 76 59', '2006-03-05', 'Vereinigtes Königreich', NULL, 'Steven Schwartz', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('15', 'Willibald', 'Artigas', 'rachel90@example.org', '+34713926142', '1961-08-24', 'Thailand', 'gB85621850', 'Jorge Tomás Yáñez', '0156477358', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('16', 'Aurore', 'Vigil', 'leleulaure@example.com', '1-114-262-6551x10475', '1952-03-28', 'Bolivia', 'fw67888610', 'Kornelius Scheuermann', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('17', 'Rosario', 'Richard', 'xpons@example.org', '+49(0) 982622444', '1955-03-20', 'Chad', NULL, 'Marc-Henri Guillet', '(843)779-9371x240', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('18', 'Raimund', 'Sacristán', 'tcerdan@example.com', '+49(0) 752654793', '1970-11-15', 'Libia', NULL, NULL, '+34 828 93 98 28', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('19', 'Stephanie', 'Neveu', 'slovato@example.org', '02 69 43 42 66', '1975-11-04', 'Malediven', 'MO68868058', NULL, '835-329-0965', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('20', 'Corey', 'Segovia', 'tilmannkoester@example.com', '+33 4 85 07 14 61', '2001-11-08', 'Japón', NULL, NULL, '+34924 738 757', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('21', 'Samuel', 'Julien', 'bradley10@example.com', '+1-423-882-8258x67362', '1947-04-09', 'Ukraine', 'WT79660334', 'Rebecca Herrera', '+34921 371 478', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('22', 'Edelmira', 'Bourdon', 'levequeadrienne@example.com', '+49 (0) 4991 251341', '1970-09-08', 'Palau', 'OI69296627', 'Clara Saiz', '+34843 25 79 05', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('23', 'Todd', 'Olivo', 'rlange@example.com', '07 52 19 03 40', '1960-08-01', 'Guinea', 'rX79788191', 'Kerstin Wernecke', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('24', 'Kathleen', 'Morvan', 'vcanales@example.net', '(074)517-1339', '2003-11-17', 'Paraguay', 'Ir29233095', 'Ing. Nikolai Hornich', '+34884 812 604', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('25', 'Guillermo', 'Concepción', 'mariapozo@example.com', '1-466-711-6845x7759', '2004-05-30', 'Saint Martin', NULL, NULL, '0183863637', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('26', 'Mohamed', 'Nebot', 'carolinneureuther@example.com', '8175012770', '2005-04-24', 'Congo', 'Ot15415206', NULL, '(110)371-2938x700', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('27', 'Olga', 'Mcneil', 'christianeguerin@example.org', '+33 (0)2 41 15 54 26', '1988-12-10', 'Belarús', 'AN90927532', NULL, '+33 2 32 12 19 65', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('28', 'Thomas', 'Gutiérrez', 'hurtadocarolina@example.net', '(04043) 898364', '1998-08-15', 'Nueva Zelandia', 'ui13791805', 'Paulette-Mathilde Morvan', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('29', 'Graciela', 'Smith', 'bakerbill@example.org', '0558661889', '1964-03-01', 'Georgia', 'tS83285691', NULL, '+33 1 80 31 61 79', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('30', 'Berthold', 'Echevarría', 'zimmermanjacqueline@example.org', '0389252410', '2000-03-16', 'Finlande', 'dF14917785', NULL, '+49 (0) 5241 913800', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('31', 'John', 'Marchal', 'josephda-silva@example.net', '+33 4 73 36 54 19', '1953-05-29', 'Russische Föderation', NULL, 'Robert Jarvis', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('32', 'Daniel', 'Carre', 'chema87@example.org', '+34 873494937', '1985-07-19', 'Sri Lanka', NULL, 'Elvira Corona', '(803)985-0506x41383', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('33', 'Teresa', 'Lemus', 'morsephyllis@example.net', '0633191826', '1985-07-24', 'Aserbaidschan', NULL, 'Georges Klein', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('34', 'Renata', 'Pozo', 'victor43@example.org', '912-127-7561', '1969-08-31', 'Mónaco', 'nu74112490', NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('35', 'Espartaco', 'Moya', 'labbetheophile@example.com', '+67(8)8317121003', '1958-10-07', 'Inde', 'Zi99410137', 'Sandra Rivera', '502.496.6706x625', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('36', 'Lino', 'Gérard', 'deborahporter@example.net', '+33 (0)2 32 46 26 38', '1988-03-16', 'Suriname', 'uy65787598', 'Albert Montaña Gilabert', '001-240-578-5932x13348', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('37', 'Milica', 'Monnier', 'nicolasvillarreal@example.com', '+34735992937', '1966-04-25', 'Noruega', 'av10393087', 'Ron Ehlert B.Eng.', '1-002-921-8515', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('38', 'Jacqueline', 'Rogers', 'faustorueda@example.net', '0325895392', '1966-03-01', 'Camerún', NULL, 'Salvador Ornelas Vanegas', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('39', 'Ian', 'Giner', 'oestrovskyfriedbert@example.com', '555.521.5704', '1969-02-18', 'Bulgaria', NULL, NULL, '8673626765', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('40', 'Simone', 'Siering', 'estherbenavides@example.org', '+34 725 41 15 26', '1995-02-04', 'Mexico', 'Bk59970629', 'Daniel Lee', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('41', 'Irmtraut', 'Hettner', 'jordan10@example.com', '07205 06149', '1958-11-14', 'Anguilla', NULL, NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('42', 'Jorge', 'Bilbao', 'le-gallsabine@example.com', '04 13 18 62 56', '1957-12-24', 'Arabie saoudite', 'WS77434902', NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('43', 'Christopher', 'Riba', 'birgittabolander@example.com', '0879374160', '1984-02-26', 'Svalbard und Jan Mayen', 'ic92172233', NULL, '+33 (0)5 82 32 94 51', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('44', 'Paul', 'Courtois', 'aurora70@example.net', '(08616) 229991', '1983-07-29', 'Solomon Islands', 'Ec85646799', NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('45', 'Rodolfo', 'Meunier', 'zbender@example.com', '+74(5)0544471324', '1997-12-15', 'Granada', 'xd91373678', NULL, '+49 (0) 1486 289023', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('46', 'Claudio', 'Apodaca', 'alvesmaryse@example.org', '+34928 78 61 03', '1978-07-18', 'Liberia', 'sb79855241', 'Édouard Masse', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('47', 'Martín', 'Fonseca', 'bvilanova@example.net', '922.690.3494x4665', '1977-01-15', 'Tailandia', 'PM96910858', 'Fanny Stolze', '815.745.4443x2830', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('48', 'Amador', 'Collet', 'yquiroga@example.net', '001-693-453-8758', '1957-08-11', 'Botswana', 'oV24825135', 'Rocío Muñoz Peral', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('49', 'Delfina', 'Silva', 'obrown@example.net', '(01738) 168460', '1954-08-19', 'Italia', 'Ol97252175', NULL, '+34807 07 43 29', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('50', 'Irene', 'Anderson', 'bantoine@example.com', '+33 (0)1 69 83 50 58', '1946-07-03', 'Niue', 'tk35421689', NULL, '4447789856', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('51', 'Agathe', 'de Anda', 'dumasmaurice@example.net', '1-098-215-0648', '1948-08-03', 'Argentinien', 'qE00167618', 'Abraham Madera', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('52', 'Margaud', 'Bates', 'silviocalvo@example.net', '+49(0)4117 393483', '1993-02-25', 'Gibraltar', 'aQ08737530', 'Sara Caldwell', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('53', 'Espartaco', 'Bruder', 'dawn74@example.com', '+33 (0)2 40 20 45 56', '1951-10-01', 'Algeria', 'vl25579415', NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('54', 'Richard', 'Maillard', 'pde-oliveira@example.org', '(402)816-9797', '1986-11-20', 'Tokelau', 'Pu77167014', NULL, '001-989-793-5889x163', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('55', 'Henri', 'Schmidtke', 'schneidereric@example.com', '+33 2 22 75 35 40', '1960-06-09', 'Pitcairn', 'FC63177971', NULL, '+34 837016608', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('56', 'Abbas', 'Conner', 'romana88@example.org', '0495037589', '1977-06-24', 'Ucrania', 'Hx11305548', 'Christopher Taylor', '+33 (0)3 87 93 31 63', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('57', 'Valérie', 'Mireles', 'owilliams@example.net', '+49(0)7798 270808', '2002-05-13', 'Mali', 'uG29221699', 'Jeanne Paris', '0449722698', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('58', 'Pía', 'Johann', 'hans-willihaering@example.net', '+34924 22 88 51', '1983-07-19', 'Nigeria', 'yj68460810', NULL, '+1-903-342-4420x43805', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('59', 'Oda', 'Hauffer', 'ghellwig@example.net', '+34 806 666 580', '1995-11-22', 'Emiratos Árabes Unidos', NULL, NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('60', 'Olena', 'Jean', 'mauraferrer@example.com', '+33 2 22 22 81 60', '1964-04-11', 'Griechenland', 'ju29405720', 'Reimar Schomber', '(04798) 51583', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('61', 'Lilia', 'Hartman', 'itorrez@example.com', '(233)355-5439x878', '1975-08-12', 'Somalia', NULL, NULL, '(03056) 164840', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('62', 'Marie', 'Vilar', 'cneuschaefer@example.com', '1-811-288-0133', '2002-02-24', 'Costa Rica', NULL, 'Univ.Prof. Rosita Boucsein', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('63', 'Alvaro', 'Wagner', 'bonillacandelario@example.org', '819-346-6766', '1946-06-07', 'Roumanie', 'Gg80919015', NULL, '+34 901 91 47 66', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('64', 'Thomas', 'Hartmann', 'strejo@example.net', '(508)821-0099', '1981-11-01', 'Ägypten', 'lo43536822', 'Cornelia Drewes', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('65', 'Yeni', 'Bloch', 'jseidel@example.org', '+34 820 41 39 75', '1954-01-03', 'Brasil', 'Qt91357759', 'Karl-Wilhelm Rosenow-Knappe', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('66', 'Tiburcio', 'Acuña', 'mireiagiralt@example.net', '0493257775', '1978-06-03', 'Bolivien', 'Ue91428341', NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('67', 'Melissa', 'Hess', 'lwilmsen@example.org', '+1-648-487-2563', '1979-05-21', 'Belize', 'Ck58039282', 'Lic. Sofía Concepción', '0170373145', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('68', 'Benito', 'Sisneros', 'dsoria@example.org', '+1-351-684-4989x2665', '2007-01-08', 'Papua Nueva Guinea', NULL, 'Marie Coulon', '+33 (0)2 69 72 31 84', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('69', 'Isaac', 'Cotto', 'grauseverino@example.com', '477.439.2603x0299', '1947-12-14', 'Burundi', 'UU24286990', NULL, '+34823 379 772', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('70', 'Dalia', 'Fechner', 'emiliasorgatz@example.net', '+34848 579 913', '1971-07-07', 'Bulgaria', NULL, 'Scott Gordon', '+33 2 37 27 99 08', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('71', 'Katalin', 'Davis', 'pradoliliana@example.com', '+34 803 86 37 65', '2000-01-14', 'Bermuda', 'Aq24731498', 'Abelardo Vélez Solorzano', '806.735.6512x69448', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('72', 'Karl-August', 'Faivre', 'yurias@example.net', '+33 4 99 88 74 49', '1997-12-19', 'Samoa', NULL, NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('73', 'Vanesa', 'Adkins', 'eugenebenoit@example.net', '0177260127', '1974-11-29', 'Bahrain', NULL, NULL, '+34876 51 90 66', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('74', 'Gerhild', 'Hörle', 'wohlgemutmariana@example.org', '01 42 38 43 09', '1980-05-20', 'Santo Tomé y Príncipe', NULL, NULL, '(053)021-4656x69380', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('75', 'Samantha', 'Hölzenbecher', 'nick43@example.net', '1-690-426-8181x845', '1999-12-04', 'Äthiopien', 'Wv89476973', 'Alix Leduc', '516-633-5658x804', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('76', 'Raymond', 'Benitez', 'willyjohann@example.com', '1-423-733-3433x3395', '1998-04-16', 'British Indian Ocean Territory (Chagos Archipelago)', 'uF79080759', 'Jasmin Gnatz', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('77', 'Karl-Josef', 'Louis', 'bernwardputz@example.com', '+33 (0)4 86 62 71 87', '1992-03-08', 'American Samoa', 'Jq69155942', 'Lic. Vicente Montalvo', '+34 867 63 65 56', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('78', 'Virgilio', 'Vázquez', 'felipejiminez@example.org', '0632270267', '2006-01-26', 'Montserrat', 'Sk74489061', 'David Combs', '754.555.8845x061', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('79', 'Christine', 'Gertz', 'moreno87@example.net', '+33 (0)5 24 94 72 25', '1988-03-29', 'Niederländische Antillen', NULL, NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('80', 'Claude', 'Miller', 'mauriciomoliner@example.net', '+34884 964 759', '1975-12-04', 'Chine (Rép. pop.)', 'gg02341326', NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('81', 'Sharon', 'Lévy', 'wisealexandria@example.org', '492-216-4334x722', '1990-06-09', 'Islandia', 'LM78487282', NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('82', 'Louise', 'Lübs', 'sibilla57@example.net', '07456424008', '1968-09-07', 'Namibia', 'oY07740649', 'Chelsea Khan', '03 84 26 63 41', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('83', 'Lorraine', 'Sierra', 'kasimir84@example.com', '02241797497', '1967-02-07', 'Canada', 'Ua80214427', 'Eduardo Adalberto Salcido', '1-647-570-5120', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('84', 'Maura', 'Guérin', 'mgirschner@example.com', '+33 (0)2 52 36 73 03', '1995-04-28', 'Mali', 'hq76452088', 'Eugène Alves de Martineau', '03650249163', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('85', 'Tanya', 'Ziegert', 'alixpires@example.org', '(719)500-5281', '1978-06-25', 'Iraq', 'cF57306524', NULL, '0753928557', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('86', 'Rufina', 'Röhrdanz', 'tamezjacinto@example.com', '+34883 85 70 86', '2005-05-14', 'Niger', NULL, 'Dafne Estrella Barroso Ponce', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('87', 'Linda', 'Gosselin', 'elfieholzapfel@example.com', '0246181022', '1959-01-13', 'Libyan Arab Jamahiriya', 'qd10967899', 'Marcio de Alberto', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('88', 'Trinidad', 'Chevalier', 'alvesfrederique@example.net', '0180948014', '1959-12-23', 'Benin', 'Ol38633839', 'Univ.Prof. Aysel Wilms', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('89', 'Orhan', 'Boutin', 'brunsophie@example.org', '0852897558', '2002-10-10', 'Malasia', NULL, 'Isabelle Thibault', '+49(0) 684577600', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('90', 'Débora', 'Holmes', 'masivan@example.org', '+34724888992', '1947-11-07', 'Honduras', 'fK24593344', NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('91', 'Hélène', 'Bernal', 'fduran@example.net', '+49(0)9409 610556', '2004-05-04', 'Trinidad and Tobago', 'IK90604805', 'Martha García Corral', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('92', 'Emily', 'Cohen', 'hartungsteve@example.com', '+33 2 57 51 79 08', '1963-02-24', 'Iran', 'PK62278376', 'Rocío Soria', '146.591.1665', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('93', 'Graciano', 'Ocaña', 'winklerleo@example.org', '+34 971 92 70 33', '1955-11-25', 'Bouvet Island (Bouvetoya)', NULL, 'Marc Hernandez', '+34 715 14 77 05', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('94', 'Marcela', 'Figueroa', 'bertha79@example.net', '1-069-804-2043x94070', '1971-09-24', 'Suecia', 'uF10463681', 'Dogan Gumprich', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('95', 'Waltraut', 'Guilbert', 'wrightalyssa@example.com', '02 97 05 55 43', '1964-01-21', 'Niue', 'Qi60843256', 'Kelly Gregory', '(392)649-5782x329', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('96', 'Hedi', 'Chavarría', 'titocodina@example.net', '+49 (0) 5188 125205', '1973-04-08', 'México', NULL, 'Roque Expósito Campillo', '(099)499-9393', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('97', 'Amador', 'Bernad', 'constancetexier@example.com', '+34 866 77 22 33', '1973-02-01', 'Uzbekistan', 'FS63331279', 'Victoria Huerta Roma', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('98', 'Philippine', 'Franklin', 'anais99@example.net', '00817 70388', '1995-04-24', 'Moldova', 'Dk80347644', NULL, NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('99', 'Théodore', 'Bloch', 'vinzenzseidel@example.com', '001-981-529-8266x5702', '1951-06-03', 'Irlanda', 'UY11175186', 'Dipl.-Ing. Karl Heinz Kramer', NULL, '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO guests (guest_id, first_name, last_name, email, phone, date_of_birth, nationality, passport_number, emergency_contact_name, emergency_contact_phone, created_at, updated_at) VALUES ('100', 'Kayla', 'Conesa', 'jose-carlosavalos@example.com', '+34902742123', '1987-08-25', 'Andorra', NULL, NULL, '08 08 09 73 39', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');


-- bookings
-- Data for bookings
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('1', '39', '15', '4', '1', '2025-06-11', '2025-06-23', '4', '3', '237.50', '28.50', '0.00', '266.00', NULL, 'BK-NVQHW06X', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('2', '77', '17', NULL, '5', '2025-06-08', '2025-06-16', '4', '0', '2151.58', '258.19', '0.00', '2409.77', 'Fuir aventure obéir derrière menacer page million.', 'BK-6LFEWVZN', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('3', '41', '9', '20', '6', '2025-06-11', '2025-06-25', '4', '0', '1981.40', '237.77', '218.48', '2000.69', NULL, 'BK-5P5O3O0L', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('4', '55', '2', '77', '3', '2025-05-27', '2025-05-29', '3', '0', '1324.04', '158.88', '98.68', '1384.24', NULL, 'BK-EC8UYO57', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('5', '80', '20', '72', '1', '2025-07-31', '2025-08-03', '3', '0', '1987.37', '238.48', '0.00', '2225.85', NULL, 'BK-D4N1U349', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('6', '28', '13', '44', '2', '2026-04-08', '2026-04-21', '3', '2', '961.50', '115.38', '0.00', '1076.88', 'Cosas yo empresa.', 'BK-A5UOFWB0', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('7', '66', '4', '15', '3', '2026-05-16', '2026-05-26', '4', '2', '1808.86', '217.06', '56.28', '1969.64', NULL, 'BK-1BCPPVOH', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('8', '69', '8', '46', '1', '2025-11-02', '2025-11-12', '4', '0', '211.61', '25.39', '0.00', '237.00', NULL, 'BK-811KERPE', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('9', '89', '12', NULL, '1', '2025-12-05', '2025-12-07', '2', '3', '2593.22', '311.19', '0.00', '2904.41', NULL, 'BK-UZPEAL2W', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('10', '94', '5', NULL, '2', '2026-01-07', '2026-01-09', '3', '1', '1217.51', '146.10', '0.00', '1363.61', NULL, 'BK-MLGSES6M', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('11', '80', '11', '41', '2', '2025-07-01', '2025-07-14', '4', '0', '2289.50', '274.74', '0.00', '2564.24', NULL, 'BK-8WQUUY5X', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('12', '12', '20', '50', '4', '2026-03-03', '2026-03-08', '1', '3', '2399.17', '287.90', '0.00', '2687.07', 'Tratamiento aumento dicho.', 'BK-MCQBNKX9', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('13', '6', '8', '57', '5', '2026-01-31', '2026-02-11', '2', '2', '605.31', '72.64', '0.00', '677.95', NULL, 'BK-S8Q349DX', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('14', '85', '20', '43', '1', '2025-09-05', '2025-09-12', '2', '2', '1255.87', '150.70', '0.00', '1406.57', NULL, 'BK-V2XCDYK0', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('15', '88', '17', NULL, '6', '2026-03-15', '2026-03-27', '4', '2', '2003.30', '240.40', '0.00', '2243.70', NULL, 'BK-ZDUXLEZ8', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('16', '95', '17', NULL, '3', '2025-09-19', '2025-09-22', '2', '3', '2855.95', '342.71', '0.00', '3198.66', NULL, 'BK-1G9FK2ST', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('17', '58', '8', '40', '4', '2025-07-15', '2025-07-29', '2', '2', '2093.89', '251.27', '0.00', '2345.16', 'Board year claim.', 'BK-6ZBNZ8V1', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('18', '48', '18', '67', '1', '2026-01-31', '2026-02-08', '3', '0', '1411.96', '169.44', '0.00', '1581.40', 'Sur i miguel cuales piel deja total cuando.', 'BK-NS832EJX', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('19', '31', '13', '48', '2', '2025-08-31', '2025-09-08', '1', '2', '2720.65', '326.48', '0.00', '3047.13', 'Solo interior donde actual resto luis.', 'BK-P8HQMABS', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('20', '33', '7', '71', '6', '2026-06-17', '2026-06-29', '4', '0', '1967.38', '236.09', '54.14', '2149.33', 'Acciones hora tenemos crisis.', 'BK-K3ZEZQAC', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('21', '92', '5', NULL, '1', '2025-08-13', '2025-08-18', '3', '1', '409.45', '49.13', '0.00', '458.58', NULL, 'BK-XWC4RTWU', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('22', '50', '12', NULL, '1', '2025-07-18', '2025-07-29', '3', '0', '2021.23', '242.55', '0.00', '2263.78', NULL, 'BK-M8T2SA5B', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('23', '81', '6', '9', '6', '2026-04-24', '2026-05-05', '4', '0', '1903.36', '228.40', '279.87', '1851.89', NULL, 'BK-LBT3G2QZ', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('24', '100', '2', '43', '3', '2025-05-06', '2025-05-19', '1', '2', '638.44', '76.61', '0.00', '715.05', NULL, 'BK-7S9TJ1GM', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('25', '24', '18', NULL, '1', '2025-11-04', '2025-11-16', '1', '2', '1347.22', '161.67', '91.35', '1417.54', 'Puede civil paciente varias durante éxito conocer expresión.', 'BK-GYN2JCPP', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('26', '8', '3', '52', '3', '2025-09-17', '2025-09-25', '2', '0', '1827.73', '219.33', '0.00', '2047.06', NULL, 'BK-YMB5M9J9', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('27', '48', '15', '74', '2', '2026-02-19', '2026-03-02', '3', '3', '2354.87', '282.58', '0.00', '2637.45', NULL, 'BK-C2NNUVY8', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('28', '89', '16', NULL, '2', '2025-09-03', '2025-09-07', '1', '3', '2883.53', '346.02', '0.00', '3229.55', NULL, 'BK-GS6E1ZHW', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('29', '90', '6', '66', '2', '2026-04-14', '2026-04-22', '1', '1', '2991.92', '359.03', '578.97', '2771.98', 'Color trata crisis explicó libro quien.', 'BK-9YZTKKFZ', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('30', '62', '17', '53', '5', '2025-08-13', '2025-08-26', '1', '1', '1507.36', '180.88', '0.00', '1688.24', 'Loch Oma Leben eigentlich nimmt schwarz zu.', 'BK-UQ9E5COZ', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('31', '8', '4', '39', '2', '2026-03-08', '2026-03-10', '2', '2', '1377.42', '165.29', '0.00', '1542.71', 'Agency personal brother summer.', 'BK-M52XG8P6', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('32', '83', '6', '75', '2', '2025-08-07', '2025-08-13', '2', '2', '2845.08', '341.41', '0.00', '3186.49', 'Ihn Glas Monate packen alle Erde.', 'BK-KCH8JWWD', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('33', '81', '18', NULL, '3', '2026-01-27', '2026-01-28', '4', '1', '2484.45', '298.13', '0.00', '2782.58', 'Mantener falta sociales sé a.', 'BK-BXUX1OXR', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('34', '45', '13', NULL, '3', '2026-03-30', '2026-04-06', '1', '2', '927.43', '111.29', '0.00', '1038.72', NULL, 'BK-CPRHVLZ0', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('35', '93', '11', NULL, '2', '2025-06-15', '2025-06-20', '4', '3', '1376.31', '165.16', '0.00', '1541.47', NULL, 'BK-B85P8637', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('36', '69', '1', '56', '2', '2025-09-18', '2025-09-26', '3', '2', '118.37', '14.20', '11.97', '120.60', 'Antonio apoyo estilo octubre historia volvió.', 'BK-8HMBR5XQ', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('37', '16', '5', '51', '3', '2025-10-18', '2025-10-19', '3', '2', '1231.72', '147.81', '0.00', '1379.53', 'Retomber payer jeune parcourir suite marier espérer.', 'BK-HTCS1K9Y', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('38', '79', '11', NULL, '5', '2025-07-24', '2025-08-03', '3', '2', '1551.91', '186.23', '0.00', '1738.14', NULL, 'BK-BELRQVSL', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('39', '81', '1', '34', '6', '2025-12-30', '2026-01-08', '2', '0', '1495.05', '179.41', '0.00', '1674.46', NULL, 'BK-RALDOL65', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('40', '20', '14', '53', '5', '2025-07-10', '2025-07-19', '4', '0', '1905.62', '228.67', '0.00', '2134.29', 'Se également projet enfoncer.', 'BK-4FYB8DAL', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('41', '89', '9', '25', '2', '2026-01-04', '2026-01-08', '3', '2', '1704.62', '204.55', '163.09', '1746.08', NULL, 'BK-N8QTTY5Y', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('42', '49', '13', '19', '3', '2025-09-13', '2025-09-26', '1', '2', '902.56', '108.31', '0.00', '1010.87', 'Erst schlafen Stunde.', 'BK-ZLM72JEY', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('43', '31', '8', NULL, '5', '2025-05-24', '2025-05-30', '2', '1', '2775.83', '333.10', '0.00', '3108.93', NULL, 'BK-0H3JUJD0', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('44', '26', '10', '8', '1', '2025-11-11', '2025-11-17', '2', '0', '2166.21', '259.95', '0.00', '2426.16', 'Septiembre don sobre j.', 'BK-1AT7O75R', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('45', '2', '10', '14', '3', '2025-07-12', '2025-07-19', '3', '3', '2652.62', '318.31', '0.00', '2970.93', 'Möglich Himmel nein vier.', 'BK-79OR7875', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('46', '38', '19', '25', '2', '2026-01-17', '2026-01-26', '4', '3', '1507.04', '180.84', '256.52', '1431.36', NULL, 'BK-QGEFQJG0', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('47', '93', '19', NULL, '6', '2025-05-28', '2025-06-04', '3', '1', '2024.30', '242.92', '0.00', '2267.22', NULL, 'BK-FLIJI18K', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('48', '29', '5', '59', '6', '2025-06-13', '2025-06-21', '3', '3', '955.08', '114.61', '0.00', '1069.69', 'Seguro mañana tan marco amor título.', 'BK-S6ZLE6KW', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('49', '73', '4', NULL, '5', '2025-12-11', '2025-12-24', '2', '1', '1635.68', '196.28', '0.00', '1831.96', NULL, 'BK-HI15CQZC', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('50', '72', '15', '40', '6', '2026-06-25', '2026-07-04', '1', '3', '1353.43', '162.41', '0.00', '1515.84', NULL, 'BK-ZR6QCEOU', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('51', '24', '5', '54', '3', '2025-04-15', '2025-04-27', '4', '3', '692.81', '83.14', '0.00', '775.95', 'Crisis pueden puerta esta dice.', 'BK-PZTC69QK', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('52', '97', '1', '60', '6', '2025-10-24', '2025-10-31', '4', '3', '286.74', '34.41', '50.15', '271.00', 'Media sometimes toward child future low.', 'BK-E4E9OE94', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('53', '27', '3', NULL, '1', '2025-08-18', '2025-08-26', '4', '0', '1071.17', '128.54', '0.00', '1199.71', NULL, 'BK-70E3P15A', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('54', '99', '11', NULL, '2', '2025-05-06', '2025-05-13', '2', '3', '1344.94', '161.39', '0.00', '1506.33', NULL, 'BK-11F9I6UU', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('55', '54', '14', NULL, '4', '2025-05-15', '2025-05-24', '2', '3', '2848.13', '341.78', '519.26', '2670.65', NULL, 'BK-WPR97Y2L', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('56', '11', '15', '12', '5', '2025-08-07', '2025-08-12', '2', '0', '2579.75', '309.57', '0.00', '2889.32', NULL, 'BK-QCOOTNJL', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('57', '25', '4', '62', '2', '2026-03-24', '2026-04-03', '2', '3', '1828.62', '219.43', '68.82', '1979.23', 'Sprechen denken von traurig Winter.', 'BK-10UR5L8A', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('58', '41', '7', '53', '1', '2026-01-21', '2026-01-27', '2', '1', '2337.77', '280.53', '0.00', '2618.30', NULL, 'BK-TMJSRD9Q', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('59', '63', '16', '46', '2', '2026-01-22', '2026-02-01', '2', '3', '1758.47', '211.02', '0.00', '1969.49', NULL, 'BK-FLN4RXYJ', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('60', '20', '1', NULL, '4', '2026-07-13', '2026-07-22', '3', '0', '2971.45', '356.57', '311.37', '3016.65', 'Éxito etc viaje duda en.', 'BK-4C3BAEWC', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('61', '90', '14', '23', '1', '2026-03-21', '2026-03-31', '1', '1', '2742.62', '329.11', '0.00', '3071.73', NULL, 'BK-ATOAZTKS', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('62', '11', '2', NULL, '4', '2026-02-25', '2026-03-06', '4', '3', '794.63', '95.36', '0.00', '889.99', NULL, 'BK-2C8QIZK3', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('63', '89', '19', '6', '1', '2025-04-18', '2025-04-30', '3', '0', '555.58', '66.67', '0.00', '622.25', NULL, 'BK-P2U4DTBH', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('64', '87', '18', '18', '6', '2026-06-23', '2026-06-29', '1', '2', '96.19', '11.54', '0.00', '107.73', NULL, 'BK-F337KUU4', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('65', '46', '18', '56', '2', '2025-11-23', '2025-11-27', '4', '0', '2524.09', '302.89', '0.00', '2826.98', 'The four threat billion she seat against serve.', 'BK-18O1BJ9R', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('66', '57', '12', '14', '2', '2025-09-12', '2025-09-25', '1', '1', '777.03', '93.24', '0.00', '870.27', NULL, 'BK-JN2FOMD7', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('67', '93', '18', '32', '5', '2026-01-24', '2026-02-02', '2', '3', '1561.70', '187.40', '0.00', '1749.10', NULL, 'BK-DTV25AO2', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('68', '79', '7', '18', '3', '2025-08-29', '2025-09-03', '1', '3', '841.80', '101.02', '0.00', '942.82', NULL, 'BK-GJK2N7ZR', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('69', '41', '6', '41', '3', '2026-02-25', '2026-03-04', '4', '1', '2422.03', '290.64', '0.00', '2712.67', NULL, 'BK-M349EL8H', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('70', '27', '15', '9', '4', '2025-09-04', '2025-09-18', '4', '1', '2368.31', '284.20', '0.00', '2652.51', 'Punto unidos apenas lejos américa esos.', 'BK-7H9G1A07', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('71', '47', '18', '11', '1', '2025-08-15', '2025-08-20', '2', '2', '1993.06', '239.17', '314.54', '1917.69', NULL, 'BK-C9ROS7YT', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('72', '72', '19', '29', '4', '2026-02-21', '2026-02-22', '3', '3', '1711.50', '205.38', '0.00', '1916.88', NULL, 'BK-X8L2DDH0', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('73', '44', '15', '67', '4', '2026-03-27', '2026-04-06', '3', '3', '2086.79', '250.41', '0.00', '2337.20', NULL, 'BK-9RK7D30M', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('74', '67', '6', '43', '5', '2026-04-18', '2026-04-30', '4', '3', '1384.72', '166.17', '0.00', '1550.89', NULL, 'BK-BZAMD270', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('75', '97', '3', '69', '2', '2025-11-07', '2025-11-18', '3', '2', '594.13', '71.30', '0.00', '665.43', NULL, 'BK-PBWHVNZH', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('76', '87', '10', '76', '1', '2025-06-11', '2025-06-16', '2', '2', '2028.57', '243.43', '0.00', '2272.00', NULL, 'BK-8LNOEMQG', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('77', '23', '18', NULL, '3', '2025-09-17', '2025-09-19', '2', '1', '589.98', '70.80', '0.00', '660.78', NULL, 'BK-SPENGWYX', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('78', '57', '16', NULL, '5', '2025-11-30', '2025-12-10', '1', '1', '208.15', '24.98', '0.00', '233.13', NULL, 'BK-AE38SRYO', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('79', '47', '18', '6', '6', '2025-09-01', '2025-09-05', '4', '1', '1635.95', '196.31', '0.00', '1832.26', 'Presidente curso derechos antes gracias.', 'BK-Q01TEE13', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('80', '95', '19', '55', '2', '2025-06-05', '2025-06-17', '2', '1', '2498.71', '299.85', '148.78', '2649.78', 'Fröhlich wirklich suchen müssen drei Geld.', 'BK-9QM3P91I', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('81', '13', '5', '53', '1', '2026-05-31', '2026-06-01', '3', '1', '1731.72', '207.81', '0.00', '1939.53', 'Sector quien aquellos trabajadores sino sólo actual.', 'BK-VG9KU8S6', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('82', '99', '3', '36', '6', '2025-06-20', '2025-06-24', '3', '3', '481.42', '57.77', '0.00', '539.19', 'Socialista pueda compañía medida político mayoría cuatro acerca.', 'BK-I4OFWWNC', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('83', '28', '16', NULL, '3', '2025-09-28', '2025-10-08', '3', '1', '57.30', '6.88', '8.40', '55.78', NULL, 'BK-0QXMCTHP', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('84', '55', '7', '17', '6', '2025-12-18', '2025-12-31', '3', '1', '1064.03', '127.68', '0.00', '1191.71', 'Zeitung sofort krank dauern.', 'BK-BD2QE4PA', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('85', '12', '4', NULL, '4', '2026-07-06', '2026-07-11', '1', '1', '325.35', '39.04', '0.00', '364.39', NULL, 'BK-CXXBW01P', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('86', '14', '11', '39', '2', '2026-01-04', '2026-01-15', '4', '1', '1362.95', '163.55', '0.00', '1526.50', 'Image politique presser inspirer.', 'BK-ME4YRID3', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('87', '28', '3', '18', '1', '2026-03-26', '2026-03-29', '4', '2', '251.81', '30.22', '0.00', '282.03', 'Mejor cama problemas c tras.', 'BK-VFMH07WP', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('88', '39', '7', '66', '2', '2025-09-22', '2025-10-05', '4', '2', '462.50', '55.50', '0.00', '518.00', 'Grupos sin hacía propia visto partido.', 'BK-DTVV2Y4X', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('89', '73', '14', '23', '4', '2026-05-20', '2026-06-02', '1', '0', '2866.28', '343.95', '0.00', '3210.23', NULL, 'BK-ERVT997E', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('90', '20', '9', NULL, '1', '2025-04-21', '2025-04-26', '2', '1', '686.44', '82.37', '130.24', '638.57', NULL, 'BK-OKZ1POXT', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('91', '78', '2', '23', '1', '2025-10-31', '2025-11-10', '1', '1', '1921.17', '230.54', '261.68', '1890.03', 'Libre universidad camino quería forma cuya mismo manos.', 'BK-CZ04CDPQ', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('92', '4', '11', '35', '5', '2025-07-06', '2025-07-14', '1', '2', '2861.40', '343.37', '0.00', '3204.77', 'Nombreux demi dernier cinquante joie aujourd''hui.', 'BK-2ZGE2J51', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('93', '30', '17', NULL, '1', '2026-02-03', '2026-02-14', '2', '0', '277.36', '33.28', '0.00', '310.64', NULL, 'BK-MRUNJDU0', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('94', '74', '12', NULL, '6', '2025-10-27', '2025-10-30', '1', '1', '577.93', '69.35', '4.09', '643.19', NULL, 'BK-2ZXII6L3', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('95', '39', '20', NULL, '3', '2026-01-03', '2026-01-04', '4', '1', '2864.53', '343.74', '0.00', '3208.27', 'Salud conseguir sol aquella acciones grupo cargo modelo.', 'BK-QK4LTAHU', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('96', '49', '10', NULL, '5', '2026-01-18', '2026-01-31', '2', '3', '2398.12', '287.77', '0.00', '2685.89', NULL, 'BK-7ATWYAM1', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('97', '18', '13', NULL, '5', '2025-05-14', '2025-05-17', '1', '3', '2149.37', '257.92', '0.00', '2407.29', 'Dabei nennen gestern braun Katze gelb hängen.', 'BK-76SZN9DD', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('98', '14', '5', NULL, '4', '2025-06-19', '2025-06-23', '4', '2', '910.44', '109.25', '168.62', '851.07', NULL, 'BK-O3LQI7E1', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('99', '42', '5', NULL, '2', '2026-01-13', '2026-01-19', '3', '3', '2895.67', '347.48', '0.00', '3243.15', NULL, 'BK-LJEFY3ZB', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO bookings (booking_id, guest_id, accommodation_id, room_id, booking_status_id, check_in_date, check_out_date, adult_count, child_count, subtotal_amount, tax_amount, discount_amount, total_amount, special_requests, booking_reference, booked_at, created_at, updated_at) VALUES ('100', '100', '8', NULL, '4', '2026-03-26', '2026-03-31', '3', '0', '817.49', '98.10', '5.08', '910.51', NULL, 'BK-OQ0IQ2FA', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');


-- booking_guests
-- Data for booking_guests
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('1', '46', 'Kathleen', 'Wilms', '59', 'vZ73477848', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('2', '46', 'Berit', 'Cisneros', '59', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('3', '46', 'Vicki', 'Reyes', NULL, 'Tk67700284', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('4', '28', 'Aurore', 'Marrero', '42', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('5', '28', 'Claire', 'Carroll', '24', 'dz88977828', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('6', '74', 'Ana Belén', 'Kostolzin', NULL, 'xw54500902', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('7', '35', 'Andrey', 'Pintor', '64', 'pP65565033', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('8', '35', 'Dora', 'Lozano', '48', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('9', '24', 'Misty', 'Morgan', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('10', '24', 'Amanda', 'Murray', NULL, 'uy98640790', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('11', '88', 'Reinhart', 'Cabañas', '35', 'tx13578529', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('12', '25', 'Luc', 'Bousquet', '49', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('13', '25', 'Mary', 'Hamann', '20', 'TL40496391', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('14', '25', 'Brittany', 'Bautista', NULL, 'Zt87635148', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('15', '64', 'Margaud', 'Johann', '67', 'bO66498782', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('16', '26', 'Nelly', 'Velázquez', '39', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('17', '26', 'Marcel', 'Royer', '7', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('18', '31', 'Manuela', 'Wilmsen', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('19', '31', 'Geneviève', 'Boyd', NULL, 'eO72324665', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('20', '31', 'Daniela', 'Madrid', NULL, 'bp49363123', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('21', '91', 'Abril', 'Vaillant', '33', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('22', '91', 'Audrey', 'Harris', '45', 'Yb20448207', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('23', '34', 'Michele', 'Edwards', NULL, 'KV16516231', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('24', '34', 'Sybilla', 'Boyd', '23', 'vL84713915', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('25', '34', 'Susan', 'Piña', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('26', '27', 'Hugo', 'Thompson', '58', 'Sh76490785', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('27', '27', 'Caridad', 'Ollivier', '37', 'cV42575409', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('28', '27', 'Hannah', 'Hernandes', '22', 'az64518376', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('29', '30', 'Marcial', 'Mayer', '52', 'fX43275604', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('30', '30', 'Charlotte', 'Le Roux', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('31', '92', 'Thérèse', 'Holloway', '38', 'Sb81569857', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('32', '32', 'Danielle', 'Quiroz', '35', 'kp06345911', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('33', '32', 'Inka', 'Villegas', '47', 'Zs57724295', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('34', '32', 'Enrique', 'Tessier', '58', 'Oo66930089', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('35', '80', 'Terri', 'Iglesias', '17', 'xk06969421', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('36', '100', 'Erik', 'Higgins', NULL, 'VF77133344', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('37', '100', 'Gilles', 'Leclerc', '27', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('38', '100', 'Heinz-Georg', 'Fajardo', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('39', '20', 'Jules', 'Rodrigues', '4', 'RP44397359', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('40', '20', 'Émile', 'Harrison', '11', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('41', '14', 'Jimena', 'Torres', NULL, 'dv66941180', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('42', '14', 'Graciela', 'Arroyo', '40', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('43', '14', 'Jon', 'Kranz', '57', 'kG65280924', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('44', '16', 'Yves', 'Payet', '22', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('45', '11', 'Logan', 'Löwer', '42', 'Bs41502745', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('46', '11', 'Emperatriz', 'Villanueva', '70', 'mj62572870', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('47', '11', 'Jerry', 'Harrison', '18', 'FD76170758', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('48', '93', 'Frédéric', 'Castañeda', '59', 'QL13422849', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('49', '93', 'Nancy', 'Fox', '56', 'sR26137150', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('50', '93', 'Phillip', 'Döring', '40', 'Qa20177749', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('51', '1', 'Armando', 'Mentzel', '12', 'JM92304501', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('52', '1', 'Éric', 'Adam', '34', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('53', '70', 'Octavio', 'Blanc', NULL, 'FZ32664214', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('54', '6', 'Nathalie', 'Castro', '61', 'rK15837767', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('55', '62', 'Sigmar', 'Avila', '62', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('56', '62', 'Encarna', 'Puente', '38', 'HO10857327', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('57', '62', 'Denis', 'Solé', '48', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('58', '48', 'Édouard', 'Ribeiro', '32', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('59', '48', 'Gonzalo', 'Ibarra', '50', 'gG64908108', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('60', '48', 'Antoinette', 'Marshall', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('61', '41', 'Margaret', 'Padilla', NULL, 'zc91801722', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('62', '41', 'Robert', 'Mir', '35', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('63', '41', 'Isabell', 'Boulay', '35', 'qR94523219', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('64', '78', 'Ryan', 'Smith', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('65', '36', 'Alexander', 'Jacques', '58', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('66', '36', 'Margaux', 'van der Dussen', '25', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('67', '36', 'Thibaut', 'Schmiedt', NULL, 'bS64122031', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('68', '63', 'Amador', 'Rosales', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('69', '96', 'Susana', 'Pulido', NULL, 'hk31472760', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('70', '96', 'Esperanza', 'Georges', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('71', '66', 'Michelle', 'Henk', '44', 'AF49605016', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('72', '76', 'Dietlinde', 'Hoffmann', '60', 'Td76789973', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('73', '76', 'Alfredo', 'Verdier', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('74', '51', 'Carolina', 'Adams', NULL, 'ks71795760', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('75', '29', 'Gloria', 'Ríos', '24', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('76', '49', 'Judith', 'Villagómez', '2', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('77', '49', 'África', 'Trubin', '32', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('78', '37', 'Gilles', 'Portero', NULL, 'il57293417', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('79', '37', 'Jacobo', 'Noack', NULL, 'wq67433800', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('80', '9', 'Inés', 'Delgado', '27', 'Jo01561931', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('81', '4', 'Raymond', 'Padilla', '42', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('82', '4', 'Kayla', 'Hethur', '67', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('83', '4', 'Laura', 'Staude', '39', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('84', '89', 'Jasmine', 'Albert', '28', 'kO19918081', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('85', '52', 'Monica', 'Crespo', '42', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('86', '99', 'Leandra', 'Ledoux', '51', 'CA71255213', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('87', '99', 'John', 'Leblanc', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('88', '90', 'Anselma', 'Briones', '20', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('89', '90', 'Ramón', 'Alves', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('90', '90', 'Israel', 'Linke', NULL, 'Cj26667850', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('91', '97', 'Jennifer', 'Bohnbach', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('92', '97', 'Matthew', 'Leleu', NULL, 'sA60602908', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('93', '97', 'Maggie', 'Jähn', NULL, 'Pn50489267', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('94', '3', 'Emine', 'Siering', '45', 'yU56341085', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('95', '3', 'Lilia', 'Hölzenbecher', '25', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('96', '33', 'Esteban', 'Rohleder', '18', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('97', '33', 'Azahar', 'Cuesta', NULL, 'hU08943468', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('98', '23', 'Mckenzie', 'Vera', NULL, 'vp10174907', '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('99', '23', 'Carola', 'Scheibe', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('100', '23', 'Anel', 'Luís', '60', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('101', '86', 'Gudula', 'Ocasio', '21', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('102', '86', 'Jessica', 'Cantú', NULL, NULL, '2026-04-15 01:23:25.356206');
INSERT INTO booking_guests (booking_guest_id, booking_id, first_name, last_name, age, document_number, created_at) VALUES ('103', '86', 'Ascensión', 'Gröttner', NULL, NULL, '2026-04-15 01:23:25.356206');


-- payments
-- Data for payments
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('1', '1', '2026-04-15 01:23:25.356206', '2447.60', 'CreditCard', 'Completed', 'e927eed7-dfe2-4802-905d-c0c7c052f08c', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('2', '2', '2026-04-15 01:23:25.356206', '2437.43', 'CreditCard', 'Failed', '84f39773-2afa-4f8c-be18-13ed9c7dad88', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('3', '3', '2026-04-15 01:23:25.356206', '199.38', 'Cash', 'Refunded', 'ac64d795-6f5e-4fea-a6f9-5071ae3f4dd5', 'Schlafen nennen tragen gesund.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('4', '4', '2026-04-15 01:23:25.356206', '136.97', 'Crypto', 'Refunded', '3f067a9e-e732-4fed-86b8-a86cf3c3845c', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('5', '5', '2026-04-15 01:23:25.356206', '602.10', 'BankTransfer', 'Refunded', 'c890a057-ec72-4730-9def-a476d5ba80d0', 'Design catch oil sense.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('6', '7', '2026-04-15 01:23:25.356206', '775.07', 'BankTransfer', 'Refunded', '327c14e9-52ca-4d67-8a0f-4ba93f7f164a', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('7', '8', '2026-04-15 01:23:25.356206', '229.89', 'BankTransfer', 'Refunded', '851dc089-8942-459a-a3a7-65d83b53cac7', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('8', '9', '2026-04-15 01:23:25.356206', '2659.72', 'Cash', 'Pending', 'ed993373-cc0c-4d03-8cb8-47916d22c39b', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('9', '10', '2026-04-15 01:23:25.356206', '2394.80', 'PayPal', 'Failed', '7f2515cf-3381-49b5-a2e3-f4ccaf008c87', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('10', '11', '2026-04-15 01:23:25.356206', '1064.90', 'Cash', 'Failed', '0e062bf2-8db5-426b-91a9-4c7796ed5bf2', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('11', '12', '2026-04-15 01:23:25.356206', '990.69', 'DebitCard', 'Completed', 'e9feecbf-aca9-4b2a-8d7e-b500adf8158d', 'Produce laugh factor past.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('12', '13', '2026-04-15 01:23:25.356206', '222.84', 'PayPal', 'Failed', 'dfaaf9cc-3aae-4beb-a0d1-024a71f71dea', 'Course sou eh rester poète.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('13', '14', '2026-04-15 01:23:25.356206', '2923.24', 'CreditCard', 'Pending', '3d2d6336-0615-424f-be7c-8b17151afa7c', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('14', '15', '2026-04-15 01:23:25.356206', '2458.04', 'Crypto', 'Completed', 'd632071e-36a5-4213-9f1b-3822cfefda7d', 'Voiture ne oncle long sept seulement.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('15', '16', '2026-04-15 01:23:25.356206', '1748.29', 'PayPal', 'Failed', '467abe42-f0af-4dfd-b59d-856cf43c529f', 'Too whose a nice without body.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('16', '17', '2026-04-15 01:23:25.356206', '562.45', 'DebitCard', 'Failed', '05d9e5f4-3fac-4e5b-9bb3-de3a57733210', 'Cambio precisamente dinero.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('17', '18', '2026-04-15 01:23:25.356206', '2746.24', 'CreditCard', 'Failed', 'a1e35ef7-3ae7-4448-ad34-ab565443ec85', 'Camino siendo bajo cuenta lugar voy.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('18', '19', '2026-04-15 01:23:25.356206', '1711.17', 'DebitCard', 'Refunded', '16f33891-09ab-42f3-8da5-ad7e039dcc36', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('19', '20', '2026-04-15 01:23:25.356206', '161.99', 'CreditCard', 'Pending', 'f83a18d9-0876-4a1c-93dd-29d5c58412a6', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('20', '22', '2026-04-15 01:23:25.356206', '1028.62', 'Cash', 'Pending', '1fc5d981-f126-4b60-8eb8-8a6c42da4d76', 'Toda somos grande hombre ese una.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('21', '23', '2026-04-15 01:23:25.356206', '573.51', 'BankTransfer', 'Completed', '5f614e45-aa2e-43a1-b7e0-e16984b1d2fd', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('22', '24', '2026-04-15 01:23:25.356206', '2755.81', 'CreditCard', 'Failed', '21be0a98-2590-48a5-a897-568a096dd9e2', 'Vieux chair chaleur riche simple suivre.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('23', '25', '2026-04-15 01:23:25.356206', '2828.67', 'PayPal', 'Completed', '23ffc625-3e62-48ae-9d53-a6262fc31ee3', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('24', '26', '2026-04-15 01:23:25.356206', '2928.79', 'Crypto', 'Refunded', '6cbea94a-5f13-49b5-a7f6-f79b43b381ce', 'Oben Klasse ist tragen hier Familie.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('25', '27', '2026-04-15 01:23:25.356206', '1965.08', 'DebitCard', 'Failed', '9e890f96-a179-4345-9e3a-d6fa464497e6', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('26', '28', '2026-04-15 01:23:25.356206', '567.29', 'BankTransfer', 'Failed', '8e83865c-d34b-49da-9031-b1ccb65563a5', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('27', '29', '2026-04-15 01:23:25.356206', '2848.92', 'Cash', 'Refunded', 'b1549507-3f88-43e2-b2eb-fb7d2cbc2e90', 'Accomplir leur public prêter divers tôt muet anglais.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('28', '30', '2026-04-15 01:23:25.356206', '1724.07', 'DebitCard', 'Failed', '27aa4307-13e3-48c9-9a12-13348ba6af31', 'Low happy oil which bag room money.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('29', '31', '2026-04-15 01:23:25.356206', '701.64', 'Cash', 'Completed', 'd8abe0ac-4253-4892-958a-3210a04d28d8', 'Mundial recursos actividades centro blanco norte cargo.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('30', '32', '2026-04-15 01:23:25.356206', '2248.76', 'DebitCard', 'Failed', '6c6f9b34-6385-4de2-b91d-8fc014de52f2', 'Genau bald Gott springen kurz Licht kurz selbst.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('31', '33', '2026-04-15 01:23:25.356206', '2661.69', 'CreditCard', 'Failed', '82fc443e-17d4-4051-972d-eea25d71c644', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('32', '34', '2026-04-15 01:23:25.356206', '786.15', 'CreditCard', 'Failed', 'c4a360f3-1176-431d-a278-62b9cda68832', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('33', '35', '2026-04-15 01:23:25.356206', '53.78', 'PayPal', 'Refunded', 'be2054c7-edd8-498d-b3bc-9ddef3041887', 'Veiller retourner eau animal toit race.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('34', '36', '2026-04-15 01:23:25.356206', '2659.43', 'PayPal', 'Refunded', 'c729e66d-c273-4048-907a-bdf8e4df6a78', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('35', '37', '2026-04-15 01:23:25.356206', '2494.98', 'Cash', 'Pending', 'a51ab675-5e57-42c8-bb13-935c1197681f', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('36', '39', '2026-04-15 01:23:25.356206', '919.98', 'BankTransfer', 'Failed', '06aeb1cb-e96a-4327-a52b-2ab12dedcf9a', 'Bei Küche drehen bald zwei.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('37', '41', '2026-04-15 01:23:25.356206', '1157.60', 'Crypto', 'Completed', '9cd5af7b-49f9-4e64-956b-506128c063b1', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('38', '42', '2026-04-15 01:23:25.356206', '324.66', 'Cash', 'Refunded', '3210c97f-3964-4852-9b22-a3c0e0587c28', 'Für Bild lesen.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('39', '43', '2026-04-15 01:23:25.356206', '1978.22', 'Cash', 'Refunded', 'f855a4ee-bea0-486f-9c20-2eb47d1c05a6', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('40', '44', '2026-04-15 01:23:25.356206', '656.37', 'DebitCard', 'Refunded', 'f705b25a-077b-4e19-9179-3b060a13179a', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('41', '45', '2026-04-15 01:23:25.356206', '2203.42', 'BankTransfer', 'Failed', 'f45a8965-a62b-46cc-9e12-e4492cd1ef04', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('42', '47', '2026-04-15 01:23:25.356206', '1671.50', 'PayPal', 'Pending', '3efabc06-37f2-4ae7-9ce1-759320a5d233', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('43', '50', '2026-04-15 01:23:25.356206', '1894.02', 'PayPal', 'Pending', 'bd36f78d-fc5c-43fc-8a6c-65c1f1a443e8', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('44', '51', '2026-04-15 01:23:25.356206', '1932.66', 'CreditCard', 'Refunded', '8c01a23a-e8d5-4001-a0d9-364ab3f669fb', 'Esto don puso no estaba.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('45', '52', '2026-04-15 01:23:25.356206', '1222.53', 'PayPal', 'Failed', 'f84d916b-6f5a-4c88-8908-4fe17cffe1e5', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('46', '53', '2026-04-15 01:23:25.356206', '595.40', 'PayPal', 'Failed', '7686b080-c392-4a66-af48-8ee50ac42705', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('47', '55', '2026-04-15 01:23:25.356206', '827.03', 'BankTransfer', 'Completed', 'c966e352-7759-4030-afda-83853395096f', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('48', '56', '2026-04-15 01:23:25.356206', '335.27', 'Crypto', 'Failed', 'd2e56432-a8bd-429a-b915-52877d72c5cd', 'Modelo amigos único tienen mayo cambio mujer tenemos.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('49', '57', '2026-04-15 01:23:25.356206', '2281.55', 'DebitCard', 'Completed', 'd48ee951-aaed-47d1-b8e6-c9ee57c8cf89', 'Worker whose other start study sell.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('50', '58', '2026-04-15 01:23:25.356206', '1284.96', 'Cash', 'Refunded', '71812564-8d2c-48c3-8f5a-f748d064a5de', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('51', '59', '2026-04-15 01:23:25.356206', '931.61', 'PayPal', 'Completed', '7c117a5a-8392-4e4e-a51a-1cb34963c34f', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('52', '60', '2026-04-15 01:23:25.356206', '2411.33', 'Crypto', 'Pending', '637200e0-8921-418a-9962-5d40dedecaff', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('53', '61', '2026-04-15 01:23:25.356206', '559.99', 'DebitCard', 'Pending', '3adb292f-cbb1-452d-a9d9-25b8ac650b59', 'Demeurer haute pas cri puissance étendue.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('54', '62', '2026-04-15 01:23:25.356206', '1298.96', 'Crypto', 'Refunded', '46d8c87e-9d1f-4e2f-a93c-fb304247e973', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('55', '63', '2026-04-15 01:23:25.356206', '486.24', 'Cash', 'Failed', '01fbf973-e828-4dad-8013-4043416bc56a', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('56', '64', '2026-04-15 01:23:25.356206', '2431.66', 'CreditCard', 'Refunded', '562cea47-0cee-4c65-ae14-48084dd79d09', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('57', '65', '2026-04-15 01:23:25.356206', '2577.04', 'Cash', 'Refunded', '742ecda8-cb6e-469e-8df6-4952fb7fd95c', 'Qué actividad nuevos nuevos.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('58', '67', '2026-04-15 01:23:25.356206', '1783.35', 'PayPal', 'Completed', '23090f9f-6dcb-4811-9167-14c8e71c5e44', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('59', '68', '2026-04-15 01:23:25.356206', '1784.41', 'CreditCard', 'Completed', '41051550-b565-4472-be13-c6f61db67e08', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('60', '69', '2026-04-15 01:23:25.356206', '893.97', 'Cash', 'Failed', '88092870-b9b4-4913-812f-dab4e83eea35', 'Herr Schuh lachen denn vom.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('61', '70', '2026-04-15 01:23:25.356206', '1981.62', 'Cash', 'Refunded', '336d4baa-15d8-4aca-9b3d-afa88d6fea72', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('62', '71', '2026-04-15 01:23:25.356206', '474.37', 'Cash', 'Refunded', '5724f42a-56da-49bb-beec-294b3788a86a', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('63', '72', '2026-04-15 01:23:25.356206', '1027.91', 'DebitCard', 'Completed', 'c0e95cc2-6021-4a86-81e3-ddf9ecd2b99b', 'Until large question which raise.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('64', '73', '2026-04-15 01:23:25.356206', '2696.24', 'CreditCard', 'Failed', '5ff525c8-6fd7-4663-b287-769f0829806b', 'Truth PM what it.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('65', '74', '2026-04-15 01:23:25.356206', '877.02', 'PayPal', 'Completed', '01a83e8d-2247-420a-923b-2013c4518e64', 'Meses chile mis experiencia visto trabajadores.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('66', '75', '2026-04-15 01:23:25.356206', '936.42', 'Crypto', 'Refunded', 'ae5bf7a6-7c24-4102-91ed-0ca70e65d11e', 'Cierta económica viene niveles primero las se donde.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('67', '76', '2026-04-15 01:23:25.356206', '2199.96', 'Cash', 'Completed', 'f3dae7b2-d928-4960-80ca-e3e91380e8bb', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('68', '77', '2026-04-15 01:23:25.356206', '2480.71', 'Crypto', 'Refunded', '03cae560-20b8-486e-8dea-cf18c17883bb', 'Maison pont être promener.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('69', '78', '2026-04-15 01:23:25.356206', '2472.00', 'Cash', 'Pending', '4e9c3664-6a04-470a-b900-f71eb132d235', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('70', '79', '2026-04-15 01:23:25.356206', '1239.99', 'Cash', 'Completed', '231a14e1-d9e9-4e54-a67d-6bcaa7b32f5c', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('71', '80', '2026-04-15 01:23:25.356206', '642.14', 'CreditCard', 'Pending', 'd9213227-dfc3-459b-9e72-dbb31551b868', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('72', '82', '2026-04-15 01:23:25.356206', '637.37', 'BankTransfer', 'Refunded', 'dd9b73ed-adac-485f-a577-6fc6b058d3d3', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('73', '83', '2026-04-15 01:23:25.356206', '415.42', 'CreditCard', 'Pending', '44cf34dc-b64b-4b84-88b4-7333eb3edbd1', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('74', '84', '2026-04-15 01:23:25.356206', '573.87', 'PayPal', 'Failed', '550afb01-c9dd-4d94-bb3d-cb357e4e6a72', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('75', '85', '2026-04-15 01:23:25.356206', '813.05', 'Crypto', 'Completed', 'c1b4c865-7666-4055-82f7-5560a0247f47', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('76', '86', '2026-04-15 01:23:25.356206', '530.58', 'Cash', 'Pending', 'f29b9375-4461-47d7-9a35-7c70965158b2', 'Entre objeto hay podemos vio.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('77', '87', '2026-04-15 01:23:25.356206', '2049.20', 'BankTransfer', 'Refunded', 'f183f885-339a-4820-b9fe-a20e97f45622', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('78', '88', '2026-04-15 01:23:25.356206', '2903.06', 'Crypto', 'Completed', '1465d644-e346-4a38-a837-c132d16888bb', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('79', '89', '2026-04-15 01:23:25.356206', '560.94', 'CreditCard', 'Pending', 'c27231aa-6f5b-4ce9-ab56-b84099237070', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('80', '90', '2026-04-15 01:23:25.356206', '951.11', 'Crypto', 'Failed', 'fccc085e-db60-4775-9e96-3e25be97c838', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('81', '91', '2026-04-15 01:23:25.356206', '1078.69', 'BankTransfer', 'Pending', '83988a88-04e6-46ae-9ae5-907e93ec5d2c', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('82', '92', '2026-04-15 01:23:25.356206', '2481.72', 'PayPal', 'Completed', '1ec8d20f-b601-4a86-ad3d-c0166033145e', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('83', '93', '2026-04-15 01:23:25.356206', '2901.13', 'BankTransfer', 'Failed', '946706e0-b8f6-46bc-8995-c4f786c15c64', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('84', '94', '2026-04-15 01:23:25.356206', '238.32', 'BankTransfer', 'Failed', '65e14e8a-add5-4850-bb25-409498f26673', 'Silencio río algo asunto quien siete revolución fuerte.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('85', '95', '2026-04-15 01:23:25.356206', '2147.73', 'Crypto', 'Failed', 'a1b7df96-dff1-47d2-b279-2410b3973cb5', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('86', '96', '2026-04-15 01:23:25.356206', '758.89', 'CreditCard', 'Refunded', 'bce37815-4444-431a-82b8-9e54adb8620a', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('87', '97', '2026-04-15 01:23:25.356206', '2177.79', 'Crypto', 'Refunded', 'bd6e8c2f-557e-4722-acaa-cb527747b050', 'Padres último niño obstante.', '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('88', '98', '2026-04-15 01:23:25.356206', '1284.77', 'PayPal', 'Completed', '54c28340-bbae-46c7-a1d0-c287fd848459', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('89', '99', '2026-04-15 01:23:25.356206', '2457.24', 'BankTransfer', 'Pending', 'cd68b0ec-0587-4c51-91aa-2c6bf7897076', NULL, '2026-04-15 01:23:25.356206');
INSERT INTO payments (payment_id, booking_id, payment_date, amount, payment_method, payment_status, transaction_reference, notes, created_at) VALUES ('90', '100', '2026-04-15 01:23:25.356206', '1453.42', 'Crypto', 'Failed', '41b7674c-91d8-40ad-99d0-f62d1c55df45', NULL, '2026-04-15 01:23:25.356206');


-- reviews
-- Data for reviews
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('1', '39', '60', '2', '1', 'Great location', 'Pour plaindre regretter devoir rentrer douceur.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('2', '54', '6', '10', '3', 'Very comfortable', 'Four art western enough key man. Particular condition man century shoulder.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('3', '85', '55', '4', '1', 'Amazing stay!', 'Esfuerzo ocho estado ahora. Principales fácil es organización resulta de esta.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('4', '13', '2', '5', '2', 'Very comfortable', 'Précipiter tandis que moyen lui.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('5', '98', '46', '15', '5', 'Excellent service', 'Français propos roi auteur début fin. Cause mari vol espace éloigner as vrai.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('6', '67', '94', '3', '3', 'Very comfortable', 'Table future subject set face data never. Produce federal hope blood read main.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('7', '35', '24', '4', '4', 'Not as described', 'Animer ajouter voyager demi.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('8', '80', '59', '9', '4', 'Hidden gem', 'Paupière lever vérité rocher vers âgé établir.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('9', '78', '54', '6', '1', 'Great location', 'Les cuestión tratamiento edad viene temas.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('10', '90', '90', '2', '2', 'Would visit again', 'Llama todo trabajo tomar aquellos. Muy habrá momento grupo está falta cuadro existe.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('11', '18', '54', '19', '4', 'Clean and cozy', 'Vuelta forma serie atrás. Parte ello orden encontrar finalmente.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('12', '99', '87', '15', '2', 'Clean and cozy', 'Vif muet chaleur second. Réduire note espoir casser chant.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('13', '14', '49', '12', '5', 'Amazing stay!', 'Midi haut ton appartenir bois séparer.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('14', '66', '88', '5', '4', 'Hidden gem', 'Als laufen acht dürfen. Schule nein führen Schluss.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('15', '93', '15', '14', '4', 'Amazing stay!', 'Charge doigt huit dent complet.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('16', '16', '9', '9', '3', 'Amazing stay!', 'Response partner because step. Girl above dog brother morning.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('17', '37', '91', '17', '5', 'Clean and cozy', 'Television would medical less phone decade. Create someone rate.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('18', '15', '29', '11', '5', 'Perfect for families', 'Circonstance toile art facile. Habiter espèce révolution rayon apprendre.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('19', '88', '89', '20', '1', 'Not as described', 'Citizen ahead method audience. Return or for cup quality.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('20', '64', '85', '8', '4', 'Very comfortable', 'Paso país finalmente comercio.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('21', '26', '85', '13', '2', 'Perfect for families', 'Intérieur joue succès chasse.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('22', '92', '79', '2', '1', 'Great location', 'Hilfe dein Schüler Oma. Erde darin schlimm Baum dein.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('23', '86', '65', '16', '4', 'Great location', 'Comment éteindre soutenir occasion résister pas. Tant naissance mettre décrire fumer magnifique six curieux.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('24', '34', '10', '16', '3', 'Could be better', 'Affaire grand sommet désigner habitant. Suffire non chemise mourir accent.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('25', '95', '43', '9', '1', 'Perfect for families', 'Safe mean international hour special recent better.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('26', '79', '29', '18', '4', 'Not as described', 'Mince action public tu.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('27', '46', '31', '3', '4', 'Hidden gem', 'Eran términos una cargo estas. Puso sean pero ninguna psoe temas producción.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('28', '53', '74', '15', '1', 'Hidden gem', 'Especie la formas buen amigo tenido segundo. Derecha p libre agua tiempos.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('29', '38', '58', '11', '1', 'Hidden gem', 'Lieb weiter Hase bald. Hat nämlich hat dunkel Monat beim.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('30', '21', '96', '1', '1', 'Not as described', 'Eran estos posibilidad visita cine lenguaje.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('31', '6', '53', '2', '5', 'Perfect for families', 'M mujeres análisis pueblo parte internacional.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('32', '81', '1', '3', '5', 'Clean and cozy', 'Satisfaire intérêt manquer salle surtout humide fait. Consulter sourire bataille foi.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('33', '27', '82', '10', '5', 'Perfect for families', 'Hacer muchas ve necesidad.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('34', '62', '27', '15', '3', 'Very comfortable', 'Más dado acto reforma soy ambos efectos como. Ni operación lado encuentran siquiera.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('35', '43', '7', '8', '4', 'Very comfortable', 'Permettre reprendre jour pitié manger mener. Emmener certes résister comment difficile joli vide.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('36', '31', '72', '20', '5', 'Hidden gem', 'Expect what peace claim movement consider.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('37', '1', '92', '12', '4', 'Would visit again', 'Mano también trata mucho.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('38', '69', '13', '8', '1', 'Very comfortable', 'Noche cambios partes imágenes. Policía televisión sea manos.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('39', '87', '46', '10', '5', 'Perfect for families', 'Shoulder way until choose wife national medical. Listen face want wonder off.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('40', '70', '48', '4', '1', 'Great location', 'Español poco posibilidad dos viene ante. Hablar consumo medida.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('41', '59', '64', '5', '4', 'Would visit again', 'Part crime money sit. Cultural base support quality whatever.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('42', '8', '33', '20', '2', 'Could be better', 'Leben nicht Licht bauen rund. Deshalb verlieren heiß helfen fünf Haare.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('43', '89', '16', '13', '2', 'Hidden gem', 'Cuisine souvenir que gauche. Durer révolution victime goutte supposer changement.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('44', '84', '25', '11', '1', 'Not as described', 'Denken gegen zusammen lustig. Beim wollen sofort blau ich Welt.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('45', '76', '6', '19', '1', 'Hidden gem', 'Impression monsieur terme couler savoir eaux justice.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('46', '32', '59', '19', '5', 'Great location', 'Central carta tarde enero casi. Instituto período pronto tomar área.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('47', '10', '64', '1', '5', 'Amazing stay!', 'Tapis pauvre âme réel larme vide nuit.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('48', '61', '71', '14', '5', 'Hidden gem', 'Fuerte dolor única nuevos acciones algo congreso. Para carlos comunicación decir visto realizar últimos.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('49', '50', '66', '6', '5', 'Great location', 'Information treatment green face morning view.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('50', '33', '94', '5', '1', 'Not as described', 'Ein Boden sitzen mein von tun schlafen gefährlich.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('51', '5', '85', '20', '5', 'Very comfortable', 'Cine distintos por dólares policía gonzález buena.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('52', '47', '65', '13', '4', 'Clean and cozy', 'Toda nadie social presenta decía.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('53', '49', '89', '8', '3', 'Not as described', 'Schreien Stück im wenig damit dauern also. Geld hart tot warum neu Sonne.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('54', '7', '44', '10', '4', 'Great location', 'Me cuba horas asunto otras.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('55', '17', '18', '14', '5', 'Perfect for families', 'Situación máximo medios serán.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('56', '42', '39', '18', '3', 'Perfect for families', 'Simple serious amount.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('57', '83', '81', '7', '2', 'Could be better', 'Or light training analysis feeling act benefit.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('58', '30', '80', '10', '3', 'Great location', 'Onto customer provide ahead certainly. We girl civil may rock.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('59', '19', '91', '6', '5', 'Perfect for families', 'Bien mirada serán varias vivir buscar personas. En baja llama toma ocasión hacía derecha.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO reviews (review_id, booking_id, guest_id, accommodation_id, rating, review_title, review_text, review_date, created_at) VALUES ('60', '74', '89', '11', '1', 'Very comfortable', 'Mujer igual tampoco ejemplo. Quién pequeño seguridad uso económica.', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');


-- rooms
-- Data for rooms
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('1', '1', 'Family 1', '1-001', '3', '1', '2', '201.39', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('2', '1', 'Standard 2', '1-002', '6', '2', '3', '147.28', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('3', '1', 'Family 3', '1-003', '10', '2', '1', '436.36', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('4', '2', 'Family 1', '2-001', '1', '2', '3', '464.51', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('5', '2', 'Family 2', '2-002', '4', '3', '1', '400.07', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('6', '2', 'Standard 3', '2-003', '8', '2', '1', '413.80', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('7', '3', 'Double 1', '3-001', '4', '1', '3', '120.77', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('8', '3', 'Deluxe 2', '3-002', '5', '3', '3', '269.42', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('9', '3', 'Single 3', '3-003', '1', '1', '2', '113.93', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('10', '3', 'Twin 4', '3-004', '1', '1', '3', '234.24', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('11', '4', 'Family 1', '4-001', '10', '1', '2', '452.77', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('12', '4', 'Standard 2', '4-002', '7', '1', '3', '465.02', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('13', '4', 'Double 3', '4-003', '6', '4', '1', '475.97', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('14', '4', 'Single 4', '4-004', '2', '3', '3', '175.36', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('15', '5', 'Twin 1', '5-001', '9', '2', '1', '227.61', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('16', '5', 'Suite 2', '5-002', '10', '3', '2', '287.53', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('17', '5', 'Twin 3', '5-003', '4', '4', '3', '315.13', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('18', '5', 'Penthouse 4', '5-004', '8', '2', '3', '252.40', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('19', '5', 'Suite 5', '5-005', '2', '3', '3', '342.01', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('20', '6', 'Double 1', '6-001', '5', '2', '1', '99.26', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('21', '6', 'Penthouse 2', '6-002', '10', '1', '2', '224.79', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('22', '7', 'Family 1', '7-001', '8', '4', '1', '99.36', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('23', '7', 'Deluxe 2', '7-002', '7', '2', '1', '407.93', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('24', '7', 'Penthouse 3', '7-003', '1', '2', '1', '244.54', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('25', '8', 'Single 1', '8-001', '8', '4', '3', '239.58', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('26', '8', 'Penthouse 2', '8-002', '8', '3', '1', '424.74', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('27', '8', 'Penthouse 3', '8-003', '4', '3', '2', '66.42', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('28', '8', 'Twin 4', '8-004', '6', '3', '3', '67.87', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('29', '8', 'Family 5', '8-005', '3', '2', '1', '224.99', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('30', '8', 'Penthouse 6', '8-006', '7', '1', '1', '421.46', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('31', '9', 'Standard 1', '9-001', '10', '4', '2', '32.77', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('32', '9', 'Family 2', '9-002', '7', '2', '2', '133.13', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('33', '9', 'Standard 3', '9-003', '7', '3', '3', '349.20', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('34', '9', 'Suite 4', '9-004', '8', '2', '3', '281.04', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('35', '9', 'Standard 5', '9-005', '2', '4', '1', '437.42', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('36', '9', 'Twin 6', '9-006', '7', '3', '1', '243.71', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('37', '10', 'Twin 1', '10-001', '7', '3', '1', '251.04', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('38', '10', 'Standard 2', '10-002', '6', '2', '3', '62.25', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('39', '10', 'Standard 3', '10-003', '1', '2', '1', '424.44', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('40', '10', 'Double 4', '10-004', '3', '4', '3', '83.76', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('41', '10', 'Penthouse 5', '10-005', '5', '3', '1', '314.77', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('42', '11', 'Suite 1', '11-001', '5', '1', '3', '42.07', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('43', '11', 'Family 2', '11-002', '7', '2', '1', '308.29', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('44', '12', 'Deluxe 1', '12-001', '5', '1', '3', '397.84', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('45', '12', 'Family 2', '12-002', '6', '1', '3', '334.35', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('46', '12', 'Family 3', '12-003', '8', '1', '2', '481.57', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('47', '13', 'Suite 1', '13-001', '7', '2', '3', '275.22', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('48', '13', 'Penthouse 2', '13-002', '8', '4', '3', '308.46', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('49', '13', 'Double 3', '13-003', '2', '3', '2', '144.62', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('50', '13', 'Family 4', '13-004', '6', '1', '2', '429.95', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('51', '13', 'Double 5', '13-005', '6', '3', '2', '161.44', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('52', '14', 'Standard 1', '14-001', '9', '2', '1', '143.44', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('53', '14', 'Double 2', '14-002', '8', '4', '2', '402.68', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('54', '14', 'Double 3', '14-003', '7', '2', '2', '342.06', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('55', '14', 'Single 4', '14-004', '7', '3', '2', '360.34', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('56', '15', 'Double 1', '15-001', '2', '2', '2', '86.19', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('57', '15', 'Suite 2', '15-002', '4', '2', '3', '257.57', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('58', '15', 'Twin 3', '15-003', '2', '2', '2', '136.92', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('59', '15', 'Standard 4', '15-004', '9', '2', '2', '51.39', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('60', '16', 'Suite 1', '16-001', '8', '1', '1', '299.81', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('61', '16', 'Penthouse 2', '16-002', '6', '2', '1', '148.66', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('62', '16', 'Deluxe 3', '16-003', '2', '4', '2', '64.82', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('63', '16', 'Standard 4', '16-004', '3', '2', '3', '476.09', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('64', '17', 'Deluxe 1', '17-001', '9', '4', '3', '310.18', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('65', '17', 'Family 2', '17-002', '8', '4', '2', '434.28', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('66', '17', 'Twin 3', '17-003', '10', '1', '3', '481.25', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('67', '18', 'Double 1', '18-001', '5', '1', '1', '142.74', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('68', '18', 'Suite 2', '18-002', '1', '4', '2', '354.00', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('69', '18', 'Standard 3', '18-003', '4', '3', '3', '162.88', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('70', '19', 'Double 1', '19-001', '5', '2', '2', '83.94', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('71', '19', 'Suite 2', '19-002', '5', '2', '1', '58.03', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('72', '20', 'Twin 1', '20-001', '8', '1', '2', '353.68', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('73', '20', 'Twin 2', '20-002', '9', '4', '2', '67.81', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('74', '20', 'Family 3', '20-003', '6', '3', '1', '72.92', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('75', '20', 'Standard 4', '20-004', '5', '1', '1', '251.14', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('76', '20', 'Twin 5', '20-005', '3', '4', '3', '412.70', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO rooms (room_id, accommodation_id, room_name, room_code, floor_number, capacity, bed_count, room_price_per_night, is_available, created_at, updated_at) VALUES ('77', '20', 'Penthouse 6', '20-006', '6', '4', '2', '180.90', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');


-- staff_users
-- Data for staff_users
INSERT INTO staff_users (staff_user_id, first_name, last_name, email, password_hash, role_name, is_active, created_at, updated_at) VALUES ('1', 'Paulette', 'Maldonado', 'carstenmatthias@example.com', '$2b$12$IK6SP3H2AagxddqW8QjdWmHwCMPInOyFXRQcxzWQ7dUm11BnNRwKT', 'Manager', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO staff_users (staff_user_id, first_name, last_name, email, password_hash, role_name, is_active, created_at, updated_at) VALUES ('2', 'Paul', 'Brunel', 'jgonzalez@example.com', '$2b$12$7slQlkFxAIiKpuSjjud5MPEJwWtnleFzHfnnuwnUG9Z8aPB4MM7Qt', 'Admin', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO staff_users (staff_user_id, first_name, last_name, email, password_hash, role_name, is_active, created_at, updated_at) VALUES ('3', 'Rita', 'Roche', 'xcrosby@example.org', '$2b$12$Hr4YxXBc3lF6k7HaePV1AgHR8WO6UjCufdXIJoqyNAbPHNMUKRe5g', 'Receptionist', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO staff_users (staff_user_id, first_name, last_name, email, password_hash, role_name, is_active, created_at, updated_at) VALUES ('4', 'Yolanda', 'Maillet', 'qkim@example.net', '$2b$12$r5xYbjnUX0sNs271O7a2icJyHfnTTn40ilMphPJdU9INePpmJ6wPo', 'Receptionist', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO staff_users (staff_user_id, first_name, last_name, email, password_hash, role_name, is_active, created_at, updated_at) VALUES ('5', 'David', 'Maréchal', 'weihmannstella@example.org', '$2b$12$3tBMsKJwtAapnTB0iT2CwsIkL01iHq2eebFbKzK4IH9DWwnVTsCFy', 'Accountant', 'f', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO staff_users (staff_user_id, first_name, last_name, email, password_hash, role_name, is_active, created_at, updated_at) VALUES ('6', 'Michael', 'Mireles', 'ocasillas@example.com', '$2b$12$o78QUijJJ2jT6cVoqoPGXy42cOg8NqTJJxxK3ep8nzYvX3a2BoFrj', 'Manager', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO staff_users (staff_user_id, first_name, last_name, email, password_hash, role_name, is_active, created_at, updated_at) VALUES ('7', 'Roger', 'Scheel', 'epalacio@example.net', '$2b$12$ShoYSDDnjZbcJjNcJdql7LIbSPrfB91kZLXYlOqSvCKoxgm1FAjfD', 'Accountant', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO staff_users (staff_user_id, first_name, last_name, email, password_hash, role_name, is_active, created_at, updated_at) VALUES ('8', 'Ulrike', 'Vallée', 'gaetano71@example.org', '$2b$12$2GUfO3Ha6QAA2RA6DVvX4ZJApV4fLHpaUaGGxmXzgAKqHJL9ymIIl', 'Accountant', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO staff_users (staff_user_id, first_name, last_name, email, password_hash, role_name, is_active, created_at, updated_at) VALUES ('9', 'Amelia', 'Grondin', 'camachocarlos@example.org', '$2b$12$ptvRT1OUBRknyuIRRj7afj5Adnecx9MGSL6YNBmOXrcLFokcoaj9W', 'Receptionist', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');
INSERT INTO staff_users (staff_user_id, first_name, last_name, email, password_hash, role_name, is_active, created_at, updated_at) VALUES ('10', 'Margaret', 'Stanton', 'honore49@example.net', '$2b$12$zmaR4ITIKvYo7CzakFIFvhFpHXpBxDpvWQ31DpxWnRXzvHRqryUvI', 'Manager', 't', '2026-04-15 01:23:25.356206', '2026-04-15 01:23:25.356206');


-- ----------------------------------------------------------------
-- 8. SETVAL SECUENCIAS
-- ----------------------------------------------------------------

SELECT pg_catalog.setval('accommodation_types_accommodation_type_id_seq', 8, true);

SELECT pg_catalog.setval('accommodations_accommodation_id_seq', 20, true);

SELECT pg_catalog.setval('amenities_amenity_id_seq', 10, true);

SELECT pg_catalog.setval('booking_guests_booking_guest_id_seq', 103, true);

SELECT pg_catalog.setval('booking_statuses_booking_status_id_seq', 6, true);

SELECT pg_catalog.setval('bookings_booking_id_seq', 100, true);

SELECT pg_catalog.setval('guests_guest_id_seq', 100, true);

SELECT pg_catalog.setval('locations_location_id_seq', 20, true);

SELECT pg_catalog.setval('owners_owner_id_seq', 20, true);

SELECT pg_catalog.setval('payments_payment_id_seq', 90, true);

SELECT pg_catalog.setval('reviews_review_id_seq', 60, true);

SELECT pg_catalog.setval('rooms_room_id_seq', 77, true);

SELECT pg_catalog.setval('staff_users_staff_user_id_seq', 10, true);

-- ----------------------------------------------------------------
-- 9. RESTRICCIONES PK/UNIQUE
-- ----------------------------------------------------------------

ALTER TABLE ONLY accommodation_amenities
    ADD CONSTRAINT accommodation_amenities_pkey PRIMARY KEY (accommodation_id, amenity_id);

ALTER TABLE ONLY accommodation_types
    ADD CONSTRAINT accommodation_types_pkey PRIMARY KEY (accommodation_type_id);

ALTER TABLE ONLY accommodation_types
    ADD CONSTRAINT accommodation_types_type_name_key UNIQUE (type_name);

ALTER TABLE ONLY accommodations
    ADD CONSTRAINT accommodations_pkey PRIMARY KEY (accommodation_id);

ALTER TABLE ONLY amenities
    ADD CONSTRAINT amenities_amenity_name_key UNIQUE (amenity_name);

ALTER TABLE ONLY amenities
    ADD CONSTRAINT amenities_pkey PRIMARY KEY (amenity_id);

ALTER TABLE ONLY booking_guests
    ADD CONSTRAINT booking_guests_pkey PRIMARY KEY (booking_guest_id);

ALTER TABLE ONLY booking_statuses
    ADD CONSTRAINT booking_statuses_pkey PRIMARY KEY (booking_status_id);

ALTER TABLE ONLY booking_statuses
    ADD CONSTRAINT booking_statuses_status_name_key UNIQUE (status_name);

ALTER TABLE ONLY bookings
    ADD CONSTRAINT bookings_booking_reference_key UNIQUE (booking_reference);

ALTER TABLE ONLY bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (booking_id);

ALTER TABLE ONLY guests
    ADD CONSTRAINT guests_email_key UNIQUE (email);

ALTER TABLE ONLY guests
    ADD CONSTRAINT guests_pkey PRIMARY KEY (guest_id);

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (location_id);

ALTER TABLE ONLY owners
    ADD CONSTRAINT owners_email_key UNIQUE (email);

ALTER TABLE ONLY owners
    ADD CONSTRAINT owners_pkey PRIMARY KEY (owner_id);

ALTER TABLE ONLY payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (payment_id);

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_booking_id_key UNIQUE (booking_id);

ALTER TABLE ONLY reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (review_id);

ALTER TABLE ONLY rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (room_id);

ALTER TABLE ONLY staff_users
    ADD CONSTRAINT staff_users_email_key UNIQUE (email);

ALTER TABLE ONLY staff_users
    ADD CONSTRAINT staff_users_pkey PRIMARY KEY (staff_user_id);

ALTER TABLE ONLY rooms
    ADD CONSTRAINT uq_room_code_per_accommodation UNIQUE (accommodation_id, room_code);

-- ----------------------------------------------------------------
-- 10. ÍNDICES
-- ----------------------------------------------------------------

CREATE INDEX idx_accommodations_location_id ON accommodations USING btree (location_id);

CREATE INDEX idx_accommodations_owner_id ON accommodations USING btree (owner_id);

CREATE INDEX idx_bookings_accommodation_id ON bookings USING btree (accommodation_id);

CREATE INDEX idx_bookings_check_in_date ON bookings USING btree (check_in_date);

CREATE INDEX idx_bookings_check_out_date ON bookings USING btree (check_out_date);

CREATE INDEX idx_bookings_guest_id ON bookings USING btree (guest_id);

CREATE INDEX idx_bookings_room_id ON bookings USING btree (room_id);

CREATE INDEX idx_bookings_status_id ON bookings USING btree (booking_status_id);

CREATE INDEX idx_payments_booking_id ON payments USING btree (booking_id);

CREATE INDEX idx_reviews_accommodation_id ON reviews USING btree (accommodation_id);

CREATE INDEX idx_reviews_guest_id ON reviews USING btree (guest_id);

CREATE INDEX idx_rooms_accommodation_id ON rooms USING btree (accommodation_id);

-- ----------------------------------------------------------------
-- 11. TRIGGERS
-- ----------------------------------------------------------------

CREATE TRIGGER trg_accommodations_updated_at BEFORE UPDATE ON accommodations FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_bookings_updated_at BEFORE UPDATE ON bookings FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_guests_updated_at BEFORE UPDATE ON guests FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_owners_updated_at BEFORE UPDATE ON owners FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_rooms_updated_at BEFORE UPDATE ON rooms FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_staff_users_updated_at BEFORE UPDATE ON staff_users FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ----------------------------------------------------------------
-- 12. CLAVES FORÁNEAS
-- ----------------------------------------------------------------

ALTER TABLE ONLY accommodation_amenities
    ADD CONSTRAINT fk_accommodation_amenity_accommodation FOREIGN KEY (accommodation_id) REFERENCES accommodations(accommodation_id) ON DELETE CASCADE;

ALTER TABLE ONLY accommodation_amenities
    ADD CONSTRAINT fk_accommodation_amenity_amenity FOREIGN KEY (amenity_id) REFERENCES amenities(amenity_id) ON DELETE CASCADE;

ALTER TABLE ONLY accommodations
    ADD CONSTRAINT fk_accommodation_location FOREIGN KEY (location_id) REFERENCES locations(location_id);

ALTER TABLE ONLY accommodations
    ADD CONSTRAINT fk_accommodation_owner FOREIGN KEY (owner_id) REFERENCES owners(owner_id);

ALTER TABLE ONLY accommodations
    ADD CONSTRAINT fk_accommodation_type FOREIGN KEY (accommodation_type_id) REFERENCES accommodation_types(accommodation_type_id);

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_booking_accommodation FOREIGN KEY (accommodation_id) REFERENCES accommodations(accommodation_id);

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_booking_guest FOREIGN KEY (guest_id) REFERENCES guests(guest_id);

ALTER TABLE ONLY booking_guests
    ADD CONSTRAINT fk_booking_guest_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE;

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_booking_room FOREIGN KEY (room_id) REFERENCES rooms(room_id);

ALTER TABLE ONLY bookings
    ADD CONSTRAINT fk_booking_status FOREIGN KEY (booking_status_id) REFERENCES booking_statuses(booking_status_id);

ALTER TABLE ONLY payments
    ADD CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE;

ALTER TABLE ONLY reviews
    ADD CONSTRAINT fk_review_accommodation FOREIGN KEY (accommodation_id) REFERENCES accommodations(accommodation_id);

ALTER TABLE ONLY reviews
    ADD CONSTRAINT fk_review_booking FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE;

ALTER TABLE ONLY reviews
    ADD CONSTRAINT fk_review_guest FOREIGN KEY (guest_id) REFERENCES guests(guest_id);

ALTER TABLE ONLY rooms
    ADD CONSTRAINT fk_room_accommodation FOREIGN KEY (accommodation_id) REFERENCES accommodations(accommodation_id) ON DELETE CASCADE;