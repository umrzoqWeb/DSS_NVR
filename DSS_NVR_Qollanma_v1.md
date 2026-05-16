# DSS NVR (Ingenic A1) — Tahlil va Persistent Telnet — v1.1

> **Maqsad:** DSS rebrend NVR'ni O'zbek bozori uchun moslashtirish — kameradagi (Hi3516CV610) muvaffaqiyatdan keyingi navbatdagi qurilma
>
> **Yondashuv:** UART → init=/bin/sh recon → persistent telnet via UBIFS hook → cloud bloklash → brending
>
> **Status:** 🟢 **PERSISTENT TELNET ISHLAYAPTI** (port 2323, parolsiz, har boot'da avto-start). Cloud blok va brending qadamlari oldinda.
>
> **Sana:** 2026-05-13 → 2026-05-16
>
> **Murakkablik:** Yuqori — UART, U-Boot, UBIFS, MIPS arxitektura
>
> **Kameradan farqi:** Hi3516CV610 emas, **Ingenic XBurst A1** (MIPS). Login wrapper YO'Q (mylogin yo'q), MD5crypt parol (DES emas), UBIFS RW partition mavjud.

---

## 📦 APPARAT MA'LUMOTLARI

| Komponent | Qiymat |
|---|---|
| SoC | **Ingenic XBurst A1** (MIPS, dual-core) |
| Chip ID | `0x00001111` |
| Board ID (Auth) | `0x1958` |
| Board string | `ISVP` (Ingenic ref), U-Boot prompt `isvp_a1#` |
| DRAM | 256 MiB |
| Flash | SFC NAND, 128 MiB |
| Disk | 2× SATA (HDD slot, link down test'da) |
| USB | 3× USB host |
| Kernel | Linux `4.4.94-20220517`, build `Mon Apr 14 10:25:51 CST 2025` |
| Toolchain | gcc 7.2.0 (Ingenic Linux-Release5.1.8) |
| U-Boot | SPL `2013.07` (build `Sep 26 2024`), `bootdelay=1` |
| MAC eth0 | `00:11:22:56:96:69` |
| MAC eth1 | `00:11:22:56:96:70` |
| Default IP (env) | `193.169.4.151/24` gw `193.169.4.1` |
| Test IP (LAN) | `192.168.1.111` (statik, init=/bin/sh shellda ifconfig bilan) |

---

## 🗂 MTD LAYOUT

```
mtd0  0x000000-0x080000   512K  boot     U-Boot bootloader
mtd1  0x080000-0x0C0000   256K  env      U-Boot env (fw_setenv ishlaydi)
mtd2  0x0C0000-0x100000   256K  logo     Boot logo
mtd3  0x100000-0x400000     3M  kernel   uImage (MIPS LZMA)
mtd4  0x400000-0x1300000   15M  appfs    SQUASHFS — rootfs (RO)
mtd5  0x1300000-0x1600000   3M  web      SQUASHFS — Boa web UI fayllari
mtd6  0x1600000-0x1900000   3M  custom   SQUASHFS — brending (analog kamera custom)
mtd7  0x1900000-0x4900000  48M  face     SQUASHFS — face recognition modellari
mtd8  0x4900000-0x8000000  55M  config   UBIFS — yagona writable partition (tconfig_ubifs)
```

`mtdblock4` rootfs sifatida boot bo'ladi (`root=/dev/mtdblock4 rootfstype=squashfs`).

---

## 💻 FIRMWARE STACK

**Brending banner:** "Into Zview Series Interface"
**OEM:** Zview / Higheasy (Xitoy)
**Distributor:** DSS (O'zbekistonga import qiluvchi, Eron ekosistemasiga ham bog'liq)

**Versiyalar:**

| Komponent | Versiya |
|---|---|
| BasicVersion (env) | `50600` |
| App binver (env) | `.N3xxB-11NEA-AI` |
| MPP | `IMP-1.6.2.2` |
| Multi-process sys | `H20230310` |
| VDE / VDEC / IPU / FB | `H20240108a` / `H20230425a` / `20230926B` / `H20241226A` |
| SOC-NNA | `20230512a` |
| AIP | `H20230213a` |
| Boa | `0.94.14rc21` |
| libvideonetclient | `V7.1.1.19705 Build 20250324` |
| PkgStream | `1.0.0.26197 Build Mar 10 2025` |
| License date | `2025-03-20` |

**Asosiy ilova:** `/root/edvr/edvr` (loyiha boot vaqtida `/tmp/edvr/edvr` ga ko'chiriladi, ~737 MiB RAM)

---

## ☁️ BULUT VA P2P MANBALARI (BLOKLASH MOLJALI)

**TUTK P2P:**
- UID: `IOTFCC-016178-PVSDB,ZQUUYH#FGFZJK`
- p2p_name: `IOTF`
- p2p_authword: `CS2_AiPN__SPSKEY`

**Boot vaqtida resolve qilinadigan domenlar:**

| Domen | IP | Joylashuv | Eslatma |
|---|---|---|---|
| `frp1.farap2p.ir` | `194.5.175.12` | **Eron** | DSS ekosistemasi P2P |
| `ruisionvps1.com` | `94.74.145.147` | **Eron** | DSS distributor VPS |
| `ewcloud.com` | `47.88.33.190` | **Xitoy AWS** | OEM bulut |
| `ai.com` | `190.92.213.42` | - | Tahlil kerak |
| `pool.ntp.org` | DNS resolve | - | Vaqt sinxronlash |

Lokal IPC config:
- `192.168.1.253:6060` — front-camera default IP (NVR shu IPdagi kamerani izlaydi)

**Yashirin trigger:** `/etc/init.d/p2p_telnet.sh` — bu **DSS backdoor**! Agar `/home/config/did.ini` mavjud bo'lsa, `/root/edvr/p2p_telnet` ni TUTK kalitlari bilan ishga tushiradi va P2P orqali masofadan telnet tunnel ochadi.

✅ Hozirgi qurilmada `did.ini` **YO'Q** (faktoring rejimda), shuning uchun p2p_telnet hozir ishlamayapti. Certificate ishida albatta bloklash kerak.

---

## 🧱 BOOT ZANJIRI

```
U-Boot → bootcmd: nand read 0x80600000 0x100000 0x300000; bootm 0x80600000
       (autoboot 1s, "Hit any key to stop autoboot")
   ↓
kernel (uImage from mtd3) + bootargs:
   console=ttyS1,115200n8 mem=156M@0x0 rmem=84M@0x9c00000 nmem=16M@0xf000000
   init=/linuxrc rootfstype=squashfs root=/dev/mtdblock4 r
   mtdparts=sfc_nand:...
   lpj=11968512
   ↓
/linuxrc → /sbin/init (busybox)
   ↓
/etc/inittab:
   ::sysinit:/etc/init.d/rcS
   ::sysinit:/bin/mkdir /dev/shm
   ::respawn:-/bin/login        ← UART login (busybox login, /etc/passwd)
   ::ctrlaltdel:/sbin/reboot
   ↓
rcS:
   /bin/mount -a
   /etc/init.d/logo start
   for S[0-9][0-9]* scripts in order
   /etc/init.d/rootapp           ← oxirgi qadam, edvr launch va custom.sh trigger
```

**rcS aniq matni:**
```sh
#! /bin/sh
/bin/mount -a
mkdir -p /dev/.udev

/etc/init.d/logo start

for initscript in /etc/init.d/S[0-9][0-9]*
do
        if [ -x $initscript ] ;
        then
                echo "[RCS]: $initscript"
                $initscript start
        fi
done

/etc/init.d/rootapp
```

**S70servers** — telnetd va Boa:
```sh
if [ -x /usr/sbin/telnetd ]; then
    /usr/sbin/telnetd          # port 23, /bin/login auth (parol kerak)
fi
# ... Boa port = Edvr.cfg'dan o'qiladi
/bin/boa -c /home/http/ -f /home/custom/config/boa.conf -p $port
```

**rootapp** — bizning persistence hook'imiz:
```sh
if [ -f /usr/local/etc/custom.sh ]
then
        /usr/local/etc/custom.sh &
fi
```

⚠️ **Watchdog xavfi:** `rootapp` quyidagi qatorni ham ishga tushiradi:
```sh
if [ ! -f /usr/local/etc/.no_watch ]
then
        /usr/sbin/watch &
fi
```
`/usr/sbin/watch` jarayoni **bilinmagan telnetd'ni SIGTERM bilan o'ldiradi** (boot'dan ~15s keyin). Yechim: custom.sh ichida **respawn loop** (quyiroqda).

---

## 🔗 SIMLINK ZANJIRI (kalit topilma)

```
/usr/local/etc → /home/config           (rootfs squashfs symlink, 12 bayt)
/home/config   → tconfig/config         (rootfs squashfs symlink, 14 bayt, RELATIVE)
                  ↓
                  /home/tconfig/config  (UBIFS, /dev/ubi0_0)
```

**Demak `/usr/local/etc/custom.sh` aslida `/home/tconfig/config/custom.sh` (UBIFS, RW, persistent).**

UBIFS factory reset bilan o'chirilishi mumkin (install.sh'da `Restore_Factory` trigger bor), shuning uchun factory-reset chidamli persistence uchun `mtd6 (custom)` yoki `mtd4 (appfs)` ni qayta build qilish kerak.

---

## 🔐 LOGIN MEXANIZMI

**`/etc/inittab`:**
```
::respawn:-/bin/login        # busybox login, parol /etc/passwd dan
```

Kameradagi `/bin/mylogin`/`ptzsupport` triki YO'Q. UART login to'g'ridan-to'g'ri parol so'raydi, 60 soniyada timeout bo'lib qaytadan respawn.

**`/etc/passwd`:**
```
root:$1$7bfnUEjV$3ogadpYTDXtJPV4ubVaGq1:0:0::/root:/bin/sh
```

- `$1$` = **MD5 crypt**
- Salt: `7bfnUEjV`
- Hash: `3ogadpYTDXtJPV4ubVaGq1`
- `/etc/shadow` bo'sh
- 119000+ namzad (wordlist + 4-digit + sanalar + vendor strings) **muvaffaqiyatsiz**
- Crack rate: ~1280/s (Python passlib)

**Web UI parol** (Boa, port 80):
- `admin / Admin1234` (boa runtime log'idan)
- Bu **Linux root parol EMAS** — alohida web auth

**Bilingan kuzatuv:** `/etc` aslida **tmpfs**, demak `/etc/passwd` boot vaqtida qayerdandir kopiyalanadi (ehtimol rootfs squashfs ostidagi original'dan). Parol almashtirish uchun yo rootfs rebuild, yo `custom.sh` ichidan boot vaqtida `/etc/passwd` ni overwrite qilish kerak.

---

## 🚀 TELNET ISHLATISH KETMA-KETLIGI (TO'LIQ)

> **Maqsad:** har boot'dan keyin **port 2323'da parolsiz root telnet** ochiq turishi. UART qadami faqat **bir martalik** kerak — keyin UART/U-Boot kerak emas.

### KERAKLI APPARAT

| Vosita | Tafsil |
|---|---|
| USB-UART konvertor | CH9102 chip, 3.3V, COM7 |
| UART pinlar | NVR plata'sida TX/RX/GND (ttyS1 → 115200 8N1) |
| Ethernet | NVR'ning LAN portini PC bilan bitta switch'ga ulang |
| Tera Term (Windows) | UART terminal — Send File qulay |
| MobaXterm/PuTTY (Windows) | Telnet client, kelajak ulanish uchun |
| PC IP | Misol uchun `192.168.1.7/24` (NVR `192.168.1.111` bo'ladi) |

### A) BIR MARTALIK SETUP (UART orqali, taxminan 5 daqiqa)

#### A.1. Tera Term sozlash
- **Setup → Serial port:** COM7, 115200, 8 bit, none parity, 1 stop, none flow
- **Setup → Terminal:** New-line = AUTO/AUTO
- **File → Transfer → SendFile → option:**
  - Binary OFF
  - **Transmit delay: 10 ms/char, 50 ms/line** (Br@y'da delay yo'q — paste drop bo'ladi)

#### A.2. NVR'ni yoqib U-Boot autoboot'ni to'xtatish
NVR'ni power-on qiling. UART'da quyidagi qator chiqishi bilan **Enter** bosing (1 soniya oynasi):
```
Hit any key to stop autoboot:  1  0
```
`isvp_a1#` prompt chiqishi kerak.

#### A.3. `init=/bin/sh` bootargs
`isvp_a1#` da quyidagi bir blokni Tera Term Paste qiling:
```
setenv bootargs 'console=ttyS1,115200n8 mem=156M@0x0 rmem=84M@0x9c00000 nmem=16M@0xf000000 init=/bin/sh rootfstype=squashfs root=/dev/mtdblock4 rw mtdparts=sfc_nand:512K(boot),256K(env),256K(logo),3M(kernel),15M(appfs),3M(web),3M(custom),48M(face),-(config) lpj=11968512'
boot
```

⚠️ **`saveenv` QILMANG** — bu bir martalik o'zgartirish, RAM env. Keyingi reboot'da asl `init=/linuxrc` qaytadi va biz aynan shuni xohlaymiz.

⚠️ **Kameradan farq:** vendor bootargs'da yolg'iz `r` tokeni bor (vendor xatosi). `init=/bin/sh` bilan birga qoldirsangiz "can't open 'r'" → kernel panic. **`r` ni `rw` ga aylantiring** (yuqoridagi misolda allaqachon shunday).

#### A.4. Shell setup (kernel boot tugab `/ #` chiqsa)
```sh
mount -t tmpfs tmpfs /tmp
mount -t proc proc /proc
mount -t sysfs sys /sys
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
ifconfig eth0 192.168.1.111 netmask 255.255.255.0 up
ubiattach /dev/ubi_ctrl -m 8
sleep 2
mount -t ubifs /dev/ubi0_0 /home/tconfig
```

`mount` natijasida `/dev/ubi0_0 on /home/tconfig type ubifs (rw)` ko'rinsin.

#### A.5. Recovery telnet (qulay tahlil uchun)
```sh
telnetd -l /bin/sh -p 2323
ps | grep telnetd
```
`ps` natijasida `telnetd -l /bin/sh -p 2323` jarayoni ko'rinsin. Endi PC'dan MobaXterm/PuTTY orqali `192.168.1.111:2323` ga ulanish mumkin.

#### A.6. PC'dan ulanishni tekshirish
PowerShell'da:
```powershell
Test-NetConnection 192.168.1.111 -Port 2323
```
Yoki Python orqali:
```python
import socket
s = socket.socket(); s.connect(('192.168.1.111', 2323)); print('OK'); s.close()
```
`TcpTestSucceeded: True` chiqsa — telnet shell tirik.

#### A.7. Persistent `custom.sh` ni UBIFS'ga yozish

Endi UART (yoki yangi ochilgan telnet 2323) shellida bu blokni paste qiling:

```sh
cat > /home/tconfig/config/custom.sh << 'CUSTOM_EOF'
#!/bin/sh
# Parolsiz root telnet 2323 -- persistent log on UBIFS
LOG=/home/tconfig/config/custom.log
{
echo "===== custom.sh started $(date) ====="
echo "PID=$$ PPID=$PPID UID=$(id -u)"
echo "PATH=$PATH"
echo "--- mount before ---"
mount
echo "--- mkdir /dev/pts ---"
mkdir -p /dev/pts && echo "mkdir OK" || echo "mkdir FAIL"
echo "--- mount devpts ---"
mount -t devpts devpts /dev/pts
echo "mount rc=$?"
mount | grep devpts
ls -la /dev/pts 2>&1
echo "--- sleeping 3 ---"
sleep 3
# Respawn loop: /usr/sbin/watch SIGTERM yuborsa qayta tushirsin
(
  while true; do
    echo "[$(date)] starting telnetd"
    telnetd -F -l /bin/sh -p 2323
    echo "[$(date)] telnetd exited rc=$?"
    sleep 2
  done
) &
RESPAWN_PID=$!
echo "respawn loop pid=$RESPAWN_PID"
sleep 2
echo "--- ps ---"
ps
echo "--- netstat ---"
netstat -tlnp 2>&1
echo "===== custom.sh done $(date) ====="
} >> $LOG 2>&1
CUSTOM_EOF
chmod +x /home/tconfig/config/custom.sh
ls -la /home/tconfig/config/custom.sh
sync
```

`ls -la` natijasida `-rwxr-xr-x ... 878 ... custom.sh` ko'rinishi kerak (~878 bayt).

#### A.8. Reboot va sinov
```sh
sync
reboot -f
```

NVR ~30-60 soniyada normal bootlanadi. **UART qadami endi kerak emas.**

PC'dan tekshirish:
```powershell
Test-NetConnection 192.168.1.111 -Port 2323
```
`True` chiqsa — persistent telnet ishladi. ✅

### B) ODATIY ULANISH (har kungi ish)

NVR yoqilgach 30-60 soniya boot vaqti — keyin har doim:

**MobaXterm:**
- Session → Telnet
- Remote host: `192.168.1.111`
- Port: `2323`
- "OK" → parol so'ralmaydi, to'g'ridan `~/edvr #` prompt

**PuTTY:**
- Host Name: `192.168.1.111`
- Port: `2323`
- Connection type: ⦿ Telnet
- Open

**Windows CMD telnet:**
```cmd
telnet 192.168.1.111 2323
```
(agar telnet client yoqilgan bo'lsa: `dism /online /Enable-Feature /FeatureName:TelnetClient`)

**Python skript (avtomatlashtirish uchun):**
```python
import socket, time
s = socket.socket()
s.connect(('192.168.1.111', 2323))
time.sleep(0.5)
s.recv(4096)  # banner + IAC bytes
s.sendall(b'<sizning buyrugingiz>\n')
time.sleep(1)
print(s.recv(8192).decode('ascii', 'replace'))
s.close()
```

---

## 🔍 PERSISTENT TELNET — IZOH VA SIRLAR

### Nima uchun avvalgi (sodda) `custom.sh` ishlamadi?

Avvalgi versiya:
```sh
#!/bin/sh
sleep 5
telnetd -l /bin/sh -p 2323 &
```

Muammo: `rootapp` qatori `/usr/sbin/watch &` ham ishga tushiradi — bu vendor watchdog **bilinmagan jarayonlarni SIGTERM bilan o'ldiradi**. Custom.log'dan dalil:
```
===== custom.sh done 00:22:44
Terminated
[00:22:55] telnetd exited rc=143    ← rc=143 = SIGTERM
[00:22:57] starting telnetd          ← respawn tuzatdi
```

### Yangi versiyaning ustunliklari

1. **UBIFS persistent log** (`/home/tconfig/config/custom.log`) — reboot'dan keyin saqlanadi, debug uchun
2. **Respawn loop** — `telnetd -F` (foreground) + while loop, SIGTERM tushsa 2s ichida qayta ishga tushadi
3. **Batafsil diagnostika** — mountlar, mkdir natijasi, mount rc, ls, ps, netstat — sabab muammo bo'lganda aniq topiladi

### Bilinmagan/kuzatilgan fakt

- **`/etc` aslida tmpfs** (4 MiB) — boot vaqtida rootfs squashfs'dan kopiyalanadi
- **`devpts` udev/systemd tomonidan auto-mount qilinadi** (avvalgi gipoteza noto'g'ri edi — devpts mavjud)
- **`/usr/sbin/systemd`** ishlayapti (PID 682 yangi boot'da) — rootapp'da kommentariya bo'lgan, lekin baribir ishlayapti
- **Port 23 (S70servers'dan telnetd)** ham ochiq, lekin login parol so'raydi
- Boot tugagandan keyin tipik jarayonlar: edvr (737M RAM), boa (port 80), telnetd port 23, watch (PID 1150)

---

## 📍 HOZIRGI HOLAT (2026-05-16)

✅ UART root shell (init=/bin/sh orqali)
✅ /home/config → tconfig/config → /home/tconfig/config (UBIFS) zanjiri tasdiqlangan
✅ /home/tconfig/config/custom.sh persistence ishlayapti
✅ Devpts udev/systemd tomonidan auto-mount qilinadi
✅ **`/usr/sbin/watch` muammosi aniqlandi va respawn loop bilan yengildi**
✅ **PERSISTENT TELNET 2323 — har boot'dan keyin avto-ochiq, parolsiz root**
✅ UBIFS persistent log mexanizmi (`/home/tconfig/config/custom.log`)
🟡 Hozirgi qurilmada `did.ini` yo'q — DSS P2P backdoor faollashtirilmagan (lekin certificate ishida vendor faollashtirishi mumkin)
❌ MD5crypt root parol topilmadi (119000 namzad sinaldi)
❌ Cloud bloklash hali boshlanmagan
❌ Brending o'zgartirish hali boshlanmagan
❌ `/etc/passwd` overlay hali kerak (yoki rootfs rebuild)
❌ Factory-reset chidamli persistence (mtd4/mtd6 reflash) hali kerak
❌ `/usr/sbin/watch` ichini o'rganish (qora ro'yxat / detection mantiq)

---

## 🎯 KEYINGI QADAMLAR

### Qadam 1 — Cloud bloklash (kameradagi v28 pattern)

**Qatlam 1: `/etc/hosts` overlay.** `/etc` tmpfs, shuning uchun custom.sh ichida har boot'da yozish kerak:
```sh
# custom.sh ichiga qo'shish (telnetd qatoridan oldin):
cat > /etc/hosts << HOSTS_EOF
127.0.0.1 localhost
0.0.0.0 frp1.farap2p.ir
0.0.0.0 ruisionvps1.com
0.0.0.0 ewcloud.com
0.0.0.0 ai.com
0.0.0.0 pool.ntp.org
HOSTS_EOF
```

Yoki UBIFS'dagi `/home/tconfig/config/hosts` ni edit qilish — rootapp uni `/usr/local/etc/hosts` ga qarab boshqaradi (kuzatilgan).

**Qatlam 2: IP route reject:**
```sh
route add -host 194.5.175.12 reject
route add -host 94.74.145.147 reject
route add -host 47.88.33.190 reject
route add -host 190.92.213.42 reject
```

**Qatlam 3: p2p_telnet.sh ni o'chirish:**
- `did.ini` faylini yaratmaslik / o'chirish
- `/etc/init.d/p2p_telnet.sh` ni neytrallashtirish (rootfs rebuild yoki tmpfs overlay)

### Qadam 2 — `/usr/sbin/watch` tahlili

Watchdog'ning aniq mantiqini bilish foydali (kelajakda qo'shimcha hooklarmiz bilan to'qnashmaslik uchun):
```sh
file /usr/sbin/watch
strings /usr/sbin/watch | grep -i -E "kill|process|telnet|ps"
# Telnet 2323 orqali PC'ga ko'chirib Ghidra'da tahlil
```

### Qadam 3 — `/etc/passwd` parolni almashtirish

`/etc` tmpfs bo'lgani uchun custom.sh ichidan overwrite qilish mumkin:
```sh
# Yangi hash yarating (PC'da):
# python -c "from passlib.hash import md5_crypt; print(md5_crypt.hash('YANGI_PAROL'))"
# Misol: $1$ABCDEFGH$xxxxxxxxxxxxxxxxxxxxxx

# custom.sh ichida (telnetd dan oldin):
cat > /etc/passwd << PASSWD_EOF
root:$1$ABCDEFGH$xxxxxxxxxxxxxxxxxxxxxx:0:0::/root:/bin/sh
PASSWD_EOF
```

Bu UART login va port 23 telnetd uchun ham ishlaydi.

### Qadam 4 — Brending

- **mtd2 (logo)** — boot logo'ni almashtirish (256 KiB, vendor formati)
- **mtd6 (custom)** ichidagi `/home/custom/config/`:
  - `CustomizedInfo.cfg` — sotuvchi nomi
  - `EGUI.cfg` — GUI matnlari
  - `Edvr.default` — factory default sozlamalar
  - `boa.conf` — web UI konfigi
- **mtd5 (web)** ichidagi `/home/http/` — web UI tarjimasi

UBIFS overlay strategiya: `/home/tconfig/config/` da o'sha fayllarning o'z versiyalarini saqlash (vendor `/home/custom/install.sh` allaqachon shu yo'l bilan ishlatadi).

### Qadam 5 — Factory reset chidamli persistence

UBIFS factory reset bilan o'chirilishi mumkin. Mukammal yechim — mtd4 (appfs) yoki mtd6 (custom) ni qayta build qilish:
1. mtd4 ni dump qilish: telnet shellda `cat /dev/mtdblock4 > /tmp/appfs.bin`, keyin SCP/FTP/HTTP orqali PC ga
2. squashfs unsquashfs → modify (`/etc/inittab`, `/etc/init.d/rootapp`, `/etc/passwd`) → mksquashfs
3. Yangi appfs.bin ni U-Boot orqali (tftpboot + nand write) yoki vendor update mexanizmi orqali yozish
4. Yoki kichikroq risk: mtd6 (custom partition, 3MB) ni reflash qilish

### Qadam 6 — Web UI tahlil (port 80, Boa)

Telnet shellda:
```sh
cat /home/custom/config/boa.conf
ls /home/http/
find /home/http -name '*.htm*' -o -name '*.cgi'
```
Boa 0.94.14rc21 — eski versiya, CVE'lar bor (CVE-2017-9833 va boshqalar). Web UI buffer overflow / auth bypass tekshirish foydali.

---

## 📂 BU LOYIHA UCHUN FAYLLAR

| Fayl | Maqsad |
|---|---|
| `C:\Users\User\Desktop\Kamera\DSS_NVR_Qollanma_v1.md` | **Bu hujjat** |
| `C:\Users\User\Desktop\Kamera\nvr_custom_fix.sh` | Eski persistent custom.sh yozish skripti (878-bayt yangi versiyaga yangilanishi kerak) |
| `C:\Users\User\Desktop\Kamera\nvr_hash.txt` | MD5crypt hash (root) |
| `C:\Users\User\Desktop\Kamera\nvr_crack.py` | Wordlist attack |
| `C:\Users\User\Desktop\Kamera\nvr_crack2.py` | Expanded (vendor + 4-digit + dates) |
| `C:\Users\User\Desktop\Kamera\nvr_crack3.py` | 5-8 digit numeric brute (to'xtatildi) |
| `C:\Users\User\Desktop\Kamera\kameralog.log` | UART terminal logi (har bir session) |

---

## ⚠️ EHTIYOT CHORALARI

1. **`saveenv` QILMANG** U-Boot'da. Asl bootargs faqat NAND'da, RAM env o'zgartirish bir martalik. Aks holda har boot'da `init=/bin/sh` mode'ga tushib ketadi (edvr ishlamaydi).
2. **`erase`, `nand erase`, `mtd erase`** — bu buyruqlar partitionni butunlay yo'q qiladi. Faqat backup olgandan keyin ishlating.
3. **mtd4 (appfs)** ga to'g'ridan-to'g'ri yozish brick xavfi tug'diradi. Avval `cat /dev/mtdblock4 > backup_appfs.bin` qilib backup oling.
4. **`/home/tconfig/config/custom.sh`** ni faktoring rejimida sinab ko'ring — UBIFS factory reset trigger uni o'chirishi mumkin.
5. **`/usr/sbin/watch`** ehtiyot bo'ling — boshqa unauthorized jarayonlarni ham o'ldirishi mumkin (telnetd uchun respawn ishlatdik, boshqa kerak bo'lsa o'sha pattern).
6. **TUTK kalitlar** (`p2p_authword`, `p2p_name`, UID) — qurilmaga bog'langan. Boshqa qurilma firmware'iga ko'chirib bo'lmaydi.
7. **DSS license** (Auth Code, Board ID 0x1958) — boshqa firmware bilan ishlamasligi mumkin.

---

## 🔑 KRITIK BUYRUQLAR (TEZ MA'LUMOTNOMA)

### U-Boot'da init=/bin/sh
```
setenv bootargs 'console=ttyS1,115200n8 mem=156M@0x0 rmem=84M@0x9c00000 nmem=16M@0xf000000 init=/bin/sh rootfstype=squashfs root=/dev/mtdblock4 rw mtdparts=sfc_nand:512K(boot),256K(env),256K(logo),3M(kernel),15M(appfs),3M(web),3M(custom),48M(face),-(config) lpj=11968512'
boot
```

### init=/bin/sh shell'da to'liq setup
```sh
mount -t tmpfs tmpfs /tmp
mount -t proc proc /proc
mount -t sysfs sys /sys
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
ifconfig eth0 192.168.1.111 netmask 255.255.255.0 up
ubiattach /dev/ubi_ctrl -m 8
sleep 2
mount -t ubifs /dev/ubi0_0 /home/tconfig
```

### Live (test) parolsiz telnet — bir martalik
```sh
telnetd -l /bin/sh -p 2323
```

### Persistent telnet ko'rsatkichi (yozilgan)
- Joy: `/home/tconfig/config/custom.sh` (878 bayt, executable)
- Log: `/home/tconfig/config/custom.log` (UBIFS, persistent)
- Avtomatik chaqiruvchi: `/etc/init.d/rootapp` (boot oxirida, edvr'dan oldin)

### PC dan ulanish (normal boot'dan keyin)
```
telnet 192.168.1.111 2323
# yoki
Test-NetConnection -ComputerName 192.168.1.111 -Port 2323
```

### Custom.log o'qish (debug uchun)
```sh
# Telnet shellda
cat /home/tconfig/config/custom.log
# yoki PC'dan Python orqali (avtomatik):
python -c "
import socket, time
s = socket.socket(); s.connect(('192.168.1.111', 2323))
time.sleep(0.5); s.recv(4096)
s.sendall(b'cat /home/tconfig/config/custom.log\necho __END__\n')
time.sleep(2); print(s.recv(16384).decode('ascii','replace'))
s.close()"
```

---

## 📚 KAMERAGA TAQQOSLASH

| Aspekt | Kamera (H4P, Hi3516CV610) | NVR (DSS, Ingenic A1) |
|---|---|---|
| SoC | HiSilicon ARM | Ingenic MIPS |
| Console | `ttyAMA0` | `ttyS1` |
| Rootfs | `mtdblock2` SQUASHFS | `mtdblock4` SQUASHFS |
| Writable mt | mtd3 (data, jffs2/?) | mtd8 (config, UBIFS) |
| Login | `/bin/mylogin` (ptzsupport) | `/bin/login` (to'g'ridan) |
| Parol hash | DES crypt (G9 salt) | MD5 crypt ($1$7bfnUEjV) |
| Cloud arch | xrscam ichida | edvr ichida (Higheasy SDK) |
| Persistence joy | `mtd2` rootfs rebuild | `/home/tconfig/config/custom.sh` (UBIFS) ✅ |
| Telnet sabab | `/etc/passwd` ochiq | `custom.sh` + respawn loop ✅ |
| Cloud blok | 3 qatlam (hosts + route + DNS) | Hali boshlanmagan |
| Watchdog | YO'Q | **`/usr/sbin/watch`** (telnetd o'ldiradi) |

---

## ✅ NIMA ISHLAGAN

1. UART terminal ulanishi (CH9102, 115200)
2. U-Boot autoboot interrupt va env tahlil
3. `init=/bin/sh` parolsiz shell (bir martalik bootargs)
4. UBIFS mount va recon
5. `/home/config` symlink zanjirini aniqlash
6. Devpts udev/systemd tomonidan auto-mount qilinishini aniqlash
7. Live telnetd 2323 parolsiz, PC dan ulanish
8. **`/usr/sbin/watch` SIGTERM hujumini aniqlash** (custom.log orqali)
9. **Persistent custom.sh + respawn loop — har boot'da telnet 2323 avto-ochiq** ✅
10. UBIFS log mexanizmi (debug uchun)

## ⏳ NIMA QOLDI

1. Cloud domen va IP'larni bloklash (3 qatlam)
2. `/usr/sbin/watch` ichini Ghidra'da tahlil
3. `/etc/passwd` parolni almashtirish (custom.sh overlay yoki rootfs rebuild)
4. Factory reset chidamli persistence (rootfs rebuild)
5. Brending (logo, GUI, til)
6. Web UI (Boa) zaifligi tekshirish
7. `p2p_telnet.sh` (DSS backdoor) ni neytrallashtirish
8. `edvr` binarini Ghidra'da tahlil — qaysi cloud chaqiruvlari bor
