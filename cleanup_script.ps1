# Define parameters and help
param (
    [switch]$All,
    [switch]$StandardPython,
    [switch]$Anaconda,
    [switch]$Mambaforge,
    [switch]$Help
)

# Function to display help
function Show-Help {
    "Usage: .\cleanup_script.ps1 [-All] [-StandardPython] [-Anaconda] [-Mambaforge] [-Help]"
    "  -All: Remove all Python distributions."
    "  -StandardPython: Remove standard Python distribution."
    "  -Anaconda: Remove Anaconda distribution."
    "  -Mambaforge: Remove Mambaforge distribution."
    "  -Help: Show this help message."
    exit
}

# Display help if requested
if ($Help) {
    Show-Help
}

# Check if no switches are provided and prompt for confirmation
if (-not ($All -or $StandardPython -or $Anaconda -or $Mambaforge -or $Help)) {
    $response = Read-Host "No switches provided. Do you want to perform a full cleanup? (Y/N)"
    if ($response -ne 'Y') {
        Write-Host "Operation cancelled. Use -Help switch for usage information."
        exit
    }
    $All = $true
}

# Function to check if the script is running as an administrator
function Check-Admin {
    if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
    {
        # Relaunch the script with administrator rights
        $arguments = "& '" + $myinvocation.mycommand.definition + "' " + (Build-ArgumentList)
        Start-Process powershell -Verb runAs -ArgumentList $arguments
        exit
    }
}

# Function to build argument list from the script's parameters
function Build-ArgumentList {
    $argList = ""
    if ($All) { $argList += "-All " }
    if ($StandardPython) { $argList += "-StandardPython " }
    if ($Anaconda) { $argList += "-Anaconda " }
    if ($Mambaforge) { $argList += "-Mambaforge " }
    return $argList.TrimEnd()
}

# Request elevation if required
Check-Admin

# PowerShell Script for Aggressive Removal of Python, Anaconda, and Mambaforge with Registry Backup

# Function to check if Chocolatey is installed
function Is-ChocolateyInstalled {
    $chocoPath = Get-Command "choco" -ErrorAction SilentlyContinue
    return $chocoPath -ne $null
}

# Uninstall Python and other distributions via Chocolatey if it's installed and selected
if (Is-ChocolateyInstalled) {
    if ($All -or $StandardPython) {
        choco uninstall python -y
        Write-Host "Uninstalled Python via Chocolatey"
    }
    if ($All -or $Mambaforge) {
        choco uninstall mambaforge -y
        Write-Host "Uninstalled Mambaforge via Chocolatey"
    }
}

# Function to backup and remove a registry key
function BackupAndRemove-RegistryKey {
    param (
        [string]$KeyPath,
        [string]$BackupDirectory
    )

    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    $backupFileName = "$BackupDirectory\Backup_$(($KeyPath -replace '\\', '_'))_$timestamp.reg"

    if (Test-Path $KeyPath) {
        reg export $KeyPath $backupFileName
        Write-Host "Exported registry key to $backupFileName"
        Remove-Item $KeyPath -Recurse
        Write-Host "Removed registry key: $KeyPath"
    }
}

# Uninstall Python, Anaconda, and Mambaforge using their uninstallers
$appsToUninstall = @("Python", "Anaconda", "Mambaforge")
foreach ($app in $appsToUninstall) {
    if (($app -eq "Python" -and ($All -or $StandardPython)) -or 
        ($app -eq "Anaconda" -and ($All -or $Anaconda)) -or 
        ($app -eq "Mambaforge" -and ($All -or $Mambaforge))) {
        $installedApps = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$app*" }
        foreach ($installedApp in $installedApps) {
            $installedApp.Uninstall()
            Write-Host "Uninstalled $($installedApp.Name)"
        }
    }
}

# Remove Python, Anaconda, and Mambaforge directories
$pathsToRemove = @("$env:LOCALAPPDATA\Programs\Python", "$env:USERPROFILE\Anaconda3", "$env:ProgramFiles\Python", "$env:ProgramFiles\Anaconda3", "$env:USERPROFILE\Mambaforge", "$env:ProgramFiles\Mambaforge")
foreach ($path in $pathsToRemove) {
    if (Test-Path $path) {
        Remove-Item -Recurse -Force $path
        Write-Host "Removed directory: $path"
    }
}

# Remove environment variables related to Python, Anaconda, and Mambaforge
$envVarsToRemove = @('PYTHONPATH', 'CONDA_PREFIX', 'PATH', 'MAMBA_ROOT_PREFIX', 'MAMBA_EXE')
foreach ($var in $envVarsToRemove) {
    [System.Environment]::SetEnvironmentVariable($var, $null, [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable($var, $null, [System.EnvironmentVariableTarget]::Machine)
    Write-Host "Removed environment variable: $var"
}

# Backup and remove registry keys related to Python, Anaconda, and Mambaforge
$registryKeysToRemove = @(
    'HKCU:\Software\Python',
    'HKLM:\Software\Python',
    'HKCU:\Software\Anaconda',
    'HKLM:\Software\Anaconda',
    'HKCU:\Software\Mambaforge',
    'HKLM:\Software\Mambaforge'
)
$backupDirectory = "$env:USERPROFILE\Desktop\PythonAnacondaMambaforgeRegistryBackups"
if (-not (Test-Path $backupDirectory)) {
    New-Item -ItemType Directory -Path $backupDirectory
}
foreach ($key in $registryKeysToRemove) {
    BackupAndRemove-RegistryKey -KeyPath $key -BackupDirectory $backupDirectory
}

Write-Host "Python environment removal process completed. Registry backups stored at $backupDirectory. Please restart your system."
