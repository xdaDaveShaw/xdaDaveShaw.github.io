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
    $ExpectedSha1Hash = "843F0BE42E86680C1663C4EF58EB0677ACE15FC29AB23897C83F4B7E5AF3EF36"
    $ActualSha1Hash = (Get-FileHash '.\tools\pngout.exe').Hash
    if ($ExpectedSha1Hash -eq $ActualSha1Hash) {
        Write-Output 'Download Complete.'
    } else {
        Write-Output "FileHash mismatch. Expected $ExpectedSha1Hash Got $ActualSha1Hash"
        exit
    }
}

Write-Output ""
Write-Output 'Performing Compressing, please wait...'

Get-ChildItem -Filter *.png -Recurse | 
    Where-Object { $_.fullname -notmatch "\\_site\\?" } | 
    Sort-Object { $_.CreationTime } -Descending |
    Select-Object FullName | 
    ForEach-Object { .\tools\pngout.exe $_.Fullname /c2 /f0 }

$finalSize = GetSize

Write-Output ""
Write-Output 'All PNGs Compressed'
Write-Output "Original Size was: $originalSize bytes."
Write-Output "Final Size is:     $finalSize bytes."
Write-Output ""