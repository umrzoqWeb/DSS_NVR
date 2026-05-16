import sys, time
from passlib.hash import md5_crypt

HASH = "$1$7bfnUEjV$3ogadpYTDXtJPV4ubVaGq1"
start = time.time()

# 5-8 digit numerics
total = 0
for length in (5, 6, 7, 8):
    for n in range(10**(length-1), 10**length):
        total += 1
        w = str(n)
        if md5_crypt.verify(w, HASH):
            print(f"\n*** FOUND: '{w}' ***  (#{total}, {time.time()-start:.0f}s)")
            sys.exit(0)
        if total % 5000 == 0:
            rate = total/(time.time()-start+0.001)
            print(f"  ... {total} tested ({length}d), rate={rate:.0f}/s, elapsed={time.time()-start:.0f}s")

print(f"\nNot found in {total} numerics ({time.time()-start:.0f}s)")
sys.exit(1)
