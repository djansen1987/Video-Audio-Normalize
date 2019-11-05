<#
.SYNOPSIS
    .
.DESCRIPTION
    .
.PARAMETER Path
    The path to the .
.PARAMETER LiteralPath
    Normalize your video audio
.EXAMPLE
    C:\PS> 
    Start-NormalizeVideos -InputFolder c:\temp\myoldvideos -InputFileType *.mp4 -Backup
    Start-NormalizeVideos -InputFolder c:\temp\myoldvideos -Backup
    Start-NormalizeVideos -InputFolder c:\temp\myoldvideos -ForceRemove -InputFileType *.mkv
.NOTES
    Author: Daniel Jansen
    Date:   June 06, 2019
#>
param (
    $InputFolder, [ValidateSet("*.mp4", "*.mkv", "*.mpg", "All")]$InputFileType, [switch]$Backup,[switch]$ForceRemove
 )

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path



Function Start-NormalizeVideos ($InputFolder, [ValidateSet("*.mp4", "*.mkv", "*.mpg", "All")]$InputFileType,  [switch]$backup,[switch]$ForceRemove){
    <#if(!(Test-Path $OutputFolder)){
        $reply = Read-Host -Prompt "Output Folder does not exist. Create ? [y/n]"
        if ( $reply -match "[yY]" ) { 
             Highway to the danger zone 
            Write-Host "Creating output folder"
            New-Item -Path $OutputFolder -ItemType Directory -Force
        }else {break}
    }#>

    if(!$InputFileType){
        write-host "Inputtype Default (*.mp4)"
        $FileType = "*.mp4"
    }else {
        write-host "Inputtype is: $InputFileType"
        $FileType = $InputFileType
    }
    <#if($Force -eq $true){
        #write-host $Force
        $reply = Read-Host -Prompt "Force enabled. This means files in output directory are overwritten. Continue ? [y/n]"
        if ( $reply -match "[yY]" ) { 
            # Highway to the danger zone 
            Write-Host "Continue, files in output directory are overwritten"
            $ForceParamter = "-f"
        }else {break}
    }#>
    New-Item -Path "$InputFolder\Backup\" -ItemType Directory -Force | Out-Null
    if($inputfiletype -like "All"){
        $oldvids = Get-ChildItem $InputFolder -File| Move-Item -Destination "$InputFolder\Backup\"
    }else{
        $oldvids = Get-ChildItem $InputFolder -File|? {$_.name -like $InputFileType}| Move-Item -Destination "$InputFolder\Backup\"
    }
    Start-Sleep 1
    $Items = Get-ChildItem -Path "$InputFolder\Backup\"

    if (!$Items){
        Write-Host "no Files Found"
    }else {
        
        #$oldvids | Move-Item -Destination "$InputFolder\Backup\"
        

        $Items|% {
            Write-Host "Converting: " $_.Name
            $FileToConvert = '"'+ ($_.FullName).tostring() + '"'
            ffmpeg-normalize $_.FullName -of $InputFolder --normalization-type peak --target-level 0 -c:a libmp3lame -b:a 256k -ext mp4 $ForceParamter 
        }

        if($Backup){
            break
        }elseif($ForceRemove){
            Get-ChildItem -Path "$InputFolder\Backup\"|Remove-Item 
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

}

function Register-ffmpeg ([switch]$Replace){

    if($replace){
        $ffmpeg = ($ENV:PATH).Split((";"))|?{$_ -like "*ffmpeg*"}
    
        if($ffmpeg){
            if(Test-Path ($ScriptDir+ "\Temp\temp.path") ){
                Move-Item ($ScriptDir+ "\Temp\temp.path") ($ScriptDir+ "\Temp\temp"+(Get-Random)+ ".path") -ea Stop
            }

            $(($ENV:PATH).Split((";"))|?{$_ -notlike "*ffmpeg*"})|%{Add-Content -NoNewline -Value ($_ + ";") -Path ($ScriptDir+ "\Temp\temp.path") }
            if(Test-Path ($ScriptDir+ "\Temp\temp.path") ){
            $temppath = Get-Content ($ScriptDir+ "\Temp\temp.path") -ea Stop
            
                $ENV:PATH = $temppath.Substring(0,$temppath.Length-1)
            }
        
        }

        $Currentffmpeg = $ScriptDir + "\Source\ffmpeg\bin\ffmpeg.exe"

        if(test-path $Currentffmpeg){
           $ENV:PATH = "$ENV:PATH;$(($Currentffmpeg).ToString())"
        }else{
           Write-Warning "Could not find ffmpeg in your `$PATH or `$FFMPEG_PATH. Please install ffmpeg from http://ffmpeg.org"
           break
        }
    }

}

# find ffmpeg
$ffmpeg = ($ENV:PATH).Split((";"))|?{$_ -like "*ffmpeg*"}

if(Test-Path $InputFolder){
    if($ffmpeg){

        if(!(Test-Path $ffmpeg)){
            Register-ffmpeg -Replace
        }


        start-NormalizeVideos -InputFolder $InputFolder -OutputFolder $OutputFolder -InputFileType $InputFileType -backup $Backup

    }else{
        Register-ffmpeg -Replace
        Start-Sleep 5 
        start-NormalizeVideos -InputFolder $InputFolder -OutputFolder $OutputFolder -InputFileType $InputFileType -force $Force
    }
}else{
    Write-Warning "Input Path not found"
    Read-Host "Enter to exit."
    break
}