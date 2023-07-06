<#
Here I modified the script to accept parameters. You would call the script like this:
Powershell
Get-ChildItem -Path .\data -Filter "*.xml" | % { .\split-xml.ps1 -dir "$pwd\data" -in_file $_.name }

Assumptions:
You call your script "split-xml.ps1"
Your xml files are in a directory called "data" that exists in the same parent directory as "split-xml.ps1"
The only xml files in the data directory are the xml files you want processed.
#>

Param (

$dir,
$in_file

)

$in_path = Join-Path -Path $dir -ChildPath $in_file

$out_file_base = "$($in_file.split(".")[0])_"

$xml_dec_regex = "<\?xml .*"
$blank_regex = "^\s*$"

$file_num = 1
$out_path = "$dir\$out_file_base$("{0:d6}" -f $file_num).xml"

$sr = New-Object -TypeName System.IO.StreamReader -ArgumentList $in_path

$length = $sr.BaseStream.Length

Write-Progress -Activity "Splitting File" `
               -Status "File: $file_num" `
               -PercentComplete ($sr.BaseStream.Position / $length * 100)

$sw = New-Object -TypeName System.IO.StreamWriter -ArgumentList $out_path

$line = $sr.ReadLine()

While ($line -match $blank_regex -and !$sr.EndOfStream) {

    $line = $sr.ReadLine()

}

$sw.WriteLine($line)

While (!$sr.EndOfStream) {

    $line = $sr.ReadLine()

    While ($line -match $blank_regex) {

        $line = $sr.ReadLine()

    }

    If ($line -match $xml_dec_regex) {
        
        $sw.close()
        $file_num += 1
        $out_path = "$dir\$out_file_base$("{0:d6}" -f $file_num).xml"
        $sw = New-Object -TypeName System.IO.StreamWriter -ArgumentList $out_path
        Write-Progress -Activity "Splitting File" `
               -Status "File: $file_num" `
               -PercentComplete ($sr.BaseStream.Position / $length * 100)

    }

    $sw.WriteLine($line)

} 

$sr.close()
$sw.close()