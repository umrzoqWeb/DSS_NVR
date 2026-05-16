import sys, time
from passlib.hash import md5_crypt

HASH = "$1$7bfnUEjV$3ogadpYTDXtJPV4ubVaGq1"

def try_word(w):
    return md5_crypt.verify(w, HASH)

def main():
    with open("D:/pythonProyektlar/kamera/nvr_wordlist.txt", "r", encoding="utf-8") as f:
        words = [w.strip() for w in f if w.strip()]
    print(f"Testing {len(words)} candidates against {HASH}")
    start = time.time()
    for i, w in enumerate(words, 1):
        if try_word(w):
            print(f"\n*** FOUND: '{w}' ***  ({i}/{len(words)}, {time.time()-start:.1f}s)")
            return 0
        if i % 20 == 0:
            print(f"  ... tested {i}/{len(words)} ({time.time()-start:.1f}s)")
    print(f"\nNot found in wordlist ({len(words)} tries, {time.time()-start:.1f}s)")
    return 1

sys.exit(main())
