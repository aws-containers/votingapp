FROM public.ecr.aws/bitnami/python:3.8-prod

COPY . /app

WORKDIR /app

RUN pip install -r requirements.txt
RUN opentelemetry-bootstrap --action=install
# Optional section
ENV OTEL_PYTHON_DISABLED_INSTRUMENTATIONS=urllib3
ENV OTEL_RESOURCE_ATTRIBUTES='service.name=votingapp'

RUN groupadd -r restaurantgroup && useradd -r -g restaurantgroup restaurantuser
USER restaurantuser
CMD OTEL_PROPAGATORS=xray OTEL_PYTHON_ID_GENERATOR=xray opentelemetry-instrument python3 -u app.py
EXPOSE 8080
