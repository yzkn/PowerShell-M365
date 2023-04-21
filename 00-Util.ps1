function Get-Config {
    $Path = "settings.ini"

    $Config = @{}
    Get-Content $Path | ForEach-Object { $Config += ConvertFrom-StringData $_ }

    return $Config
}
