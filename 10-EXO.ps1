# Copyright (c) 2023 YA-androidapp(https://github.com/YA-androidapp) All rights reserved.


.".\02-Auth.ps1"


Write-Host "認証"
Connect-ExchangeOnline -Credential $credential

Write-Host "組織内の承認済みドメインの構成情報"
Get-AcceptedDomain


Write-Host "組織内の既存のユーザーオブジェクト（ユーザー アカウントを持つすべてのオブジェクト (ユーザー メールボックス、メール ユーザー、ユーザー アカウントなど) ）"
Get-User -ResultSize unlimited

Write-Host "特定のユーザーの詳細情報"
Get-User -Identity "Admin" | Format-List

Write-Host "ユーザーのCommonName (CN), DisplayName, FirstName, LastName, Aliasを対象にしたあいまい検索"
Get-User -Anr "Adel" | Format-List

Write-Host "OU内の既存のユーザーオブジェクト"
Get-User -OrganizationalUnit "contoso.onmicrosoft.com"


Write-Host "組織内の既存の受信者オブジェクト（メールが有効なすべてのオブジェクト (メールボックス、メール ユーザー、メール連絡先、配布グループなど)）"
Get-Recipient -ResultSize unlimited

Write-Host "Adminという名前の受信者の詳細情報"
Get-Recipient -Identity "Admin" | Format-List

Write-Host "ユーザーのCommonName (CN), DisplayName, FirstName, LastName, Aliasを対象にしたあいまい検索"
Get-Recipient -Anr "Adel" | Format-List

Write-Host "受信者タイプ・受信者サブタイプでフィルタリング"
Get-Recipient -RecipientType MailUniversalDistributionGroup, UserMailbox -RecipientTypeDetails RoomMailbox, UserMailbox | Format-Table Name, RecipientType, RecipientTypeDetails
# -RecipientType
#   DynamicDistributionGroup
#   MailContact
#   MailNonUniversalGroup
#   MailUniversalDistributionGroup
#   MailUniversalSecurityGroup
#   MailUser
#   PublicFolder
#   UserMailbox

# -RecipientTypeDetails
#   DiscoveryMailbox
#   DynamicDistributionGroup
#   EquipmentMailbox
#   GroupMailbox
#   GuestMailUser
#   LegacyMailbox
#   LinkedMailbox
#   LinkedRoomMailbox
#   MailContact
#   MailForestContact
#   MailNonUniversalGroup
#   MailUniversalDistributionGroup
#   MailUniversalSecurityGroup
#   MailUser
#   PublicFolder
#   PublicFolderMailbox
#   RemoteEquipmentMailbox
#   RemoteRoomMailbox
#   RemoteSharedMailbox
#   RemoteTeamMailbox
#   RemoteUserMailbox
#   RoomList
#   RoomMailbox
#   SchedulingMailbox
#   SharedMailbox
#   SharedWithMailUser
#   TeamMailbox
#   UserMailbox


Write-Host "メール ユーザーと、クラウド環境でのMicrosoft 365 グループのゲスト ユーザーを表示"
Write-Host "組織内のすべてのメール ユーザーの要約リスト"
Get-MailUser

Write-Host "メール ユーザーのCommonName (CN), DisplayName, FirstName, LastName, Aliasを対象にしたあいまい検索"
Get-MailUser -Anr "user"


Write-Host "組織内の既存のグループ オブジェクト（セキュリティ グループ、メールが有効なセキュリティ グループ、配布グループ、および役割グループ）"
Write-Host "組織内のすべてのグループの要約リスト"
Get-Group

Write-Host "会議室一覧という名前のグループの詳細情報"
Get-Group -Identity 会議室一覧 | Format-List

Write-Host "グループのCommonName (CN), DisplayName, FirstName, LastName, Aliasを対象にしたあいまい検索"
Get-Group -Anr Security


Write-Host "クラウドベースの組織のMicrosoft 365 グループを表示"
Write-Host "すべてのMicrosoft 365 グループの概要リスト"
Get-UnifiedGroup
Get-UnifiedGroup | Format-List

Write-Host "All Company という名前のMicrosoft 365 グループに関する詳細情報"
Get-UnifiedGroup -Identity "All Company" | Format-List

Write-Host "所有者がいないMicrosoft 365 グループ"
Get-UnifiedGroup | Where-Object { -Not $_.ManagedBy }

Write-Host "Microsoft チームの作成時に作成された Microsoft 365 グループを返す"
Get-UnifiedGroup -Filter { ResourceProvisioningOptions -eq "Team" }

Write-Host "メンバー一覧"
Get-UnifiedGroup | ForEach-Object {
    $_.PrimarySmtpAddress
    Get-UnifiedGroupLinks -Identity $_.PrimarySmtpAddress -LinkType Members | FT
    # -Identity ... 表示するMicrosoft 365 グループを指定
    #   Name
    #   Alias
    #   Distinguished name (DN)
    #   Canonical DN
    #   Email address
    #   GUID
    # -LinkType
    #   Members
    #   Owners
    #   Subscribers
}


Write-Host "既存の配布グループ、またはメールが有効なセキュリティ グループ"
Write-Host "組織内のすべての配布グループとメールが有効なセキュリティ グループの要約リスト"
Get-DistributionGroup

Write-Host "会議室一覧という名前の配布グループに関する詳細情報"
Get-DistributionGroup -Identity "会議室一覧" | Format-List

Write-Host "配布グループのCommonName (CN), DisplayName, FirstName, LastName, Aliasを対象にしたあいまい検索"
Get-DistributionGroup -Anr 会議室 | Format-Table Name, ManagedBy -Auto

Write-Host "メンバー一覧"
Get-DistributionGroupMember -Identity "会議室一覧"


Write-Host "既存の動的配布グループ"
Write-Host "組織内のすべての動的配布グループの要約リスト"
Get-DynamicDistributionGroup

Write-Host "Marketing という名前の動的配布グループに関する詳細情報"
Get-DynamicDistributionGroup -Identity "Marketing" | Format-List

Write-Host "名前に文字列 research が含まれるすべての動的配布グループ"
Get-DynamicDistributionGroup -Anr *research* | Format-Table Name, ManagedBy -Auto

Write-Host "Marketing という名前の動的配布グループの既存のメンバー（コマンドレットの結果は、24 時間ごとに更新される）"
Get-DynamicDistributionGroupMember -Identity "Marketing"

Write-Host "Marketing という名前の動的配布グループのメンバー"
$DDG = Get-DynamicDistributionGroup "Marketing"
Get-Recipient -RecipientPreviewFilter $DDG.RecipientFilter -OrganizationalUnit $DDG.RecipientContainer


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
