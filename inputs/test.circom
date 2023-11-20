pragma circom 2.1.2;

template Test() {
    signal input a;
    signal input b;
    signal output c;
    c <== a * b;
}

component main = Test();