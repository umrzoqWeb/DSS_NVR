# DSS NVR (Ingenic A1) — Tahlil, O'zbeklashtirish, Cloud Bloklash — v2.0

> **Maqsad:** DSS rebrend NVR'ni O'zbek bozori uchun to'liq moslashtirish — Hi3516CV610 kameradan keyingi qurilma.
>
> **Yondashuv:** UART → init=/bin/sh recon → UBIFS hook → **mtd5 reflash (til)** → **mtd6 reflash (cloud blok)** → factory-reset chidamli.
>
> **Status:** 🏆 **YAKUNLANGAN** — barcha asosiy maqsadlar bajarildi va factory reset bilan sinovdan o'tdi.
>
> **Sana:** 2026-05-13 → 2026-05-17 (5 kun)
>
> **Murakkablik:** Yuqori — UART, U-Boot, UBIFS, MIPS, squashfs reflash
>
> **Kameradan farqi:** Hi3516CV610 emas, **Ingenic XBurst A1** (MIPS). Login wrapper YO'Q, MD5crypt parol (DES emas), UBIFS RW partition mavjud, SFC NAND 128MB.

---

## 🎯 ERISHILGAN NATIJALAR

| Bosqich | Holat | Saqlanish |
|---|---|---|
| 1. UART root access (init=/bin/sh) | ✅ | Bir martalik |
| 2. Telnet 2323 persistent | ✅ | mtd6 install.sh dan |
| 3. O'zbek tilga tarjima (1346 string) | ✅ | mtd5'da hardcoded |
| 4. `language.json` (ja → uz) | ✅ | mtd5'da |
| 5. `playMode.json` (EasyVideo → DirectMode) | ✅ | mtd5'da |
| 6. Cloud DNS bloklash (47 domen → 0.0.0.0) | ✅ | mtd6 install.sh dan |
| 7. Cloud IP route reject (35 ta IP) | ✅ | mtd6 install.sh dan |
| 8. `p2p_telnet.sh` backdoor neytrali | ✅ | mtd6 install.sh dan |
| 9. /etc/hosts edvr-overwrite himoyasi | ✅ | mtd6 guard loop |
| 10. **Factory reset chidamliligi** | ✅ | mtd5 + mtd6 RO squashfs |
| 11. Firmware update endpoints bloklangan | ✅ | mtd6 v4 |

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
| Disk | 2× SATA (HDD slot) |
| USB | 3× USB host |
| Kernel | Linux `4.4.94-20220517`, build `Mon Apr 14 10:25:51 CST 2025` |
| Toolchain | gcc 7.2.0 (Ingenic Linux-Release5.1.8) |
| U-Boot | SPL `2013.07` (build `Sep 26 2024`), `bootdelay=1` |
| MAC eth0 | `00:11:22:56:96:69` |
| Test IP (LAN) | `192.168.1.111` yoki DHCP |

---

## 🗂 MTD LAYOUT

```
mtd0  0x000000-0x080000   512K  boot     U-Boot bootloader
mtd1  0x080000-0x0C0000   256K  env      U-Boot env (fw_setenv ishlaydi)
mtd2  0x0C0000-0x100000   256K  logo     Boot logo
mtd3  0x100000-0x400000     3M  kernel   uImage (MIPS LZMA)
mtd4  0x400000-0x1300000   15M  appfs    SQUASHFS — rootfs (RO)
mtd5  0x1300000-0x1600000   3M  web      SQUASHFS — Boa web UI ★ TIL O'ZGARTIRILDI
mtd6  0x1600000-0x1900000   3M  custom   SQUASHFS — install.sh ★ CLOUD BLOK QO'SHILDI
mtd7  0x1900000-0x4900000  48M  face     SQUASHFS — face recognition modellari
mtd8  0x4900000-0x8000000  55M  config   UBIFS — yagona writable (factory reset bilan tozalanadi)
```

