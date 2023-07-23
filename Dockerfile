FROM dart:stable AS build
RUN apt-get update && apt-get install -y wget

# Resolve app dependencies.
WORKDIR /
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
RUN mkdir build

# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline

# Build Watchtower Service
RUN dart compile exe bin/main.dart -o build/pillar-chat-verifier
RUN cp example.config.yaml build/config.yaml

# Start service.
CMD ["/build/pillar-chat-verifier"]
