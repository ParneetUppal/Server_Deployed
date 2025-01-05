param (
    [Parameter(Position=0, Mandatory=$false)]
    [string]$OU1,

    [Parameter(Position=1, Mandatory=$false)]
    [string]$OU2,

    [Parameter(Position=2, Mandatory=$false)]
    [string]$OU3
)

# Function for creating OU, users, and group
function Create-OUUsersGroup {
    param (
        [string]$OUName
    )
    
    $ouPath = "OU=$OUName,DC=uppalproject,DC=com"
    $ouExists = Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $ouPath}
    
    if (-not $ouExists) {
        New-ADOrganizationalUnit -Name $OUName -Path "DC=uppalproject,DC=com" -PassThru
        Write-Host "Created OU: $OUName"
    } else {
        Write-Host "OU $OUName already exists."
    }
        # Create users within the OU
    1..25 | ForEach-Object {
        $userName = "$OUName User $_"
        $userExists = Get-ADUser -Filter {Name -eq $userName}
        
        if (-not $userExists) {
            New-ADUser -Name $userName `
                -UserPrincipalName "$userName@uppalproject.com" `
                -GivenName $userName `
                -Surname "User" `
                -Enabled $true `
                -Path $ouPath `
                -AccountPassword (ConvertTo-SecureString "Password01" -AsPlainText -Force)
            Write-Host "Created user: $userName"
        } else {
            Write-Host "$userName already exists."
        }
    }

    # Create group
    $groupName = "$OUName Group"
    $groupExists = Get-ADGroup -Filter {Name -eq $groupName}
    
    if (-not $groupExists) {
        $group = New-ADGroup -Name $groupName -GroupScope Global -Path $ouPath -PassThru
        $users = Get-ADUser -Filter * -SearchBase $ouPath
        Add-ADGroupMember -Identity $group -Members $users
        Write-Host "Created group: $groupName and added users."
    } else {
        Write-Host "$groupName already exists."
    }
}
# Check for each OU parameter and create OUs, users, and groups
if ($OU1) { Create-OUUsersGroup -OUName $OU1 }
if ($OU2) { Create-OUUsersGroup -OUName $OU2 }
if ($OU3) { Create-OUUsersGroup -OUName $OU3 }

Write-Host "Script execution completed."


