import os

from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor


def _trace_endpoint():
    endpoint = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://otel-collector.observability.svc.cluster.local:4318")
    endpoint = endpoint.rstrip("/")
    if not endpoint.endswith("/v1/traces"):
        endpoint = endpoint + "/v1/traces"
    return endpoint


def configure_otel(app, default_service_name):
    if os.getenv("OTEL_TRACES_EXPORTER", "otlp").lower() == "none":
        return

    service_name = os.getenv("OTEL_SERVICE_NAME", default_service_name)
    resource = Resource.create({
        "service.name": service_name,
        "service.namespace": "togglemaster",
        "deployment.environment": os.getenv("ENVIRONMENT", "dev"),
    })

    provider = TracerProvider(resource=resource)
    provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter(endpoint=_trace_endpoint())))
    trace.set_tracer_provider(provider)

    FlaskInstrumentor().instrument_app(app)
    RequestsInstrumentor().instrument()
