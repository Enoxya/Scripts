function Convert-ExcelToCsv {
    # converts a worksheet from .xsl and .xslx files to Csv files in UTF-8 encoding
    [CmdletBinding()]
    Param(
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("FilePath", "FullName")]
        [string[]]$Path,

        [Parameter(Mandatory = $false)]
        [int]$SheetNumber = 1,

        [Parameter(Mandatory = $false)]
        [char]$Delimiter = ','

    )
    begin {
        try {
            $excel = New-Object -ComObject Excel.Application -ErrorAction Stop -Verbose:$false
            $excel.Visible = $false 
            $excel.DisplayAlerts = $false
        }
        catch { 
            throw "This function needs Microsoft Excel to be installed." 
        }
    }

    process {
        foreach ($xlFile in $Path) {
            Write-Verbose "Processing '$xlFile'"
            # convert Excel file to CSV file UTF-8
            $workbook = $excel.Workbooks.Open($xlFile)

            # set the active worksheet
            if ($SheetNumber -notin 1..@($workbook.Sheets).Count) { $SheetNumber = 1 }
            $workbook.Worksheets.Item($SheetNumber).Activate()

            # Unfortunately, Excel up to and including version 2016 has no option to export csv format in UTF8 encoding 
            # so we save as 'Unicode Text (*.txt)' (= Tab delimited)
            # See: https://msdn.microsoft.com/en-us/library/microsoft.office.tools.excel.workbook.saveas.aspx

            # Apparently, at some point (version 2019?) there is a new format specifier called xlCSVUTF8 (value 62),
            # but I can't find anywhere as of which version this is a valid value. It certainly doesn't exist in 
            # versions up to and including version 2016.
            # see https://learn.microsoft.com/en-us/office/vba/api/excel.xlfileformat

            # create a temporary file to store the in-between result
            $tempFile = [System.IO.Path]::ChangeExtension([System.IO.Path]::GetTempFileName(), ".txt")
            if (Test-Path -Path $tempFile -PathType Leaf) { Remove-Item -Path $tempFile -Force }

            $xlUnicodeText = 42         # Tab-delimited. See: https://msdn.microsoft.com/en-us/library/bb241279.aspx
            $workbook.SaveAs($tempFile, $xlUnicodeText) 
            $workbook.Saved = $true
            $workbook.Close()

            # now import, delete the temp file and save as Csv in UTF-8 encoding
            $result = Import-Csv -Path $tempFile -Encoding Unicode -Delimiter "`t" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            Remove-Item -Path $tempFile -Force
            $csvFile = [System.IO.Path]::ChangeExtension($xlFile, ".csv")
            Write-Verbose "Creating '$csvFile'"
            $result | Export-Csv -Path $csvFile -Delimiter $Delimiter -Encoding UTF8 -NoTypeInformation -Force
        }
    }

    end {
        Write-Verbose "Quit and cleanup"
        $excel.Quit()

        # cleanup COM objects
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
        [System.GC]::Collect()
        [System.GC]::WaitForPendingFinalizers()
    }
}