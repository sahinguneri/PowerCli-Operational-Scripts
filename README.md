# PowerCLI Operational Scripts

Bu depo (repository), günlük VMware altyapı operasyonları, raporlama ve otomasyon süreçleri için yazılmış performanslı PowerCLI scriptlerini barındırır.

## Scriptler

### 1. Get-Spesific-TagFilter.ps1

Sanal makineleri (VM) sahip oldukları ağ (network) tag'lerine göre çok hızlı bir şekilde filtreleyen ve raporlayan optimize edilmiş bir PowerCLI scriptidir.

**Ne Yapar?**
- vCenter sunucunuza bağlanır (SSL sertifika hatalarını otomatik yoksayar).
- Doğrudan vCenter veritabanı üzerinden (sunucu tarafında) arama yaparak `NetworkType` kategorisinde `Private` tag'ine sahip makineleri saniyeler içinde tespit eder.
- Bu `Private` makineleri nihai listeden **dışlar**.
- Geriye kalan tüm makineleri (örn: `Public`, `DMZ` tagine sahip olanlar veya **hiçbir tag almamış olanlar**) listeler.
- Listeye dahil edilen sanal makinelerin bağlı olduğu ağ adaptörlerinin (PortGroup) isimlerini rapora ekler.

**Neden Çok Hızlı?**
Binlerce makinenin tag bilgisini tek tek ağ üzerinden çekmek (`Get-TagAssignment`) yerine; vCenter'ın kendi native filtrelemesini (`Get-VM -Tag`) kullanır. İstenmeyen makineleri tespit ettikten sonra, filtreleme işlemini bilgisayarınızın RAM'i üzerinde O(1) hızında Hash-Table (Sözlük) kullanarak milisaniyeler içerisinde tamamlar.

#### Nasıl Kullanılır?

1. `Get-Spesific-TagFilter.ps1` dosyasını açın.
2. Dosyanın en üstünde bulunan bağlantı bilgilerini kendi vCenter ortamınıza göre güncelleyin:
   ```powershell
   $vCenterServer = "vcenter_server_ip_veya_fqdn" 
   $username = "domain\kullanici_adiniz"
   $password = "sifreniz"
   ```
3. Scripti çalıştırın.
4. *(Opsiyonel)*: Sonuçları Excel'de incelemek üzere CSV olarak dışarı aktarmak isterseniz, dosyanın en altındaki `Export-Csv` satırının başındaki `#` işaretini kaldırabilirsiniz.
