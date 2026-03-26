Resolver Anycast
======================

Proyek ini menyediakan solusi **High Availability DNS** menggunakan mekanisme **Anycast** dengan memanfaatkan fitur healthcheck dari ExaBGP. rute IP DNS (Anycast IP) akan diumumkan (*announced*) dengan attribute BGP yang disesuaikan ke router jaringan hanya jika layanan DNS dalam kondisi sehat (*healthy*).

🚀 Fitur Utama
--------------

-   **Automated Routing Control**: Otomatis melakukan *announce*, *update attribute* atau *withdraw* prefix BGP berdasarkan status service.

-   **Parallel Healthcheck**: Melakukan kueri DNS ke beberapa domain (subdomain acak) secara asinkron untuk akurasi status yang tinggi (menghindari false positive karena cache).

-   **Maintenance Mode**: Fitur "saklar" manual melalui file `disable_resolver` untuk melakukan *update attribute* atau *withdraw* saat pemeliharaan server.

-   **Custom Script**: Sesuaikan apa yang di inginkan ketika service UP, DOWN, dan DISABLED


* * * * *

🛠 Instalasi & Persiapan
------------------------

### 1\. Prasyarat Sistem

Pastikan perangkat Anda sudah terinstal paket berikut:

```
sudo apt update
sudo apt install git exabgp dnsutils -y
```

### 2\. Penempatan File

Clone repositori ini dan letakkan di direktori `/opt`:

```
git clone https://github.com/frizanwr/anycast-resolver.git
sudo cp -r anycast-resolver /opt/
sudo chmod +x /opt/anycast-resolver/bin/*
sudo chmod +x /opt/anycast-resolver/scripts/*
```

Salin template exabgp.conf ke /etc/exabgp/

```
sudo cp /opt/anycast-resolver/template/exabgp.conf /etc/exabgp/
```

* * * * *

⚙️ Konfigurasi
--------------

### Konfigurasi Utama

Atur IP DNS Server yang ingin di monitoring (healthchek), *threshold*, domain, dan perintah/script conditional:

Bash

```
sudo nano /opt/anycast-resolver/anycast.conf
```

### Konfigurasi ExaBGP

Sesuaikan informasi peering dengan Router Core Anda, interval, metric, community, dll:

Bash

```
sudo nano /etc/exabgp/exabgp.conf
```

Untuk melihat parameter healtcheck apa saja yang tersedia ketik perintah:

```
python3 -m exabgp healthcheck --help
```

* * * * *

 Optimize Logging (Opsional)
--------------
Agar log tidak menumpuk, dikarenakan log INFO healhcheck dilakukan setiap interval yang telah di set, lakukan perubahan log level dari INFO ke NOTICE

Bash

```
sudo nano /etc/exabgp/exabgp.env
```

Ubah bagian `[exabgp.log]` parameter `level = INFO` menjadi `level = NOTICE`

* * * * *

Exabgp + unbound
-------------
Jika exabgp dijalankan di mesin yang sama dengan unbound masukkan user `exabgp` kedalam group `unbound` agar user exabgp bisa melakukan execute perintah yang dimiliki unbound seperti `unbound-control`

```
sudo usermod -aG unbound exabgp
```

* * * * *

Exabgp + bind9
-------------
Jika exabgp dijalankan di mesin yang sama dengan bind9 masukkan user `exabgp` kedalam group `bind` agar user exabgp bisa melakukan execute perintah yang dimiliki bind9 seperti `rndc`

```
sudo usermod -aG bind exabgp
```

* * * * *

🚦 Penggunaan
-------------

### Menjalankan Layanan

Anda dapat menjalankan ExaBGP langsung dengan systemd:

Bash

```
sudo systemctl enable exabgp
sudo systemctl start exabgp
```

### Mode Pemeliharaan (Maintenance)

Jika Anda perlu mematikan DNS tanpa mematikan proses BGP secara keseluruhan, cukup buat file berikut:

Bash

```
touch /opt/anycast-resolver/disable_resolver
```

*ExaBGP akan mendeteksi file ini, dan akan melakukan apa yang kita definisikan di /etc/exabgp.conf, dan memicu event-handler DISABLED.*

* * * * *

📊 Alur Kerja (Workflow)
------------------------

1.  **ExaBGP** memanggil skrip `bin/healthcheck` setiap interval tertentu.

2.  Skrip melakukan kueri ke beberapa domain yang kita definsiikan di file `anycast.conf` secara paralel.

3.  Jika sukses >= threshold, ExaBGP mengirimkan Update Message (Announce) ke tetangga BGP.

4.  Jika gagal, ExaBGP mengirimkan Withdraw atau menaikkan MED untuk mengalihkan trafik ke node DNS lain.

* * * * *

📝 Kontribusi
-------------

Jika Anda ingin meningkatkan efisiensi skrip ini atau menemukan bug, silakan buat *Pull Request* atau buka *Issue* di repositori ini.
