####################################################
# Measure-StorageSpacesPhysicalDiskPerformance.ps1 #
#                                                  #
# By Bruce Langworthy                              #
####################################################
# This script accepts an input of the FriendlyName of a Storage Space, and yields a performance monitor log
# of the Physical Disks which back the Storage Space to diagnose issues with a single Physical Disk which is 
# performing slowly, and causing the Storage Space to be slow.


Function Measure-StorageSpacesPhysicalDiskPerformance {
<#
.SYNOPSIS
    Generates Performance Monitor data for the Physical Disks in a pool used to create a Storage Space. This information can then be viewed
    In Performance Monitor to determine which phyhsical disks (if any) are performing slowy relative to other physical disks in the pool.
.Description
    Automates collection of Performance Monitor counters for every Physical Disk related to the Storage Space specified to diagnose performance 
    issues related to slow physical disks.
.LINK
    Http://blogs.msdn.com/san
.EXAMPLE
    Measure-StorageSpacesPhysicalDiskPerformance.ps1 -StorageSpaceFriendlyName Data -MaxNumberOfSamples 25 -SecondsBetweenSamples 1 -ResultsFilePath s:\PerfData.blg -SpacetoPDMappingPath s:\DiskMap.csv -Verbose -ReplaceExistingResultsFile -WarningAction SilentlyContinue
    
    Produces a file named PerfData.blg in the current directory containing performance counter samples, plus DiskMap.Csv containing  information about every physical disk backing the Storage Space which was provided.
    
    The following performance counters are collected for each Physical Disk associated with the specified Storage Space.

    \PhysicalDisk({0})\Disk Writes/sec
    \PhysicalDisk({0})\Avg. Disk sec/write
    \PhysicalDisk({0})\Avg. Disk sec/read
    \PhysicalDisk({0})\Disk Read Bytes/sec
    \PhysicalDisk({0})\Disk Write Bytes/sec
    \PhysicalDisk({0})\Avg. Disk Read Queue Length
    \PhysicalDisk({0})\Avg. Disk Write Queue Length
    \PhysicalDisk({0})\Disk Transfers/sec
    \PhysicalDisk({0})\Disk Reads/sec
    \PhysicalDisk({0})\Split IO/Sec
#>
    [CmdletBinding(SupportsShouldProcess=$False)]
    param(  
    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $StorageSpaceFriendlyName,

    [parameter(Mandatory=$true)]
    [Int]
    $MaxNumberOfSamples,

    [parameter(Mandatory=$true)]
    [Int]
    $SecondsBetweenSamples,

    [parameter(Mandatory=$false)]
    [Switch]
    $ReplaceExistingResultsFile,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $ResultsFilePath,

    [parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [String]
    $SpacetoPDMappingPath
    )

# Check to ensure the filename and path for output files does not already exist
$Errors = $Null

# Check to see if the results file already exisits, and user did not request to replace the file.
if ((Test-Path $ResultsFilePath) -eq $True -and (!$ReplaceExistingResultsFile)) 
{
    Write-Error "Specified output file $ResultsFilePath already exisits"
    $Errors = $True
}
# Check to see if the results file already exisits, and user did not request to replace the file.
if ((Test-Path $SpacetoPDMappingPath) -eq $True -and (!$ReplaceExistingResultsFile)) 
{
    Write-Error "Specified output file $SpaceToPDMappingPath already exists"
    $Errors = $True
}

# If errors were hit with the file names, exit the script
if ($Errors -eq $True -and (!$ReplaceExistingResultsFile)) 
{
    Write-error "One or more output files already exist, please remove these files, or specify different output filenames and try again" -ErrorAction Stop
}

# If user specifed the replace the files, make sure the files are there before attempting deletion.
if ($ReplaceExistingResultsFile -ne $Null)
{
    # User specified to replace the file, make sure it exists before attempting removal.
    if ((Test-Path $SpacetoPDMappingPath) -eq $True)
    {
        write-warning "Remove the file $SpaceToPDMappingPath ?" -WarningAction Inquire
        Remove-Item $SpacetoPDMappingPath
    }
    # User specified to replace the file, make sure it exists before attempting removal.
    if ((Test-Path $ResultsFilePath) -eq $True)
    {
    
        write-warning "Remove the file $ResultsFilePath ?" -WarningAction Inquire 
        Remove-Item $ResultsFilePath
    }
}

# Collect data for the foreach loop based on parameter inputs
$StorageSpace = Get-VirtualDisk -FriendlyName $StorageSpaceFriendlyName
$PDForSpace = $StorageSpace | Get-PhysicalDisk
$Pdcount = $PDForSpace.count

# Save Physical disk to disk number mapping

write-verbose "Collecting mapping of Physical Disk, DeviceID, and UniqueID"
Foreach ($Object in $PDForSpace)
{
    $Object | Select FriendlyName, DeviceID, UniqueID | Export-Csv $SpacetoPDMappingPath -NoTypeInformation -Append 
    
}

# Ensure variables are null before the foreach loop
$StringtoExecute = ""
$TempObj = ""
$PDobj = ""
$String = ""
$teststring=""
$Pdobj=""
$teststring1=""
$teststring2=""

# Using the collected Physical Disk objects, build a string to collect performance data for each of them.
Foreach ($PDObj in $PDForSpace)
{ 
   $Tempobj = $PDObj.DeviceID    
   [String]$String+=@("\PhysicalDisk({0})\Disk Writes/sec",',' -f $TempOBJ)
            $String+=@("\PhysicalDisk({0})\Avg. Disk sec/write",',' -f $TempOBJ)
            $String+=@("\PhysicalDisk({0})\Avg. Disk sec/read",',' -f $TempOBJ)
            $String+=@("\PhysicalDisk({0})\Disk Read Bytes/sec",',' -f $TempOBJ)
            $String+=@("\PhysicalDisk({0})\Disk Write Bytes/sec",',' -f $TempOBJ)
            $String+=@("\PhysicalDisk({0})\Avg. Disk Read Queue Length",',' -f $TempOBJ)
            $String+=@("\PhysicalDisk({0})\Avg. Disk Write Queue Length",',' -f $TempOBJ)
            $String+=@("\PhysicalDisk({0})\Disk Transfers/sec",',' -f $TempObj)
            $String+=@("\PhysicalDisk({0})\Disk Reads/sec",',' -f $TempObj)
            $String+=@("\PhysicalDisk({0})\Split IO/Sec",',' -f $TempObj)}

# Convert string to one usable with Get-Counter

    # Remove extra trailing comma added by the foreach loop
    [String]$TestString = ($String.TrimEnd(' ,') )

    # Remove spaces preceeding commas
    [String]$TestString1 = $TestString.Replace(' ,',',')


    # Remove spaces trailing commas
    [String]$TestString2 = $TestString1.Replace(', ',',')

    # Convert the result into an array of strings so it works with get-counter.
    $result = $teststring2 -split ","


# Start Performance Monitor collection run.
write-warning "Beginning Performance Monitor capture for on the Storage Space named $StorageSpaceFriendlyName for $MaxNumberOfSamples samples collected at $SecondsBetweenSamples second intervals." 
Get-Counter -SampleInterval $SecondsBetweenSamples -MaxSamples $MaxNumberOfSamples -Counter $result | Export-Counter -Path $ResultsFilePath -Force
 
# Assemble the output object 
$ResultsFiles = New-Object Object
$ResultsFiles | Add-Member "PerformanceLogPath"   -Value $ResultsFilePath       -MemberType NoteProperty;
$ResultsFiles | Add-Member "PhysicalDiskLogPath"  -Value $SpacetoPDMappingPath  -MemberType NoteProperty;
Return $ResultsFiles;

}

Export-ModuleMember Measure-StorageSpacesPhysicalDiskPerformance