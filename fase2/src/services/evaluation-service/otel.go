package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"time"

	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel"
	"go.opentelemetry.io/otel/attribute"
	"go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/sdk/resource"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"
)

func startTracing() func() {
	serviceName := os.Getenv("OTEL_SERVICE_NAME")
	if serviceName == "" {
		serviceName = "togglemaster-evaluation-service"
	}

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	exporter, err := otlptracehttp.New(ctx)
	if err != nil {
		log.Printf("OpenTelemetry desabilitado: erro ao criar OTLP exporter: %v", err)
		return func() {}
	}

	res, err := resource.Merge(
		resource.Default(),
		resource.NewWithAttributes(
			"",
			attribute.String("service.name", serviceName),
			attribute.String("service.namespace", "togglemaster"),
			attribute.String("deployment.environment", os.Getenv("ENVIRONMENT")),
		),
	)
	if err != nil {
		log.Printf("OpenTelemetry: erro ao criar resource: %v", err)
		res = resource.Default()
	}

	tp := sdktrace.NewTracerProvider(
		sdktrace.WithBatcher(exporter),
		sdktrace.WithResource(res),
	)

	otel.SetTracerProvider(tp)
	otel.SetTextMapPropagator(propagation.NewCompositeTextMapPropagator(
		propagation.TraceContext{},
		propagation.Baggage{},
	))

	return func() {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := tp.Shutdown(ctx); err != nil {
			log.Printf("OpenTelemetry: erro ao finalizar tracer provider: %v", err)
		}
	}
}

func instrumentHTTPClient(client *http.Client) *http.Client {
	if client == nil {
		client = &http.Client{}
	}
	if client.Transport == nil {
		client.Transport = http.DefaultTransport
	}
	client.Transport = otelhttp.NewTransport(client.Transport)
	return client
}

func instrumentHandler(name string, handler http.Handler) http.Handler {
	return otelhttp.NewHandler(handler, name)
}
