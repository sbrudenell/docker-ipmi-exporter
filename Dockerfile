FROM golang:1-alpine

ENV COMMIT_HASH=0c4d5f0ea293abc799a6cc197e2bf3eeb322f937

RUN apk add --no-cache git && go get -d github.com/soundcloud/ipmi_exporter \
&& cd $GOPATH/src/github.com/soundcloud/ipmi_exporter \
&& git checkout $COMMIT_HASH && go install

WORKDIR /root
COPY install-freeipmi.sh /root/install-freeipmi.sh
RUN /bin/sh /root/install-freeipmi.sh

EXPOSE 9290

ENTRYPOINT [ "/go/bin/ipmi_exporter" ]
