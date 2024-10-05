# Función para detener y deshabilitar servicios no esenciales
function Disable-Service {
    param (
        [string]$ServiceName
    )
    Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
    Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "Servicio $ServiceName detenido y deshabilitado."
}

# Lista de servicios innecesarios para la mayoría de los usuarios
$servicesToDisable = @(
    "DiagTrack",      # Telemetría de Windows
    "WSearch",        # Búsqueda de Windows
    "SysMain",        # Superfetch (útil en SSDs)
    "PrintSpooler",   # Solo detener si no usas impresoras
    "XboxGipSvc",     # Servicios de Xbox
    "XblAuthManager", # Servicios de Xbox Live
    "RetailDemo",     # Servicio de modo demo
    "Dmwappushservice", # Servicio de mensajes push
    "CDPSvc"          # Servicio de entrega de contenido
)

# Deshabilitar los servicios no esenciales
foreach ($service in $servicesToDisable) {
    Disable-Service -ServiceName $service
}

# Deshabilitar la telemetría de Windows
Write-Host "Deshabilitando la telemetría de Windows..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force
Write-Host "Telemetría deshabilitada."

# Optimizar el uso del disco y la memoria virtual
Write-Host "Optimización del uso de la memoria virtual..."
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value 1
Write-Host "Memoria virtual optimizada."

# Deshabilitar programas innecesarios en el inicio del sistema
Write-Host "Deshabilitando programas del inicio..."
Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" |
    ForEach-Object {
        Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $_.PSChildName -ErrorAction SilentlyContinue
        Write-Host "Programa $($_.PSChildName) deshabilitado del inicio."
    }

# Limpiar archivos temporales y caché
Write-Host "Limpiando archivos temporales y cachés..."
Remove-Item -Recurse -Force "$env:TEMP\*" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force "$env:SystemRoot\Temp\*" -ErrorAction SilentlyContinue
Write-Host "Archivos temporales eliminados."

# Desactivar efectos visuales para mejorar el rendimiento
Write-Host "Deshabilitando efectos visuales innecesarios..."
$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
Set-ItemProperty -Path $regPath -Name "VisualFXSetting" -Value 2
Write-Host "Efectos visuales deshabilitados."

# Deshabilitar la indexación de búsqueda (si no usas mucho la búsqueda de Windows)
Write-Host "Deshabilitando la indexación de búsqueda..."
Stop-Service -Name WSearch -Force
Set-Service -Name WSearch -StartupType Disabled
Write-Host "Indexación de búsqueda deshabilitada."

# Optimizar la configuración de energía (poner en alto rendimiento)
Write-Host "Configurando el modo de energía en alto rendimiento..."
powercfg /S SCHEME_MIN
Write-Host "Modo de energía configurado en alto rendimiento."

# Optimización completada
Write-Host "Optimización del sistema completada. Se recomienda reiniciar el sistema para aplicar todos los cambios."
