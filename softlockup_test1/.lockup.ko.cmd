cmd_/root/crashtest1/lockup.ko := ld -r -m elf_x86_64 -T ./scripts/module-common.lds --build-id  -o /root/crashtest1/lockup.ko /root/crashtest1/lockup.o /root/crashtest1/lockup.mod.o
