# https://youtu.be/iPoL03tFBtU?si=aumR8R1Z3flK-KyG
# please note that DOCKER FILES DO NOT SCALE
# this is only a reference, `pkgs.dockerTools` is just better. See above video by and engineer from Anthropic i.e. Claude
FROM nixos/nix:latest AS builder

COPY . /tmp/build
WORKDIR /tmp/build

RUN nix \
    --extra-experimental-features "nix-command flakes" \
    --option filter-syscalls false \
    build

RUN mkdir /tmp/nix-store-closure
RUN cp -R $(nix-store -qR result/) /tmp/nix-store-closure

FROM scratch

WORKDIR /

# Copy Nix Closure
COPY --from=builder /tmp/nix-store-closure /nix/store
COPY --from=builder /tmp/build/result /

ENTRYPOINT ["/bin/hello_world"]