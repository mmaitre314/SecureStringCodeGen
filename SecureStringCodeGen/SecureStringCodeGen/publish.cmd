@echo off
setlocal

set VERSION=1.0.5

set OUTPUT=c:\NuGet\

%OUTPUT%nuget.exe push %OUTPUT%Packages\MMaitre.SecureStringCodeGen.%VERSION%.nupkg