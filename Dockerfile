# Do the buildroot build inside a Linux container with well-defined toolchain.
# It appears that my local toolchain is too new (?) for some parts, as buildroot
# uses the host machine's compiler for some of the host-* packages.
#
# $ docker build -t buildrootbuilder .
# $ docker run --rm -it -v (pwd):/dacspot -w /dacspot buildrootbuilder
#

# start with stable debian
FROM debian:12

# requirements for buildroot, partially based on
# https://buildroot.org/downloads/Vagrantfile
RUN apt update && apt install -y \
    build-essential git cvs bzr mercurial subversion \
    wget curl ca-certificates rsync unzip cpio bc \
    findutils file ncurses-dev clang gcc-multilib
# RUN dpkg --add-architecture i386 && \
#     apt install -y libc6:i386

# use a nicer shell as default
RUN apt install -y fish && chsh -s /usr/bin/fish
CMD [ "fish" ]
