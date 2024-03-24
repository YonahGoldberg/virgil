#!/bin/bash

# See ./Arm64AssemblerTestGen.v3 for details on this test script.

. ../../common.bash arm64-asm

VIRGIL_OBJDUMP=${OUT}/virgil-objdump.txt
ASM=${OUT}/asm.s
OBJECT=${OUT}/asm.o
ASM_OBJDUMP=${OUT}/asm-objdump.txt
DIFF_OBJDUMP=${OUT}/diff-objdump.txt

LIB_UTIL="${VIRGIL_LOC}/lib/util/*.v3"
LIB_ASM="${VIRGIL_LOC}/lib/asm/arm64/*.v3"

AS=$(which as)
if [ -z "$AS" ]; then
	echo "as assembler not installed."
	exit 0
fi

printf "  Generating (v3i)..."
run_v3c "" -run ./Arm64AssemblerTestGen.v3 $LIB_ASM $LIB_UTIL $ASM $VIRGIL_OBJDUMP $OBJECT
if [ "$?" != 0 ]; then
    printf "\n"
    cat $S
    exit $?
fi
check_passed $ASM


printf "  Assembling (as)..."
as -o $OBJECT $ASM
objdump -d $OBJECT > $ASM_OBJDUMP
check $?

printf "  Comparing..."
diff -i -b $ASM_OBJDUMP $VIRGIL_OBJDUMP > $DIFF_OBJDUMP
X=$?
check $X

if [ $X != 0 ]; then
    echo $DIFF_OBJDUMP
    head -n 10 $DIFF_OBJDUMP
fi