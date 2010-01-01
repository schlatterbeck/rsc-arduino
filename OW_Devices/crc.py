#!/usr/bin/python

def crc (s) :
    val = 0
    for c in s:
        if isinstance (c, str) :
            c = ord (c)
        for j in range (8) :
            mix = (val ^ c) & 0x01
            val >>= 1
            if mix :
                val ^= 0x8C
            c >>= 1
    return val
