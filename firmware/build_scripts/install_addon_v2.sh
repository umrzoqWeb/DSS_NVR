

# ============================================================================
# === DSS NVR cloud blokirovkasi v2 (mtd6 reflash, 2026-05-17) ===
# v1 dan farq: /etc/hosts symlink-ni 0.0.0.0 fayl bilan qoplaymiz
# Edvr har boot'da UBIFS hosts ni real IP'lar bilan to'ldiradi —
# lekin /etc/hosts symlink emas regular fayl bo'lsa, edvr ga ta'sir qilmaydi
# ============================================================================

# --- 1. p2p_telnet.sh backdoor neytrallash ---
rm -rf /home/tconfig/config/did.ini 2>/dev/null
mkdir -p /home/tconfig/config/did.ini
chmod 555 /home/tconfig/config/did.ini

# --- 2. /etc/hosts ni symlink dan regular fayl ga aylantirish (KEYIN edvr ishga tushadi) ---
rm -f /etc/hosts
cat > /etc/hosts << 'HOSTS_EOF'
127.0.0.1   localhost
# === DSS NVR cloud bloklash (mtd6 install.sh, factory-reset-resistant) ===
0.0.0.0  bjdev.aftx.net
0.0.0.0  hzdev.aftx.net
0.0.0.0  szdev.aftx.net
0.0.0.0  erp.zwcloud.wang
0.0.0.0  p6sstore.sales.zwcloud.wang
0.0.0.0  testwx.zwcloud.wang
0.0.0.0  szdev.zviewcloud.com
0.0.0.0  usdev.zviewcloud.com
0.0.0.0  erdev.zviewcloud.com
0.0.0.0  iotb_gzdev.zviewcloud.com
0.0.0.0  iotb_asdev.zviewcloud.com
0.0.0.0  iotb_usdev.zviewcloud.com
0.0.0.0  iotd_gzdev.zviewcloud.com
0.0.0.0  iotd_hkdev.zviewcloud.com
0.0.0.0  iotd-mxdev.zviewcloud.com
0.0.0.0  auth.p6sai.com
0.0.0.0  rsiotg-gz.zviewcloud.com
0.0.0.0  rsiotg-sgp.zviewcloud.com
0.0.0.0  rsbotd-gz.p6sai.com
0.0.0.0  rsbotd-bj.p6sai.com
0.0.0.0  rsbotd-sgp.p6sai.com
0.0.0.0  rsiotf-gz.p6sai.com
0.0.0.0  rsiotf-us.p6sai.com
0.0.0.0  rsiote-gz.zviewcloud.com
0.0.0.0  rsiote-sgp.zviewcloud.com
0.0.0.0  rsiote-mx.zviewcloud.com
0.0.0.0  ruisionvps1.com
0.0.0.0  ruisionvps2.com
0.0.0.0  ruisionvps3.com
0.0.0.0  p6saistore-cn.p6sai.com
0.0.0.0  store-cn.p6sai.com
0.0.0.0  frp1.farap2p.ir
0.0.0.0  frp2.farap2p.ir
0.0.0.0  farap2p.ir
0.0.0.0  ewcloud.com
0.0.0.0  www.ewcloud.com
0.0.0.0  ai.com
0.0.0.0  pool.ntp.org
0.0.0.0  0.pool.ntp.org
0.0.0.0  1.pool.ntp.org
0.0.0.0  2.pool.ntp.org
0.0.0.0  3.pool.ntp.org
HOSTS_EOF
chmod 644 /etc/hosts

# --- 3. Background: route reject + telnet + /etc/hosts qo'riqlash ---
(
  # Network kutish
  for i in 1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 25 30; do
    if ifconfig eth0 2>/dev/null | grep -q "RUNNING"; then break; fi
    sleep 2
  done

  # 34 ta cloud IP route reject (+yangi 156.241.140.221 aftx.net uchun)
  for ip in 110.41.13.246 114.116.238.53 116.205.164.133 119.23.131.217 \
            120.46.153.209 120.76.126.62 121.37.22.107 121.43.96.85 \
            123.249.104.144 123.57.156.223 124.71.101.114 \
            139.159.200.147 139.159.218.144 139.159.221.132 \
            139.9.136.239 139.9.5.224 156.241.140.221 159.138.103.66 \
            159.138.148.125 164.152.106.227 185.8.174.214 190.92.213.42 \
            194.5.175.12 47.106.167.176 47.252.8.80 47.74.153.98 \
            47.88.33.190 47.91.88.40 94.74.145.147 94.74.145.148 \
            94.74.145.152 94.74.66.27 94.74.67.179 94.74.90.36; do
    route add -host $ip reject 2>/dev/null
  done
  echo "[cloud-block] $(date) IPs blocked" > /tmp/cloudblock.log
  route -n | grep -c "!H" >> /tmp/cloudblock.log

  # /etc/hosts qo'riqchi (edvr qaytaroq yozsa, tiklash)
  ( while sleep 30; do
      SZ=$(wc -c < /etc/hosts 2>/dev/null)
      LINK=$(readlink /etc/hosts 2>/dev/null)
      if [ -n "$LINK" ] || [ "${SZ:-0}" -lt 1000 ]; then
        rm -f /etc/hosts
        cp /home/custom/config/hosts /etc/hosts 2>/dev/null || \
        cat /home/custom/config/hosts > /etc/hosts
        echo "[guard] $(date) /etc/hosts restored" >> /tmp/cloudblock.log
      fi
  done ) &

  # Telnet 2323
  sleep 3
  mkdir -p /dev/pts
  mount -t devpts devpts /dev/pts 2>/dev/null
  while true; do
    echo "[telnet] $(date)" >> /tmp/cloudblock.log
    telnetd -F -l /bin/sh -p 2323
    sleep 2
  done
) &

# === DSS NVR cloud blokirovkasi v2 yakuni ===
