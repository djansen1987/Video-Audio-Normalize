<#
.SYNOPSIS
    .
.DESCRIPTION
    .
.PARAMETER Path
    The path to the .
.PARAMETER LiteralPath
    Remove All Audio from input folder 
.EXAMPLE
    C:\PS> 
    Remove-VideoAudio -InputFolder c:\temp\myoldvideos -Backup
.NOTES
    Author: Daniel Jansen
    Date:   september 25, 2019
#>

param (
    $InputFolder,[switch]$Backup,[switch]$ForceRemove
 )

#$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path


Function remove-audio($InputFolder,[switch]$Backup,[switch]$ForceRemove){

    New-Item -Path "$InputFolder\Backup\" -ItemType Directory -Force
    Get-ChildItem $InputFolder | Move-Item -Destination "$InputFolder\Backup\"
    $Items = Get-ChildItem -Path "$InputFolder\Backup\" -File

    $Items|%{
        ffmpeg -loglevel panic -i $_.FullName  -vcodec copy -an "$InputFolder\$($_.Name)"
    }

    if($Backup){
        break
    }elseif($ForceRemove){
        Get-ChildItem -Path "$InputFolder\Backup\" -File|Remove-Item 
    }else{
        $reply = Read-Host -Prompt "WARNING! You did not choose to keep the backup the original files. Continue removing originals ? [y/n]"
        if ( $reply -match "[yY]" ) { 
            # Highway to the danger zone 
            Write-Host "Clearing Backup folder"
            Get-ChildItem -Path "$InputFolder\Backup\"|Remove-Item 
        }else {
            Write-Host "No worries we saved your originals at `"$InputFolder\Backup\`""
            Read-Host "Enter to exit."
            break
        }
    
    }

}


if(Test-Path $InputFolder){

    if($Backup){
        remove-audio -InputFolder $InputFolder -Backup
    }elseif($ForceRemove){
        remove-audio -InputFolder $InputFolder -ForceRemove
    }else{
        remove-audio -InputFolder $InputFolder
    }
}else{
    Write-Warning "Input Path not found"
    Read-Host "Enter to exit."
    break
}