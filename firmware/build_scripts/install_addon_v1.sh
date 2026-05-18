

# ============================================================================
# === DSS NVR cloud blokirovkasi (mtd6 reflash, 2026-05-17) ===
# Maqsad: factory reset bilan saqlanadi (mtd6 RO squashfs)
# Qatlamlar: did.ini neutralize + IP route reject + persistent telnet 2323
# ============================================================================

# --- 1. p2p_telnet.sh backdoor neytrallash (did.ini fayl o'rniga DIRECTORY) ---
rm -rf /home/tconfig/config/did.ini 2>/dev/null
mkdir -p /home/tconfig/config/did.ini
chmod 555 /home/tconfig/config/did.ini

# --- 2. Background: IP route reject + persistent telnet (eth0 kutadi) ---
(
  # Network kutish (eth0 UP)
  for i in 1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 25 30; do
    if ifconfig eth0 2>/dev/null | grep -q "RUNNING"; then break; fi
    sleep 2
  done

  # Cloud IPs - hammasini reject qilish (33 ta IP)
  for ip in 110.41.13.246 114.116.238.53 116.205.164.133 119.23.131.217 \
            120.46.153.209 120.76.126.62 121.37.22.107 121.43.96.85 \
            123.249.104.144 123.57.156.223 124.71.101.114 \
            139.159.200.147 139.159.218.144 139.159.221.132 \
            139.9.136.239 139.9.5.224 159.138.103.66 159.138.148.125 \
            164.152.106.227 185.8.174.214 190.92.213.42 194.5.175.12 \
            47.106.167.176 47.252.8.80 47.74.153.98 47.88.33.190 \
            47.91.88.40 94.74.145.147 94.74.145.148 94.74.145.152 \
            94.74.66.27 94.74.67.179 94.74.90.36; do
    route add -host $ip reject 2>/dev/null
  done
  echo "[cloud-block] $(date) IP rejects qo'shildi" > /tmp/cloudblock.log
  route -n | grep -c "!H" >> /tmp/cloudblock.log

  # Persistent telnet 2323 (parolsiz, LAN debug uchun)
  sleep 3
  mkdir -p /dev/pts
  mount -t devpts devpts /dev/pts 2>/dev/null
  while true; do
    echo "[telnet] $(date) starting" >> /tmp/cloudblock.log
    telnetd -F -l /bin/sh -p 2323
    sleep 2
  done
) &

# === DSS NVR cloud blokirovkasi yakuni ===
