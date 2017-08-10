--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.3
-- Dumped by pg_dump version 9.6.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pta_dist_14; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pta_dist_14;


ALTER SCHEMA pta_dist_14 OWNER TO postgres;

--
-- Name: pta_dist_14_private; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pta_dist_14_private;


ALTER SCHEMA pta_dist_14_private OWNER TO postgres;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = pta_dist_14, pg_catalog;

--
-- Name: jwt_token; Type: TYPE; Schema: pta_dist_14; Owner: postgres
--

CREATE TYPE jwt_token AS (
	role text,
	person_id integer
);


ALTER TYPE jwt_token OWNER TO postgres;

--
-- Name: post_topic; Type: TYPE; Schema: pta_dist_14; Owner: postgres
--

CREATE TYPE post_topic AS ENUM (
    'discussion',
    'inspiration',
    'help',
    'showcase'
);


ALTER TYPE post_topic OWNER TO postgres;

--
-- Name: authenticate(text, text); Type: FUNCTION; Schema: pta_dist_14; Owner: postgres
--

CREATE FUNCTION authenticate(email text, password text) RETURNS jwt_token
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $_$
declare
  account pta_dist_14_private.person_account;
begin
  select a.* into account
  from pta_dist_14_private.person_account as a
  where a.email = $1;

  if account.password_hash = crypt(password, account.password_hash) then
    return ('pta_dist_14_person', account.person_id)::pta_dist_14.jwt_token;
  else
    return null;
  end if;
end;
$_$;


ALTER FUNCTION pta_dist_14.authenticate(email text, password text) OWNER TO postgres;

--
-- Name: FUNCTION authenticate(email text, password text); Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON FUNCTION authenticate(email text, password text) IS 'Creates a JWT token that will securely identify a person and give them certain permissions.';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: person; Type: TABLE; Schema: pta_dist_14; Owner: postgres
--

CREATE TABLE person (
    id integer NOT NULL,
    first_name text NOT NULL,
    last_name text,
    about text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT person_first_name_check CHECK ((char_length(first_name) < 80)),
    CONSTRAINT person_last_name_check CHECK ((char_length(last_name) < 80))
);


ALTER TABLE person OWNER TO postgres;

--
-- Name: TABLE person; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON TABLE person IS 'A person of the forum.';


--
-- Name: COLUMN person.id; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN person.id IS 'The primary unique identifier for the person.';


--
-- Name: COLUMN person.first_name; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN person.first_name IS 'The person’s first name.';


--
-- Name: COLUMN person.last_name; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN person.last_name IS 'The person’s last name.';


--
-- Name: COLUMN person.about; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN person.about IS 'A short description about the person, written by the person.';


--
-- Name: COLUMN person.created_at; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN person.created_at IS 'The time this person was created.';


--
-- Name: current_person(); Type: FUNCTION; Schema: pta_dist_14; Owner: postgres
--

CREATE FUNCTION current_person() RETURNS person
    LANGUAGE sql STABLE
    AS $$
  select *
  from pta_dist_14.person
  where id = current_setting('jwt.claims.person_id')::integer
$$;


ALTER FUNCTION pta_dist_14.current_person() OWNER TO postgres;

--
-- Name: FUNCTION current_person(); Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON FUNCTION current_person() IS 'Gets the person who was identified by our JWT.';


--
-- Name: person_full_name(person); Type: FUNCTION; Schema: pta_dist_14; Owner: postgres
--

CREATE FUNCTION person_full_name(person person) RETURNS text
    LANGUAGE sql STABLE
    AS $$
	select person.first_name || ' ' || person.last_name
$$;


ALTER FUNCTION pta_dist_14.person_full_name(person person) OWNER TO postgres;

--
-- Name: FUNCTION person_full_name(person person); Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON FUNCTION person_full_name(person person) IS 'A person’s full name which is a concatenation of their first and last name.';


--
-- Name: post; Type: TABLE; Schema: pta_dist_14; Owner: postgres
--

CREATE TABLE post (
    id integer NOT NULL,
    author_id integer NOT NULL,
    headline text NOT NULL,
    body text,
    topic post_topic,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    CONSTRAINT post_headline_check CHECK ((char_length(headline) < 280))
);


ALTER TABLE post OWNER TO postgres;

--
-- Name: TABLE post; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON TABLE post IS 'A forum post written by a person.';


--
-- Name: COLUMN post.id; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN post.id IS 'The primary key for the post.';


--
-- Name: COLUMN post.author_id; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN post.author_id IS 'The id of the author person.';


--
-- Name: COLUMN post.headline; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN post.headline IS 'The title written by the person.';


--
-- Name: COLUMN post.body; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN post.body IS 'The main body text of our post.';


--
-- Name: COLUMN post.topic; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN post.topic IS 'The topic this has been posted in.';


--
-- Name: COLUMN post.created_at; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN post.created_at IS 'The time this post was created.';


--
-- Name: person_latest_post(person); Type: FUNCTION; Schema: pta_dist_14; Owner: postgres
--

CREATE FUNCTION person_latest_post(person person) RETURNS post
    LANGUAGE sql STABLE
    AS $$
  select post.*
  from pta_dist_14.post as post
  where post.author_id = person.id
  order by created_at desc
  limit 1
$$;


ALTER FUNCTION pta_dist_14.person_latest_post(person person) OWNER TO postgres;

--
-- Name: FUNCTION person_latest_post(person person); Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON FUNCTION person_latest_post(person person) IS 'Get’s the latest post written by the person.';


--
-- Name: post_summary(post, integer, text); Type: FUNCTION; Schema: pta_dist_14; Owner: postgres
--

CREATE FUNCTION post_summary(post post, length integer DEFAULT 50, omission text DEFAULT '…'::text) RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select case
    when post.body is null then null
    else substr(post.body, 0, length) || omission
  end
$$;


ALTER FUNCTION pta_dist_14.post_summary(post post, length integer, omission text) OWNER TO postgres;

--
-- Name: FUNCTION post_summary(post post, length integer, omission text); Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON FUNCTION post_summary(post post, length integer, omission text) IS 'A truncated version of the body for summaries.';


--
-- Name: register_person(text, text, text, text); Type: FUNCTION; Schema: pta_dist_14; Owner: postgres
--

CREATE FUNCTION register_person(first_name text, last_name text, email text, password text) RETURNS person
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
declare
  person pta_dist_14.person;
begin
  insert into pta_dist_14.person (first_name, last_name) values
    (first_name, last_name)
    returning * into person;

  insert into pta_dist_14_private.person_account (person_id, email, password_hash) values
    (person.id, email, crypt(password, gen_salt('bf')));

  return person;
end;
$$;


ALTER FUNCTION pta_dist_14.register_person(first_name text, last_name text, email text, password text) OWNER TO postgres;

--
-- Name: FUNCTION register_person(first_name text, last_name text, email text, password text); Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON FUNCTION register_person(first_name text, last_name text, email text, password text) IS 'Registers a single person and creates an account in our forum.';


--
-- Name: search_posts(text); Type: FUNCTION; Schema: pta_dist_14; Owner: postgres
--

CREATE FUNCTION search_posts(search text) RETURNS SETOF post
    LANGUAGE sql STABLE
    AS $$
  select post.*
  from pta_dist_14.post as post
  where post.headline ilike ('%' || search || '%') or post.body ilike ('%' || search || '%')
$$;


ALTER FUNCTION pta_dist_14.search_posts(search text) OWNER TO postgres;

--
-- Name: FUNCTION search_posts(search text); Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON FUNCTION search_posts(search text) IS 'Returns posts containing a given search term.';


SET search_path = pta_dist_14_private, pg_catalog;

--
-- Name: set_updated_at(); Type: FUNCTION; Schema: pta_dist_14_private; Owner: postgres
--

CREATE FUNCTION set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
  new.updated_at := current_timestamp;
  return new;
end;
$$;


ALTER FUNCTION pta_dist_14_private.set_updated_at() OWNER TO postgres;

SET search_path = pta_dist_14, pg_catalog;

--
-- Name: page; Type: TABLE; Schema: pta_dist_14; Owner: postgres
--

CREATE TABLE page (
    id integer NOT NULL,
    author_id integer NOT NULL,
    route text NOT NULL,
    title text NOT NULL,
    template text,
    data jsonb NOT NULL,
    style text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    parent_id integer,
    CONSTRAINT page_route_check CHECK ((char_length(route) < 2000)),
    CONSTRAINT page_route_check1 CHECK ((char_length(route) < 280))
);


ALTER TABLE page OWNER TO postgres;

--
-- Name: TABLE page; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON TABLE page IS 'A collection of pages for the app';


--
-- Name: COLUMN page.author_id; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN page.author_id IS 'The id of the person who created this page';


--
-- Name: COLUMN page.route; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN page.route IS 'The route where this page should be shown';


--
-- Name: COLUMN page.title; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN page.title IS 'The page title';


--
-- Name: COLUMN page.template; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN page.template IS 'The page template';


--
-- Name: COLUMN page.data; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN page.data IS 'Static data for the page template';


