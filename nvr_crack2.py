import sys, time, itertools
from passlib.hash import md5_crypt

HASH = "$1$7bfnUEjV$3ogadpYTDXtJPV4ubVaGq1"

def try_word(w):
    return md5_crypt.verify(w, HASH)

candidates = []

with open("D:/pythonProyektlar/kamera/nvr_wordlist.txt", "r", encoding="utf-8") as f:
    candidates.extend(w.strip() for w in f if w.strip())

vendor_strings = [
    "CS2_AiPN__SPSKEY", "CS2_AiPN_SPSKEY", "AiPN_SPSKEY", "SPSKEY",
    "IOTF", "IOTFCC", "N3xxB", "N3xxB-11NEA-AI", "N3xxB11NEAAI",
    "50600", "0x1958", "1958", "6488", "binver",
    "IOTFCC-016178", "PVSDB", "ZQUUYH", "FGFZJK",
    "farap2p", "ruision", "ewcloud", "ruisionvps",
    "Higheasy", "higheasy", "ZView", "Zview",
    "Edvr", "edvr1234", "edvradmin", "EDVR",
    "ingenicA1", "tucana", "tucana1234",
    "TUTK", "tutk", "tutk1234", "p2pwifi", "p2pcam",
    "888888", "777777", "999999", "111111", "222222", "333333",
    "00000000", "00000000a", "abcd1234", "1234abcd",
    "Aa1234", "Aa12345", "Aa123456", "Aa1234567",
    "ZW2024", "ZW2025", "ZW@2024", "ZW@2025", "Zview@2024",
    "DSS@2024", "DSS@2025", "DSS2024", "DSS2025",
    "Higheasy@2024", "HighEasy2024",
    "Ruision1", "ruision1", "ruision123", "ruision2024",
    "xrscam", "xrscam123", "xrs1234", "xrsdebug",
]
candidates.extend(vendor_strings)

# 4-digit numerics
for n in range(0, 10000):
    candidates.append(f"{n:04d}")

# common 5-6 digit patterns
for n in range(0, 100000, 1):
    candidates.append(str(n).zfill(6))

# date patterns 2020-2026
for y in range(2018, 2027):
    for m in range(1, 13):
        for d in range(1, 32):
            candidates.append(f"{y:04d}{m:02d}{d:02d}")
            candidates.append(f"{d:02d}{m:02d}{y:04d}")
            candidates.append(f"{m:02d}{d:02d}{y:04d}")

# dedupe but preserve order
seen = set()
unique = []
for c in candidates:
    if c not in seen:
        seen.add(c)
        unique.append(c)

print(f"Testing {len(unique)} candidates against {HASH}")
start = time.time()
report = max(len(unique)//40, 100)
for i, w in enumerate(unique, 1):
    if try_word(w):
        print(f"\n*** FOUND: '{w}' ***  (try #{i}, {time.time()-start:.1f}s)")
        sys.exit(0)
    if i % report == 0:
        rate = i/(time.time()-start+0.001)
        remain = (len(unique)-i)/rate
        print(f"  ... {i}/{len(unique)}  rate={rate:.0f}/s  eta={remain:.0f}s")

print(f"\nNot found in {len(unique)} candidates ({time.time()-start:.0f}s)")
sys.exit(1)
