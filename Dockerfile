FROM public.ecr.aws/bitnami/python:3.6-prod

COPY . /app

WORKDIR /app

RUN pip install -r requirements.txt

RUN groupadd -r restaurantgroup && useradd -r -g restaurantgroup restaurantuser
USER restaurantuser
CMD ["python", "-u", "app.py"]
