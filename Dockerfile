FROM golang:1-alpine AS build-env
RUN go install github.com/prometheus-community/ipmi_exporter@latest

FROM alpine
WORKDIR /root
COPY --from=build-env /go/bin/ipmi_exporter /opt/ipmi_exporter/.
RUN apk add --no-cache freeipmi

EXPOSE 9290

ENTRYPOINT [ "/opt/ipmi_exporter" ]
