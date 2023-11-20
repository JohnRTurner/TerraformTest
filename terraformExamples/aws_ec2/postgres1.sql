\l
select current_user, current_database();
CREATE TABLE IF NOT EXISTS words (
                                     id SERIAL PRIMARY KEY,
                                     word VARCHAR(500),
                                     create_time TIMESTAMP DEFAULT NOW()
);

insert into words values (DEFAULT, 'hi',DEFAULT), (DEFAULT, 'there',DEFAULT), (DEFAULT, 'everyone',DEFAULT);
create extension aiven_extras cascade;
select * from aiven_extras.pg_create_publication('cdc_words_pub','INSERT,UPDATE,DELETE','public.words');
select now();