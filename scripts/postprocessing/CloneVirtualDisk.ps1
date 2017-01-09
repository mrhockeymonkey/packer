<#
	.SYNOPSIS
	Clone a virtual hard disk file

	.DESCRIPTION
	This script wraps calling the clonemedium command using VBoxManage.exe. 
	It can be called via the 'shell-local' post-processor to clone a virtual 
	hard disk file into a specified format.

	.EXAMPLE
	"post-processors": [
		{
			"type":"shell-local",
			"execute_command": "{{.Script}} -Artifact {{.Artifact}} -Format VHD",
			"script": "scripts/CloneVirtualDisk.ps1"
		}

	.NOTES
	This assume you have copied powershell.exe to sh.exe to make shell-local useable on windows
#>

[CmdletBinding()]
Param (
	[Parameter (Mandatory = $true)]
	[String]$Artifact,

	[Parameter (Mandatory = $true)]
	[ValidateSet ('VDI','VMDK','VHD','RAW')]
	[String]$Format
)

Try {
	#Get the artifact and and define what we need
	$SourceFile = Get-Item $Artifact -ErrorAction Stop
	$VBoxManage = "$env:ProgramFiles\Oracle\VirtualBox\VBoxManage.exe"
	$TargetPath = "$($SourceFile.Directory.FullName)\$($SourceFile.BaseName).$($Format.ToLower())"

	#Remove any old artifacts from previous runs
	If (Test-Path $TargetPath) {
		Write-Host "Removing old artifact..."
		Remove-Item -Path $TargetPath -Force -ErrorAction Stop
	}

	#Clone to specified format using VBoxManage.exe
	Write-Host "Invoking: VBoxManage.exe clonemedium $($SourceFile.Name) $($TargetPath | Split-Path -Leaf) --format $Format"
	& $VBoxManage clonemedium $SourceFile.FullName $TargetPath --format $Format
}
Catch {
	Write-Warning $_.Exception.Message
	Exit 1
}