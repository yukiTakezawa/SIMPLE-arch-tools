#!/bin/sh

fail() {
    echo $1
    exit 1
}

runtest(){
    echo "$1" | ./encoder > _test.bin
    ./aqemu _test.bin
    res=$?
    [ $res -eq $2 ] || fail "[ERROR] \"$1\": expect $2 but got $res"
}

# FE  DCB  A98  7654  3210
# 11  Rs   Rd   op3   d
#runtest "8001C0F0" 1
# reg[0] <- 1; HLT
runtest "c[0 0 1] a[0 0 15 0]" 1
# reg[1] <- 1; reg[0] <- reg[1]; HLT
runtest "c[0 1 1] a[1 0 6 0] a[0 0 15 0]" 1
# reg[0] <- 1; reg[1] <- 2; reg[0] <- reg[0] + reg[1]; HLT
runtest "c[0 0 1] c[0 1 2] a[1 0 0 0] a[0 0 15 0]" 3
# reg[0] <- 1; reg[1] <- -1; reg[0] <- reg[0] + reg[1]; HLT
runtest "c[0 0 1] c[0 1 -1] a[1 0 0 0] a[0 0 15 0]" 0
# reg[0] <- 2; reg[1] <- 1; reg[0] <- reg[0] - reg[1]; HLT
runtest "c[0 0 2] c[0 1 1] a[1 0 1 0] a[0 0 15 0]" 1
# reg[0] <- 2; reg[1] <- -1; reg[0] <- reg[0] - reg[1]; HLT
runtest "c[0 0 2] c[0 1 -1] a[1 0 1 0] a[0 0 15 0]" 3
# reg[0] <- 1; reg[1] <- 1; reg[0] <- reg[0] - reg[1]; HLT
runtest "c[0 0 1] c[0 1 1] a[1 0 1 0] a[0 0 15 0]" 0
# reg[0] <- 4; reg[1] <- 5; reg[0] <- reg[0] & reg[1]; HLT
runtest "c[0 0 4] c[0 1 5] a[1 0 2 0] a[0 0 15 0]" 4
# reg[0] <- 4; reg[1] <- 5; reg[0] <- reg[0] | reg[1]; HLT
runtest "c[0 0 4] c[0 1 5] a[1 0 3 0] a[0 0 15 0]" 5
# reg[0] <- 4; reg[1] <- 5; reg[0] <- reg[0] ^ reg[1]; HLT
runtest "c[0 0 4] c[0 1 5] a[1 0 4 0] a[0 0 15 0]" 1

echo "ok"
