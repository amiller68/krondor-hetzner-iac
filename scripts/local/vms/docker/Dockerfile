# Use the official Debian image as a parent image
FROM debian:latest

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Install SSH server and sudo
RUN apt-get update
RUN apt-get install -y openssh-server sudo python3 python3-pip
RUN echo 'root:root' | chpasswd

# Add a passwordless sudoer admin user
RUN useradd -m -s /bin/bash admin
RUN echo 'admin:admin' | chpasswd
RUN echo 'admin ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Expose the SSH port
EXPOSE 22

# Run the SSH server
CMD ["/usr/sbin/sshd", "-D"]
