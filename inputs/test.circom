template Test () {
    signal private input a;
    signal private input b;
    signal output c;
    c <== a * b;
}

component main = Test();