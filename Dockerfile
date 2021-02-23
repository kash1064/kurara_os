FROM python:3.8
ENV PYTHONUNBUFFERED 1

ENV TZ=Asia/Tokyo

RUN mkdir -p /kurara_os
ENV HOME=/kurara_os
WORKDIR $HOME

# If you henge shell to Bash
# Shell ["/bin/bash", "-c"] 

RUN useradd ubuntu
RUN dpkg --add-architecture i386
RUN apt update && apt upgrade -y

# Utils
RUN apt install  vim unzip zip gdb ltrace strace bash-completion -y

# Dev tools
RUN apt install mtools nasm build-essential g++ cmake make -y

# Qemu
RUN apt install qemu qemu-system-x86 qemu-utils qemu-system-arm -y