FROM swift:4.2
WORKDIR /app
ADD . ./
RUN swift package clean
RUN swift build -c debug
RUN mkdir /app/bin
RUN mv `swift build -c debug --show-bin-path` /app/bin
EXPOSE 8080
ENTRYPOINT ./bin/debug/Run serve -e debug -b 0.0.0.0