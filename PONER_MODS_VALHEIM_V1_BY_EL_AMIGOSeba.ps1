Add-Type -AssemblyName System.Windows.Forms
$valheimPath = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" | ForEach-Object { Get-ItemProperty $_.PSPath } | Select-Object DisplayName, InstallLocation | Where-Object { $_.DisplayName -like "*Valheim*" } | Select-Object -First 1 -ExpandProperty InstallLocation

$askForPath = $true
if ($valheimPath) {
  $result = [System.Windows.Forms.MessageBox]::Show("Is this the correct Valheim installation path?`n$valheimPath","Confirm Valheim Path",[System.Windows.Forms.MessageBoxButtons]::YesNo,[System.Windows.Forms.MessageBoxIcon]::Question)
  $askForPath = $result -eq [System.Windows.Forms.DialogResult]::No
}
if ($askForPath) {
  [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
  $form = New-object System.Windows.Forms.FolderBrowserDialog
  $form.Description = "Selecciona la carpeta de instalacion de Valheim"
  $form.ShowNewFolderButton = $false
  $form.RootFolder = "MyComputer"
  $form.SelectedPath = $valheimPath
  if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $valheimPath = $form.SelectedPath
  } else {
    [System.Windows.Forms.MessageBox]::Show("No se selecciono una ruta de instalacion de Valheim.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
  }
}
Write-Host "Valheim folder: $valheimPath"

if (-not (Test-Path $valheimPath)) {
  [System.Windows.Forms.MessageBox]::Show("La ruta de instalacion de Valheim no existe: $valheimPath", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
  exit
}

$scriptExtenderPath = Join-Path $PSScriptRoot "script_extender"
if (-not (Test-Path $scriptExtenderPath)) {
  [System.Windows.Forms.MessageBox]::Show("No se pudo encontrar la carpeta 'script_extender' en el directorio del script.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
  exit
}
Write-Host "Script extender folder: $scriptExtenderPath"
$scriptExtenderModsPath = Join-Path $scriptExtenderPath "BepInEx\plugins"
Write-Host "Script extender mods folder: $scriptExtenderModsPath"
if (-not (Test-Path $scriptExtenderModsPath)) {
  [System.Windows.Forms.MessageBox]::Show("No se pudo encontrar la carpeta 'script_extender/BepInEx/plugins' en el directorio del script.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
  exit
}

$modsPath = Join-Path $PSScriptRoot "mods"
if (-not (Test-Path $modsPath)) {
  [System.Windows.Forms.MessageBox]::Show("No se pudo encontrar la carpeta 'mods' en el directorio del script.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
  exit
}

Copy-Item -Path $scriptExtenderPath\* -Destination $valheimPath -Recurse -Force

Copy-Item -Path $modsPath\* -Destination $scriptExtenderModsPath -Recurse -Force

$player = New-Object System.Media.SoundPlayer
$player.SoundLocation = Join-Path $PSScriptRoot "src\PeonJobDone.wav"
$player.LoadAsync()
$player.PlaySync()


