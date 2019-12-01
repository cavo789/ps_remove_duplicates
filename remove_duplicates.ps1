begin {

    $SourceFolder = "c:\christophe\source_folder"
    $ComparedWith = "c:\temp\copy"

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

    function RemoveIndenticalFiles ([string] $SourceFolder, [string] $ComparedWith) {

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

        Write-Host ""
        Write-Host "    Number of deleted files: $deleted"
    }

    function showIntro() {
        Write-Host "Compare two folders and remove in the second duplicated files" -ForegroundColor Cyan
        Write-Host ""
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

    showIntro

    Write-Host ""
    Write-Host "   * Original folder: ""$SourceFolder"""       "<-- That folder won't be modified at all"
    Write-Host "   * Compared With folder: ""$ComparedWith"""  "<-- Duplicated files will be removed from here"
    Write-Host ""

    if (Ask-BeforeContinue) {
        # Remove duplicate files in $ComparedWith
        RemoveIndenticalFiles $SourceFolder $ComparedWith
    }
    else {
        Write-Host ""
        Write-Host "Nothing has been done, exiting"
    }

}
