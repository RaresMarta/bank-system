#!/bin/bash

# Build the app image
echo "Building app image..."
docker compose build app

# Start the database service
echo "Starting database container..."
docker compose up -d db

# Run the CLI app
echo "Launching the CLI app..."
docker run --rm -it \
  --network=bank-system_default \
  --env-file .env \
  bank-system-app
