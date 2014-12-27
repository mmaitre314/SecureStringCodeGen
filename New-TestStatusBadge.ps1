<#
.SYNOPSIS
Generates an SVG image reflecting the state of the latest test run for that project
.DESCRIPTION
The script requires two environment variables to be set:
    APPVEYOR_REPO_NAME
    APPVEYOR_API_TOKEN
The first one is set by default by AppVeyor. The second one must be specified as secure
variable via AppVeyor YAML/portal.
The script should be located in the project root folder. The generated file will be 
TestStatusBadge.svg in that same folder.
.EXAMPLE
New-TestStatusBadge
#>

$svgFilename = "TestStatusBadge.svg"

if ($env:APPVEYOR_API_TOKEN -eq $null)
{
    throw "APPVEYOR_API_TOKEN environment variable missing"
}

# Get test results
Write-Host "Getting last build results for $env:APPVEYOR_REPO_NAME"
$headers = @{
  "Authorization" = "Bearer $env:APPVEYOR_API_TOKEN"
  "Content-type" = "application/json"
}
$result = Invoke-RestMethod -Uri ('https://ci.appveyor.com/api/projects/' + $env:APPVEYOR_REPO_NAME) -Headers $headers -Method Get

# Aggregate test results
$passedTestsCount = 0
$failedTestsCount = 0
foreach ($job in $result.build.jobs)
{
    $passedTestsCount += $job.passedTestsCount
    $failedTestsCount += $job.failedTestsCount
}
Write-Host "Test results: $passedTestsCount passed, $failedTestsCount failed"

# Choose SVG text and color based on test results
if ($failedTestsCount -gt 0)
{
    $svgColor = "#FF4242" # Some test failed -> red
    $svgText = "Test failing"
}
elseif ($passedTestsCount -eq 0)
{
    $svgColor = "#FF8000" # No tests passed -> orange
    $svgText = "No test"
}
else
{
    $svgColor = "#42CC42" # All tests passed -> green
    $svgText = "Test passing"
}

# Output SVG
Write-Host "Writing file $svgFilename"
'<svg xmlns="http://www.w3.org/2000/svg" width="102px" height="18px" style="shape-rendering:geometricPrecision; text-rendering:geometricPrecision; image-rendering:optimizeQuality; fill-rule:evenodd; clip-rule:evenodd">' | Out-File $svgFilename
'  <rect fill="' + $svgColor + '" width="102px" height="18" rx="2" ry="2"/>' | Out-File $svgFilename -Append
'  <g transform="scale(0.045)">' | Out-File $svgFilename -Append
'    <path fill="#fff" d="M242 48c86,0 155,69 155,154 0,86 -69,155 -155,155 -85,0 -154,-69 -154,-155 0,-85 69,-154 154,-154zm38 184c-17,22 -48,26 -69,9 -21,-16 -24,-47 -7,-69 18,-21 49,-25 70,-9 21,17 24,48 6,69zm-82 101l59 -57c-22,5 -45,1 -63,-14 -21,-16 -30,-43 -27,-68l-53 58c0,0 -7,-13 -9,-37l93 -73c28,-20 66,-21 93,0 30,24 36,68 14,101l-68 97c-10,0 -30,-3 -39,-7z"/>' | Out-File $svgFilename -Append
'  </g>' | Out-File $svgFilename -Append
'  <text x="22" y="13" fill="#fff" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="11px">' + $svgText + '</text>' | Out-File $svgFilename -Append
'</svg>' | Out-File $svgFilename -Append
