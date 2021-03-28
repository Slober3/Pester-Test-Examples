 ## run pester
 $results = ((invoke-pester -Script .\dhcp_wu_test.ps1 -PassThru).testresult | Format-List | Out-String)
 
 
## create event log if not exist
 try {       
		New-EventLog -LogName PesterTest -Source 'PesterTest' -ErrorAction Stop
	 }  
 catch {        
	   }    

 ## write results to log file
 Write-EventLog -LogName PesterTest -EventID 3001 -EntryType Warning -Source 'PesterTest' -Message "$($results)"