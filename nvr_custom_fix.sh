# Update custom.sh on UBIFS with devpts mount so telnetd survives normal boot
ubiattach /dev/ubi_ctrl -m 8 2>/dev/null
sleep 2
mkdir -p /home/tconfig
mount -t ubifs /dev/ubi0_0 /home/tconfig 2>/dev/null
cat > /home/tconfig/config/custom.sh << 'CUSTOM_EOF'
#!/bin/sh
# Persistent parolsiz root telnet on port 2323
# (boa/RTSP normal portlarda qoladi)
exec >>/tmp/custom.log 2>&1
echo "===== custom.sh started $(date)"
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts 2>/dev/null
sleep 3
telnetd -l /bin/sh -p 2323
echo "telnetd exit=$?"
sleep 1
ps | grep -v grep | grep telnetd
echo "===== custom.sh done"
CUSTOM_EOF
chmod +x /home/tconfig/config/custom.sh
ls -la /home/tconfig/config/custom.sh
cat /home/tconfig/config/custom.sh
sync
echo "---DONE---"
