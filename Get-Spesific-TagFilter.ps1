# vCenter Bağlantı Bilgileri
$vCenterServer = "vcenter_server_ip_veya_fqdn" # Örn: 10.100.17.10
$username = "domain\kullanici_adiniz"
$password = "sifreniz"

# SSL Sertifika hatalarını yoksay
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

# 1. vCenter'a Bağlan
Connect-VIServer -Server $vCenterServer -User $username -Password $password

Write-Host "Sanal makineler ve Tag bilgileri alınıyor, lütfen bekleyin..." -ForegroundColor Cyan

# 2. "Private" Tag'ine Sahip Makineleri Bul 
# (vCenter seviyesinde filtreleme yaptığı için saniyeler sürer ve %100 kesindir)
$privateTag = Get-Tag -Category "NetworkType" -Name "Private" -ErrorAction SilentlyContinue
$privateVMs = if ($privateTag) { Get-VM -Tag $privateTag -ErrorAction SilentlyContinue } else { @() }

# Hızlı arama için Private VM'lerin ID'lerini sözlüğe alıyoruz
$privateVmIds = @{}
if ($privateVMs) {
    foreach ($vm in $privateVMs) {
        $privateVmIds[$vm.Id] = $true
    }
}

# 3. Tüm VM'leri al
$allVms = Get-VM

# 4. Sonuçları listele (Sadece Private olmayanlar veya tagsiz olanlar)
$results = foreach ($vm in $allVms) {
    # Eğer makine Private listesindeyse direkt atla, listeye ekleme
    if ($privateVmIds.ContainsKey($vm.Id)) {
        continue
    }
    
    # Makine Private DEĞİLSE (Public, DMZ veya tamamen Tagsiz ise) listeye ekle
    $networkAdapters = Get-NetworkAdapter -VM $vm -ErrorAction SilentlyContinue
    $networkNames = ($networkAdapters.NetworkName) -join ", "
    
    [PSCustomObject]@{
        "VM Name"       = $vm.Name
        "Network Name"  = if ($networkNames) { $networkNames } else { "Bağlı Ağ Yok" }
    }
}

Write-Host "`nİşlem Tamamlandı. Sonuçlar:`n" -ForegroundColor Green

# 5. Sonuçları ekranda tablo olarak göster
$results | Format-Table -AutoSize

# 6. vCenter Bağlantısını Kes
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
