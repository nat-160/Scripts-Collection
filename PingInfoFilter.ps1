<#
.SYNOPSIS
    Generate a custom filter for a PingInfoView address file

.DESCRIPTION
    Takes a PingInfoView address file and an input file of device names, matches the names, and outputs to the hosts file.

.PARAMETER NoOverwrite
    Script will destroy input.txt and PingInfoView_hosts.txt by default
    Specifying this switch will use saved input.txt and send output to output.txt

.EXAMPLE
    ./PingInfoFilter.ps1
    Creates a filtered view by writing over the hosts file

.NOTES
    Author: Nat
    Created 12/24/25
    Revised 12/28/25
#>
param(
    [switch]$NoOverwrite
)

# Load address file
Add-Type -AssemblyName System.Windows.Forms
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.form")
$FileSelector = New-Object System.Windows.Forms.OpenFileDialog
$FileSelector.Title = "Select PingInfoView address file"
$FileSelector.InitialDirectory = "."
$FileSelector.filter = "TXT (*.txt)| *.txt"
$FileSelector.ShowDialog()
if (-not $FileSelector.FileName){ exit }

# Get input depending on override settings
$OutputFile = ".\PingInfoView_hosts.txt"
if ($NoOverwrite){
    $OutputFile = ".\output.txt"
} else {
    "Paste and replace this text with your input, then save & exit" | Out-File ".\input.txt" 
    Start-Process notepad.exe -ArgumentList ".\input.txt" -Wait
}

# Generate output file
(Get-Content $FileSelector.FileName) -split "`n" | Where-Object {$_ -match ("(Crane|" + $(((Get-Content ".\input.txt") -split "`n" | ForEach-Object {if ($_.trim()) {$_.trim()}}) -join "|") + ")")} | Out-File $OutputFile

# Start PingInfoView

Start-Process ./PingInfoView.exe
