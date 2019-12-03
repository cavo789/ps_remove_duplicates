@echo off
cls
powershell .\remove_duplicates.ps1 -SourceFolder C:\Christophe\source -ComparedWith C:\Temp\copy -StartWinMerge 1
