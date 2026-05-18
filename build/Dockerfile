# Stage 1: Builder - extract & strip /system
FROM ubuntu:22.04 AS builder

COPY --from=erstt/redroid:13.0.0_ndk_ChromeOS / /build/rootfs

COPY strip.sh /build/strip.sh
RUN chmod +x /build/strip.sh
RUN /build/strip.sh /build/rootfs/system

# Stage 2: Final - tạo image từ scratch với rootfs đã strip
FROM scratch
COPY --from=builder /build/rootfs/ /

# Metadata từ image gốc
ENTRYPOINT ["/init", "qemu=1", "androidboot.hardware=redroid"]
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
