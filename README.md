#  Linux Server Monitoring & PostgreSQL Reporting

Bu proje, Linux tabanlı sunucuların performans metriklerini (CPU, RAM, Disk, Ağ Portları ve Sistem Logları) otomatik olarak toplayan ve merkezi bir PostgreSQL veritabanına kaydeden profesyonel bir izleme çözümüdür.

##  Özellikler
* **Sistem Metrikleri:** CPU, RAM ve Disk kullanımı anlık olarak takip edilir.
* **Ağ İzleme:** `netstat` entegrasyonu ile açık portlar, protokoller ve bu portları kullanan Process ID (PID) bilgileri kaydedilir.
* **Güvenlik ve Log Analizi:** `journalctl` üzerinden sistem hataları (err) yakalanır ve raporlanır.
* **Kullanıcı Envanteri:** Sistemdeki kullanıcılar ve sudo yetkileri takip edilir.
* **Veri Güvenliği:** SQL Injection riskine karşı `sed` ile karakter temizliği yapılmıştır.
##  Dosya Yapısı
* `monitor.sh`: Veri toplama ve veritabanına aktarım yapan ana Bash scripti.
* `database_schema.sql`: PostgreSQL veritabanı tablolarını oluşturan sorgular.
* `README.md`: Proje dökümantasyonu.
##  Kurulum ve Çalıştırma

Bu projeyi iki farklı yöntemle otomatize edebilirsiniz:

### Yöntem A: Sistem Servisi Olarak (Sürekli İzleme)
Scriptin arka planda bir servis gibi çalışması ve sistem her açıldığında otomatik başlaması için:
1. `monitoring.service` dosyasını `/etc/systemd/system/` dizinine kopyalayın.
2. `sudo systemctl enable --now monitoring.service` komutuyla aktif edin.

### Yöntem B: Crontab İle (Periyodik İzleme)
Eğer belirli zaman aralıklarında (örneğin her dakikada bir) çalışmasını isterseniz:
1. `crontab -e` komutunu çalıştırın.
2. En alta şu satırı ekleyin:

   `* * * * * /bin/bash /path/to/monitor.sh`

   ## System Screenshots

![Screenshot1](WhatsApp%20Image%202026-03-08%20at%2018.03.55.jpeg)

![Screenshot2](WhatsApp%20Image%202026-03-08%20at%2018.03.55&20(1).jpeg)

![Screenshot3](WhatsApp%20Image%202026-03-08%at%18.03.55%20(2).jpeg)

![Screenshot4](WhatsApp%20Image%202026-03-08%20at%2018.03.55%20(3).jpeg)

![Screenshot5](WhatsApp%20Image%202026-03-08%20at%2018.03.55%20(4).jpeg)


