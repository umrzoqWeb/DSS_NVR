mount -t tmpfs tmpfs /tmp 2>/dev/null
cat > /tmp/d.sh << 'NVR_DIAG_EOF'
#!/bin/sh
echo "=== /home/config (BEFORE UBI load) ==="
ls -la /home/config 2>&1
echo "readlink:"
readlink /home/config 2>&1
echo
echo "=== /usr/local/etc symlink ==="
ls -la /usr/local/etc 2>&1
readlink /usr/local/etc 2>&1
echo
echo "=== /dev/pts (telnetd PTY) ==="
ls -la /dev/pts 2>&1
echo
echo "=== load drivers (S01driver loads UBI etc) ==="
/etc/init.d/S01driver 2>&1
sleep 1
echo
echo "=== attach UBI ==="
ubiattach /dev/ubi_ctrl -m 8 2>&1
sleep 2
mount -t ubifs /dev/ubi0_0 /home/tconfig 2>&1
echo
echo "=== /home/tconfig/config (UBIFS) ==="
ls -la /home/tconfig/config/ 2>&1
echo
echo "=== /home/config (AFTER UBI mount) ==="
ls -la /home/config/ 2>&1
echo
echo "=== resolve custom.sh via each path ==="
echo "/usr/local/etc/custom.sh:"
ls -la /usr/local/etc/custom.sh 2>&1
echo "/home/config/custom.sh:"
ls -la /home/config/custom.sh 2>&1
echo "/home/tconfig/config/custom.sh:"
ls -la /home/tconfig/config/custom.sh 2>&1
echo
echo "=== inode check (same file?) ==="
ls -i /home/config/custom.sh 2>&1
ls -i /home/tconfig/config/custom.sh 2>&1
echo
echo "=== mount table ==="
mount
echo
echo "=== END ==="
NVR_DIAG_EOF
chmod +x /tmp/d.sh
ls -la /tmp/d.sh
/tmp/d.sh
