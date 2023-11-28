import argparse
import random
from datetime import datetime, timedelta
from multiprocessing import Process, Queue, freeze_support
from time import sleep

import numpy as np
import pytz
from faker import Faker

import psycopg2.pool
from psycopg2.extensions import register_adapter, AsIs
from psycopg2.extras import execute_batch

register_adapter(np.int64, AsIs)

# Initialize Faker to generate fake data
fake = Faker()


def worker(inp, out, dbname, user, password, host, port):
    # Create a connection pool
    l_pool = psycopg2.pool.ThreadedConnectionPool(
        minconn=5,
        maxconn=5,
        dbname=dbname,
        user=user,
        password=password,
        host=host,
        port=port,
    )
    for func1, args1 in iter(inp.get, 'STOP'):
        out.put(func1(l_pool, *args1))


# Function to generate mock data for agents
def generate_agents_data(record_count: int):
    return [
        (
            fake.name()[:50],
            fake.job()[:50],
            fake.date_of_birth(minimum_age=22, maximum_age=65),
            fake.boolean()
        ) for _ in range(record_count)
    ]


# Function to generate mock data for customers
def generate_customers_data(record_count):
    return [
        (
            fake.name()[:50],
            fake.phone_number()[:15],
            fake.email()[:100],
            fake.address()[:200],
            fake.city()[:100],
            fake.country()[:100]
        ) for _ in range(record_count)
    ]


# Function to insert data into the tables using a connection from the pool
def insert_data(pool, table_name, col_list, data):
    con1 = None
    try:
        con1 = pool.getconn()
    except Exception as e:
        print(f"WAITING FOR CONNECTION FOR {table_name} {e}", flush=True)

    while con1 is None:
        sleep(1)
        try:
            con1 = pool.getconn()
        except Exception as e:
            print(f"WAITING FOR CONNECTION FOR {table_name} {e}", flush=True)
    try:
        with con1:
            with con1.cursor() as cur:
                placeholders = ', '.join(['%s'] * len(data[0]))
                insert_query = f"INSERT INTO {table_name}({col_list}) VALUES ({placeholders})"
                execute_batch(cur, insert_query, data)
                print(f"inserted into {table_name}.", flush=True)
    except Exception as e:
        print(f"INSERT INTO {table_name} FAILED {e}", flush=True)
    finally:
        pool.putconn(con1)


# Function to get the count of rows in agents table
def get_count(pool, table_name):
    conn = pool.getconn()
    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(f"SELECT COUNT(*) FROM {table_name}")
                count = cur.fetchone()[0]
                return count
    finally:
        pool.putconn(conn)


# Function to get the count of rows in agents table
def max_date(pool, table_name):
    conn = pool.getconn()
    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(
                    f"select date_trunc('day',coalesce(max(call_date) + interval '1 day',current_timestamp(3) - interval '90 days')) from {table_name}")
                l_start_dt = cur.fetchone()[0]
                if l_start_dt.weekday() > 4:
                    l_start_dt = l_start_dt - timedelta(days=(7 - l_start_dt.weekday()))
                return l_start_dt
    finally:
        pool.putconn(conn)


def gen_agent(pool, batch_sz):
    dat = generate_agents_data(batch_sz)
    insert_data(pool, 'agents', "agent_name, department, hire_date, is_active", dat)
    return f"gen_agent completed {batch_sz}"


def gen_customer(pool, batch_sz):
    dat = generate_customers_data(batch_sz)
    insert_data(pool, 'customers', "customer_name, phone_number, email, address, city, country", dat)
    return f"gen_customer completed {batch_sz}"


