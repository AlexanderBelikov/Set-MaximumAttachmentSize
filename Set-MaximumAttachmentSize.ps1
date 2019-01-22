param(
    [parameter(Mandatory=$true)]
    [ValidateRange(10MB,100MB)]
    [int] $Size
)

#====================================================================================================
#   Main
$ErrorActionPreference = "Stop";
Write-Host $Size
$SizeBytes = "$Size";
$SizeKB = "$($Size/1KB)";

$BackUpNamePostfix = ".$(Get-Date -Format "yyyy_MM_dd_hh_mm_ss").bak";

Get-ExchangeServer | %{
    $ServerName = $_.Name;
    $RootFolderPath = "\\$ServerName\c$\Program Files\Microsoft\Exchange Server\V15";
    Write-Host $ServerName;

    #----------------------------------------------------------------------------------------------------   
    #ActiveSync
    Write-Host "ActiveSync" -ForegroundColor Yellow;

    Write-Host "\FrontEnd\HttpProxy\sync\web.config";
    $ConfigFilePath = "$RootFolderPath\FrontEnd\HttpProxy\sync\web.config";
    $ConfigBakFilePath = $ConfigFilePath+$BackUpNamePostfix;

    Copy-Item $ConfigFilePath -Destination "$ConfigBakFilePath";
    $Doc = [xml](Get-Content $ConfigFilePath);
    $Doc.SelectSingleNode("/configuration/system.web/httpRuntime[@maxRequestLength]").maxRequestLength = $SizeKB;
    $Doc.Save($ConfigFilePath);

    #--------------------------------------------------------
    Write-Host "\ClientAccess\Sync\web.config";
    $ConfigFilePath = "$RootFolderPath\ClientAccess\Sync\web.config";
    $ConfigBakFilePath = $ConfigFilePath+$BackUpNamePostfix;
    Copy-Item $ConfigFilePath -Destination "$ConfigBakFilePath";
    $Doc = [xml](Get-Content $ConfigFilePath);
    $Doc.SelectSingleNode("/configuration/appSettings/add[@key='MaxDocumentDataSize']").value = $SizeBytes;
    $Doc.SelectSingleNode("/configuration/system.web/httpRuntime[@maxRequestLength]").maxRequestLength = $SizeKB;
    $Doc.Save($ConfigFilePath);

    #ActiveSync
    #----------------------------------------------------------------------------------------------------
    #OWA
    Write-Host "OWA" -ForegroundColor Yellow;

    Write-Host "\FrontEnd\HttpProxy\Owa\web.config";
    $ConfigFilePath = "$RootFolderPath\FrontEnd\HttpProxy\Owa\web.config";
    $ConfigBakFilePath = $ConfigFilePath+$BackUpNamePostfix;

    Copy-Item $ConfigFilePath -Destination "$ConfigBakFilePath";
    $Doc = [xml](Get-Content $ConfigFilePath);
    $Doc.SelectSingleNode("/configuration/location/system.webServer/security/requestFiltering/requestLimits[@maxAllowedContentLength]").maxAllowedContentLength = $SizeBytes;
    $Doc.SelectSingleNode("/configuration/location/system.web/httpRuntime[@maxRequestLength]").maxRequestLength = $SizeKB;
    $Doc.Save($ConfigFilePath);

    #--------------------------------------------------------
    Write-Host "\ClientAccess\Owa\web.config";
    $ConfigFilePath = "$RootFolderPath\ClientAccess\Owa\web.config";
    $ConfigBakFilePath = $ConfigFilePath+$BackUpNamePostfix;

    Copy-Item $ConfigFilePath -Destination "$ConfigBakFilePath";
    $Doc = [xml](Get-Content $ConfigFilePath);
    $Doc.SelectSingleNode("/configuration/location/system.webServer/security/requestFiltering/requestLimits[@maxAllowedContentLength]").maxAllowedContentLength = $SizeBytes;
    $Doc.SelectSingleNode("/configuration/location/system.web/httpRuntime[@maxRequestLength]").maxRequestLength = $SizeKB;
    $Doc.SelectSingleNode("/configuration/system.serviceModel/bindings/webHttpBinding/binding[@name='httpsBinding']").maxReceivedMessageSize = $SizeBytes;
    $Doc.SelectSingleNode("/configuration/system.serviceModel/bindings/webHttpBinding/binding[@name='httpBinding']").maxReceivedMessageSize = $SizeBytes;
    $Doc.SelectSingleNode("/configuration/system.serviceModel/bindings/webHttpBinding/binding[@name='httpsBinding']/readerQuotas[@maxStringContentLength]").maxStringContentLength = $SizeBytes;
    $Doc.SelectSingleNode("/configuration/system.serviceModel/bindings/webHttpBinding/binding[@name='httpBinding']/readerQuotas[@maxStringContentLength]").maxStringContentLength = $SizeBytes;
    $Doc.Save($ConfigFilePath);

    #ActiveSync
    #----------------------------------------------------------------------------------------------------
}


