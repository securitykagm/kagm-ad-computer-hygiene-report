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
