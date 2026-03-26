#!/bin/bash

# ==============================================================================
# UNBOUND CACHE FLUSH SCRIPT
# Digunakan oleh ExaBGP Event Handler untuk membersihkan cache DNS
# ==============================================================================

# Cek apakah user menjalankan sebagai root atau punya akses ke unbound-control
if [[ $EUID -ne 0 ]]; then
   echo "Error: Skrip ini harus dijalankan dengan sudo atau sebagai root."
   exit 1
fi

echo "Starting Unbound cache flush..."

# Jalankan perintah pembersihan
/usr/sbin/unbound-control flush .
/usr/sbin/unbound-control flush zone .
/usr/sbin/unbound-control flush_infra all

# Berikan status ke stdout/log
if [ $? -eq 0 ]; then
    echo "Unbound cache successfully flushed."
    exit 0
else
    echo "Error: Gagal menjalankan unbound-control."
    exit 1
fi
