\l
select current_user, current_database();

CREATE TABLE IF NOT EXISTS agents (
                        agent_id SERIAL PRIMARY KEY,
                        agent_name VARCHAR(50) NOT NULL,
                        department VARCHAR(50) NOT NULL,
                        hire_date DATE,
                        is_active BOOLEAN
);

CREATE TABLE IF NOT EXISTS customers (
                           customer_id SERIAL PRIMARY KEY,
                           customer_name VARCHAR(50) NOT NULL,
                           phone_number VARCHAR(15) NOT NULL,
                           email VARCHAR(100),
                           address VARCHAR(200),
                           city VARCHAR(100),
                           country VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS calls (
                       call_id SERIAL PRIMARY KEY,
                       agent_id INT REFERENCES agents(agent_id),
                       customer_id INT REFERENCES customers(customer_id),
                       call_date TIMESTAMP(3) NOT NULL,
                       call_duration INTERVAL,
                       call_purpose TEXT,
                       satisfaction_rating INT,
                       notes TEXT
);

create extension aiven_extras cascade;

select * from aiven_extras.pg_create_publication('cdc_cust_pub','INSERT,UPDATE,DELETE','public.customers', 'public.calls');



select now();