# Active Directory Computer Hygiene Report

Bu repo, **Active Directory ortamındaki bilgisayarların genel durumunu (hijyenini)** görmek için
hazırlanmış, **salt-okunur (read-only)** bir PowerShell scripti içerir.

Amaç; güvenlik ve operasyon açısından **dikkat edilmesi gereken bilgisayarları**
tek bir raporda görünür hale getirmektir.

## Ne Yapar?

Script aşağıdaki kontrolleri gerçekleştirir:

- **Pasif bilgisayarlar**  
  Belirlenen süreden (varsayılan: 90 gün) uzun süredir oturum açmamış cihazları tespit eder.

- **Hiç oturum açmamış bilgisayarlar**  
  AD’de kayıtlı olmasına rağmen hiç kullanılmamış objectleri listeler.

- **Bilgisayar parolası durumu**  
  Uzun süredir değiştirilmeyen bilgisayar parolalarını işaretler.

- **İşletim sistemi sinyalleri**  
  Destek dışı (legacy) Windows sürümleri için uyarı üretir.

- **Risk seviyesi**  
  Tespit edilen durumlara göre her bilgisayar için basit bir risk seviyesi belirler.

---

## Gereksinimler

- Active Directory ortamı
- RSAT – ActiveDirectory PowerShell modülü  
  (Domain Controller veya RSAT yüklü yetkili pc)
- AD bilgisayar nesnelerini okuma yetkisi

---

## Kullanım

### Varsayılan kullanım

90 gün pasiflik ve 180 gün parola süresi eşikleri ile çalışır.

```powershell
.\Get-ADComputerHygieneReport.ps1
```

Pasiflik ve parola eşiklerini değiştirme

```powershell
.\Get-ADComputerHygieneReport.ps1 -InactiveDays 60 -PasswordStaleDays 120
```

Belirli bir OU altında çalıştırma

```powershell
.\Get-ADComputerHygieneReport.ps1 -SearchBase "OU=Computers,DC=domain,DC=local"
```

Disabled bilgisayarları da dahil etme

```powershell
.\Get-ADComputerHygieneReport.ps1 -IncludeDisabled
```

CSV çıktısı alma

```powershell
.\Get-ADComputerHygieneReport.ps1 -ExportCsv -ExportPath "C:\Temp\ad_computer_hygiene.csv"
```

<div align="center">
<hr/>

<img src="https://img.shields.io/badge/Kurum-Kalkinma%20Ajanslari%20Genel%20Mudurlugu-blue"/>
<img src="https://img.shields.io/badge/Kapsam-Kamu%20Bilgi%20Sistemleri%20ve%20Guvenlik-lightgrey"/>

<a href="https://www.ka.gov.tr" target="_blank">
  <img src="https://img.shields.io/badge/Web-ka.gov.tr-darkgreen"/>
</a>

<a href="https://www.kalkinmagalerisi.org.tr" target="_blank">
  <img src="https://img.shields.io/badge/Kalkinma%20Galerisi-kalkinmagalerisi.org.tr-6f42c1"/>
</a>

<a href="https://www.yatirimadestek.gov.tr" target="_blank">
  <img src="https://img.shields.io/badge/Yatirima%20Destek-yatirimadestek.gov.tr-success"/>
</a>

<a href="https://yerelkalkinmahamlesi.sanayi.gov.tr" target="_blank">
  <img src="https://img.shields.io/badge/Yerel%20Kalkinma%20Hamlesi-sanayi.gov.tr-orange"/>
</a>

<a href="https://www.instagram.com/kalkinmaajansgm/" target="_blank">
  <img src="https://img.shields.io/badge/Instagram-kalkinmaajansgm-pink"/>
</a>

<a href="https://www.linkedin.com/company/kalkinmaajansgenelm%C3%BCd%C3%BCrl%C3%BC%C4%9F%C3%BC/" target="_blank">
  <img src="https://img.shields.io/badge/LinkedIn-Kalkinma%20Ajanslari%20Genel%20Mudurlugu-blue"/>
</a>

</div>
