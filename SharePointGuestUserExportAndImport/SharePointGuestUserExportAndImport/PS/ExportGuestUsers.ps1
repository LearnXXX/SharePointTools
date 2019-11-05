param ($exportReportFilePath)

#$userName="aosiptest@longgod.onmicrosoft.com"
#$password="demo12!@"
#$exportReportFilePath="C:\Users\xluo\Desktop\AllTenantGuestsUsers.csv"
$sMessage="Export guest users"
#$exportReportFilePath="C:\Users\xluo\Desktop\AllTenantGuestsUsers.csv"


function Get-O365GuestsUsersThroughAzureAD
{   
    param($sCSVFileName) 
    Try
    {   
        [array]$O365GuestsUsers = $null
        $O365TenantGuestsUsers=Get-AzureADUser  -All $true -Filter "Usertype eq 'Guest'”
        write-output "there are $($O365TenantGuestsUsers.Count) guest users"
        $index = 1
        foreach ($O365GuestUser in $O365TenantGuestsUsers) 
        { 
            write-output "start to export $($O365GuestUser.Mail), index: $index"
            $O365GuestsUsers=New-Object PSObject
            $O365GuestsUsers | Add-Member NoteProperty -Name "Guest User DisplayName" -Value $O365GuestUser.DisplayName
            $O365GuestsUsers | Add-Member NoteProperty -Name "User Principal Name" -Value $O365GuestUser.UserPrincipalName
            $O365GuestsUsers | Add-Member NoteProperty -Name "Mail Address" -Value $O365GuestUser.Mail
            $O365AllGuestsUsers+=$O365GuestsUsers  
            write-output "export $($O365GuestUser.Mail) finish"
            $index++
        } 
        $O365AllGuestsUsers | Export-Csv $sCSVFileName
    }
    catch [System.Exception]
    {
        Write-output -ForegroundColor Red $($_.Exception).ToString()   
    } 
}


#$pWord = ConvertTo-SecureString -String $password -AsPlainText -Force
#$O365Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName, $pWord
write-output "Start to connect AzureAD"
#Creating an EXO PowerShell session
try
{
    Connect-AzureAD 
    write-output "Connect AzureAD Successfully"

    #Getting Tenant Guests Users

    Get-O365GuestsUsersThroughAzureAD -sCSVFileName $exportReportFilePath
}
catch [System.Exception]
{
    $errorMessage =  $_.Exception.ToString()   
    write-error "Connect AzureAD failed, Error: $errorMessage"
}

