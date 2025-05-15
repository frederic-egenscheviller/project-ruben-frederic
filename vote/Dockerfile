FROM python:3.11-alpine

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt \
 && find /usr/local/lib/python3.11/site-packages -name "*.pyc" -delete \
 && find /usr/local/lib/python3.11/site-packages -name "tests" -type d -exec rm -rf {} +

COPY . .

CMD ["python", "app.py"]