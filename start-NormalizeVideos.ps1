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
    start-NormalizeVideos -InputFolder c:\temp\myoldvideos -OutputFolder C:\Temp\mynormalizedvideos -InputFileType *.mp4
.NOTES
    Author: Daniel Jansen
    Date:   June 06, 2019
#>
param (
    $InputFolder,$OutputFolder, [ValidateSet("*.mp4", "*.mkv", "*.mpg")]$InputFileType, [switch]$Force
 )



Function start-NormalizeVideos ($InputFolder,$OutputFolder, [ValidateSet("*.mp4", "*.mkv", "*.mpg")]$InputFileType, $Force){
 
    if(!$InputFileType){
        write-host "Inputtype Default (*.mp4)"
        $FileType = "*.mp4"
    }else {
        write-host "Inputtype is: $InputFileType"
        $FileType = $InputFileType
    }
    if($Force -eq $true){
        #write-host $Force
        $reply = Read-Host -Prompt "Force enabled. This means files in output directory are overwritten. Continue ? [y/n]"
        if ( $reply -match "[yY]" ) { 
            # Highway to the danger zone 
            Write-Host "Continue, files in output directory are overwritten"
            $ForceParamter = "-f"
        }else {break}
    }

    $oldvids = Get-ChildItem $InputFolder -Recurse |? {$_.name -like $InputFileType}
    if (!$oldvids ){
        Write-Host "no Files Found"
    }else {
        foreach ($oldvid in ($oldvids)) {
            Write-Host "Converting: " $oldvid.Name
            $FileToConvert = '"'+ ($oldvid.FullName).tostring() + '"'
            ffmpeg-normalize $FileToConvert -of $OutputFolder --normalization-type peak --target-level 0 -c:a aac -b:a 256k -ext mp4 $ForceParamter 
        }
    }

}

#$InputFolder = "C:\Users\Studio\Videos\Bruiloft 15-6 - 2019\"
#$OutputFolder = "C:\Users\Studio\Videos\Bruiloft 15-6 - 2019\norm"
start-NormalizeVideos -InputFolder $InputFolder -OutputFolder $OutputFolder -InputFileType *.mp4 -force $Force