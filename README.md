[![Build status](https://ci.appveyor.com/api/projects/status/s08qgb4egku0pa3d?svg=true)](https://ci.appveyor.com/project/mmaitre314/securestringcodegen)

Secure-String Code Generator
===

The client-side equivalent of Azure's web.config/app.config setting override. It avoids leaking confidential information like API keys and connection strings in open-source code repositories.

On the server side
---

On the server side there is already [an](http://azure.microsoft.com/blog/2013/07/17/windows-azure-web-sites-how-application-strings-and-connection-strings-work/) [effective](http://www.asp.net/identity/overview/features-api/best-practices-for-deploying-passwords-and-other-sensitive-data-to-aspnet-and-azure) [solution](http://typecastexception.com/post/2014/04/06/ASPNET-MVC-Keep-Private-Settings-Out-of-Source-Control.aspx) to avoid checking in sensitive strings: Azure overrides settings in app.config and web.config files with values specified in the Azure portal. 

(AzureSettings.png)

So a config file can be checked in with connection strings pointing to a local test server for initial testing:
       
```xml
<configuration>
  <connectionStrings>
    <add name="AzureWebJobsStorage" connectionString="UseDevelopmentStorage=true;DevelopmentStorageProxyUri=http://127.0.0.1;" />
  </connectionStrings>
  <appSettings>
    <add key="MS_MicrosoftClientID" value="Overridden by portal settings" />
    <add key="MS_MicrosoftClientSecret" value="Overridden by portal settings" />
  </appSettings>
</configuration>
```

Later on during publication to the cloud those strings get replaced by new ones pointing to production servers:

```xml
<configuration>
  <connectionStrings>
    <add name="AzureWebJobsStorage" connectionString="DefaultEndpointsProtocol=https;AccountName=someaccountname;AccountKey=somelongstring" />
  </connectionStrings>
  <appSettings>
    <add key="MS_MicrosoftClientID" value="0000000012345678" />
    <add key="MS_MicrosoftClientSecret" value="anotherlongstring" />
  </appSettings>
</configuration>
```

On the client side
---

Things don't work so well on the client side, especially for Universal Windows/Windows Phone Store apps which do not even support app.config files.

The AppVeyor CI build server provides the first half of a solution: like Azure, sensitive strings can be [specified](http://www.appveyor.com/docs/build-configuration#secure-variables) in its portal.

(AppVeyorSettings.png)

They can also be provided as encrypted strings in checked-in YAML config files:

```yaml
environment:
  Property2:
    secure: F175Fzw/JJX3Kfc2gOkyCQr3ObuViwce+k3qOQQDd2Q=
  Property3:
    secure: 0jMqSEZxjEdWE2qLPcuR2SznHEZhbtB7heqbN/eIh3M=
```

The build server then sets those values as environment variables during the build process. 

What is missing is something which takes those environment variables and makes them available to app code during compilation. This is what this project is about.

Secure-string code generation
---

To get started, install the [MMaitre.SecureStringCodeGen](https://www.nuget.org/packages/MMaitre.SecureStringCodeGen/) NuGet package, add a couple of XML files to the VS project as decribed below, and build. The NuGet package adds an MSBuild target to the Visual Studio project which generates C# code during the build process. 

Following Azure's model, settings are split into two XML files, one which is checked in and one which is not. The one checked in (with .stx extension, as in "Settings Template XML") contains a list of keys, along with an optional set of non-sensitive values.

```xml
<settings override="GlobalSettings.sox" >
  <set key="Property1" value="value1"/>
  <set key="Property2" />
</settings>
```

The one kept out of source control (with .sox extension, as in "Settings Override XML") contains sensitive strings to be used during dev builds on local machines.

```xml
<settings>
  <set key="Property1" value="valueA"/>
  <set key="Property2" value="valueB"/>
</settings>
```

Those sensitive strings are also provided to AppVeyor via portal/YAML.

During the build, the XML files and environment variables are transformed into C# classes which the app can use just like regular code:

```c#
internal static class GlobalSettings
{
    public const String Property1 = "valueA";
    public const String Property2 = "valueB";
}
```

The names of the classes match the names of the .stx files.

There are a couple of caveats in that process worth mentioning:

1. C# classes are generated during the build process and changes to the .stx/.sox config files and to registry keys are not immediately reflected in Intellisense.
2. Strings are not obfuscated in binaries, so attackers can recover them via decompilation or even Notepad. This project only avoids storing those strings in source control.
