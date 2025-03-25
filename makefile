all:
	./bazelisk.sh build //sw/otbn/crypto/handwritten/matvec_mul:matvec_mul_test
	/home/anon/Chelpis_intern/otbn-mq/opentitan/hw/ip/otbn/dv/otbnsim/standalone.py --dump-regs ~/matvec_mul_regs  bazel-out/k8-fastbuild-ST-1df456420242/bin/sw/otbn/crypto/handwritten/matvec_mul/matvec_mul_test.elf
	batcat ~/matvec_mul_regs