**Qatlamli arxitektura:**
- **mtd4, mtd5, mtd6, mtd7** — SQUASHFS RO. Factory reset bilan **saqlanadi**.
- **mtd8** — UBIFS RW. Factory reset bilan **o'chiriladi**.

**Bizning strategiya:** Doimiy o'zgarishlarni mtd5 va mtd6'ga reflash qilish → factory reset chidamli.

---

## 💻 FIRMWARE STACK

**Brending:** "Into Zview Series Interface" / OEM Zview / Higheasy (Xitoy) / Distributor DSS (O'zbekiston + Eron ekosistema).

| Komponent | Versiya |
|---|---|
| BasicVersion (env) | `50600` |
| App binver (env) | `.N3xxB-11NEA-AI` |
| MPP | `IMP-1.6.2.2` |
| Boa | `0.94.14rc21` |
| libvideonetclient | `V7.1.1.19705 Build 20250324` |
| License date | `2025-03-20` |

**Asosiy ilova:** `/root/edvr/edvr` (~737M RAM, ko'p tarmoq portda tinglaydi).

---

## ☁️ CLOUD VA P2P MANBALARI

### TUTK P2P kalitlar (qurilmaga bog'langan)
- UID: `IOTFCC-016178-PVSDB,ZQUUYH#FGFZJK`
- p2p_name: `IOTF`
- p2p_authword: `CS2_AiPN__SPSKEY`

### Bloklangan domenlar va IP'lar (mtd6 reflash bilan)

**Eron P2P (DSS ekosistemasi):**
- `frp1.farap2p.ir` (194.5.175.12)
- `frp2.farap2p.ir` (185.8.174.214)
- `ruisionvps1/2/3.com` (94.74.145.147/148/152)

**Xitoy OEM cloud (Higheasy/Zview/P6Sai):**
- `*.zviewcloud.com` (9 ta endpoint: szdev, usdev, erdev, iotb_×3, iotd_×3, rsiotg, rsiote)
- `*.p6sai.com` (7 ta: auth, rsbotd_×3, rsiotf_×2, p6saistore-cn, store-cn)
- `*.zwcloud.wang` (3 ta: erp, p6sstore.sales, testwx)
- `*.aftx.net` (3 ta: bjdev, hzdev, szdev)
- `ewcloud.com`, `ai.com`

**Firmware update endpointlar (mtd6 v4 da qo'shildi):**
- `update.ods.org` + `ods.org` (DDNS provider, ServerName_05)
- `www.zwcloud.wang` + `zwcloud.wang` root (ver10/XMLSchema)
- IP: `139.9.6.140` (CloudUpgradeTest test serveri)

**Vaqt server:**
- `pool.ntp.org` + variantlar (lokal NTP server tavsiya)

**JAMI: 47 ta domen → 0.0.0.0, 35 ta IP → No route to host**

### DSS backdoor

`/etc/init.d/p2p_telnet.sh` — agar `/home/config/did.ini` mavjud bo'lsa, TUTK orqali masofadan ulanish ochadi. **Neytrallashtirish:** `did.ini` ni **DIRECTORY** qilib qo'yamiz — fayl operatsiyalari fail bo'ladi.

---

## 🧱 BOOT ZANJIRI

```
U-Boot → bootcmd: nand read 0x80600000 0x100000 0x300000; bootm 0x80600000
       (autoboot 1s, "Hit any key to stop autoboot")
   ↓
kernel (uImage from mtd3) + bootargs:
   console=ttyS1,115200n8 ... init=/linuxrc rootfstype=squashfs root=/dev/mtdblock4
   ↓
/linuxrc → /sbin/init (busybox) → /etc/inittab
   ↓
::sysinit:/etc/init.d/rcS:
   /bin/mount -a
   /etc/init.d/logo start
   for S* scripts (S00devs, S01driver, S02udev, S03unlzma, S09mount,
                   S70servers, S71autofs, S80network, S90hwclock)
   /etc/init.d/rootapp           ← oxirgi qadam, edvr launch va custom.sh trigger
```

**S09mount → install.sh** (mtd6'dan, BIZNING modify qilingan versiya) ← cloud blok shu yerda.

**rootapp → custom.sh** (UBIFS'dan, hozir kerakmas — mtd6 install.sh hammasini qiladi).

---

## 🔗 SIMLINK ZANJIRI

```
/usr/local/etc → /home/config           (rootfs squashfs symlink, 12 bayt)
/home/config   → tconfig/config         (rootfs squashfs symlink, 14 bayt, RELATIVE)
                  ↓
                  /home/tconfig/config  (UBIFS, /dev/ubi0_0)

/etc/hosts → /home/config/hosts         (rootfs symlink, 18 bayt)
                  ↓
                  /home/tconfig/config/hosts  (UBIFS — edvr buni qoplab yozadi!)
```

**KRITIK:** `/etc/hosts` symlink-i orqali edvr UBIFS'dagi hostsni o'zgartiradi. Yechim — install.sh ichida symlink-ni regular tmpfs faylga aylantirish.

---

## 🔐 LOGIN MEXANIZMI

### Boa Basic Auth (CGI uchun)
- `/etc/conf.d/boa/userlist.conf` (mtd4 RO)
- Original: `admin:Admin1234`
- **Factory reset paytida boshqa parol ham bo'lishi mumkin (yoki bo'sh)**

### Web Form (Edvr UserAuth)
- `/Security/UserAuth` PUT endpoint
- `statusCode == 0` → success → `loginLoad()` → redirect
- `statusCode == -17` → wrong password
- `statusCode == -45` → empty/weak password → **MAJBURIY STRONG PASSWORD SETUP**

### Linux Root Parol (MD5crypt)
- `/etc/passwd`: `root:$1$7bfnUEjV$3ogadpYTDXtJPV4ubVaGq1:0:0::/root:/bin/sh`
- 119000+ namzad sinaldi — **muvaffaqiyatsiz** (boshqa loyiha)

---

## 🛠 BAJARILGAN ISH JARAYONI

### Faza 1: UART access + UBIFS overlay (2026-05-13 → 14)
1. UART terminal (CH9102, 115200 8N1, ttyS1)
2. U-Boot interrupt → `init=/bin/sh` bootargs
3. UBIFS mount → custom.sh yozish → telnet 2323

### Faza 2: O'zbek tilga tarjima va UBIFS overlay (2026-05-16)
1. Web UI til arxitekturasini aniqlash (jQuery i18n properties plugin)
2. `/home/web_language/strings_xx.properties` — 9 ta til fayli
3. `/home/http/custom/language.json` — til ro'yxati JSON
4. `/home/http/nvr/language/` — symlink directory
5. **1346 string tarjima** (en → uz, lotin alifbosi)
6. UBIFS overlay (bind mount 3 ta papka)

### Faza 3: Login Bug Tahlili (2026-05-16)
1. `playMode.json` → `["EasyVideo"]` muammosi
2. login.js'da `isSupportEasyVideo()` analizi
3. **EasyVideo → DirectMode** o'zgartirish → dashboard ochiladi

### Faza 4: Ubuntu Server o'rnatish (2026-05-17)
1. MCP orqali Ubuntu Server (testuser-Standard-PC, 10.0.4.17)
2. SSH ProxyJump: PC → admin-SPC (87.192.226.203:8770) → testuser (10.0.4.17:22)
3. 9 ta MTD partition backup (~129 MB) → server'ga SCP
4. `squashfs-tools` (mksquashfs/unsquashfs) va `binwalk` o'rnatilgan

### Faza 5: mtd5 reflash — TIL doimiy qilindi
1. `unsquashfs mtd5_web.bin` → 335 fayl + 14 symlink
2. **Vendor mksquashfs opsiyalari:** `-comp xz -b 262144 -no-progress` (NFS exportable)
3. Modifikatsiyalar:
   - `strings_uz.properties` qo'shish (real fayl, symlink emas)
   - `strings_ja.properties` symlink olib tashlash
   - `language.json` — `ja` o'rniga `uz`
   - `playMode.json` — `EasyVideo` → `DirectMode`
4. Rebuild + pad → 3 MB
5. `flashcp /tmp/mtd5_new.bin /dev/mtd5` (3 soniya)
6. **Factory reset sinov ✓**

### Faza 6: Cloud bloklash — UBIFS overlay
1. `/usr/sbin/iptables` mavjud emas — faqat `route`
2. `route add -host X reject` — kernel reject
3. `/etc/hosts` `0.0.0.0` overlay
4. `did.ini` directory (p2p_telnet.sh neytrali)
5. Custom.sh telnet 2323 respawn loop

### Faza 7: mtd6 reflash — CLOUD BLOK doimiy qilindi (3 iteratsiya)

**v1:** install.sh ga 33 ta IP route reject qo'shildi + hosts file 0.0.0.0 ga aylandi.

**v2:** `/etc/hosts` symlink-ni tmpfs regular fayl ga aylantirish.

**v3:** **edvr ishga tushgandan keyin** `/etc/hosts` ni qaytadan yozish + **60s guard loop** edvr qaytaroq yozishidan himoya.

**v4 (FINAL):** firmware update endpointlar qo'shildi — `139.9.6.140` IP, `update.ods.org`, `www.zwcloud.wang`. **Audit topilmalari** asosida (login.js + Edvr.cfg dan).

### Faza 8: Factory reset — yakuniy QA sinov
- ✅ Til o'zbekcha (mtd5)
- ✅ Telnet 2323 ochiq (mtd6 install.sh)
- ✅ 12/12 cloud domain → 0.0.0.0
- ✅ 6/6 cloud IP → No route to host
- ✅ Internet umumiy ishlayapti (8.8.8.8 ping OK, google.com DNS OK)
- ✅ Edvr tashqi ulanishlar = 0
- ✅ Guard loop edvr qaytaroq yozgan, tikladi

---

## 🛡️ HOZIRGI HIMOYA QATLAMLARI

```
1. mtd5 (RO)   — O'zbek til, DirectMode
2. mtd6 (RO)   — install.sh: cloud blok + telnet 2323 + p2p_telnet neytrali
3. UBIFS (RW)  — endi BO'SH (factory reset bilan o'chiriladi, lekin kerakmas)
4. Guard loop  — har 60s /etc/hosts ni qayta tekshiradi
5. Route reject — kernel level IP bloklash (35 ta)
```

---

## 📂 LOYIHA FAYLLARI

### NVR (mtd partitionlar)
| Fayl | Joy | Maqsad |
|---|---|---|
| `mtd5_web_uz.bin` | flashed → /dev/mtd5 | O'zbek til |
| `mtd6_custom_cloudblock.bin` | flashed → /dev/mtd6 | Cloud blok + telnet |

### Manba fayllar (modify uchun)
| Fayl | Joy | Maqsad |
|---|---|---|
| `strings_uz.properties` | Repo + mtd5 ichida | 1346 string o'zbek tarjima |
| `language.json` | Repo + mtd5 ichida | Til selektor JSON (ja → uz) |
| `firmware/install_addon_v1.sh` | Repo | mtd6 v1 install.sh qo'shimchasi |
| `firmware/install_addon_v2.sh` | Repo | mtd6 v2 — /etc/hosts symlink fix |
| `firmware/mtd5_web_uz.bin` | Repo | **mtd5 — O'zbek til (FINAL)** |
| `firmware/mtd6_custom_v4.bin` | Repo | **mtd6 — cloud blok v4 (FINAL)** |
| `firmware/build_scripts/install_addon_v1-v4.sh` | Repo | install.sh ga qo'shimcha (versiyalar tarixi) |
| `firmware/README.md` | Repo | Firmware deploy ko'rsatma |
| `firmware/MD5SUMS.txt` | Repo | Hash tasdiqlash |

### PC va helper
| Fayl | Joy | Maqsad |
|---|---|---|
| `nvr_custom_fix.sh` | Repo | UBIFS custom.sh (eski persistent) |
| `nvr_diag.sh` | Repo | UBIFS + devpts diagnostikasi |
| `nvr_crack*.py` | Repo | MD5crypt brute force urunishlar |

### Backup (git'da yo'q, mahalliy)
| Fayl | Joy | Maqsad |
|---|---|---|
| `mtd_backup/mtd[0-8]_*.bin` | `C:\...\mtd_backup\` | TO'LIQ FIRMWARE BACKUP (~129 MB) |
| `mtd_backup/md5sums.txt` | mahalliy | Cheksumlar |

⚠️ mtd backup'lari git'da yo'q (katta hajm + qurilmaga xos ma'lumotlar). **Doimiy saqlang!**

---

## 🚨 SQUASHFS REFLASH WORKFLOW (qisqacha)

### PC → Ubuntu Server (SSH ProxyJump bilan)
```bash
# PC'da SSH config (~/.ssh/config):
Host nvr-jump
    HostName 87.192.226.203
    Port 8770
    User adminl
    IdentityFile ~/.ssh/id_ed25519

Host nvr-srv
    HostName 10.0.4.17
    User testuser
    IdentityFile ~/.ssh/id_ed25519
    ProxyJump nvr-jump

# Upload:
scp file.bin nvr-srv:/home/testuser/NVR/
```

### Ubuntu Server'da modify
```bash
cd /home/testuser/NVR

# 1. Extract
unsquashfs -s mtd6_custom.bin            # Superblock info
unsquashfs -d extracted mtd6_custom.bin   # Extract

# 2. Modify fayllar
vim extracted/install.sh
echo "0.0.0.0  domain" >> extracted/config/hosts

# 3. Rebuild (VENDOR opsiyalari!)
mksquashfs extracted/ new.bin -comp xz -b 262144 -no-progress

# 4. Pad 3 MB ga
PARTSZ=3145728
NEW_SZ=$(stat -c%s new.bin)
head -c $((PARTSZ - NEW_SZ)) /dev/zero | tr '\0' '\377' >> new.bin

# 5. SCP qaytarish
scp new.bin pc:/path/
```

### NVR'da flash
```sh
# Telnet 2323 orqali NVR ichida:
cd /tmp && wget -O new.bin http://PC_IP:8080/new.bin
md5sum /tmp/new.bin   # cheksumni tasdiqlash
sync
/usr/sbin/flashcp -v /tmp/new.bin /dev/mtd6   # erase + write + verify
sync
rm -f /home/tconfig/config/hosts   # eski UBIFS overlay'ni o'chirish
sync
reboot -f
```

⚠️ **flashcp** atomik: erase + write + verify. Verify pass bo'lsa, partition to'g'ri yozilgan.

---

## ⚠️ EHTIYOT CHORALARI

1. **mtd0 (boot)** ga TEGMANG — bricking kafolatlanadi (faqat JTAG bilan tiklash)
2. **mtd3 (kernel)** — U-Boot tftpboot orqali tiklash mumkin, lekin xavfli
3. **mtd4 (rootfs)** — 15 MB, brick xavfi o'rta. Yangi rootfs tayyorlasa bo'ladi, lekin har bir loyiha alohida
4. **mtd5, mtd6, mtd7** — squashfs partition, kichik, eng past riskli
5. **`saveenv` QILMANG** U-Boot'da
6. **TO'LIQ BACKUP** — har bir reflash'dan oldin majburiy
7. **Cheksum tekshirish** — md5sum NVR va PC bir xilligi
8. **Vendor `mksquashfs` opsiyalari** — `-comp xz -b 262144 -no-progress` (NFS exportable). Boshqa opsiyalar bilan kernel mount qila olmaydi

---

## 🔑 KRITIK BUYRUQLAR (TEZ MA'LUMOTNOMA)

### U-Boot'da init=/bin/sh
```
setenv bootargs 'console=ttyS1,115200n8 mem=156M@0x0 rmem=84M@0x9c00000 nmem=16M@0xf000000 init=/bin/sh rootfstype=squashfs root=/dev/mtdblock4 rw mtdparts=sfc_nand:512K(boot),256K(env),256K(logo),3M(kernel),15M(appfs),3M(web),3M(custom),48M(face),-(config) lpj=11968512'
boot
```

### init=/bin/sh shellda to'liq setup
```sh
mount -t tmpfs tmpfs /tmp
mount -t proc proc /proc
mount -t sysfs sys /sys
mkdir -p /dev/pts && mount -t devpts devpts /dev/pts
ifconfig eth0 192.168.1.111 netmask 255.255.255.0 up
ubiattach /dev/ubi_ctrl -m 8
sleep 2
mount -t ubifs /dev/ubi0_0 /home/tconfig
mount -t squashfs /dev/mtdblock5 /home/http
mount -t squashfs /dev/mtdblock6 /home/custom
mount -t squashfs /dev/mtdblock7 /home/face_algo
telnetd -l /bin/sh -p 2323
```

### Partition dump (backup)
```sh
# Telnet 2323 da:
cat /dev/mtdblock0 | nc PC_IP 9999
# yoki HTTP via wget --post-file (kerak bo'lsa)
```

### Flash yangi mtd
```sh
sync
/usr/sbin/flashcp -v /tmp/new.bin /dev/mtdN
sync
reboot -f
```

### PC dan tekshirish
```
Test-NetConnection 192.168.1.111 -Port 2323
curl http://192.168.1.111/nvr/language/strings_uz.properties
curl http://192.168.1.111/custom/language.json
```

---

## 📚 KAMERA BILAN TAQQOSLASH

| Aspekt | Kamera (H4P, Hi3516CV610) | NVR (DSS, Ingenic A1) |
|---|---|---|
| SoC | HiSilicon ARM | Ingenic MIPS |
| Console | `ttyAMA0` | `ttyS1` |
| Rootfs | `mtdblock2` SQUASHFS | `mtdblock4` SQUASHFS |
| Writable | mtd3 (data, jffs2/?) | mtd8 (config, UBIFS) |
| Login | `/bin/mylogin` (ptzsupport) | `/bin/login` (to'g'ridan) |
| Parol hash | DES crypt (G9 salt) | MD5 crypt ($1$7bfnUEjV) |
| Cloud arch | xrscam ichida | edvr ichida (Higheasy SDK) |
| Persistence joy | rootfs rebuild | mtd5 + mtd6 reflash |
| Cloud blok | 3 qatlam (hosts + route + DNS) | **5 qatlam** (hosts + route + did.ini + guard + post-edvr timing) |
| Til | Web UI hech (test qilinmagan) | **mtd5 reflash bilan o'zbekcha** |
| Factory reset chidamliligi | ? | ✅ tasdiqlangan |

---

## 🎓 ASOSIY TEXNIK TOPILMALAR

### 1. Edvr `/etc/hosts` ni qaytaroq yozadi
- install.sh boot vaqtida yozadi → edvr keyinroq qoplab yozadi
- **Yechim:** `/etc/hosts` symlink → tmpfs regular fayl + edvr ishga tushgandan **15 soniya keyin** qaytadan yozish

### 2. `/usr/sbin/watch` SIGTERM yuboradi
- Vendor watchdog "noma'lum" jarayonlarni o'ldiradi
- Bizning telnet 2323 birinchi safar o'ldirildi (rc=143)
- **Yechim:** `while true; do telnetd -F ...; done` respawn loop

### 3. Squashfs vendor opsiyalari kritik
- Standart `mksquashfs file.bin` ishlamaydi
- **Kerak:** `-comp xz -b 262144 -no-progress` (NFS exportable)
- Aksincha → kernel mount qila olmaydi → brick yo'q lekin partition ishlamaydi

### 4. `flashcp` xavfsiz
- Atomik erase + write + verify
- Vendor SFC NAND uchun moslashtirilgan
- 3 MB ~3 soniyada flash bo'ladi

### 5. mtd5 + mtd6 yetarli (mtd4 ga tegmaslik)
- Til → mtd5 (web UI tarkibi)
- Cloud blok → mtd6 (install.sh)
- Telnet → mtd6 install.sh background
- mtd4 rootfs RISK kerak emas

### 6. Factory reset → UBIFS o'chadi → mtd5/mtd6 saqlanadi
- mtd8 UBIFS to'liq tozalanadi
- mtd5, mtd6 RO squashfs → barcha o'zgartirishlar saqlanadi
- install.sh boot paytida hammasini qayta o'rnatadi

---

## ⏳ KEYINGI BOSQICHLAR (ixtiyoriy)

| Vazifa | Murakkablik | Risk |
|---|---|---|
| **Boot logo o'zgartirish** (mtd2) | Past | Past |
| **CustomizedInfo.cfg brending** (mtd6) | Past | Past — qayta reflash |
| **Web UI rasm/logo** (mtd5 ichidagi `img/`) | Past | Past — qayta reflash |
| **MD5crypt parol almashtirish** (mtd4) | Yuqori | O'rta — rootfs reflash |
| **WebPlayer (WASM) sozlash** (video oqimi uchun) | Yuqori | Past |
| **Lokal NTP server** (pool.ntp.org o'rniga) | Past | Past — hosts qator qo'shish |
| **Local OSD (HDMI ekran)** Uzbek tarjima | **Juda yuqori** (2-3 oy) | O'rta — `iDVR_9000.rc` 1.8MB binary, **HECS-1 vendor encoding** (GBK emas), `.cs` schema fayli, custom rcc kerak. NVR allaqachon English+Russian ni qo'llab-quvvatlaydi (MenuLanguage tanlash orqali) |

---

## ✅ NIMA ISHLAGAN

1. UART terminal ulanishi (CH9102, 115200)
2. U-Boot autoboot interrupt va env tahlil
3. `init=/bin/sh` parolsiz shell
4. UBIFS mount va recon
5. Symlink zanjirini aniqlash
6. Devpts + telnet 2323 (live)
7. Web UI til arxitekturasi (jQuery i18n)
8. 1346 string o'zbek tarjima
9. `language.json` (ja → uz)
10. `playMode.json` (EasyVideo → DirectMode)
11. UBIFS overlay (bind mount 3 ta)
12. **Ubuntu Server (MCP + SSH ProxyJump)**
13. **9 mtd backup → server SCP**
14. **mtd5 reflash (til doimiy)**
15. Factory reset bilan til sinovi
16. Cloud bloklash UBIFS overlay (DNS + route + did.ini)
17. **mtd6 reflash v4 (cloud blok doimiy, firmware update endpoints ham)**
18. **Factory reset bilan to'liq sinov — ✅ HAMMA TEST OK**

---

## ⏳ NIMA QOLDI (loyiha tashqarisi)

1. Boot logo brending (mtd2)
2. Customized info / vendor brending matn (mtd6)
3. Web UI img/logo PNG fayllari (mtd5 ichida)
4. Lokal OSD til tarjima (`iDVR_9000.rc` MiniGUI compiled binary)
5. WebPlayer (WASM) video oqimi
6. MD5crypt parol (UART shell-da auto-login uchun)

---

## 📞 ALOQA

**Loyiha mualliflari:** [umrzoqWeb]
**Repo:** https://github.com/umrzoqWeb/DSS_NVR
**Sana:** 2026-05-17

---

*Hujjat v2.0 — DSS NVR uchun to'liq o'zbeklashtirish va cloud blokirovkasi. Factory reset bilan sinovdan o'tgan.*
