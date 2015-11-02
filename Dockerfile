FROM gliderlabs/alpine:3.2
MAINTAINER team@pganalyze.com

RUN adduser -D pganalyze pganalyze
ENV HOME_DIR /home/pganalyze
ENV CODE_DIR /go/src/github.com/lfittl/pganalyze-collector-next

COPY . $CODE_DIR

# We run this all in one layer to reduce the resulting image size
RUN apk-install -t build-deps curl libc-dev gcc go git \
  && curl -o /usr/local/bin/gosu -sSL "https://github.com/tianon/gosu/releases/download/1.6/gosu-amd64" \
  && cd $CODE_DIR \
	&& export GOPATH=/go \
	&& go get \
	&& go build -o $HOME_DIR/collector \
	&& rm -rf /go \
	&& apk del --purge build-deps

RUN chmod +x /usr/local/bin/gosu
RUN chown pganalyze:pganalyze $HOME_DIR/collector

CMD ["/usr/local/bin/gosu", "pganalyze", "/home/pganalyze/collector"]
