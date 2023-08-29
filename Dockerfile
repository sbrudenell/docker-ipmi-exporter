FROM golang:1-alpine AS build-env
RUN go install github.com/prometheus-community/ipmi_exporter@latest

COPY install-freeipmi.sh /root/install-freeipmi.sh
RUN /bin/sh /root/install-freeipmi.sh

FROM alpine:3.7
WORKDIR /root
RUN mkdir -p /opt/freeipmi/sbin
COPY --from=build-env /go/bin/ipmi_exporter /opt/ipmi_exporter/.
COPY --from=build-env /opt/freeipmi/sbin/* /opt/freeipmi/sbin/
RUN /bin/sh -c 'for t in ipmimonitoring ipmi-sensors ipmi-dcmi bmc-info; do ln -s "/opt/freeipmi/sbin/${t}" "/usr/sbin/${t}"; done'

EXPOSE 9290

ENTRYPOINT [ "/opt/ipmi_exporter" ]
