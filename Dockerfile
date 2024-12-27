FROM jenkins/jenkins:lts

USER root

# Install prerequisites
RUN apt-get update && \
    apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Add Docker's official GPG key
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | tee /etc/apt/trusted.gpg.d/docker.asc

# Set up the stable Docker repository
RUN echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable" | tee /etc/apt/sources.list.d/docker.list
# Update package lists again
RUN apt-get update

# Install AWS CLI v2
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip
# Verify installation
RUN aws --version


# Install Docker
RUN apt-get install -y docker-ce docker-ce-cli containerd.io

# Clean up unnecessary files to reduce image size
RUN apt-get clean

# Expose Docker socket from the host
VOLUME /var/run/docker.sock:/var/run/docker.sock

# Add jenkins user to the Docker group to allow non-sudo Docker usage
RUN usermod -aG docker jenkins
# Set the user back to jenkins
USER jenkins

# Expose Jenkins default port
EXPOSE 8080

# Run Docker daemon (DinD) in the background
ENTRYPOINT ["sh", "-c", "dockerd & exec /usr/local/bin/jenkins.sh"]
