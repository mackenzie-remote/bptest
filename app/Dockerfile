FROM python:3

WORKDIR /app
COPY requirements.txt /app/
COPY main.py /app/

RUN pip3 install -r requirements.txt
ENTRYPOINT [ "python3", "main.py"]
