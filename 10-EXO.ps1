# Copyright (c) 2023 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


.".\02-Auth.ps1"


Write-Host "認証"
Connect-ExchangeOnline -Credential $credential

Write-Host "組織内の承認済みドメインの構成情報"
Get-AcceptedDomain

Write-Host "組織内の全メールボックス"
Get-Mailbox -ResultSize unlimited

Write-Host "ユーザーのメールボックス"
Get-Mailbox -Identity admin

Write-Host "OU一覧"
Get-OrganizationalUnit -SearchText "onmicrosoft.com" | ForEach-Object {
    Write-Host $_.Name $_.DistinguishedName

    # OU の組織内にある全メールボックスの一覧
    Get-Mailbox -OrganizationalUnit $_.Name

    Write-Host ""
}

Write-Host "自分のメールフォルダ"
Get-MailboxFolder -Identity :\ -GetChildren | Format-Table

Write-Host "受信トレイ フォルダ"
# Get-MailboxFolder -Identity :\Inbox
Get-MailboxFolder -Identity :\受信トレイ | Format-List

Write-Host "予定表フォルダ"
# Get-MailboxCalendarFolder -Identity admin:\Calendar
Get-MailboxCalendarFolder -Identity admin:\予定表

Write-Host "指定したメールボックス内のフォルダーに関する情報"
Get-MailboxFolderStatistics -Identity AdeleV -FolderScope Calendar


Pause
