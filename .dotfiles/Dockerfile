FROM ubuntu

ENV HOME /home/test

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    nano \
    ssh \
    sudo \
    tmux \
    vim \
    wget

# Configure sudo to allow testing 'agi' (apt-get install) and friends
ADD sudoers /etc/sudoers

# Create a non-root test user
RUN useradd --create-home --home-dir $HOME --shell /bin/bash --groups sudo test

# The first time Bash is run, automatically run the config file
RUN echo "if [ ! -d ~/.git ]; then cd; . cfg; fi" >> /etc/bash.bashrc

# Disable the sudo tutorial
USER test
RUN touch $HOME/.sudo_as_admin_successful

# Copy the cfg script
USER test
COPY cfg $HOME/cfg

USER root
COPY cfg $HOME/cfg

# Run Bash when the image is run, starting in the current user's home directory
# (either /root or /home/test depending on the -u option)
USER test
WORKDIR /home/test
ENTRYPOINT cd && bash