def gen_call_day(pool, start_date, bus_day, num_agents, num_customers, b_size):
    print(
        f"Kick off job for {start_date} with {bus_day} business day for num_agents {num_agents} and num_customers {num_customers}")
    start_date += timedelta(hours=8)  # start at 8am
    for agent in range(1, num_agents + 1):
        s_dt = start_date
        customer = (bus_day * num_agents) + agent
        call_list = []
        while customer < num_customers:
            call_length = timedelta(minutes=random.randint(4, 12))  # Call Duration
            call_list.append(
                (agent,
                 customer,
                 s_dt,
                 call_length,
                 fake.text(),
                 random.randint(1, 5),  # Satisfaction rating from 1 to 5
                 fake.text()
                 )
            )
            if len(call_list) > b_size:
                insert_data(pool, "calls",
                            "agent_id, customer_id, call_date, call_duration, call_purpose, satisfaction_rating, notes",
                            call_list)
                call_list = []
            s_dt += call_length
            s_dt += timedelta(minutes=random.randint(1, 5))  # Pause Between Calls
            customer += num_agents * days_to_cycle
        if len(call_list) > 0:
            insert_data(pool, "calls",
                        "agent_id, customer_id, call_date, call_duration, call_purpose, satisfaction_rating, notes",
                        call_list)


if __name__ == '__main__':
    freeze_support()

    # Parse command-line arguments
    parser = argparse.ArgumentParser(description='Insert mock data into PostgresSQL tables')
    parser.add_argument('--dbname', help='Database name', required=True)
    parser.add_argument('--user', help='Database user', required=True)
    parser.add_argument('--password', help='Database password', required=True)
    parser.add_argument('--host', help='Database host', required=True)
    parser.add_argument('--port', help='Database port', required=True)
    parser.add_argument('--num_jobs', help='Number of jobs to run parallel', required=True)
    parser.add_argument('--num_agents', help='Number of agents', required=True)
    parser.add_argument('--num_customers', help='Number of customers', required=True)
    args = parser.parse_args()

    # Create a connection pool
    connection_pool = psycopg2.pool.ThreadedConnectionPool(
        minconn=(int(args.num_jobs) * 6) + 1,
        maxconn=(int(args.num_jobs) * 6) + 1,
        dbname=args.dbname,
        user=args.user,
        password=args.password,
        host=args.host,
        port=int(args.port),
    )

    epic_date = datetime(2022, 1, 1).date()
    today = datetime.today().replace(tzinfo=pytz.utc)
    days_to_cycle = 22
    batch_size = 1000
    n_workers = int(args.num_jobs)

    # pool = mp.Pool(processes=n_workers)
    print(f"Starting with {n_workers} workers.", flush=True)
    task_queue = Queue()
    done_queue = Queue()
    for i in range(n_workers):
        Process(target=worker, args=(task_queue, done_queue, args.dbname, args.user, args.password, args.host, int(args.port))).start()

    # Generate data for agents table
    agents_count = get_count(connection_pool, "agents")
    min_batch = batch_size if (batch_size < int(args.num_agents)) else int(args.num_agents)
    tskCnt = 0
    while agents_count < int(args.num_agents):
        task_queue.put((gen_agent, [min_batch]))
        agents_count += min_batch
        tskCnt += 1
    for i in range(tskCnt):
        print(f"{done_queue.get()}")
    agents_count = get_count(connection_pool, "agents")
    print(f"Total Agents in Table: {agents_count}", flush=True)

    # Generate data for customers table
    customer_count = get_count(connection_pool, "customers")
    min_batch = batch_size if (batch_size < int(args.num_customers)) else int(args.num_customers)
    tskCnt = 0
    while customer_count < int(args.num_customers):
        task_queue.put((gen_customer, [min_batch]))
        customer_count += min_batch
        tskCnt += 1
    for i in range(tskCnt):
        print(f"{done_queue.get()}")
    customer_count = get_count(connection_pool, "customers")
    print(f"Total Customers in Table: {customer_count}", flush=True)

    # Generate data for calls table
    start_dt = max_date(connection_pool, "calls")
    bus_days = np.busday_count(epic_date, start_dt.date())
    tskCnt = 0
    while start_dt < today:
        task_queue.put((gen_call_day,
                       (start_dt, bus_days % days_to_cycle,
                        int(args.num_agents), int(args.num_customers), batch_size)))
        start_dt += timedelta(days=1)
        if start_dt.weekday() > 4:
            start_dt += timedelta(days=(7 - start_dt.weekday()))
        bus_days += 1
        tskCnt += 1
    for i in range(tskCnt):
        print(f"{done_queue.get()}")

    # Stop mulitithreaded prpocs
    for i in range(n_workers):
        task_queue.put('STOP')
    # Can add more to continue running today then staying real-time...
