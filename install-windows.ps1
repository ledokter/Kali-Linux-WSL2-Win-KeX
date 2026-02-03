###############################################################################
# Script d'installation des composants Windows pour Win-KeX
# Installe VcXsrv X Server et configure le pare-feu
###############################################################################

# Vérifier les privilèges administrateur
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ Ce script nécessite des privilèges administrateur" -ForegroundColor Red
    Write-Host "Relancez PowerShell en tant qu'administrateur" -ForegroundColor Yellow
    exit 1
}

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " INSTALLATION WIN-KEX - COMPOSANTS WINDOWS" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan

# Vérifier si WSL2 est installé
Write-Host "`n[1/6] Vérification de WSL2..." -ForegroundColor Yellow
$wslVersion = wsl --list --verbose 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ WSL2 n'est pas installé ou activé" -ForegroundColor Red
    Write-Host "Installez WSL2 avec : wsl --install" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ WSL2 détecté" -ForegroundColor Green

# Vérifier si Kali Linux est installé
Write-Host "`n[2/6] Vérification de Kali Linux..." -ForegroundColor Yellow
$kaliInstalled = wsl --list | Select-String -Pattern "kali-linux"
if (-not $kaliInstalled) {
    Write-Host "⚠️  Kali Linux n'est pas installé dans WSL2" -ForegroundColor Yellow
    Write-Host "Installation de Kali Linux..." -ForegroundColor Cyan
    wsl --install -d kali-linux
    Write-Host "✅ Kali Linux installé. Configurez-le puis relancez ce script." -ForegroundColor Green
    exit 0
}

Write-Host "✅ Kali Linux détecté" -ForegroundColor Green

# Installation de Chocolatey si nécessaire
Write-Host "`n[3/6] Vérification de Chocolatey..." -ForegroundColor Yellow
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installation de Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "✅ Chocolatey installé" -ForegroundColor Green
} else {
    Write-Host "✅ Chocolatey déjà installé" -ForegroundColor Green
}

# Installation de VcXsrv
Write-Host "`n[4/6] Installation de VcXsrv X Server..." -ForegroundColor Yellow
if (-not (Test-Path "C:\Program Files\VcXsrv\vcxsrv.exe")) {
    choco install vcxsrv -y
    Write-Host "✅ VcXsrv installé" -ForegroundColor Green
} else {
    Write-Host "✅ VcXsrv déjà installé" -ForegroundColor Green
}

# Configuration du pare-feu pour VcXsrv
Write-Host "`n[5/6] Configuration du pare-feu Windows..." -ForegroundColor Yellow

# Autoriser VcXsrv dans le pare-feu
$rules = @(
    @{Name="VcXsrv Windows X Server (TCP)"; Program="C:\Program Files\VcXsrv\vcxsrv.exe"; Protocol="TCP"; Direction="Inbound"},
    @{Name="VcXsrv Windows X Server (UDP)"; Program="C:\Program Files\VcXsrv\vcxsrv.exe"; Protocol="UDP"; Direction="Inbound"}
)

foreach ($rule in $rules) {
    $existingRule = Get-NetFirewallRule -DisplayName $rule.Name -ErrorAction SilentlyContinue
    if ($existingRule) {
        Write-Host "  ℹ️  Règle '$($rule.Name)' existe déjà" -ForegroundColor Gray
    } else {
        New-NetFirewallRule -DisplayName $rule.Name `
                            -Program $rule.Program `
                            -Protocol $rule.Protocol `
                            -Direction $rule.Direction `
                            -Action Allow `
                            -Enabled True | Out-Null
        Write-Host "  ✅ Règle '$($rule.Name)' créée" -ForegroundColor Green
    }
}

# Configuration RDP (Enhanced Session Mode)
Write-Host "`n[6/6] Configuration RDP pour Enhanced Session Mode..." -ForegroundColor Yellow

# Activer Remote Desktop (optionnel pour ESM)
$rdpEnabled = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -ErrorAction SilentlyContinue
if ($rdpEnabled.fDenyTSConnections -eq 1) {
    Write-Host "  ℹ️  RDP est déjà configuré pour ESM" -ForegroundColor Gray
} else {
    Write-Host "  ✅ RDP prêt pour Enhanced Session Mode" -ForegroundColor Green
}

# Créer un raccourci pour lancer Kali avec KeX
Write-Host "`n[7/6] Création du raccourci de lancement..." -ForegroundColor Yellow

$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = "$desktopPath\Kali Linux KeX.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "wsl.exe"
$Shortcut.Arguments = "-d kali-linux kex --esm --ip -s"
$Shortcut.IconLocation = "C:\Windows\System32\imageres.dll,98"
$Shortcut.Description = "Lancer Kali Linux avec Win-KeX en mode ESM"
$Shortcut.Save()

Write-Host "✅ Raccourci créé sur le Bureau" -ForegroundColor Green

# Message final
Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host " INSTALLATION TERMINÉE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Composants Windows installés avec succès !" -ForegroundColor Green
Write-Host ""
Write-Host "Prochaines étapes :" -ForegroundColor Yellow
Write-Host "  1. Ouvrez WSL Kali Linux" -ForegroundColor White
Write-Host "  2. Exécutez : ./install-kali.sh" -ForegroundColor Cyan
Write-Host "  3. Lancez Kali avec : kex --esm --ip -s" -ForegroundColor Cyan
Write-Host ""
Write-Host "Raccourci créé : $shortcutPath" -ForegroundColor Gray
Write-Host ""
