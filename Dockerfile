FROM alpine:latest as builder
ARG TARGETARCH
WORKDIR /build
ENV CFLAGS="-flto=auto -ffat-lto-objects -fexceptions -pipe -Wall \
            -Werror=format-security -Wp,-U_FORTIFY_SOURCE,-D_FORTIFY_SOURCE=3 \
            -fstack-protector-strong -fasynchronous-unwind-tables \
            -fstack-clash-protection"
ENV LDFLAGS="-Wl,-z,relro -Wl,--as-needed  -Wl,-z,now"
RUN if [ "${TARGETARCH}" = "amd64" ]; then export CFLAGS="${CFLAGS} -fcf-protection"; fi && \
    apk add --no-cache git build-base && \
    git clone --depth 1 https://github.com/Wind4/vlmcsd.git && \
    cd vlmcsd && \
    make VERBOSE=1 LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS}" && \
    strip --strip-all bin/vlmcsd

FROM alpine:latest
COPY --from=builder /build/vlmcsd/bin/vlmcsd /app/vlmcsd
COPY --from=builder /build/vlmcsd/etc/vlmcsd.kmd /app/vlmcsd.kmd
RUN adduser --disabled-password --no-create-home appuser && \
    apk add --no-cache tzdata
EXPOSE 1688/tcp
USER appuser
CMD ["/app/vlmcsd", "-D", "-d", "-t", "3", "-e", "-v"]
