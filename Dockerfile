FROM golang:1-alpine

RUN apk add --no-cache git && go get github.com/soundcloud/ipmi_exporter

EXPOSE 9290

ENTRYPOINT [ "/go/bin/ipmi_exporter" ]
