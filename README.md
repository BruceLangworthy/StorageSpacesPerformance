# StorageSpacesPerformance
A PowerShell module for diagnosing performance issues with Microsoft Storage Spaces

Diagnosing Storage Spaces Performance
Issues with Physical Disks:


By Bruce Langworthy and Tobias Klima
Abstract:

This paper and accompanying module for Windows PowerShell
provides the ability to diagnose physical disks which are performing slowly in
a Storage Spaces pool to determine the cause for slow performance with observed
with a Storage Space.

Background:

While it would normally be expected to achieve very good
performance when using Storage Spaces, there are a number of factors which can
contribute to sub-optimal performance, depending on the configuration and
hardware used.

Some of these specific factors are:

Issues resulting from configuration problems.
For example, the Storage Space itself is not configured optimally for the
intended workload or does not utilize all physical disks in the pool optimally

Issues resulting from bus throughput limits –
For example,  By using SAS-Expanders, its
possible to connect 10, 50, perhaps even 100 disks on a single SAS port,
however the total throughput for all Storage Spaces in use cannot exceed the
maximum speed of the single SAS Port.

Issues resulting from dissimilar disk
performance types in a pool – For example, in creating a pool using 5 SAS disks
plus a single USB 2.0 disk, the maximum performance of any Storage Space which
uses the USB 2.0 disk is limited to the USB 2.0 bus-speed limit of
approximately 30MB a sec split across all USB 2.0 connected devices.

PowerShell
Measure-StorageSpacesPhysicalDiskPerformance -StorageSpaceFriendlyName Data -MaxNumberOfSamples 30 -SecondsBetweenSamples 1 -ReplaceExistingResultsFile -ResultsFilePath StorageSpaces.blg -SpacetoPDMappingPath PDMap.csv
