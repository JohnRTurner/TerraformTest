CREATE TABLE agents (
                        agent_id SERIAL PRIMARY KEY,
                        agent_name VARCHAR(50) NOT NULL,
                        department VARCHAR(50) NOT NULL,
                        hire_date DATE,
                        is_active BOOLEAN
);

CREATE TABLE customers (
                           customer_id SERIAL PRIMARY KEY,
                           customer_name VARCHAR(50) NOT NULL,
                           phone_number VARCHAR(15) NOT NULL,
                           email VARCHAR(100),
                           address VARCHAR(200),
                           city VARCHAR(100),
                           country VARCHAR(100)
);

CREATE TABLE calls (
                       call_id SERIAL PRIMARY KEY,
                       agent_id INT REFERENCES agents(agent_id),
                       customer_id INT REFERENCES customers(customer_id),
                       call_date TIMESTAMP(3) NOT NULL,
                       call_duration INTERVAL,
                       call_purpose TEXT,
                       satisfaction_rating INT,
                       notes TEXT
);
