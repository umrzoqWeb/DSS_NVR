# DSS NVR — Modified Firmware

O'zbekistonga moslashtirilgan DSS NVR (Ingenic XBurst A1) firmware partitsiyalari.

## Fayllar

| Fayl | Hajm | MD5 | Mqsad |
|---|---|---|---|
| `mtd5_web_uz.bin` | 3 MiB | `28cebfe9761f9ced4004f6300b445979` | Web UI o'zbekcha tarjimasi (mtd5) |
| `mtd6_custom_v4.bin` | 3 MiB | `80acfa527b240a15fa90f1d2aa531c4a` | Cloud blokirovkasi + persistent telnet (mtd6) |
| `build_scripts/install_addon_*.sh` | — | — | install.sh ga qo'shilgan bloklar (versiyalar tarixi) |

## mtd5_web_uz.bin

**Manba:** original mtd5 squashfs ni unsquashfs qilib, modifikatsiya, qayta mksquashfs.

**O'zgartirishlar:**
- `nvr/language/strings_uz.properties` — yangi O'zbek tarjima (1346 qator, 52 KB)
- `nvr/language/strings_ja.properties` — olib tashlangan (Japanese kerak emas)
- `custom/language.json` — `ja` o'rniga `uz` qo'shilgan (O'zbekcha tanlash uchun)
- `custom/playMode.json` — `EasyVideo` o'rniga `DirectMode` (Chrome'da login redirect ishlashi uchun)

**Format:** SquashFS 4.0, XZ compression, 256K block, padded to 3 MiB.

## mtd6_custom_v4.bin

**Manba:** original mtd6 squashfs ni unsquashfs qilib, modifikatsiya, qayta mksquashfs.

**O'zgartirishlar:**
- `config/hosts` — 45+ cloud domen `0.0.0.0` ga yo'naltirilgan
- `install.sh` ga `install_addon_v4.sh` (cloud blok mantiqi) qo'shilgan:
  - 35 ta cloud IP route reject
  - `did.ini` directory (p2p_telnet.sh backdoor neytrali)
  - Persistent telnet 2323 (parolsiz, LAN debug)
  - `/etc/hosts` qaytariq yozish (edvr boot post-startup)
  - Guard loop (60s, edvr qaytaroq yozsa tikladi)

**Bloklangan cloud manbalar:**

| Tur | Domen/IP |
|---|---|
| Eron P2P | `frp1+frp2.farap2p.ir` (194.5.175.12, 185.8.174.214) |
| DSS Eron VPS | `ruisionvps1/2/3.com` (94.74.145.147/148/152) |
| Xitoy OEM IoT | `*.zviewcloud.com` (9 ta subdomain) |
| Xitoy OEM auth | `*.p6sai.com` (7 ta subdomain) |
| ZW Cloud | `*.zwcloud.wang` + `www.` |
| Aftx Dev | `*.aftx.net` (3 ta subdomain) |
| Firmware update | `update.ods.org`, `139.9.6.140` (CloudUpgradeTest) |
| OEM bulut | `ewcloud.com`, `ai.com` |
| NTP | `pool.ntp.org` (variantlar) |

**Format:** SquashFS 4.0, XZ compression, 256K block, padded to 3 MiB.

## Build jarayoni (xulosa)

```bash
# 1. mtd partition'ni NVR'dan dump
cat /dev/mtdblock5 > mtd5_web.bin   # 3 MiB
cat /dev/mtdblock6 > mtd6_custom.bin # 3 MiB

# 2. Ubuntu serverda extract
unsquashfs -d mtd5_extracted mtd5_web.bin
unsquashfs -d mtd6_extracted mtd6_custom.bin

# 3. Modify (kerakli fayllar)

# 4. Rebuild
mksquashfs mtd5_extracted/ mtd5_new.bin -comp xz -b 262144 -no-progress
mksquashfs mtd6_extracted/ mtd6_new.bin -comp xz -b 262144 -no-progress

# 5. Pad to partition size (3 MiB = 3,145,728 bayt)
PARTSZ=3145728
NEWSZ=$(stat -c%s mtd5_new.bin)
PADSZ=$((PARTSZ - NEWSZ))
head -c $PADSZ /dev/zero | tr '\0' '\377' >> mtd5_new.bin

# 6. NVR'ga flash (telnet 2323 orqali shell'da)
wget -O /tmp/mtd5.bin http://PC_IP:8080/mtd5_new.bin
/usr/sbin/flashcp -v /tmp/mtd5.bin /dev/mtd5
```

## Xavfsizlik / Risk

⚠️ **Bu fayllarni flash qilish — strogo NVR_2616A1 / similar Ingenic A1 modellariga.** Boshqa modelga flash qilsa **brick qilish xavfi**.

✅ **Tasdiqlangan model:**
- Board ID: `0x1958`
- Board string: `ISVP` (U-Boot prompt `isvp_a1#`)
- SoC: Ingenic XBurst A1 (MIPS, dual-core)
- App binver: `.N3xxB-11NEA-AI`

✅ **Tasdiqlangan natijalar:**
- Factory reset bilan saqlanadi (mtd5, mtd6 RO squashfs)
- O'zbek til hammasiga ko'rinadi (web UI)
- 35+ cloud domen va 35 cloud IP bloklangan
- Telnet 2323 har boot'da avto-ochiladi (LAN admin uchun)
- Edvr cloud'ga ulanmaydi (TCP ESTABLISHED tashqi = 0)

## Foydalanish ko'rsatma

Asosiy hujjat: [`../DSS_NVR_Qollanma_v1.md`](../DSS_NVR_Qollanma_v1.md)

Loyiha jarayoni: UART → init=/bin/sh → backup → extract → modify → rebuild → flash.
