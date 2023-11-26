#Deriving the latest base image
FROM python:3.9.6
LABEL Maintainer="jturner"
WORKDIR /opt/app
COPY  . /opt/app/
RUN pip install -r requirements.txt
CMD [ "sh", "-c", "python main.py -b $BATCH_SIZE -P $PROC_COUNT -t $KAFKA_TOPIC -k $KAFKA_SERVER"]