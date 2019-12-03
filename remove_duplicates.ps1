[CmdletBinding()]
Param (
    [Parameter(Mandatory = $true)] [string] $SourceFolder,
    [Parameter(Mandatory = $true)] [string] $ComparedWith,
    [Parameter(Mandatory = $true)] [bool] $StartWinMerge
)
begin {

    # Kill empty folders. Use recursivity to make sure that no empty folders remains
    # once an empty subfolder has been removed
    # @https://stackoverflow.com/a/28631669
    function DeleteEmptyDirectories {
        param ([string]$folder)
        do {
            $dirs = gci $folder -directory -recurse | Where { (gci $_.fullName).count -eq 0 } | select -expandproperty FullName
            $dirs | Foreach-Object {
                Remove-Item $_
            }
        } while ($dirs.count -gt 0)

    }

    function RemoveIndenticalFiles {

        $deleted = 0

        # Get the list of all files in the source folder
        Write-Host "    Getting the list of files in ""$SourceFolder"""
        $fso = Get-ChildItem -Path $SourceFolder -Recurse

        # Get the list of all files in the compared with folder
        Write-Host "    Getting the list of files in ""$ComparedWith"""
        $fsoComparedWith = Get-ChildItem -Path $ComparedWith -Recurse

        # Compare both folders; make sure to first mention the backup folder
        # Search exactly the same file; same hash
        # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/compare-object?view=powershell-6
        Write-Host "    Comparing files, please wait..."
        Write-Host ""

        Compare-Object -ReferenceObject $fsoComparedWith `
            -DifferenceObject $fso -IncludeEqual | `
            Where-Object { $_.SideIndicator -eq "==" } | `
            ForEach-Object {
            if ((Get-Item $_.InputObject.FullName) -is [System.IO.FileInfo]) {
                # It's a file
                Write-Host "    Duplicate file found, kill" $_.InputObject.FullName
                Remove-Item $_.InputObject.FullName

                $deleted += 1
            }
        }

        # Remove empty folders in the backup folder
        DeleteEmptyDirectories $ComparedWith

        if ($deleted > 0) { 
            Write-Host ""
            Write-Host "    Number of deleted files: $deleted"
        }
        else {
            Write-Host "    No duplicate files found."
        }

    }

    # Count the number of files still in the CompareWith folder and if greater than
    # zero, start WinMerge to make easier to finish the comparaison
    function CountFiles() {
        $fso = Get-ChildItem -Path $ComparedWith -Recurse -File
        $count = $fso | Measure-Object | % { $_.Count }

        if ($count -gt 0) {
            Write-Host "    There are $count files in ""$ComparedWith""."
            Write-Host "    These files are missing in ""$SourceFolder"" or were different."

            if ($StartWinMerge -eq 1) {
                # Start WinMerge
                # If not installed, download it from here https://sourceforge.net/projects/winmerge/
                # Command line arguments: https://manual.winmerge.org/en/Command_line.html
                Start "C:\Program Files\WinMerge\WinMergeU.exe" "/r /wl ""$SourceFolder"" /wr ""$ComparedWith"" /u"
            }
            else {
                Write-Host "    Tips: run the script with -StartWinMerge=1 to complete your comparison work with ease"
            }
        }
        else {
            Write-Host "    No more files are present in ""$ComparedWith"". All files were duplicated files."
        }

    }

    #  Validate command line parameters
    function validate() {
        $SourceFolder = $SourceFolder.Trim()
        $ComparedWith = $ComparedWith.Trim()

        if (-not (Test-Path $SourceFolder)) {
            Write-Host "ERROR - The source folder ""$SourceFolder"" didn't exists" -ForegroundColor White -BackgroundColor Red
            exit -1
        }

        if (-not (Test-Path $ComparedWith)) {
            Write-Host "ERROR - The compare with folder ""$ComparedWith"" didn't exists" -ForegroundColor White -BackgroundColor Red
            exit -2
        }
    }

    function showIntro() {
        Write-Host "The script will compare the ""$ComparedWith"" and the ""$SourceFolder"" folders and:"
        Write-Host ""
        Write-Host "   1. Check any files present in ""$ComparedWith"" and if an exact copy is already in ""$SourceFolder"", THE FILE WILL BE REMOVED IN ""$ComparedWith"""
        Write-Host "   2. Remove empty folder in the ""$ComparedWith"""
        Write-Host ""
        Write-Host "Be careful, this script is destructive and will kill duplicated files in the ""$ComparedWith""" -ForegroundColor White -BackgroundColor Red
        Write-Host ""
        Write-Host "At the end, the folder ""$ComparedWith"" will contains files not in ""$SourceFolder"" or with another version"
    }

    function Ask-BeforeContinue {
        $input = read-host "Do you want to continue? Type yes or no then press Enter"

        switch ($input) `
        {
            'yes' {
                return $TRUE
            }

            'no' {
                return $FALSE
            }

            default {
                Write-Host 'You may only answer yes or no, please try again.'
                Ask-BeforeContinue
            }
        }
    }

    # ###############
    # # Entry point #
    # ###############

    Write-Host "Remove_duplicates - Compare two folders on your disk and remove duplicates in the second folder" -ForegroundColor Cyan
    Write-Host ""

    validate

    showIntro

    Write-Host ""
    Write-Host "   * Original folder: ""$SourceFolder"""       "<-- That folder won't be modified at all"
    Write-Host "   * Compared With folder: ""$ComparedWith"""  "<-- Duplicated files will be removed from here"
    Write-Host ""

    if (Ask-BeforeContinue) {
        # Remove duplicate files in $ComparedWith
        RemoveIndenticalFiles
        CountFiles
    }
    else {
        Write-Host ""
        Write-Host "Nothing has been done, exiting"
    }

}
