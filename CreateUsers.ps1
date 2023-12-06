# Get template password for all users
$passwordStr = Read-Host -Prompt "Enter the password for users"
#$passwordStr   = "Password123!"
# Read names and cities TXT files
$nameList = Get-Content .\names.txt
$cityList = Get-Content .\cities.txt

# Convert password string to secure string for AD user creation
$passwordSecStr = ConvertTo-SecureString $passwordStr -AsPlainText -Force

# Create an OU for each city, with 'Users' and 'Computers' sub-OUs
foreach  ($city in $cityList){
    New-ADOrganizationalUnit -Name $city -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name "Users" -ProtectedFromAccidentalDeletion $false -Path "OU=$($city),$(([ADSI]'').distinguishedName)"
    New-ADOrganizationalUnit -Name "Computers" -ProtectedFromAccidentalDeletion $false -Path "OU=$($city),$(([ADSI]'').distinguishedName)"
}

# 'textInfo' for converting names to title case
$textInfo = (Get-Culture).TextInfo
$cnt = 0
$n = $cityList.Count

# Create each user in names TXT file
foreach ($name in $nameList) {
    # Split line into forename and surname, and change to title case
    $fName, $sName = $nameList.Split(" ") | ForEach-Object {$textInfo.ToTitleCase($_)}
    $uName = "$($fName.Substring(0,1))$($sName)".ToLower()
    Write-Host "Creating user $($fName) $($sName) ($($uName))" -BackgroundColor Black -ForegroundColor Cyan
    
    # Create new user
    New-AdUser -AccountPassword $passwordSecStr `
               -GivenName $fname `
               -Surname $lname `
               -DisplayName "$fname $sname" `
               -Name $username `
               -EmployeeID $username `
               -PasswordNeverExpires $true `
               # Add users to one of the cities, cycles through each city every time a user is created
               # 'ADSI' accesses the domain name of the domain for user creation
               -Path "OU=Users,OU=$($cityList[$cnt]),$(([ADSI]'').distinguishedName)"
               -Enabled $true
}