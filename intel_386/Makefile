SHELL=/bin/bash

QEMU=qemu-system-x86_64
OSNAME=${shell uname -s}

# Boot
bootdir := /kurara_os/src/boot
kerneldir := /kurara_os/src/kernel

# qemu-system-x86_64.exe -drive file=kurara_os.img
outputdir := /kurara_os/outputs

boot.bin: ${bootdir}/boot.s
	nasm ${bootdir}/boot.s -l ${outputdir}/boot.lst -o ${outputdir}/boot.bin

kernel.bin: ${bootdir}/kernel.s
	nasm ${bootdir}/kernel.s -l ${outputdir}/kernel.lst -o ${outputdir}/kernel.bin

# kernel.bin: ${kerneldir}/kernel.c
# 	gcc -S ${kerneldir}/kernel.c -o ${outputdir}/kernel.lst
# 	gcc -c ${kerneldir}/kernel.c -o ${outputdir}/kernel.bin

kurara_os.img: boot.bin kernel.bin
	# gcc -o ${outputdir}/kurara_os.img ${outputdir}/boot.bin ${outputdir}/kernel.bin
	cat ${outputdir}/boot.bin > ${outputdir}/kurara_os.img
	cat ${outputdir}/kernel.bin >> ${outputdir}/kurara_os.img

run_nogui: ${outputdir}/kurara_os.img
	${QEMU} -drive file=${outputdir}/kurara_os.img -nographic

build: boot.bin kernel.bin kurara_os.img


remove_comments_from_lst: ${outputdir}/boot.lst ${outputdir}/kernel.lst env/remove_comment_from_lst.py
	python3 env/remove_comment_from_lst.py

# Docker
pwd := `pwd`
login_container:
	docker run --rm -it --user ubuntu -v ${pwd}:/kurara_os kurara_os_x86_64 /bin/bash -login
	# docker run --rm -it -v ${pwd}:/kurara_os kurara_os_x86_64 /bin/bash

start_docker:
	sudo /etc/init.d/docker start