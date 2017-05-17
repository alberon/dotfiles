#===============================================================================
#
# To use Docker to test Dotfiles setup:
#
#   dinit                                   # Initialise docker-machine
#   db -t dotfiles ~/.dotfiles-docker       # Build image
#   dsh dotfiles                            # Run as 'test' user
#   dr -it -u root dotfiles                 # Run as 'root' user
#   dresume                                 # Resume previous session
#
# In either case it will run the setup script then drop you into a Bash prompt
#
#===============================================================================

FROM ubuntu

ENV HOME /home/test

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    nano \
    ssh \
    sudo \
    tmux \
    vim

# Configure sudo to allow testing 'agi' (apt-get install) and friends
ADD sudoers /etc/sudoers

# Create a non-root test user
RUN useradd --create-home --home-dir $HOME --shell /bin/bash --groups sudo test

# Download setup script
ADD https://alberon.uk/cfg /root/cfg

# Copy it to the test user's home directory
RUN cp /root/cfg $HOME/cfg && \
    chown test $HOME/cfg

# The first time Bash is run, automatically run the config file
# Not using ENTRYPOINT with --init-file so that "dresume" works correctly
RUN echo "if [ -f ~/cfg ]; then source ~/cfg; fi" >> /etc/bash.bashrc

# Disable the sudo tutorial
USER test
RUN touch $HOME/.sudo_as_admin_successful

# Run Bash when the image is run, starting in the current user's home directory
# (either /root or /home/test depending on the -u option)
WORKDIR /home/test
ENTRYPOINT cd && bash
