<#
  Descripcion: Lanzador del laboratorio en Windows. Genera el .env segun el
  modo elegido (local/shared), descarga la imagen de Docker Hub y la arranca.
  Uso: ./start.ps1 [-Modo local|shared] [-Puerto 8800]
  Autor: @naflashdev
#>
param(
    [ValidateSet('local', 'shared', '')]
    [string]$Modo = '',
    [int]$Puerto = 8800
)

$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

<#
  Descripcion: Genera un token aleatorio hexadecimal de 32 caracteres.
  Retorna: [string] token.
#>
function New-LabToken {
    $bytes = New-Object byte[] 16
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    return ($bytes | ForEach-Object { $_.ToString('x2') }) -join ''
}

# Si no se indica modo, preguntamos al usuario
if (-not $Modo) {
    Write-Host 'Modo del laboratorio:'
    Write-Host '  1) local  - solo en este equipo (alumnos)'
    Write-Host '  2) shared - accesible desde la red del aula (profesor)'
    $opcion = Read-Host 'Elige [1/2]'
    if ($opcion -eq '2') { $Modo = 'shared' } else { $Modo = 'local' }
}

# Valores por modo: en shared se escucha en toda la red y se generan secretos
if ($Modo -eq 'shared') {
    $bind = '0.0.0.0'; $token = New-LabToken; $secret = New-LabToken
} else {
    $bind = '127.0.0.1'; $token = 'profesor-local'; $secret = ''
}

$envContent = @"
LAB_MODE=$Modo
BIND_ADDR=$bind
PORT=$Puerto
TEACHER_TOKEN=$token
FLAG_SECRET=$secret
DISABLE_CHALLENGES=
LAB_VERSION=latest
"@
# UTF-8 sin BOM para que docker compose lea bien el fichero
[System.IO.File]::WriteAllText((Join-Path $PSScriptRoot '.env'), $envContent, (New-Object System.Text.UTF8Encoding $false))

docker compose pull
if ($LASTEXITCODE -ne 0) { throw 'No se pudo descargar la imagen' }
docker compose up -d
if ($LASTEXITCODE -ne 0) { throw 'docker compose ha fallado' }

Write-Host ''
Write-Host "Bastion Seguridad en marcha (modo $Modo)"
Write-Host "  URL:            http://localhost:$Puerto"
if ($Modo -eq 'shared') {
    Write-Host "  Token profesor: $token   (panel en /profesor)"
    Write-Host "  Comparte con los alumnos la IP de este equipo y el puerto $Puerto."
}
