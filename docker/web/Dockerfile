FROM python:3.6
ENV PYTHONUNBUFFERED 1
RUN mkdir -p /web/mysite
WORKDIR /web/mysite
ADD requirements.txt /web/mysite/
RUN pip install -r requirements.txt
