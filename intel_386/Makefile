SHELL=/bin/bash

MS32GCC := gcc -fno-pie -m32 -march=i486 -nostdlib -c
NASM := nasm

NASMFILE_DIR := /haribote/src/nasm
CFILE_DIR := /haribote/src/c
LDFILE_DIR := /haribote/src/ld


QEMU=qemu-system-x86_64
OSNAME=${shell uname -s}

# Boot
BOOT_DIR := /kurara_os/src/boot
KERNEL_DIR := /kurara_os/src/kernel
LDFILE_DIR := /kurara_os/src/modules/ld
KERNEL_MODULE_DIR := /kurara_os/src/modules/kernel

# qemu-system-x86_64.exe -drive file=kurara_os.img
OBJFILE_DIR := /kurara_os/outputs/obj
LSTFILE_DIR := /kurara_os/outputs/lst
HRBFILE_DIR := /kurara_os/outputs/hrb

boot.bin: ${BOOT_DIR}/boot.s
	${NASM} ${BOOT_DIR}/boot.s -l ${LSTFILE_DIR}/boot.lst -o ${OBJFILE_DIR}/boot.bin

library.bin: ${KERNEL_MODULE_DIR}/library.s Makefile
	${NASM} -g -f elf ${KERNEL_MODULE_DIR}/library.s -o ${OBJFILE_DIR}/library.bin -l ${LSTFILE_DIR}/library.lst

# kernel.bin: ${BOOT_DIR}/kernel.s
# 	${NASM} ${BOOT_DIR}/kernel.s -l ${LSTFILE_DIR}/kernel.lst -o ${OBJFILE_DIR}/kernel.bin

# %.obj : ${CFILE_DIR}/%.c Makefile
# 	$(MS32GCC) ${CFILE_DIR}/$*.c -o ${OBJFILE_DIR}/$*.obj

kernel.bin: ${KERNEL_DIR}/kernel.c ${LDFILE_DIR}/har.ld library.bin
	gcc -march=i486 -m32 -fno-pie -nostdlib -T ${LDFILE_DIR}/har.ld -g \
			${KERNEL_DIR}/kernel.c ${OBJFILE_DIR}/library.bin \
			-o ${OBJFILE_DIR}/kernel.bin

kurara_os.img: boot.bin kernel.bin
	# gcc -o ${OBJFILE_DIR}/kurara_os.img ${OBJFILE_DIR}/boot.bin ${OBJFILE_DIR}/kernel.bin
	cat ${OBJFILE_DIR}/boot.bin > kurara_os.img
	cat ${OBJFILE_DIR}/kernel.bin >> kurara_os.img

run_nogui: kurara_os.img
	${QEMU} -drive file=kurara_os.img -nographic

build: boot.bin kernel.bin kurara_os.img

remove_comments_from_lst: ${OBJFILE_DIR}/boot.lst ${LSTFILE_DIR}/kernel.lst env/remove_comment_from_lst.py
	python3 env/remove_comment_from_lst.py

# Docker
pwd := `pwd`
login_container:
	docker run --rm -it --user ubuntu -v ${pwd}:/kurara_os kurara_os_x86_64 /bin/bash -login
	# docker run --rm -it -v ${pwd}:/kurara_os kurara_os_x86_64 /bin/bash

start_docker:
	sudo /etc/init.d/docker start