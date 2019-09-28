FROM python:3.7
EXPOSE 80
RUN mkdir /app
COPY devops-takehome/ /app

RUN cd /app; \
  pip install -r requirements.txt
ENTRYPOINT python /app/app.py