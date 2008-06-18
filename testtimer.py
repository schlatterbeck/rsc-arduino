#!/usr/bin/python

ulong_modulus = 0x100000000; # overflow of unsigned long in C
F_CPU         = 16000000

# return timer0_overflow_count * 64UL * 256UL / (F_CPU / 1000UL);
# instead find 1/128th the number of clock cycles and divide by
# 1/128th the number of clock cycles per millisecond
# return timer0_overflow_count * 64UL * 2UL / (F_CPU / 128000UL);


for k in range (34359730, 34359751) :
    print k, (k * (F_CPU / 128000) * 64 * 2) % ulong_modulus / (F_CPU / 128000)

y = 0x100000000 / 128 
for k in range (y - 200, y + 200) :
    print k, (k * 64 * 2),
    print ((k * 64 * 2) % ulong_modulus) / int (F_CPU / 128000)
