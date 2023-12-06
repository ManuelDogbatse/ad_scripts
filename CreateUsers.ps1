# ----- Edit these Variables for your own Use Case ----- #
$passwordStr = Read-Host -Prompt "Enter the password for users"
#$passwordStr   = "Password123!"
$nameList = Get-Content .\names.txt
$cityList = Get-Content .\cities.txt
# ------------------------------------------------------ #
$passwordSecStr = ConvertTo-SecureString $passwordStr -AsPlainText -Force

foreach  ($city in $cityList){
    New-ADOrganizationalUnit -Name $city -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name "Users" -ProtectedFromAccidentalDeletion $false -Path "OU=$($city),$(([ADSI]'').distinguishedName)"
    New-ADOrganizationalUnit -Name "Computers" -ProtectedFromAccidentalDeletion $false -Path "OU=$($city),$(([ADSI]'').distinguishedName)"
}

$textInfo = (Get-Culture).TextInfo
$cnt = 0
$n = $cityList.Count

foreach ($name in $nameList) {
    $fName, $sName = $nameList.Split(" ").ToLower() | ForEach-Object {$textInfo.ToTitleCase($_)}
    $uName = "$($fName.Substring(0,1))$($sName)".ToLower()
    Write-Host "Creating user $($fName) $($sName) ($($uName))" -BackgroundColor Black -ForegroundColor Cyan
    
    New-AdUser -AccountPassword $passwordSecStr `
               -GivenName $fname `
               -Surname $lname `
               -DisplayName "$fname $sname" `
               -Name $username `
               -EmployeeID $username `
               -PasswordNeverExpires $true `
               -Path "OU=Users,OU=$($cityList[$cnt]),$(([ADSI]'').distinguishedName)"
               -Enabled $true
}