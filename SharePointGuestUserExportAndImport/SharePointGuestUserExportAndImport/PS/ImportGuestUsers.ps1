param ($guestsUsersFilePath,$importUserReport)

#$userName=""
#$password=""
#$guestsUsersFilePath=""
#$importUserReport=""
#$guestsUsers ="AllTenantGuestsUsers.csv"
$sMessage="Import external user"
#$importUserReport = "ImportGuestsUsersReport.csv"

function Import-O365GuestsUsers
{   
    param($guestsUsers) 

    $users = Import-csv $guestsUsers
    [array]$O365GuestsUsers = $null
    foreach($user in $users)
    {
     $email = $user.'Mail Address'
     $displayName = $user.'Guest User DisplayName'

     $O365GuestsUsers=New-Object PSObject
     $O365GuestsUsers | Add-Member NoteProperty -Name "Guest User DisplayName" -Value $displayName
     $O365GuestsUsers | Add-Member NoteProperty -Name "Mail Address" -Value $email
     write-output "Start to import $email"

     try
     {
        $guestUser= New-AzureADMSInvitation -InvitedUserEmailAddress $email -InvitedUserDisplayName $displayName  -InviteRedirectUrl https://myapps.microsoft.com -InvitedUserMessageInfo $messageInfo -SendInvitationMessage $false -InvitedUserType guest
        $O365GuestsUsers | Add-Member NoteProperty -Name "Status" -Value 'Successful'
        $O365GuestsUsers | Add-Member NoteProperty -Name "Comment" -Value ''
        write-output "Import $($guestUser.InvitedUserEmailAddress) successfully."
     }
     catch [System.Exception]
     {
        $errorMessage =  $_.Exception.ToString()   
        write-error "Import $email failed, error: $errorMessage"
        $O365GuestsUsers | Add-Member NoteProperty -Name "Status" -Value 'Failed'
        $O365GuestsUsers | Add-Member NoteProperty -Name "Comment" -Value $errorMessage

     }
     $O365AllGuestsUsers+=$O365GuestsUsers  
    }
    $O365AllGuestsUsers | Export-Csv $importUserReport
}


#Connection to Office 365
#$pWord = ConvertTo-SecureString -String $password -AsPlainText -Force
#$O365Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $pWord
#Creating an EXO PowerShell session
write-output "Start to connect AzureAD with $userName"
try
{
    Connect-AzureAD 
    write-output "Connect AzureAD Successfully"
    Import-O365GuestsUsers -guestsUsers $guestsUsersFilePath
}
catch [System.Exception]
{
    $errorMessage =  $_.Exception.ToString()   
    write-error "Connect AzureAD failed, Error: $errorMessage"

}

