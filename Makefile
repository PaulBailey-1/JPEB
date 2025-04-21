# Does not automatically rebuild compiler, emulator, or simulator!
CC = ./JPEB-compiler/dist-newstyle/build/x86_64-linux/ghc-9.4.8/c-compiler-0.1.0.0/x/c-compiler/build/c-compiler/c-compiler
AS = python3 ./JPEB-compiler/Assembler.py
EMU = ./JPEB-emulator/target/release/JPEB-emulator
SIM = ./JPEB-FPGA/build/cpu

TEST_SRC = tests/asm
TEST_BIN = tests/bin
TEST_OUT = tests/out
DATA_DIR = data
SIM_DATA = JPEB-FPGA/data

TEST_COMMON = $(wildcard tests/common/*.s)
ASM_TESTS = $(wildcard ${TEST_SRC}/*.s)
# C_TESTS = $(wildcard tests/c/*.c) doesnt support c tests yet

TEST_NAMES = ${sort ${subst ${TEST_SRC}/, , ${subst .s,,${ASM_TESTS}}}}
TEST_BINS = ${addprefix ${TEST_BIN}/, ${addsuffix .bin,${TEST_NAMES}}}
TEST_NAMES_OUT = ${addprefix ${TEST_OUT}/, ${TEST_NAMES}}
TEST_OUTS = ${addsuffix .out,${TEST_NAMES_OUT}}
TEST_OK = ${addsuffix .ok,${TEST_NAMES_OUT}}
TEST_DIFFS = ${addsuffix .diff,${TEST_NAMES_OUT}}
TEST_RESULTS = ${addsuffix .result,${TEST_NAMES_OUT}}
TEST_CLEAN = ${addsuffix .clean,${TEST_NAMES}}

.PRECIOUS: %.s %.bin %.ok

all: test

${TEST_BINS} : ${TEST_BIN}/%.bin : Makefile ${TEST_SRC}/%.s
	@mkdir -p ${TEST_BIN}
	$(AS) ${TEST_SRC}/$*.s ${TEST_COMMON} -o ${TEST_BIN}

${TEST_OUTS} : ${TEST_OUT}/%.out : Makefile ${TEST_BIN}/%.bin
# Make raw
	@echo "failed to run" > ${TEST_OUT}/$*.raw
	@cp ${TEST_BIN}/$*.hex ${SIM_DATA}/program.hex
	@cp ${DATA_DIR}/*.hex ${SIM_DATA}/
	@mkdir -p ${TEST_OUT}
	$(SIM) +DATAPATH=${SIM_DATA} > ${TEST_OUT}/$*.raw	
# Make out
	@echo "no output" > ${TEST_OUT}/$*.out
	@grep -o "<<[^>]*>>" ${TEST_OUT}/$*.raw > ${TEST_OUT}/$*.out

${TEST_OK} : ${TEST_OUT}/%.ok : Makefile ${TEST_BIN}/%.bin
	$(EMU) ${TEST_BIN}/$*.bin ${DATA_DIR}/ > ${TEST_OUT}/$*.ok

${TEST_RESULTS} : %.result : Makefile %.ok %.out
# Make diff
	@echo "failed to diff" > $*.diff
	-diff -a $*.out $*.ok > $*.diff 2>&1 || true
# Make result
	@echo "fail" > $*.result
	@(test \! -s $*.diff && echo "pass" > $*.result) || true

${TEST_NAMES} : % : Makefile ${TEST_OUT}/%.result
	@echo "$* ... `cat ${TEST_OUT}/$*.result`"

test : ${TEST_TESTS};

${TEST_CLEAN} : %.clean :
	-rm -rf ${TEST_BIN}/$*.bin ${TEST_BIN}/$*.hex
	-rm -rf ${TEST_OUT}/$*.out ${TEST_OUT}/$*.diff ${TEST_OUT}/$*.raw ${TEST_OUT}/$*.result

clean:
	-rm -rf ${TEST_BIN}/*.bin ${TEST_BIN}/*.hex
	-rm -rf ${TEST_OUT}/*.out ${TEST_OUT}/*.diff ${TEST_OUT}/*.raw ${TEST_OUT}/*.result