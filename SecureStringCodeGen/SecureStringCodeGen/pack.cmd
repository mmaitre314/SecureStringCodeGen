@echo off
setlocal

set VERSION=1.0.3

set OUTPUT=c:\NuGet\

%OUTPUT%nuget.exe pack MMaitre.SecureStringCodeGen.nuspec -OutputDirectory %OUTPUT%Packages -Prop NuGetVersion=%VERSION% -NoPackageAnalysis
