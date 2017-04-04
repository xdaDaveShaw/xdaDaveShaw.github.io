#TODO: Make work off of git status to only find uncommitted PNGs
Write-Output ""

Function GetSize {
    (Get-ChildItem *.png -recurse | Measure-Object -property length -sum).Sum
}

Write-Output 'Compressing all PNG images...'

$originalSize = GetSize

if (!(Test-Path -Path tools))
{
    mkdir tools > $null
}

if (!(Test-Path -Path tools\pngout.exe))
{
    Write-Output 'Downloading PNGOut...'
    Invoke-WebRequest 'http://advsys.net/ken/util/pngout.exe' -OutFile '.\tools\pngout.exe'
    Write-Output 'Download Complete.'
}

Write-Output ""
Write-Output 'Performing Compressing, please wait...'

Get-ChildItem *.png -Recurse | Select-Object FullName | ForEach-Object { .\tools\pngout.exe $_.Fullname /c2 /f0 }

$finalSize = GetSize

Write-Output ""
Write-Output 'All PNGs Compressed'
Write-Output "Original Size was: $originalSize bytes."
Write-Output "Final Size is:     $finalSize bytes."
Write-Output ""