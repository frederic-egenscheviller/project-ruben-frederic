# Pour avoir la bonne version de dotnet sur mac
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0 as build-env

ARG TARGETPLATFORM
ARG TARGETARCH
ARG BUILDPLATFORM

WORKDIR /app

COPY . /app/source

RUN cd /app/source && \
    dotnet restore -r linux-musl-x64 && \
    dotnet publish -c Release -o /app/out -r linux-musl-x64 --self-contained true /p:PublishSingleFile=true /p:EnableCompressionInSingleFile=true

FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/runtime-deps:8.0-alpine AS final

WORKDIR /app

COPY --from=build-env /app/out ./

CMD ["./Worker"]
