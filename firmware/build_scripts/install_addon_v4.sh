

# ============================================================================
# === DSS NVR cloud blokirovkasi v4 (mtd6 reflash, 2026-05-17) ===
# v3 dan farq: 3 ta yangi blok qo'shildi (firmware update vektorlar)
#   - IP 139.9.6.140 (CloudUpgradeTest test server)
#   - update.ods.org (DDNS provider, ServerName_05)
#   - www.zwcloud.wang (ver10/XMLSchema upgrade)
# ============================================================================

# --- 1. p2p_telnet.sh backdoor neytrallash ---
rm -rf /home/tconfig/config/did.ini 2>/dev/null
mkdir -p /home/tconfig/config/did.ini
chmod 555 /home/tconfig/config/did.ini

# --- 2. Background: hammasi bir necha qadamda ---
(
  # === 2a. Network kutish (eth0 UP) ===
  for i in 1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 25 30; do
    if ifconfig eth0 2>/dev/null | grep -q "RUNNING"; then break; fi
    sleep 2
  done

  # === 2b. IP route reject (35 ta cloud IP, v4 da +139.9.6.140) ===
  for ip in 110.41.13.246 114.116.238.53 116.205.164.133 119.23.131.217 \
            120.46.153.209 120.76.126.62 121.37.22.107 121.43.96.85 \
            123.249.104.144 123.57.156.223 124.71.101.114 \
            139.159.200.147 139.159.218.144 139.159.221.132 \
            139.9.136.239 139.9.5.224 139.9.6.140 156.241.140.221 \
            159.138.103.66 159.138.148.125 164.152.106.227 185.8.174.214 \
            190.92.213.42 194.5.175.12 47.106.167.176 47.252.8.80 \
            47.74.153.98 47.88.33.190 47.91.88.40 94.74.145.147 \
            94.74.145.148 94.74.145.152 94.74.66.27 94.74.67.179 \
            94.74.90.36; do
    route add -host $ip reject 2>/dev/null
  done
  echo "[cloud-block] $(date) Route rejects added" > /tmp/cloudblock.log
  route -n | grep -c "!H" >> /tmp/cloudblock.log

  # === 2c. EDVR ishga tushishini kutish ===
  for i in 1 2 3 4 5 6 7 8 9 10 12 14 16 18 20 25 30 35 40 50 60; do
    if ps 2>/dev/null | grep -v grep | grep -q "edvr"; then
      echo "[cloud-block] $(date) edvr detected at iter=$i" >> /tmp/cloudblock.log
      break
    fi
    sleep 2
  done
  sleep 15

  # === 2d. /etc/hosts ni qaytadan yozish (45+ domen) ===
  rm -f /etc/hosts
  cat > /etc/hosts << 'HOSTS_EOF'
127.0.0.1   localhost
0.0.0.0  bjdev.aftx.net
0.0.0.0  hzdev.aftx.net
0.0.0.0  szdev.aftx.net
0.0.0.0  erp.zwcloud.wang
0.0.0.0  p6sstore.sales.zwcloud.wang
0.0.0.0  testwx.zwcloud.wang
0.0.0.0  www.zwcloud.wang
0.0.0.0  zwcloud.wang
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
0.0.0.0  update.ods.org
0.0.0.0  ods.org
0.0.0.0  pool.ntp.org
0.0.0.0  0.pool.ntp.org
0.0.0.0  1.pool.ntp.org
0.0.0.0  2.pool.ntp.org
0.0.0.0  3.pool.ntp.org
HOSTS_EOF
  chmod 644 /etc/hosts
  echo "[cloud-block] $(date) /etc/hosts rewritten ($(wc -l < /etc/hosts) lines)" >> /tmp/cloudblock.log

  # === 2e. Guard loop — har 60s da tekshirish ===
  ( while sleep 60; do
      if ! grep -q "^0.0.0.0.*update.ods.org" /etc/hosts 2>/dev/null; then
        rm -f /etc/hosts
        cat > /etc/hosts << 'GUARD_EOF'
127.0.0.1   localhost
0.0.0.0  bjdev.aftx.net
0.0.0.0  hzdev.aftx.net
0.0.0.0  szdev.aftx.net
0.0.0.0  erp.zwcloud.wang
0.0.0.0  p6sstore.sales.zwcloud.wang
0.0.0.0  testwx.zwcloud.wang
0.0.0.0  www.zwcloud.wang
0.0.0.0  zwcloud.wang
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
0.0.0.0  ai.com
0.0.0.0  update.ods.org
0.0.0.0  ods.org
0.0.0.0  pool.ntp.org
GUARD_EOF
        echo "[guard] $(date) /etc/hosts restored" >> /tmp/cloudblock.log
      fi
  done ) &

  # === 2f. Persistent telnet 2323 ===
  sleep 3
  mkdir -p /dev/pts
  mount -t devpts devpts /dev/pts 2>/dev/null
  while true; do
    telnetd -F -l /bin/sh -p 2323
    sleep 2
  done
) &

# === DSS NVR cloud blokirovkasi v4 yakuni ===
