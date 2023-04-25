# Copyright (c) 2023 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


function Get-Config {
    $Path = "settings.ini"

    $Config = @{}
    Get-Content $Path | ForEach-Object { $Config += ConvertFrom-StringData $_ }

    return $Config
}
