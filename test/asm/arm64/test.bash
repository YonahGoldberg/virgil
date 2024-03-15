#!/bin/bash

# See ./Arm64AssemblerTestGen.v3 for details on this test script.

. ../../common.bash arm64-asm

VIRGIL_OPCODES=${OUT}/virgil-opcodes.txt
ASM=${OUT}/asm.s
OBJECT=${OUT}/asm.o
OBJDUMP=${OUT}/objdump.txt
ASM_OPCODES=${OUT}/asm-opcodes.txt
DIFF_OPCODES=${OUT}/diff-opcodes.txt

LIB_UTIL="${VIRGIL_LOC}/lib/util/*.v3"
LIB_ASM="${VIRGIL_LOC}/lib/asm/arm64/*.v3"

AS=$(which as)
if [ -z "$AS" ]; then
	echo "as assembler not installed."
	exit 0
fi

printf "  Generating (v3i)..."
run_v3c "" -run ./Arm64AssemblerTestGen.v3 $LIB_ASM $LIB_UTIL $ASM $VIRGIL_OPCODES
if [ "$?" != 0 ]; then
    printf "\n"
    cat $S
    exit $?
fi
check_passed $ASM


printf "  Assembling (as)..."
as -o $OBJECT $ASM
objdump -d $OBJECT > $OBJDUMP
check $?

printf "  Comparing..."
run_v3c "" -run ./ObjdumpParser.v3 $LIB_UTIL $OBJDUMP $ASM_OPCODES
diff $ASM_OPCODES $VIRGIL_OPCODES > $DIFF_OPCODES
X=$?
check $X

if [ $X != 0 ]; then
    echo $DIFF_OPCODES
    head -n 10 $DIFF_OPCODES
fi