--
-- Name: COLUMN page.style; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN page.style IS 'Extra style to apply to template';


--
-- Name: COLUMN page.parent_id; Type: COMMENT; Schema: pta_dist_14; Owner: postgres
--

COMMENT ON COLUMN page.parent_id IS 'Id of parent page';


--
-- Name: page_id_seq; Type: SEQUENCE; Schema: pta_dist_14; Owner: postgres
--

CREATE SEQUENCE page_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE page_id_seq OWNER TO postgres;

--
-- Name: page_id_seq; Type: SEQUENCE OWNED BY; Schema: pta_dist_14; Owner: postgres
--

ALTER SEQUENCE page_id_seq OWNED BY page.id;


--
-- Name: person_id_seq; Type: SEQUENCE; Schema: pta_dist_14; Owner: postgres
--

CREATE SEQUENCE person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE person_id_seq OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: pta_dist_14; Owner: postgres
--

ALTER SEQUENCE person_id_seq OWNED BY person.id;


--
-- Name: post_id_seq; Type: SEQUENCE; Schema: pta_dist_14; Owner: postgres
--

CREATE SEQUENCE post_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE post_id_seq OWNER TO postgres;

--
-- Name: post_id_seq; Type: SEQUENCE OWNED BY; Schema: pta_dist_14; Owner: postgres
--

ALTER SEQUENCE post_id_seq OWNED BY post.id;


SET search_path = pta_dist_14_private, pg_catalog;

--
-- Name: person_account; Type: TABLE; Schema: pta_dist_14_private; Owner: postgres
--

CREATE TABLE person_account (
    person_id integer NOT NULL,
    email text NOT NULL,
    password_hash text NOT NULL,
    CONSTRAINT person_account_email_check CHECK ((email ~* '^.+@.+\..+$'::text))
);


ALTER TABLE person_account OWNER TO postgres;

--
-- Name: TABLE person_account; Type: COMMENT; Schema: pta_dist_14_private; Owner: postgres
--

COMMENT ON TABLE person_account IS 'Private information about a person’s account.';


--
-- Name: COLUMN person_account.person_id; Type: COMMENT; Schema: pta_dist_14_private; Owner: postgres
--

COMMENT ON COLUMN person_account.person_id IS 'The id of the person associated with this account.';


--
-- Name: COLUMN person_account.email; Type: COMMENT; Schema: pta_dist_14_private; Owner: postgres
--

COMMENT ON COLUMN person_account.email IS 'The email address of the person.';


--
-- Name: COLUMN person_account.password_hash; Type: COMMENT; Schema: pta_dist_14_private; Owner: postgres
--

COMMENT ON COLUMN person_account.password_hash IS 'An opaque hash of the person’s password.';


SET search_path = public, pg_catalog;

--
-- Name: schema_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE schema_info (
    version text NOT NULL
);


ALTER TABLE schema_info OWNER TO postgres;

SET search_path = pta_dist_14, pg_catalog;

