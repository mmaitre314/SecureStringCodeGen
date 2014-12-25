<#
.SYNOPSIS
Generates a C# settings class from XML values and environment variables
.DESCRIPTION  
Enables sensitive settings to be stored in a C# class whose code is not checked in.
A first XML file contains settings declarations and any non-sensitive values.
This file is checked in. A second XML file contains sensitive settings to be used
during local builds. This file is not checked in and added to source-control ignore lists.
On CI build servers the same values are read from environment variables.
.EXAMPLE
New-SettingsClass -input GlobalSettings.stx -output GlobalSettings.g.cs -namespace App1 -class GlobalSettings
#>

param([String]$inputPath, [String]$outputPath, [String]$namespace, [String]$class)

function Update-Settings([ref]$settingsRef, $overrideSettings)
{
    $settings = $settingsRef.value
    $key = $settings.key
    
    # Replace value with environment variable if present
    if (Test-Path env:$key)
    {
        $settings.SetAttribute("value", (Get-Item env:$key).Value)
    }
    
    # Replace value with override value if present
    if ($overrideSettings -ne $null)
    {
        if (($overrideSettings.Count -eq $null) -and ($overrideSettings.key -eq $key))
        {
            $settings.SetAttribute("value", $overrideSettings.value)
        }
        else
        {
            $index = $overrideSettings.key.IndexOf($key)
            if ($index -ge 0)
            {
                $settings.SetAttribute("value", $overrideSettings[$index].value)
            }
        }
    }
    
    # Verify value present
    if ($settings.value -eq $null)
    {
        throw "Could not find a value for setting $key"
    }    
}

# Load XML settings template
$template = [xml](Get-Content $inputPath)
$settings = $template.settings.set

# Load optional XML settings override
$overrideSettings = $null
if (($template.settings.override -ne $null) -and (Test-Path $template.settings.override))
{
    $override = [xml](Get-Content $template.settings.override)
    $overrideSettings = $override.settings.set
}

# Apply override values and environment variables
if ($settings.Count -eq $null)
{
    Update-Settings ([ref]$settings) $overrideSettings
}
else
{
    for ($i = 0; $i -lt $settings.Count; $i++)
    {
        Update-Settings ([ref]$settings[$i]) $overrideSettings
    }
}

# Generate C# settings file
'using System;' | Out-File $outputPath
'' | Out-File $outputPath -Append
('namespace ' + $namespace) | Out-File $outputPath -Append
'{' | Out-File $outputPath -Append
('    internal static class ' + $class) | Out-File $outputPath -Append
'    {' | Out-File $outputPath -Append
if ($settings.Count -eq $null)
{
    ('        public const String ' + $settings.key + ' = "' + $settings.value + '";') | Out-File $outputPath -Append
}
else
{
    for ($i = 0; $i -lt $settings.Count; $i++)
    {
        ('        public const String ' + $settings[$i].key + ' = "' + $settings[$i].value + '";') | Out-File $outputPath -Append
    }
}
'    }' | Out-File $outputPath -Append
'}' | Out-File $outputPath -Append
