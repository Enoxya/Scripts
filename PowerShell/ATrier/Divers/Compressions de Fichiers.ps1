Function CompressGZip
{
    param
    (
        [String]$inFile = $(throw "Gzip-File: No filename specified"),
        [String]$outFile = $($inFile + ".gz"),
        [switch]$delete # Delete the original file
    )
 
    trap
    {
        Write-Host "Received an exception: $_.  Exiting."
        break
    }
 
    if (! (Test-Path $inFile))
    {
        "Input file $inFile does not exist."
        exit 1
    }
 
    Write-Host "Compressing $inFile to $outFile."
 
    $input = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
 
    $buffer = New-Object byte[]($input.Length)
    $byteCount = $input.Read($buffer, 0, $input.Length)
 
    if ($byteCount -ne $input.Length)
    {
        $input.Close()
        Write-Host "Failure reading $inFile."
        exit 2
    }
    $input.Close()
 
    $output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
    $gzipStream = New-Object System.IO.Compression.GzipStream $output, ([IO.Compression.CompressionMode]::Compress)
 
    $gzipStream.Write($buffer, 0, $buffer.Length)
    $gzipStream.Close()
 
    $output.Close()
 
    if ($delete)
    {
        Remove-Item $inFile
    }
}


Function CompressZip
 {
     param([string]$Directory)

    if(-not (test-path($Directory)))
     {
         set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
         (Get-ChildItem $zipfilename).IsReadOnly = $false    
     }
         
     $shellApplication = new-object -com shell.application
     $zipPackage = $shellApplication.NameSpace($zipfilename)
         
     $ZipFile.CopyHere($Directory)

        do { $zipCount = $ZipFile.Items().count
             Start-sleep -Seconds 1
           } While($ZipFile.Items().count -lt 1)
           
 }


 function ZipFiles( $zipfilename, $sourcedir)
{
   Add-Type -Assembly System.IO.Compression.FileSystem
   $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
   [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,
        $zipfilename, $compressionLevel, $false)
}


