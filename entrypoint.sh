#!/bin/sh

# Replace placeholders in config.yaml with environment variables
sed -i 's|${NODE}|'${NODE}'|g' /build/config.yaml
sed -i 's|${URL}|'${URL}'|g' /build/config.yaml
sed -i 's|${USERNAME}|'${USERNAME}'|g' /build/config.yaml
sed -i 's|${PASSWORD}|'${PASSWORD}'|g' /build/config.yaml
sed -i 's|${CHANNEL}|'${CHANNEL}'|g' /build/config.yaml

# Start the application
exec /build/pillar-chat-verifier

