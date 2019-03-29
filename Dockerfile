FROM golang:1-alpine

env COMMIT_HASH=0c4d5f0ea293abc799a6cc197e2bf3eeb322f937

RUN apk add --no-cache git && go get -d github.com/soundcloud/ipmi_exporter
RUN cd $GOPATH/src/github.com/soundcloud/ipmi_exporter && git checkout $COMMIT_HASH && go install

EXPOSE 9290

ENTRYPOINT [ "/go/bin/ipmi_exporter" ]
