<#
.SYNOPSIS
Active Directory Computer Hygiene Report (Inactive / Never Logged On / Stale Password / Legacy OS signals)
#>

[CmdletBinding()]
param(
    [int]    $InactiveDays = 90,
    [int]    $PasswordStaleDays = 180,
    [string] $SearchBase,
    [switch] $IncludeDisabled,
    [switch] $ExportCsv,
    [string] $ExportPath = ("ad_computer_hygiene_{0}.csv" -f (Get-Date -Format "yyyyMMdd_HHmmss"))
)

$ErrorActionPreference = "Stop"

function Ensure-ADModule {
    if (-not (Get-Module -ListAvailable -Name ActiveDirectory)) {
        throw "ActiveDirectory module not found. Install RSAT (RSAT-AD-PowerShell) or run on a Domain Controller."
    }
    Import-Module ActiveDirectory -ErrorAction Stop
}

function Get-BuildNumberFromOSVersion([string]$osVersion) {
    if ([string]::IsNullOrWhiteSpace($osVersion)) { return $null }
    # AD'de çoğu zaman: "10.0 (19045)" veya "10.0.19045" gibi gelir.
    $m = [regex]::Match($osVersion, '(?<build>\d{5})')
    if ($m.Success) { return [int]$m.Groups['build'].Value }
    return $null
}

try {
    Ensure-ADModule

    if ($InactiveDays -lt 1) { throw "InactiveDays must be >= 1." }
    if ($PasswordStaleDays -lt 1) { throw "PasswordStaleDays must be >= 1." }

    $cutoffLogon = (Get-Date).AddDays(-$InactiveDays)
    $cutoffPwd   = (Get-Date).AddDays(-$PasswordStaleDays)

    $props = @(
        "Name","DNSHostName","Enabled",
        "OperatingSystem","OperatingSystemVersion",
        "LastLogonDate","PasswordLastSet",
        "DistinguishedName","whenCreated"
    )

    # Basit tut: AD filter string olmalı.
    $params = @{
        Filter      = "Name -like '*'"
        Properties  = $props
        ErrorAction = "Stop"
    }
    if ($SearchBase) { $params.SearchBase = $SearchBase }

    $computers = Get-ADComputer @params

    if (-not $IncludeDisabled) {
        $computers = $computers | Where-Object { $_.Enabled -eq $true }
    }

    $now = Get-Date

    $report = $computers | ForEach-Object {
        $os    = $_.OperatingSystem
        $osVer = $_.OperatingSystemVersion
        $build = Get-BuildNumberFromOSVersion $osVer

        $neverLoggedOn = ($null -eq $_.LastLogonDate)
        $inactive      = (-not $neverLoggedOn) -and ($_.LastLogonDate -lt $cutoffLogon)

        $pwdNeverSet   = ($null -eq $_.PasswordLastSet)
        $pwdStale      = (-not $pwdNeverSet) -and ($_.PasswordLastSet -lt $cutoffPwd)

        # Basit legacy OS flag
        $legacyOS = $false
        if ($os -match "Windows 7|Windows 8") { $legacyOS = $true }

        # Basit risk etiketi
        $risk = "Low"
        if ($legacyOS -or $inactive -or $neverLoggedOn -or $pwdStale) { $risk = "Medium" }
        if ($legacyOS -and ($inactive -or $neverLoggedOn)) { $risk = "High" }

        [PSCustomObject]@{
            Name              = $_.Name
            DNSHostName       = $_.DNSHostName
            Enabled           = $_.Enabled

            OperatingSystem   = $os
            OSVersionRaw      = $osVer
            BuildNumber       = $build

            LastLogonDate     = $_.LastLogonDate
            NeverLoggedOn     = $neverLoggedOn
            Inactive          = $inactive
            InactiveDays      = if ($neverLoggedOn -or -not $_.LastLogonDate) { $null } else { [int](($now - $_.LastLogonDate).TotalDays) }

            PasswordLastSet   = $_.PasswordLastSet
            PasswordNeverSet  = $pwdNeverSet
            PasswordStale     = $pwdStale

            WhenCreated       = $_.whenCreated
            DistinguishedName = $_.DistinguishedName

            LegacyOS          = $legacyOS
            RiskLevel         = $risk
        }
    }

    # Varsayılan çıktı: sadece aksiyon gerektirenler (yani riskli grup)
    $actionable = $report |
        Where-Object { $_.Inactive -or $_.NeverLoggedOn -or $_.PasswordStale -or $_.LegacyOS } |
        Sort-Object `
            @{Expression = 'RiskLevel';   Descending = $true},
            @{Expression = 'InactiveDays';Descending = $true},
            @{Expression = 'Name';        Descending = $false}

    if (-not $actionable -or $actionable.Count -eq 0) {
        Write-Host "No actionable records found for the given thresholds." -ForegroundColor Green
        exit 0
    }

    $actionable | Format-Table Name, RiskLevel, Inactive, NeverLoggedOn, PasswordStale, LegacyOS, LastLogonDate -AutoSize -Wrap

    Write-Host ""
    Write-Host "Summary:"
    Write-Host ("- Total actionable: {0}" -f $actionable.Count)

    $actionable | Group-Object RiskLevel | Sort-Object Name | ForEach-Object {
        Write-Host ("- {0}: {1}" -f $_.Name, $_.Count)
    }

    if ($ExportCsv) {
        $actionable | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
        Write-Host ("CSV exported: {0}" -f $ExportPath) -ForegroundColor Cyan
    }

    exit 0
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
