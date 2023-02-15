FROM python:3.7
WORKDIR /app
COPY . /app

RUN pip install -r requirements.txt
EXPOSE 9999
ENTRYPOINT ["python","hello.py"]
ENTRYPOINT ["python", "test_hello.py"]
