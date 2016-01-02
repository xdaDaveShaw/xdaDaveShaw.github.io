#TODO: Make work off of git status to only find uncommitted PNGs
echo ""

Function GetSize {
    (Get-ChildItem *.png -recurse | Measure-Object -property length -sum).Sum
}

echo 'Compressing all PNG images...'

$originalSize = GetSize

if (!(Test-Path -Path tools))
{
    md tools > $null
}

if (!(Test-Path -Path tools\pngout.exe))
{
    echo 'Downloading PNGOut...'
    Invoke-WebRequest 'http://advsys.net/ken/util/pngout.exe' -OutFile '.\tools\pngout.exe'
    echo 'Download Complete.'
}

echo ""
echo 'Performing Compressing, please wait...'

gci *.png -Recurse | select FullName | foreach { .\tools\pngout.exe $_.Fullname}

$finalSize = GetSize

echo ""
echo 'All PNGs Compressed'
echo "Original Size was: $originalSize bytes."
echo "Final Size is:     $finalSize bytes."
echo ""