FROM clojure:temurin-21-tools-deps-bookworm-slim

RUN apt-get update && \
    apt-get install -y curl unzip iputils-ping htop procps && \
    rm -rf /var/lib/apt/lists/*

RUN curl -s https://raw.githubusercontent.com/babashka/babashka/master/install | bash

RUN mkdir -p /usr/workspace/data /usr/workspace/logs && \
    curl -L \
      https://github.com/h2database/h2database/releases/download/version-2.2.224/h2-2023-09-17.zip \
      -o /usr/workspace/h2-database.zip && \
    unzip /usr/workspace/h2-database.zip -d /usr/workspace/ && \
    rm /usr/workspace/h2-database.zip

WORKDIR /usr/workspace

CMD java -Xmx256M \
      -cp h2/bin/*.jar org.h2.tools.Server \
      -webAllowOthers -tcpAllowOthers -pgAllowOthers -ifNotExists \
      -baseDir /usr/workspace/data
