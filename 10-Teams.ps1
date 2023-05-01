# Copyright (c) 2023 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


.".\02-Auth.ps1"


Write-Host "認証"
Connect-MicrosoftTeams -Credential $credential

Write-Host "ユーザーに関連付けられたチームの一覧"
Get-AssociatedTeam

# Get-AssociatedTeam | Get-Member
#     TypeName: Microsoft.Teams.PowerShell.TeamsCmdlets.Model.TeamInfo
#     Name        MemberType Definition
#     ----        ---------- ----------
#     Equals      Method     bool Equals(System.Object obj)
#     GetHashCode Method     int GetHashCode()
#     GetType     Method     type GetType()
#     ToString    Method     string ToString()
#     DisplayName Property   string DisplayName { get; set; }
#     GroupId     Property   string GroupId { get; set; }
#     TenantId    Property   string TenantId { get; set; }

Write-Host "各チームのメンバー一覧"
Get-AssociatedTeam | ForEach-Object { Get-TeamUser -GroupId $_.GroupId }

Write-Host "各チームのチャネル一覧"
Get-AssociatedTeam | ForEach-Object { Get-TeamChannel -GroupId $_.GroupId }

Get-AssociatedTeam | ForEach-Object {
    $groupId = $_.GroupId

    Write-Host $_.DisplayName " " $groupId

    Get-TeamChannel -GroupId $groupId | ForEach-Object {
        Write-Host $_.DisplayName

        Get-TeamChannelUser -GroupId $groupId -DisplayName $_.DisplayName | FT
    }
}


Pause
