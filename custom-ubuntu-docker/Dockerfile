# Use the official Ubuntu image
FROM ubuntu:20.04

# Set environment variables to prevent interactive prompts during builds
ENV DEBIAN_FRONTEND=noninteractive

# Update and install essential tools
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    build-essential \
    && apt-get clean

# Set the working directory inside the container
WORKDIR /workspace

# Default command (optional, can be overridden in build spec or run command)
CMD ["/bin/bash"]
