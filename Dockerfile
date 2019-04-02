FROM golang:1-alpine AS build-env

ENV COMMIT_HASH=0c4d5f0ea293abc799a6cc197e2bf3eeb322f937

RUN apk add --no-cache git && go get -d github.com/soundcloud/ipmi_exporter \
&& cd $GOPATH/src/github.com/soundcloud/ipmi_exporter \
&& git checkout $COMMIT_HASH && go install

COPY install-freeipmi.sh /root/install-freeipmi.sh
RUN /bin/sh /root/install-freeipmi.sh

FROM alpine:3.7
WORKDIR /root
COPY --from=build-env /go/bin/ipmi_exporter /opt/ipmi_exporter/.
COPY --from=build-env /opt/netdata/sbin/ipmimonitoring /usr/sbin/.
COPY --from=build-env /opt/netdata/sbin/ipmi-sensors /usr/sbin/.
COPY --from=build-env /opt/netdata/sbin/ipmi-dcmi /usr/sbin/.
COPY --from=build-env /opt/netdata/sbin/bmc-info /usr/sbin/.

EXPOSE 9290

ENTRYPOINT [ "/opt/ipmi_exporter" ]