--
-- Name: page id; Type: DEFAULT; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE ONLY page ALTER COLUMN id SET DEFAULT nextval('page_id_seq'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE ONLY person ALTER COLUMN id SET DEFAULT nextval('person_id_seq'::regclass);


--
-- Name: post id; Type: DEFAULT; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE ONLY post ALTER COLUMN id SET DEFAULT nextval('post_id_seq'::regclass);


--
-- Data for Name: page; Type: TABLE DATA; Schema: pta_dist_14; Owner: postgres
--

COPY page (id, author_id, route, title, template, data, style, created_at, updated_at, parent_id) FROM stdin;
3	1	board	Board	  <div v-static="{ h2: 'title', 'div.backdrop': 'body' }">     <jumbo-tron :title="title" :img="img"></jumbo-tron>    <div class="backdrop" v-html="body"> </div>  </div>	{"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<ul> \\n      <li><span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Abby Fellman - </span><a href=\\"mailto:14thdistpresident@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">President</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Christal Barquero - </span><a href=\\"mailto:14thReflections@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">VP/ Reflections</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Michelle Wing - </span><a href=\\"mailto:4thtreasurer@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Treasurer</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\"> </span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Elizabeth Smith-</span><a href=\\"mailto:14thsecretary@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Secretary</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">  </span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;margin-right: -13.5pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Nicole Turner - </span><a href=\\"mailto:14thrparea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Rohnert Park/ Cotati Area</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Samantha Bolinger - </span><a href=\\"mailto:14thPetalumaArea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Area</span></a></p><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Trish Luna - </span><a href=\\"mailto:WestArea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Coast Area</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\"> </span></span><br /></li>\\n      </ul>", "route": "/about/board", "title": "Board", "children": [], "parentId": 2}	\N	2017-07-31 17:18:46.503631	2017-08-03 22:15:38.758661	2
6	1	mission-statement	Mission Statement	  <div v-static="{ h2: 'title', 'div.backdrop': 'body' }">     <jumbo-tron :title="title" :img="img"></jumbo-tron>    <div class="backdrop" v-html="body"></div>  </div>	{"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">The mission of the 14th district is to improve the education, health, and well being of the children and families and Sonoma, Mendocino, and Lake County by advocating for cultivating and empowering units</span></p></span>", "route": "/about/mission-statement", "title": "Mission Statement", "children": [], "parentId": 2}	\N	2017-07-31 17:18:46.503631	2017-08-01 18:27:59.759932	2
9	1	welcome	Welcome	  <div v-static="{ h2: 'title', 'div.backdrop': 'body' }">     <jumbo-tron :title="title" :img="img"></jumbo-tron>    <div class="backdrop" v-html="body"></div>  </div>	{"img": "/public/balloon.jpg", "body": "The 14th District PTA serves Sonoma, Mendocino, and Lake counties. We are comprised of 45 school PTAs and have approximately 6,000 members. Our members are parents, administrators, teachers, students, and community members from around our community. &nbsp;<div><br>Are you looking for a PTA to join? &nbsp;Would you like to start a PTA at your school? &nbsp;Would you like to know more about what we do for kids? &nbsp;Contact us and let us know how we can help you!</div>", "route": "/home/welcome", "title": "Welcome", "children": [], "parentId": 1}	\N	2017-07-31 17:18:46.503631	2017-08-01 08:56:48.723746	1
8	1	units	Our Units	  <div v-static="{ h2: 'title', 'div.backdrop': 'body' }">     <jumbo-tron :title="title" :img="img"></jumbo-tron>    <div class="backdrop" v-html="body"></div>  </div>	{"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 13.5pt; font-family: Ubuntu; font-weight: 700; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Area PTA Units</span></p></span><span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><span></span></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"background-color: transparent; font-family: Arial; font-size: 10pt; font-style: italic; white-space: pre-wrap;\\">Casa Grande High School PTSA</span><br /></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Friends Of Penngrove Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Grant Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Kennilworth Jr High PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">La Tercera Elementary Boosters PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Loma Vista PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Mary COllins School at Cherry Valley PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McDowell PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McKinley PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McNear Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Meadow/ Corona Creek PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Miwok Valley Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Jr. High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Sonoma Mountain Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Valley Vista Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Wilson School PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><br /></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:13.5pt;font-family:Ubuntu;color:#000000;background-color:#ffffff;font-weight:700;font-style:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Rohnert Park/ Cotati Area PTA Units</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Evergreen Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">John Reed PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Lawrence E. Jones Middle School PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Marguerite Hahn Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Monte Vista PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Rancho Cotate High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Richard Crane PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Technology High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Technology Middle School PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Thomas Page PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">University at La Fiesta PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Waldo Rohnert Elementary School PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><b style=\\"font-weight:normal;\\"><br /></b></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:13.5pt;font-family:Ubuntu;color:#000000;background-color:#ffffff;font-weight:700;font-style:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Santa Rosa and North Area PTA Units</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Biella PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">CAVA@Sonoma PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Madrone Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Mark West School PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Meadow View PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Piner High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Proctor Terrace Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Riebli PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Spring Creek-Matanzas Charter PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Taylor Mountain PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Cali Calmecac PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Jefferson School PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Washington and Cloverdale High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Yokayo Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><b style=\\"font-weight:normal;\\"><br /></b></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:13.5pt;font-family:Ubuntu;color:#000000;background-color:#ffffff;font-weight:700;font-style:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">West Area PTA Units</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Bodega Bay Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Tomales Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><br /></span></p><div><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><br /></span></div></span>", "route": "/about/units", "title": "Our Units", "children": [], "parentId": 2}	\N	2017-07-31 17:18:46.503631	2017-08-03 22:12:43.274151	2
2	1	about	About	  <div class="row">    <jumbo-tron :title="title"></jumbo-tron>    <card v-for="(page, idx) in $store.state.page.data.children" :key="page.id"      v-bind:path="page.data.route"      v-bind:text="page.data.body"      v-bind:img="page.data.img"      v-bind:title="page.data.title"      v-bind:sub-title="page.data.subTitle"      v-bind:idx="idx"    ></card>  </div>	{"body": "here have some text", "route": "/about", "title": "About", "children": [{"id": 3, "data": {"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<ul> \\n      <li><span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Abby Fellman - </span><a href=\\"mailto:14thdistpresident@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">President</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Christal Barquero - </span><a href=\\"mailto:14thReflections@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">VP/ Reflections</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Michelle Wing - </span><a href=\\"mailto:4thtreasurer@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Treasurer</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\"> </span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Elizabeth Smith-</span><a href=\\"mailto:14thsecretary@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Secretary</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">  </span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;margin-right: -13.5pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Nicole Turner - </span><a href=\\"mailto:14thrparea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Rohnert Park/ Cotati Area</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Samantha Bolinger - </span><a href=\\"mailto:14thPetalumaArea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Area</span></a></p><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Trish Luna - </span><a href=\\"mailto:WestArea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Coast Area</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\"> </span></span><br /></li>\\n      </ul>", "text": "<ul> \\n      <li><span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Abby Fellman - </span><a href=\\"mailto:14thdistpresident@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">President</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Christal Barquero - </span><a href=\\"mailto:14thReflections@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">VP/ Reflections</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Michelle Wing - </span><a href=\\"mailto:4thtreasurer@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Treasurer</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\"> </span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Elizabeth Smith-</span><a href=\\"mailto:14thsecretary@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Secretary</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">  </span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;margin-right: -13.5pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Nicole Turner - </span><a href=\\"mailto:14thrparea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Rohnert Park/ Cotati Area</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Samantha Bolinger - </span><a href=\\"mailto:14thPetalumaArea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Area</span></a></p><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Trish Luna - </span><a href=\\"mailto:WestArea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Coast Area</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\"> </span></span><br /></li>\\n      </ul><span style=\\"float: right;\\">cF</span>", "route": "/about/board", "title": "Board", "children": [], "parentId": 2}, "path": "/about/board", "route": "board", "title": "Board", "parentId": 2, "template": "  <div v-static=\\"{ h2: 'title', 'div.backdrop': 'body' }\\">     <jumbo-tron :title=\\"title\\" :img=\\"img\\"></jumbo-tron>    <div class=\\"backdrop\\" v-html=\\"body\\"> </div>  </div>", "__typename": "Page"}, {"id": 5, "data": {"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Join our team!  We are looking for volunteers to help in these rolls:</span></p><br /><ul style=\\"margin-top:0pt;margin-bottom:0pt;\\"><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Santa Rosa &amp; North Area Coordinator</span></p></li><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Diversity &amp; Inclusion VP</span></p></li><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Student Board Member</span></p></li><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Communications VP</span></p></li></ul><br /><span style=\\"font-size: 11pt; font-family: Arial; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Email </span><a href=\\"mailto:14thdistpresident@gmail.com\\"><span style=\\"font-size: 11pt; font-family: Arial; color: rgb(17, 85, 204); background-color: transparent; text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">14thdistpresident@gmail.com</span></a><span style=\\"font-size: 11pt; font-family: Arial; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\"> for more information.</span></span>", "route": "/about/join", "title": "Join Our Team", "children": [], "parentId": 2}, "path": "/about/join", "route": "join", "title": "Join Our Team", "parentId": 2, "template": "  <div v-static=\\"{ h2: 'title', 'div.backdrop': 'body' }\\">     <jumbo-tron :title=\\"title\\" :img=\\"img\\"></jumbo-tron>    <div class=\\"backdrop\\" v-html=\\"body\\"></div>   </div>", "__typename": "Page"}, {"id": 6, "data": {"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">The mission of the 14th district is to improve the education, health, and well being of the children and families and Sonoma, Mendocino, and Lake County by advocating for cultivating and empowering units</span></p></span>", "route": "/about/mission-statement", "title": "Mission Statement", "children": [], "parentId": 2}, "path": "/about/mission-statement", "route": "mission-statement", "title": "Mission Statement", "parentId": 2, "template": "  <div v-static=\\"{ h2: 'title', 'div.backdrop': 'body' }\\">     <jumbo-tron :title=\\"title\\" :img=\\"img\\"></jumbo-tron>    <div class=\\"backdrop\\" v-html=\\"body\\"></div>  </div>", "__typename": "Page"}, {"id": 8, "data": {"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 13.5pt; font-family: Ubuntu; font-weight: 700; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Area PTA Units</span></p></span><span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><span></span></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"background-color: transparent; font-family: Arial; font-size: 10pt; font-style: italic; white-space: pre-wrap;\\">Casa Grande High School PTSA</span><br /></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Friends Of Penngrove Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Grant Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Kennilworth Jr High PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">La Tercera Elementary Boosters PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Loma Vista PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Mary COllins School at Cherry Valley PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McDowell PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McKinley PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McNear Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Meadow/ Corona Creek PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Miwok Valley Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Jr. High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Sonoma Mountain Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Valley Vista Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Wilson School PTA</span></p></span>", "text": "<span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 13.5pt; font-family: Ubuntu; font-weight: 700; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Area PTA Units</span></p></span><span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><span></span></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"background-color: transparent; font-family: Arial; font-size: 10pt; font-style: italic; white-space: pre-wrap;\\">Casa Grande High School PTSA</span><br /></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Friends Of Penngrove Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Grant Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Kennilworth Jr High PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">La Tercera Elementary Boosters PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Loma Vista PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Mary COllins School at Cherry Valley PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McDowell PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McKinley PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McNear Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Meadow/ Corona Creek PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Miwok Valley Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Jr. High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Sonoma Mountain Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Valley Vista Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Wilson School PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><br /></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><b style=\\"font-weight:normal;\\"><br /></b></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:13.5pt;font-family:Ubuntu;color:#000000;background-color:#ffffff;font-weight:700;font-style:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">West Area PTA Units</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Bodega Bay Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Tomales Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><br /></span></p><div><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><br /></span></div></span>", "route": "/about/units", "title": "Petaluma Area PTA Units", "children": [], "parentId": 2}, "path": "/about/units", "route": "units", "title": "Our Units", "parentId": 2, "template": "  <div v-static=\\"{ h2: 'title', 'div.backdrop': 'body' }\\">     <jumbo-tron :title=\\"title\\" :img=\\"img\\"></jumbo-tron>    <div class=\\"backdrop\\" v-html=\\"body\\"></div>  </div>", "__typename": "Page"}, {"data": {"body": "<p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Evergreen Elementary PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">John Reed PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Lawrence E. Jones Middle School PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Marguerite Hahn Elementary PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Monte Vista PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Rancho Cotate High PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Richard Crane PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Technology High PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Technology Middle School PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Thomas Page PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">University at La Fiesta PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Waldo Rohnert Elementary School PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><br /></span></p><span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;margin-right: -72pt;\\"><span style=\\"font-size: 20pt; font-family: Ubuntu; background-color: transparent; font-weight: 700; vertical-align: baseline; white-space: pre-wrap;\\">West Area</span></p></span><span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;margin-right: -72pt;\\"><span style=\\"background-color: transparent; font-family: Arial; font-size: 10pt; font-style: italic; white-space: pre-wrap;\\">Bodega Bay PTA</span><br /></p></span><div><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Tomales Elementary PTA</span></p></div>", "text": "<p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Evergreen Elementary PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">John Reed PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Lawrence E. Jones Middle School PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Marguerite Hahn Elementary PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Monte Vista PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Rancho Cotate High PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Richard Crane PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Technology High PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Technology Middle School PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Thomas Page PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">University at La Fiesta PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Waldo Rohnert Elementary School PTA</span></p>", "title": "Rohnert Park/Cotati Area PTA Units"}}, {"data": {"body": "<p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Biella PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">CAVA@Sonoma PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Madrone Elementary PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Mark West School PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Meadow View PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Piner High PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Proctor Terrace Elementary PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Riebli PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Spring Creek-Matanzas Charter PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Taylor Mountain PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Cali Calmecac PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Jefferson School PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Washington and Cloverdale High PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Yokayo Elementary PTA</span></p>", "text": "card <span style=\\"background-color: transparent; font-family: Arial; font-size: 10pt; font-style: italic; white-space: pre-wrap;\\">Biella PTA</span><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">CAVA@Sonoma PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Madrone Elementary PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Mark West School PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Meadow View PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Piner High PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Proctor Terrace Elementary PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Riebli PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Spring Creek-Matanzas Charter PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Taylor Mountain PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Cali Calmecac PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Jefferson School PTA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Washington and Cloverdale High PTSA</span></p><p style=\\"margin-top: 0pt; margin-bottom: 0pt; line-height: 1.38;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Yokayo Elementary PTA</span></p><div><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><br /></span></div>", "title": "Santa Rosa and North Area PTA Units"}}], "childPages": [{"id": 3, "data": {"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<ul> \\n      <li><span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Abby Fellman - </span><a href=\\"mailto:14thdistpresident@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">President</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Christal Barquero - </span><a href=\\"mailto:14thReflections@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">VP/ Reflections</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Michelle Wing - </span><a href=\\"mailto:4thtreasurer@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Treasurer</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\"> </span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Elizabeth Smith-</span><a href=\\"mailto:14thsecretary@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Secretary</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">  </span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;margin-right: -13.5pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Nicole Turner - </span><a href=\\"mailto:14thrparea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Rohnert Park/ Cotati Area</span></a></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Samantha Bolinger - </span><a href=\\"mailto:14thPetalumaArea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Area</span></a></p><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Trish Luna - </span><a href=\\"mailto:WestArea@gmail.com\\"><span style=\\"font-size: 10pt; font-family: Verdana; color: rgb(17, 85, 204); text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">Coast Area</span></a><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\"> </span></span><br /></li>\\n      </ul>", "route": "/about/board", "title": "Board", "children": [], "parentId": 2, "childPages": []}, "path": "/about/board", "route": "board", "title": "Board", "parentId": 2, "template": "  <div v-static=\\"{ h2: 'title', 'div.backdrop': 'body' }\\">     <jumbo-tron :title=\\"title\\" :img=\\"img\\"></jumbo-tron>    <div class=\\"backdrop\\" v-html=\\"body\\"> </div>  </div>", "__typename": "Page"}, {"id": 5, "data": {"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Join our team!  We are looking for volunteers to help in these rolls:</span></p><br /><ul style=\\"margin-top:0pt;margin-bottom:0pt;\\"><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Santa Rosa &amp; North Area Coordinator</span></p></li><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Diversity &amp; Inclusion VP</span></p></li><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Student Board Member</span></p></li><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Communications VP</span></p></li></ul><br /><span style=\\"font-size: 11pt; font-family: Arial; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Email </span><a href=\\"mailto:14thdistpresident@gmail.com\\"><span style=\\"font-size: 11pt; font-family: Arial; color: rgb(17, 85, 204); background-color: transparent; text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">14thdistpresident@gmail.com</span></a><span style=\\"font-size: 11pt; font-family: Arial; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\"> for more information.</span></span>", "route": "/about/join", "title": "Join Our Team", "children": [], "parentId": 2, "childPages": []}, "path": "/about/join", "route": "join", "title": "Join Our Team", "parentId": 2, "template": "  <div v-static=\\"{ h2: 'title', 'div.backdrop': 'body' }\\">     <jumbo-tron :title=\\"title\\" :img=\\"img\\"></jumbo-tron>    <div class=\\"backdrop\\" v-html=\\"body\\"></div>   </div>", "__typename": "Page"}, {"id": 6, "data": {"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">The mission of the 14th district is to improve the education, health, and well being of the children and families and Sonoma, Mendocino, and Lake County by advocating for cultivating and empowering units</span></p></span>", "route": "/about/mission-statement", "title": "Mission Statement", "children": [], "parentId": 2, "childPages": []}, "path": "/about/mission-statement", "route": "mission-statement", "title": "Mission Statement", "parentId": 2, "template": "  <div v-static=\\"{ h2: 'title', 'div.backdrop': 'body' }\\">     <jumbo-tron :title=\\"title\\" :img=\\"img\\"></jumbo-tron>    <div class=\\"backdrop\\" v-html=\\"body\\"></div>  </div>", "__typename": "Page"}, {"id": 8, "data": {"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 13.5pt; font-family: Ubuntu; font-weight: 700; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Area PTA Units</span></p></span><span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><span></span></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"background-color: transparent; font-family: Arial; font-size: 10pt; font-style: italic; white-space: pre-wrap;\\">Casa Grande High School PTSA</span><br /></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Friends Of Penngrove Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Grant Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Kennilworth Jr High PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">La Tercera Elementary Boosters PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Loma Vista PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Mary COllins School at Cherry Valley PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McDowell PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McKinley PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">McNear Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Meadow/ Corona Creek PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Miwok Valley Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Petaluma Jr. High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Sonoma Mountain Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Valley Vista Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\">Wilson School PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><br /></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:13.5pt;font-family:Ubuntu;color:#000000;background-color:#ffffff;font-weight:700;font-style:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Rohnert Park/ Cotati Area PTA Units</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Evergreen Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">John Reed PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Lawrence E. Jones Middle School PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Marguerite Hahn Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Monte Vista PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Rancho Cotate High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Richard Crane PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Technology High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Technology Middle School PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Thomas Page PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">University at La Fiesta PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Waldo Rohnert Elementary School PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><b style=\\"font-weight:normal;\\"><br /></b></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:13.5pt;font-family:Ubuntu;color:#000000;background-color:#ffffff;font-weight:700;font-style:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Santa Rosa and North Area PTA Units</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Biella PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">CAVA@Sonoma PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Madrone Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Mark West School PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Meadow View PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Piner High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Proctor Terrace Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Riebli PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Spring Creek-Matanzas Charter PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Taylor Mountain PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Cali Calmecac PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Jefferson School PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Washington and Cloverdale High PTSA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Yokayo Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><b style=\\"font-weight:normal;\\"><br /></b></span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:13.5pt;font-family:Ubuntu;color:#000000;background-color:#ffffff;font-weight:700;font-style:normal;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">West Area PTA Units</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Bodega Bay Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size:10pt;font-family:Arial;color:#000000;background-color:transparent;font-weight:400;font-style:italic;font-variant:normal;text-decoration:none;vertical-align:baseline;white-space:pre-wrap;\\">Tomales Elementary PTA</span></p><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><br /></span></p><div><span style=\\"font-size: 10pt; font-family: Arial; background-color: transparent; font-style: italic; vertical-align: baseline; white-space: pre-wrap;\\"><br /></span></div></span>", "route": "/about/units", "title": "Our Units", "children": [], "parentId": 2, "childPages": []}, "path": "/about/units", "route": "units", "title": "Our Units", "parentId": 2, "template": "  <div v-static=\\"{ h2: 'title', 'div.backdrop': 'body' }\\">     <jumbo-tron :title=\\"title\\" :img=\\"img\\"></jumbo-tron>    <div class=\\"backdrop\\" v-html=\\"body\\"></div>  </div>", "__typename": "Page"}]}	\N	2017-07-31 17:18:46.503631	2017-08-06 16:06:24.189411	\N
7	1	programs	Programs	  <div class="row">    <jumbo-tron :title="title"></jumbo-tron>    <card v-for="(link, idx) in links" :key="link.id"      v-bind:idx="idx"      v-bind:url="link.url"      v-bind:title="link.title"      v-bind:text="link.text"      v-static="{ '.snippet': 'text', '.card-title': 'title', ctx: link }"    ></card>  </div>	{"links": [{"url": "http://capta.org/programs-events/reflections/", "text": "<p><span style=\\"background-color: rgb(255, 255, 255); color: black; font-family: -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, Roboto, Oxygen, Ubuntu, Cantarell, &quot;Fira Sans&quot;, &quot;Droid Sans&quot;, &quot;Helvetica Neue&quot;, sans-serif;\\">Students are encouraged to explore their creative side in this program which fosters creativity and offers recognition!</span></p><p>This year's theme: Within Reach</p>", "title": "Reflections"}, {"url": "http://www.pta.org/programs/familyreading.cfm?ItemNumber=4733&navItemNumber=4765", "text": "<p>Parents take part in the fun with their kids and leave the event with a deeper understanding of the simple ways they can support the core skills of literacy.<br /></p>", "title": "Family Reading Experience"}, {"url": "http://www.pta.org/programs/content.cfm?ItemNumber=3003&navItemNumber=3984", "text": "<p></p><p>(C4R) is National PTA’s initiative to help students, parents and educators to create school climates full of safe and supportive peer relationships.</p>", "title": "Connect for Respect"}, {"url": "http://www.pta.org/programs/content.cfm?ItemNumber=4280&navItemNumber=4216", "text": "<p>The Healthy Lifestyles program provides family centered education and tools that connect them with schools and advocate for healthy changes in nutrition and physical activity.</p>", "title": "Healthy Lifestyles"}, {"url": "http://www.pta.org/programs/content.cfm?ItemNumber=3789&navItemNumber=4631", "text": "Six activity lesson plans (children k-5 and their families) addressing safety concerns", "title": "Safety At Home And At Play / Safety Toolkit"}, {"url": "http://www.pta.org/programs/familytoschool.cfm?ItemNumber=3262&navItemNumber=5106", "text": "<p>Help us celebrate PTA’s long legacy of family engagement during National PTA's Take Your Family to School Week—Feb. 11-18, 2018.</p>", "title": "Take Your Family to School Week"}, {"url": "http://www.pta.org/programs/content.cfm?ItemNumber=3792", "text": "<p>This collection of 28 lesson plans helps parents and teachers emphasize the importance of developing healthy habits in fun and interesting ways. </p><div><br /></div>", "title": "Healthy Habits"}, {"url": "https://thesmarttalk.org/#/", "text": "The Smart Talk gets parents and kids together for a conversation about being responsible with new technology.", "title": "Smart Talk"}, {"url": "http://s3.amazonaws.com/rdcms-pta/files/production/public/TYFTSW_Guide_MulticulturalGuide-2016.pdf", "text": "<p>A Multi-Cultural event allows families to share elements of their culture or ethnicity with other members of the school community using food, dance, arts, etc.  </p>", "title": "Multi-Cultural Event"}, {"url": "http://s3.amazonaws.com/rdcms-pta/files/production/public/TYFTSW_Guide_CreativeCareer-2016.pdf", "text": "This is an interactive experience and a powerful tool for career exploration.  Families connect a student’s current interest in the arts with tomorrow’s career potential.  Parents and students will get to see how investing in the arts now can influence careers in a wide variety of fields", "title": "Creative Career Fair Guide"}, {"url": "http://www.pta.org/parents/content.cfm?ItemNumber=3616", "text": "The National PTA Military Alliance for Parents and Partners(MAPP) is a group of organizations that work together to provide resources to and advocate for military-connected families.", "title": "Military Alliance "}, {"url": "http://www.pta.org/programs/content.cfm?ItemNumber=3274", "text": "<p>This program will help PTAs and parents find different ways to volunteer at home, in school, and in the community—all which support student learning. This way, parents can volunteer when they have time!<br /></p>", "title": "PTA Three for Me"}], "route": "/programs", "title": "Programs", "children": [], "childPages": []}	\N	2017-07-31 17:18:46.503631	2017-08-06 16:46:47.639032	\N
5	1	join	Join Our Team	  <div v-static="{ h2: 'title', 'div.backdrop': 'body' }">     <jumbo-tron :title="title" :img="img"></jumbo-tron>    <div class="backdrop" v-html="body"></div>   </div>	{"img": "http://thecatapi.com/api/images/get?format=src&type=gif&size=med", "body": "<span><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; font-family: Verdana; vertical-align: baseline; white-space: pre-wrap;\\">Join our team!  We are looking for volunteers to help in these rolls:</span></p><br /><ul style=\\"margin-top:0pt;margin-bottom:0pt;\\"><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Santa Rosa &amp; North Area Coordinator</span></p></li><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Diversity &amp; Inclusion VP</span></p></li><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Student Board Member</span></p></li><li style=\\"list-style-type: disc; font-size: 10pt; font-family: Verdana; background-color: transparent; vertical-align: baseline;\\"><p style=\\"line-height:1.38;margin-top:0pt;margin-bottom:0pt;\\"><span style=\\"font-size: 10pt; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Communications VP</span></p></li></ul><br /><span style=\\"font-size: 11pt; font-family: Arial; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\">Email </span><a href=\\"mailto:14thdistpresident@gmail.com\\"><span style=\\"font-size: 11pt; font-family: Arial; color: rgb(17, 85, 204); background-color: transparent; text-decoration-line: underline; vertical-align: baseline; white-space: pre-wrap;\\">14thdistpresident@gmail.com</span></a><span style=\\"font-size: 11pt; font-family: Arial; background-color: transparent; vertical-align: baseline; white-space: pre-wrap;\\"> for more information.</span></span>", "route": "/about/join", "title": "Join Our Team", "children": [], "parentId": 2}	\N	2017-07-31 17:18:46.503631	2017-08-01 18:30:34.750144	2
4	1	forms	Forms	  <div class="row">    <jumbo-tron :title="title"></jumbo-tron>    <card v-for="(link, idx) in links" :key="link.id"      v-bind:idx="idx"      v-bind:url="link.path"      v-bind:title="link.title"      v-bind:text="link.text"      v-static="{ '.snippet': 'text', '.card-title': 'title', ctx: link }"    ></card>  </div>	{"links": [{"path": "path", "text": "This form will be emailed to unit presidents each month and will be fillable from your email.", "title": "Monthly Unit Report"}, {"path": "/public/forms/2017-2018 unit remittance form.pdf", "text": "To be included with all forms and payments mailed to the 14th District.  ", "type": "pdf", "title": "Unit Remittance Form "}, {"path": "/public/forms/Annual Workers Comp 2016.pdf", "text": "To be submitted to 14th District annually in November.  Mail with a Remittance Form and your insurance check!", "type": "pdf", "title": "Annual Workers Comp "}, {"path": "/public/forms/PTA UNIT BANK INFORMATION FORM.pdf", "text": "To be submitted to 14th District annually in September", "type": "pdf", "title": "Unit Bank Information Form"}, {"path": "/public/forms/ChangeOfStatus--fillable copy.pdf", "text": "replace me", "type": "pdf", "title": "Fillable Change Of Status "}, {"path": "/public/forms/Bylaws_Submittal Form - Units.doc", "text": "This form MUST be submitted to the 14th District with your newly revised bylaws.<span style=\\"background-color: rgb(238, 238, 238); color: black; font-family: -apple-system, BlinkMacSystemFont, &quot;Segoe UI&quot;, Roboto, Oxygen, Ubuntu, Cantarell, &quot;Fira Sans&quot;, &quot;Droid Sans&quot;, &quot;Helvetica Neue&quot;, sans-serif;\\"> </span>", "type": "doc", "title": "Bylaws Submittal Form   Units"}, {"path": "/public/forms/Unit_Bylaws_ES_OOC_FILLABLE2016.pdf", "text": "Modifique esta plantilla de los estatuos para requisitos particulares para su unidad.  Primero, lea la hoja de instrucciones de revision de los estatuos", "type": "pdf", "title": "Fillable Unit Bylaws (Español)"}, {"path": "/public/forms/Bylaws_Unit_OOC_2017-FILLABLE.pdf", "text": "Customize this bylaws template for your unit.  First, read the Bylaws Review Instruction sheet!<div><br /></div><div><br /></div>", "type": "pdf", "title": "Fillable Unit Bylaws (English)"}, {"path": "/public/forms/Annual Financial Rept.pdf", "text": "To be submitted via PTA EZ by September 15th", "title": "Annual Financial Report (example)"}, {"path": "/public/forms/AuditChkList-Rept.pdf", "text": "To be submitted via PTA EZ by September 15th AND by March 15th each year.", "title": "Audit Checklist and Report"}, {"path": "/public/forms/rrf1_form.pdf", "text": "To be submitted via PTA EZ by November 15th", "title": "Charitable Trust- RRF1"}, {"path": "/public/forms/ct_nrp_2.pdf", "text": "If your unit will have any raffles this year, you MUST submit this form by October.", "title": "Non Profit Raffle Registration - CT-NRP-1<div><br /></div>"}, {"path": "/public/forms/AnnualHistorianRept.pdf", "text": "This annual report is due by April 15th (with projected numbers thru the end of June)", "title": "Historian Report and Volunteer Tally"}, {"path": "/public/forms/PymtAuth.pdf", "text": "Use this basic check request for all payments from the PTA checking account.", "title": "Payment Authorization / Check Request "}, {"path": "/public/forms/cashverification2016updated.pdf", "text": "Use this basic cash verification form to tally all PTA income.  Remember to have 2 people counting the cash together!", "title": "Cash Verification "}], "route": "/forms", "title": "Forms", "children": [], "childPages": []}	\N	2017-07-31 17:18:46.503631	2017-08-06 16:29:40.720748	\N
1	1	home	Home	  <div class="row">    <jumbo-tron :title="title"></jumbo-tron>    <card v-for="(page, idx) in $store.state.page.data.children" :key="page.id"      v-bind:path="page.data.route"      v-bind:text="page.data.body"      v-bind:img="page.data.img"      v-bind:title="page.data.title"      v-bind:sub-title="page.data.subTitle"      v-bind:idx="idx"    ></card>  </div>	{"body": "here have some text", "route": "/home", "title": "Home", "welcome": {"text": "<p>The 14th District PTA serves Sonoma, Mendocino, and Lake counties. We are comprised of 45 school PTAs and have approximately 6,000 members. Our members are parents, administrators, teachers, students, and community members from around our community who are excited to invest in the children in our community.</p><p>Are you looking for a PTA to join? Would you like to start a PTA at your school? Would you like to know more about what we do for kids? Contact us and let us know how we can help you!</p>", "title": "<h4>Welcome to the 14th District PTA!                     <br /></h4>"}, "children": [{"id": 9, "data": {"img": "/public/balloon.jpg", "body": "The 14th District PTA serves Sonoma, Mendocino, and Lake counties. We are comprised of 45 school PTAs and have approximately 6,000 members. Our members are parents, administrators, teachers, students, and community members from around our community. &nbsp;<div><br>Are you looking for a PTA to join? &nbsp;Would you like to start a PTA at your school? &nbsp;Would you like to know more about what we do for kids? &nbsp;Contact us and let us know how we can help you!</div>", "route": "/home/welcome", "title": "Welcome", "children": [], "parentId": 1}, "path": "/home/welcome", "route": "welcome", "title": "Welcome", "parentId": 1, "template": "  <div v-static=\\"{ h2: 'title', 'div.backdrop': 'body' }\\">     <jumbo-tron :title=\\"title\\" :img=\\"img\\"></jumbo-tron>    <div class=\\"backdrop\\" v-html=\\"body\\"></div>  </div>", "__typename": "Page"}], "childPages": [{"id": 9, "data": {"img": "/public/balloon.jpg", "body": "The 14th District PTA serves Sonoma, Mendocino, and Lake counties. We are comprised of 45 school PTAs and have approximately 6,000 members. Our members are parents, administrators, teachers, students, and community members from around our community. &nbsp;<div><br>Are you looking for a PTA to join? &nbsp;Would you like to start a PTA at your school? &nbsp;Would you like to know more about what we do for kids? &nbsp;Contact us and let us know how we can help you!</div>", "route": "/home/welcome", "title": "Welcome", "children": [], "parentId": 1, "childPages": []}, "path": "/home/welcome", "route": "welcome", "title": "Welcome", "parentId": 1, "template": "  <div v-static=\\"{ h2: 'title', 'div.backdrop': 'body' }\\">     <jumbo-tron :title=\\"title\\" :img=\\"img\\"></jumbo-tron>    <div class=\\"backdrop\\" v-html=\\"body\\"></div>  </div>", "__typename": "Page"}], "announcements": {"text": "<div>Date: Sunday August 13, 2017</div><div>Time: 8:00 A.M.(doors open) - 3:00 P.M.</div><div>Location: SCOE, 5340 Skylane Blvd. Santa Rosa</div><div>Cost: $10.00 per person for lunch </div><div><br /></div><div><b style=\\"color: rgb(17, 85, 204); font-family: arial, sans-serif; text-size-adjust: auto; background-color: rgb(255, 255, 255);\\">     <a href=\\"https://docs.google.com/forms/d/e/1FAIpQLSd4wdqPRlY3pxqsy7rsC-aIJzrm39_xW8S39bgTLEFanHZPMQ/viewform?usp=sf_link\\" style=\\"color: rgb(17, 85, 204); font-family: arial, sans-serif; text-size-adjust: auto; background-color: rgb(255, 255, 255);\\">Click here to register online now!</a></b><br /></div>", "title": "           Join us for the <div>        14th District Training!</div>"}}	\N	2017-07-31 17:18:46.503631	2017-08-06 16:42:33.281749	\N
10	1	calendar	Calendar	  <div class="row">    <jumbo-tron :title="title"></jumbo-tron>    <card v-for="(page, idx) in $store.state.page.data.children" :key="page.id"      v-bind:path="page.data.route"      v-bind:text="page.data.body"      v-bind:img="page.data.img"      v-bind:title="page.data.title"      v-bind:sub-title="page.data.subTitle"      v-bind:idx="idx"    ></card>  </div>	{"body": "here have have a calendar", "title": "Calendar"}	\N	2017-08-06 20:37:36.052553	2017-08-06 20:37:36.052553	\N
\.


--
-- Name: page_id_seq; Type: SEQUENCE SET; Schema: pta_dist_14; Owner: postgres
--

SELECT pg_catalog.setval('page_id_seq', 10, true);


--
-- Data for Name: person; Type: TABLE DATA; Schema: pta_dist_14; Owner: postgres
--

COPY person (id, first_name, last_name, about, created_at, updated_at) FROM stdin;
1	Sara	Powell	\N	2015-07-03 14:11:30	2017-07-31 17:18:46.488555
2	Andrea	Fox	\N	1999-04-04 21:21:42	2017-07-31 17:18:46.488555
3	Stephen	Banks	\N	2003-12-09 04:39:10	2017-07-31 17:18:46.488555
4	Kathy	\N	\N	2001-11-03 15:37:15	2017-07-31 17:18:46.488555
5	Kenneth	Williams	\N	2002-08-16 19:03:47	2017-07-31 17:18:46.488555
6	Ann	Peterson	\N	2013-09-24 15:05:29	2017-07-31 17:18:46.488555
7	Gloria	Lee	Curabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo.	2007-04-23 12:56:09	2017-07-31 17:18:46.488555
8	Douglas	\N	\N	2008-07-10 21:49:16	2017-07-31 17:18:46.488555
9	Jeffrey	Palmer	\N	2000-07-28 22:33:20	2017-07-31 17:18:46.488555
10	Robert	Fisher	Suspendisse potenti. Cras in purus eu magna vulputate luctus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.	2000-06-12 09:11:56	2017-07-31 17:18:46.488555
\.


--
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: pta_dist_14; Owner: postgres
--

SELECT pg_catalog.setval('person_id_seq', 11, false);


--
-- Data for Name: post; Type: TABLE DATA; Schema: pta_dist_14; Owner: postgres
--

COPY post (id, author_id, headline, body, topic, created_at, updated_at) FROM stdin;
1	1	Ameliorated optimal emulation	Aenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.	\N	2011-06-01 09:27:57	2017-07-31 17:18:46.488555
2	6	Open-source non-volatile protocol	In hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.	\N	2001-02-18 16:35:03	2017-07-31 17:18:46.488555
3	1	Decentralized tangible circuit	Maecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.	\N	2006-10-08 01:42:03	2017-07-31 17:18:46.488555
4	8	Secured exuding challenge	Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.	\N	2010-09-11 19:51:48	2017-07-31 17:18:46.488555
5	4	Devolved empowering workforce	Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.	\N	2003-04-29 00:29:15	2017-07-31 17:18:46.488555
6	8	Optional actuating forecast	Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.	discussion	2006-02-10 01:39:13	2017-07-31 17:18:46.488555
25	6	Seamless system-worthy info-mediaries	Nulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.	\N	2005-06-17 17:48:28	2017-07-31 17:18:46.488555
7	3	Profound reciprocal product	Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.	inspiration	1999-09-24 04:47:33	2017-07-31 17:18:46.488555
8	6	Balanced uniform complexity	Etiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.	showcase	2001-07-07 01:59:11	2017-07-31 17:18:46.488555
9	2	Centralized bifurcated alliance	Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.	\N	2005-03-30 10:57:22	2017-07-31 17:18:46.488555
10	1	Self-enabling dynamic capacity	Phasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.	inspiration	2007-02-17 14:23:43	2017-07-31 17:18:46.488555
11	4	Proactive zero administration portal	In quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.	\N	2011-04-15 02:55:23	2017-07-31 17:18:46.488555
12	10	Cloned interactive info-mediaries	Morbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.	\N	2015-05-13 02:11:01	2017-07-31 17:18:46.488555
13	6	Up-sized encompassing open architecture	Vestibulum quam sapien, varius ut, blandit non, interdum in, ante. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Duis faucibus accumsan odio. Curabitur convallis.\n\nDuis consequat dui nec nisi volutpat eleifend. Donec ut dolor. Morbi vel lectus in quam fringilla rhoncus.\n\nMauris enim leo, rhoncus sed, vestibulum sit amet, cursus id, turpis. Integer aliquet, massa id lobortis convallis, tortor risus dapibus augue, vel accumsan tellus nisi eu orci. Mauris lacinia sapien quis libero.\n\nNullam sit amet turpis elementum ligula vehicula consequat. Morbi a ipsum. Integer a nibh.\n\nIn quis justo. Maecenas rhoncus aliquam lacus. Morbi quis tortor id nulla ultrices aliquet.\n\nMaecenas leo odio, condimentum id, luctus nec, molestie sed, justo. Pellentesque viverra pede ac diam. Cras pellentesque volutpat dui.\n\nMaecenas tristique, est et tempus semper, est quam pharetra magna, ac consequat metus sapien ut nunc. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Mauris viverra diam vitae quam. Suspendisse potenti.\n\nNullam porttitor lacus at turpis. Donec posuere metus vitae ipsum. Aliquam non mauris.\n\nMorbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.	showcase	2016-06-22 17:58:39	2017-07-31 17:18:46.488555
14	2	Robust next generation project	Donec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.	\N	2013-03-17 23:41:48	2017-07-31 17:18:46.488555
15	9	Ameliorated systemic challenge	\N	inspiration	2010-05-18 01:12:19	2017-07-31 17:18:46.488555
16	8	Streamlined uniform instruction set	Proin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.	inspiration	2000-10-28 15:19:54	2017-07-31 17:18:46.488555
17	7	Reactive asymmetric hierarchy	Integer ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.\n\nCurabitur at ipsum ac tellus semper interdum. Mauris ullamcorper purus sit amet nulla. Quisque arcu libero, rutrum ac, lobortis vel, dapibus at, diam.	\N	2005-08-25 09:38:48	2017-07-31 17:18:46.488555
18	10	Function-based radical intranet	Sed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.	\N	2002-05-15 16:24:42	2017-07-31 17:18:46.488555
19	3	Ergonomic even-keeled firmware	Integer tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.	\N	2004-05-20 05:03:30	2017-07-31 17:18:46.488555
20	6	Cross-platform hybrid support	Praesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.	help	2010-12-13 23:30:01	2017-07-31 17:18:46.488555
21	2	Organic needs-based emulation	In sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.	\N	2002-04-08 03:01:02	2017-07-31 17:18:46.488555
22	2	Monitored disintermediate flexibility	Praesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.\n\nIn congue. Etiam justo. Etiam pretium iaculis justo.\n\nIn hac habitasse platea dictumst. Etiam faucibus cursus urna. Ut tellus.\n\nNulla ut erat id mauris vulputate elementum. Nullam varius. Nulla facilisi.\n\nCras non velit nec nisi vulputate nonummy. Maecenas tincidunt lacus at velit. Vivamus vel nulla eget eros elementum pellentesque.\n\nQuisque porta volutpat erat. Quisque erat eros, viverra eget, congue eget, semper rutrum, nulla. Nunc purus.\n\nPhasellus in felis. Donec semper sapien a libero. Nam dui.\n\nProin leo odio, porttitor id, consequat in, consequat ut, nulla. Sed accumsan felis. Ut at dolor quis odio consequat varius.\n\nInteger ac leo. Pellentesque ultrices mattis odio. Donec vitae nisi.\n\nNam ultrices, libero non mattis pulvinar, nulla pede ullamcorper augue, a suscipit nulla elit ac nulla. Sed vel enim sit amet nunc viverra dapibus. Nulla suscipit ligula in lacus.	inspiration	2003-07-09 22:53:17	2017-07-31 17:18:46.488555
23	9	Secured 5th generation help-desk	Duis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.	help	2012-07-18 17:38:09	2017-07-31 17:18:46.488555
24	3	Customizable intermediate framework	Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.	\N	2010-05-29 16:41:03	2017-07-31 17:18:46.488555
26	5	Integrated high-level circuit	Fusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.\n\nIn hac habitasse platea dictumst. Morbi vestibulum, velit id pretium iaculis, diam erat fermentum justo, nec condimentum neque sapien placerat ante. Nulla justo.\n\nAliquam quis turpis eget elit sodales scelerisque. Mauris sit amet eros. Suspendisse accumsan tortor quis turpis.\n\nSed ante. Vivamus tortor. Duis mattis egestas metus.\n\nAenean fermentum. Donec ut mauris eget massa tempor convallis. Nulla neque libero, convallis eget, eleifend luctus, ultricies eu, nibh.\n\nQuisque id justo sit amet sapien dignissim vestibulum. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nulla dapibus dolor vel est. Donec odio justo, sollicitudin ut, suscipit a, feugiat et, eros.\n\nVestibulum ac est lacinia nisi venenatis tristique. Fusce congue, diam id ornare imperdiet, sapien urna pretium nisl, ut volutpat sapien arcu sed augue. Aliquam erat volutpat.	\N	2011-09-08 07:14:15	2017-07-31 17:18:46.488555
27	2	Integrated needs-based matrices	Morbi non lectus. Aliquam sit amet diam in magna bibendum imperdiet. Nullam orci pede, venenatis non, sodales sed, tincidunt eu, felis.\n\nFusce posuere felis sed lacus. Morbi sem mauris, laoreet ut, rhoncus aliquet, pulvinar sed, nisl. Nunc rhoncus dui vel sem.\n\nSed sagittis. Nam congue, risus semper porta volutpat, quam pede lobortis ligula, sit amet eleifend pede libero quis orci. Nullam molestie nibh in lectus.\n\nPellentesque at nulla. Suspendisse potenti. Cras in purus eu magna vulputate luctus.\n\nCum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Vivamus vestibulum sagittis sapien. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.\n\nEtiam vel augue. Vestibulum rutrum rutrum neque. Aenean auctor gravida sem.\n\nPraesent id massa id nisl venenatis lacinia. Aenean sit amet justo. Morbi ut odio.\n\nCras mi pede, malesuada in, imperdiet et, commodo vulputate, justo. In blandit ultrices enim. Lorem ipsum dolor sit amet, consectetuer adipiscing elit.\n\nProin interdum mauris non ligula pellentesque ultrices. Phasellus id sapien in sapien iaculis congue. Vivamus metus arcu, adipiscing molestie, hendrerit at, vulputate vitae, nisl.\n\nAenean lectus. Pellentesque eget nunc. Donec quis orci eget orci vehicula condimentum.\n\nCurabitur in libero ut massa volutpat convallis. Morbi odio odio, elementum eu, interdum eu, tincidunt in, leo. Maecenas pulvinar lobortis est.\n\nPhasellus sit amet erat. Nulla tempus. Vivamus in felis eu sapien cursus vestibulum.\n\nProin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.	showcase	2015-07-03 18:23:59	2017-07-31 17:18:46.488555
28	9	User-friendly asynchronous emulation	\N	\N	2015-07-12 10:49:26	2017-07-31 17:18:46.488555
29	10	Compatible needs-based implementation	\N	help	2011-09-30 14:11:44	2017-07-31 17:18:46.488555
30	7	Pre-emptive exuding algorithm	Proin eu mi. Nulla ac enim. In tempor, turpis nec euismod scelerisque, quam turpis adipiscing lorem, vitae mattis nibh ligula nec sem.\n\nDuis aliquam convallis nunc. Proin at turpis a pede posuere nonummy. Integer non velit.\n\nDonec diam neque, vestibulum eget, vulputate ut, ultrices vel, augue. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Donec pharetra, magna vestibulum aliquet ultrices, erat tortor sollicitudin mi, sit amet lobortis sapien sapien non mi. Integer ac neque.\n\nDuis bibendum. Morbi non quam nec dui luctus rutrum. Nulla tellus.\n\nIn sagittis dui vel nisl. Duis ac nibh. Fusce lacus purus, aliquet at, feugiat non, pretium quis, lectus.\n\nSuspendisse potenti. In eleifend quam a odio. In hac habitasse platea dictumst.\n\nMaecenas ut massa quis augue luctus tincidunt. Nulla mollis molestie lorem. Quisque ut erat.\n\nCurabitur gravida nisi at nibh. In hac habitasse platea dictumst. Aliquam augue quam, sollicitudin vitae, consectetuer eget, rutrum at, lorem.\n\nInteger tincidunt ante vel ipsum. Praesent blandit lacinia erat. Vestibulum sed magna at nunc commodo placerat.\n\nPraesent blandit. Nam nulla. Integer pede justo, lacinia eget, tincidunt eget, tempus vel, pede.\n\nMorbi porttitor lorem id ligula. Suspendisse ornare consequat lectus. In est risus, auctor sed, tristique in, tempus sit amet, sem.\n\nFusce consequat. Nulla nisl. Nunc nisl.\n\nDuis bibendum, felis sed interdum venenatis, turpis enim blandit mi, in porttitor pede justo eu massa. Donec dapibus. Duis at velit eu est congue elementum.	\N	2001-11-13 19:44:44	2017-07-31 17:18:46.488555
\.


--
-- Name: post_id_seq; Type: SEQUENCE SET; Schema: pta_dist_14; Owner: postgres
--

SELECT pg_catalog.setval('post_id_seq', 31, false);


SET search_path = pta_dist_14_private, pg_catalog;

--
-- Data for Name: person_account; Type: TABLE DATA; Schema: pta_dist_14_private; Owner: postgres
--

COPY person_account (person_id, email, password_hash) FROM stdin;
1	spowell0@noaa.gov	$2a$06$.Ryt.S6xCN./QmTx3r9Meu/nsk.4Ypfuj.o9qIqv4p3iipCWY45Bi
2	afox1@npr.org	$2a$06$FS4C7kwDs6tSrrjh0TITLuQ/pAjUHuCH0TBukHC.2m5n.Z1HxApRO
3	sbanks2@blog.com	$2a$06$i7AoCg3pbAOmf8J2w/lGpukUfDuRdfyUrR/mN7I0x.AYZb3Ak6DYS
4	kaustin3@nyu.edu	$2a$06$YJJ.vNqGcrKcX4ZtPl1nG.crDhCCoA6t5tWXkAokvprG4nytdWNli
5	kwilliams4@paypal.com	$2a$06$Mx2dB7Y1yfL7WhCg0JHNLetBeIgsOqxRbKBOPc1Kv66lYEfbPghzi
6	apeterson5@webnode.com	$2a$06$wCdceaTUqf9fxp/j6hswk.pWp9aY7N2HMQeNKb2TJZMUm.i8IZ.3G
7	glee6@arizona.edu	$2a$06$WQiZeChX8yUR14DAshXKd.W6cwz0tsvf49IaNhmM65FkFJVr8GEgW
8	drodriguez7@mashable.com	$2a$06$8Wa.RA33V4MrCIKQ1rAJIu7HMJSLjTZLcZY1zrlU4fZrJOIVFtvQS
9	jpalmer8@washingtonpost.com	$2a$06$q3H4ngUMZ9ADz3utyzGRX.6pWrzmPurqEjKtm7qzbYJrmSEYrsYvu
10	rfisher9@nytimes.com	$2a$06$lvLbqB8u.BVnqa8Zmy5E0.1LgSyKJkBnRYztVu3gO.hE6kCIsx2YK
\.


SET search_path = public, pg_catalog;

--
-- Data for Name: schema_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY schema_info (version) FROM stdin;
2017-06-16T06:42:50.401Z-init.sql
2017-06-16T06:42:51.401Z-posts.sql
2017-06-16T07:07:30.523Z-auth.sql
2017-06-16T08:05:02.751Z-post-seed-data.sql
2017-07-11T20:34:00.627Z-pages.sql
2017-07-14T06:48:57.618Z-page-seed-data.sql
2017-08-06T19:01:00.706Z-calendar-page.sql
\.


SET search_path = pta_dist_14, pg_catalog;

--
-- Name: page page_pkey; Type: CONSTRAINT; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE ONLY page
    ADD CONSTRAINT page_pkey PRIMARY KEY (id);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE ONLY person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id);


--
-- Name: post post_pkey; Type: CONSTRAINT; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE ONLY post
    ADD CONSTRAINT post_pkey PRIMARY KEY (id);


SET search_path = pta_dist_14_private, pg_catalog;

--
-- Name: person_account person_account_email_key; Type: CONSTRAINT; Schema: pta_dist_14_private; Owner: postgres
--

ALTER TABLE ONLY person_account
    ADD CONSTRAINT person_account_email_key UNIQUE (email);


--
-- Name: person_account person_account_pkey; Type: CONSTRAINT; Schema: pta_dist_14_private; Owner: postgres
--

ALTER TABLE ONLY person_account
    ADD CONSTRAINT person_account_pkey PRIMARY KEY (person_id);


SET search_path = public, pg_catalog;

--
-- Name: schema_info schema_info_version_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY schema_info
    ADD CONSTRAINT schema_info_version_key UNIQUE (version);


SET search_path = pta_dist_14, pg_catalog;

--
-- Name: page page_updated_at; Type: TRIGGER; Schema: pta_dist_14; Owner: postgres
--

CREATE TRIGGER page_updated_at BEFORE UPDATE ON page FOR EACH ROW EXECUTE PROCEDURE pta_dist_14_private.set_updated_at();


--
-- Name: person person_updated_at; Type: TRIGGER; Schema: pta_dist_14; Owner: postgres
--

CREATE TRIGGER person_updated_at BEFORE UPDATE ON person FOR EACH ROW EXECUTE PROCEDURE pta_dist_14_private.set_updated_at();


--
-- Name: post post_updated_at; Type: TRIGGER; Schema: pta_dist_14; Owner: postgres
--

CREATE TRIGGER post_updated_at BEFORE UPDATE ON post FOR EACH ROW EXECUTE PROCEDURE pta_dist_14_private.set_updated_at();


--
-- Name: page page_author_id_fkey; Type: FK CONSTRAINT; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE ONLY page
    ADD CONSTRAINT page_author_id_fkey FOREIGN KEY (author_id) REFERENCES person(id);


--
-- Name: page page_parent_id_fkey; Type: FK CONSTRAINT; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE ONLY page
    ADD CONSTRAINT page_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES page(id);


--
-- Name: post post_author_id_fkey; Type: FK CONSTRAINT; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE ONLY post
    ADD CONSTRAINT post_author_id_fkey FOREIGN KEY (author_id) REFERENCES person(id);


SET search_path = pta_dist_14_private, pg_catalog;

--
-- Name: person_account person_account_person_id_fkey; Type: FK CONSTRAINT; Schema: pta_dist_14_private; Owner: postgres
--

ALTER TABLE ONLY person_account
    ADD CONSTRAINT person_account_person_id_fkey FOREIGN KEY (person_id) REFERENCES pta_dist_14.person(id) ON DELETE CASCADE;


SET search_path = pta_dist_14, pg_catalog;

--
-- Name: person delete_person; Type: POLICY; Schema: pta_dist_14; Owner: postgres
--

CREATE POLICY delete_person ON person FOR DELETE TO pta_dist_14_person USING ((id = (current_setting('jwt.claims.person_id'::text))::integer));


--
-- Name: post delete_post; Type: POLICY; Schema: pta_dist_14; Owner: postgres
--

CREATE POLICY delete_post ON post FOR DELETE TO pta_dist_14_person USING ((author_id = (current_setting('jwt.claims.person_id'::text))::integer));


--
-- Name: post insert_post; Type: POLICY; Schema: pta_dist_14; Owner: postgres
--

CREATE POLICY insert_post ON post FOR INSERT TO pta_dist_14_person WITH CHECK ((author_id = (current_setting('jwt.claims.person_id'::text))::integer));


--
-- Name: person; Type: ROW SECURITY; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE person ENABLE ROW LEVEL SECURITY;

--
-- Name: post; Type: ROW SECURITY; Schema: pta_dist_14; Owner: postgres
--

ALTER TABLE post ENABLE ROW LEVEL SECURITY;

--
-- Name: person select_person; Type: POLICY; Schema: pta_dist_14; Owner: postgres
--

CREATE POLICY select_person ON person FOR SELECT TO PUBLIC USING (true);


--
-- Name: post select_post; Type: POLICY; Schema: pta_dist_14; Owner: postgres
--

CREATE POLICY select_post ON post FOR SELECT TO PUBLIC USING (true);


--
-- Name: person update_person; Type: POLICY; Schema: pta_dist_14; Owner: postgres
--

CREATE POLICY update_person ON person FOR UPDATE TO pta_dist_14_person USING ((id = (current_setting('jwt.claims.person_id'::text))::integer));


--
-- Name: post update_post; Type: POLICY; Schema: pta_dist_14; Owner: postgres
--

CREATE POLICY update_post ON post FOR UPDATE TO pta_dist_14_person USING ((author_id = (current_setting('jwt.claims.person_id'::text))::integer));


--
-- Name: pta_dist_14; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA pta_dist_14 TO pta_dist_14_person;
GRANT USAGE ON SCHEMA pta_dist_14 TO pta_dist_14_anonymous;


--
-- Name: authenticate(text, text); Type: ACL; Schema: pta_dist_14; Owner: postgres
--

REVOKE ALL ON FUNCTION authenticate(email text, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION authenticate(email text, password text) TO pta_dist_14_person;
GRANT ALL ON FUNCTION authenticate(email text, password text) TO pta_dist_14_anonymous;


--
-- Name: person; Type: ACL; Schema: pta_dist_14; Owner: postgres
--

GRANT SELECT ON TABLE person TO pta_dist_14_anonymous;
GRANT SELECT,DELETE,UPDATE ON TABLE person TO pta_dist_14_person;


--
-- Name: current_person(); Type: ACL; Schema: pta_dist_14; Owner: postgres
--

REVOKE ALL ON FUNCTION current_person() FROM PUBLIC;
GRANT ALL ON FUNCTION current_person() TO pta_dist_14_person;
GRANT ALL ON FUNCTION current_person() TO pta_dist_14_anonymous;


--
-- Name: person_full_name(person); Type: ACL; Schema: pta_dist_14; Owner: postgres
--

REVOKE ALL ON FUNCTION person_full_name(person person) FROM PUBLIC;
GRANT ALL ON FUNCTION person_full_name(person person) TO pta_dist_14_person;
GRANT ALL ON FUNCTION person_full_name(person person) TO pta_dist_14_anonymous;


--
-- Name: post; Type: ACL; Schema: pta_dist_14; Owner: postgres
--

GRANT SELECT ON TABLE post TO pta_dist_14_anonymous;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE post TO pta_dist_14_person;


--
-- Name: person_latest_post(person); Type: ACL; Schema: pta_dist_14; Owner: postgres
--

REVOKE ALL ON FUNCTION person_latest_post(person person) FROM PUBLIC;
GRANT ALL ON FUNCTION person_latest_post(person person) TO pta_dist_14_person;
GRANT ALL ON FUNCTION person_latest_post(person person) TO pta_dist_14_anonymous;


--
-- Name: post_summary(post, integer, text); Type: ACL; Schema: pta_dist_14; Owner: postgres
--

REVOKE ALL ON FUNCTION post_summary(post post, length integer, omission text) FROM PUBLIC;
GRANT ALL ON FUNCTION post_summary(post post, length integer, omission text) TO pta_dist_14_person;
GRANT ALL ON FUNCTION post_summary(post post, length integer, omission text) TO pta_dist_14_anonymous;


--
-- Name: register_person(text, text, text, text); Type: ACL; Schema: pta_dist_14; Owner: postgres
--

REVOKE ALL ON FUNCTION register_person(first_name text, last_name text, email text, password text) FROM PUBLIC;
GRANT ALL ON FUNCTION register_person(first_name text, last_name text, email text, password text) TO pta_dist_14_anonymous;


--
-- Name: search_posts(text); Type: ACL; Schema: pta_dist_14; Owner: postgres
--

REVOKE ALL ON FUNCTION search_posts(search text) FROM PUBLIC;
GRANT ALL ON FUNCTION search_posts(search text) TO pta_dist_14_person;
GRANT ALL ON FUNCTION search_posts(search text) TO pta_dist_14_anonymous;


SET search_path = pta_dist_14_private, pg_catalog;

--
-- Name: set_updated_at(); Type: ACL; Schema: pta_dist_14_private; Owner: postgres
--

REVOKE ALL ON FUNCTION set_updated_at() FROM PUBLIC;


SET search_path = pta_dist_14, pg_catalog;

--
-- Name: page; Type: ACL; Schema: pta_dist_14; Owner: postgres
--

GRANT SELECT ON TABLE page TO pta_dist_14_anonymous;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE page TO pta_dist_14_person;


--
-- Name: post_id_seq; Type: ACL; Schema: pta_dist_14; Owner: postgres
--

GRANT USAGE ON SEQUENCE post_id_seq TO pta_dist_14_person;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: -; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres REVOKE ALL ON FUNCTIONS  FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

