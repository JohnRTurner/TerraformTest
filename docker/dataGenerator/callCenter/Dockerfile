#Deriving the latest base image
FROM python:3.9.6
LABEL Maintainer="jturner"
WORKDIR /opt/app
COPY  . /opt/app/
RUN pip install -r requirements.txt
CMD [ "sh", "-c", "python main.py --dbname $PGDATABASE --user $PGUSER --password $PGPASSWORD --host $PGHOST --port $PGPORT --num_jobs $NUMJOBS --num_agents $NUMAGENTS --num_customers $NUMCUSTOMERS"]
