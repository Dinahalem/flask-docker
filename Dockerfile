FROM python:3.7
WORKDIR /app
COPY ./requirements.txt /app/requirements.txt

RUN pip install -r requirements.txt
COPY . /app
EXPOSE 9999
ENTRYPOINT ["python","hello.py"]
ENTRYPOINT ["python", "test_hello.py"]
