Param(
    [parameter(Mandatory=$true)]
    [alias("nwlogin")]
    $login,
    [alias("nwpassword")]
    $password,
    [alias("nwresultfilepath")]
    $ResultFilePath = "c:\result.csv",
    [alias("nwtimeout")]
    $timeout = 100000)

function Output-String($outPutString)
{
	echo $outPutString;
}

[IO.Directory]::SetCurrentDirectory((Convert-Path (Get-Location -PSProvider FileSystem)))

# accept SSL Certificates if this is an SSL call
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

$siteHashTable = @{};
# build the credential object
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($login,$secpasswd);

if(Test-Path($ResultFilePath))
{
	Remove-Item $ResultFilePath
}

"WorkflowName,SiteUrl,Type,ListName,Actions"| Out-File -FilePath $ResultFilePath -Append -Encoding utf8

# check if we are in the same location as the nwadmin.exe
if(Test-Path(".\nwadmin.exe"))
{ 
  # find all the workflows and store them in a variable
  $foundworkflows = .\nwadmin -o FindWorkflows

  foreach($line in $foundworkflows)
  {
  
    if($line.StartsWith("Active at "))
    {
      $site = $line.Replace("Active at ","");
    }
    if($line.StartsWith("-- "))
    { 
      # get the list name
      $list = $line.Replace("-- ","");
    }
    if($line.StartsWith("---- "))
    {
	  $type="";
      $listName="";
      try
      {
        # get the workflow name
        $workflowname = $line.Replace("---- ","");
        $webserviceurl = $site + "/_vti_bin/NintexWorkflow/Workflow.asmx"
        $knownSite = $siteHashTable.ContainsKey($webserviceurl);
        if($knownSite -eq $true)
        {
          # echo 'This is a known site';
          $page = $siteHashTable.Get_Item($webserviceurl);
        }
        else
        {
          # get web service proxy
          $page = New-WebServiceProxy -Uri $webserviceurl -Credential $credential;
          $page.Url = $webserviceurl;
          $page.Timeout = $timeout;
          # ($page | Get-Member -Name ExportWorkflow).definition;
  
          # echo 'Adding site to hash table';
          $siteHashTable.Add($webserviceurl,$page);
        }

		Output-String("Start export " + $workflowname)
        # export workflow
        if($list -eq "Site Workflow")
           {
           $exportedworkflow = $page.ExportWorkflow($workflowname,$list,'Site');
           $type="Site Workflow";
           }
          elseif($list -eq "Reusable workflow template")
           {
           $exportedworkflow = $page.ExportWorkflow($workflowname,$list,'Reusable');
           $type="Reusable workflow template";
           }
          elseif($list -eq "Site collection reusable workflow template")
           {
           $exportedworkflow = $page.ExportWorkflow($workflowname,$list,'GloballyReusable');
           $type="Site collection reusable workflow template";
           }
          else
           {
           $exportedworkflow = $page.ExportWorkflow($workflowname,$list,'List');
           $type="List";
		   $listName=$list;
           }
		   
		  Output-String("Start analysis " +$workflowname)
              $actions = [regex]::matches($exportedworkflow, "(?<=TLabel&gt;)[\w ]+(?=&lt;/TLabel)");
              $hashtableActions = @{};  
			  $actionsNames =$null;
              # iterate through each action found
              foreach($action in $actions)
              {
                if($hashtableActions.ContainsKey($action.Value))
                {
                  $hashtableActions.Set_Item($action.Value,$hashtableActions.Get_Item($action.Value) + 1);
                }
                else
                {
				if($actionsNames -eq $null)
				{
				$actionsNames= $action.Value;
				}
				else
				{
				$actionsNames= $actionsNames+","+$action.Value;
				}
                  $hashtableActions.Add($action.Value,1);
                }
              }
			  $actionsNames= """"+$actionsNames+""""
			  
			  $workflowLine = """"+$workflowname+""""+","+$site+","+$type+","+$listName+","+$actionsNames
			  $workflowLine| Out-File -FilePath $ResultFilePath -Append -Encoding utf8
			  
			  Output-String("Analysis " +$workflowname +" complete!")
      }
      catch
      {
        $message = "Site - {0}" -f $webserviceurl;
        Output-String($message);
        $message = "List - {0}" -f $list
        Output-String($message);
        $message = "Workflow - {0}" -f $workflowname
        Output-String($message);
        if ($_.Exception.InnerException) {
          Output-String($_.Exception.InnerException.message);
        }
        Write-Error ("Error - " + $_);
        $exportedworkflow = "";
      }
    }
  }
  Output-String("The job over.")
}
else
{
  Output-String("NWAdmin doesn't exist.  Change directory to where NWAdmin.exe lives.");
}
