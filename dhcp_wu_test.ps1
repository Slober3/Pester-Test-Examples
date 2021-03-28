$networkinf = (Get-NetIPConfiguration -InterfaceAlias ethernet)

## DHCP service
describe 'The DHCP service' {

    $status = (Get-Service -Name 'DHCP').Status
	
    it 'should be running' {
        $status | should Be 'Running'

    }
}

## Windows update service
describe 'The windows update service' {

    $status = (Get-Service -Name 'wuauserv').Status

    it 'should be running' {
        $status | should Be 'Running'

    }
}


## check multiple services

    $Services = @(
        'DNSCache','Eventlog','MpsSvc'
    )
describe 'Multiple Services check' {
    context 'Service Availability' {
        $Services | ForEach-Object {
            it "[$_] should be running" {
                (Get-Service $_).Status | Should Be running
            }
        }
    }
}

## Check if software is installed
    $Services = @(
        'python','java','firefox','Amazing Superman 3000', 'blender'
    )
describe 'Multiple Installation check' {
    context 'check if the programs are installed' {
        $Services | ForEach-Object {
            it "[$_] should be installed" {
                ((gp HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName -Match $_).Length -gt 0 | Should Be $true
            }
        }
    }
}


## Check if a specific process is running
Describe  'Process checks' {
        It 'winlogon.exe is running' {
            get-process -Name 'winlogon' | Should be $true
        }
}


## check if a specific file exists
describe 'The hello_world.txt exists' {

    $status = (Test-Path C:\Users\quint\hello_world.txt)

    it 'should be true' {
        $status | should Be 'true'

    }
}



##  tests LoopBack adapter
Describe 'LoopBack' {
	
	$status = (Test-Connection -ComputerName 127.0.0.1 -Quiet -Count 1)

	
	It 'Loopback should be available' {
        $status | should Be $true
		
	}

}


##  tests localNIC 
Describe 'Testing default gateway connection' {
	
	$status = (Test-Connection -ComputerName $networkinf.IPv4Address.IPAddress -Quiet -Count 1)

	
	It 'Default gateway should be available' {
        $status | should Be $true
		
	}

}

## check if DNS server is correct IPAddress
Describe 'check if DNS server is correct IPAddress' {
	
	if($networkinf.dnsserver.serveraddresses[2] -eq '8.8.8.8'){
	$status = $true
}
else{
$status = $false
}

		
			It "DNS IP should be 8.8.8.8 " {
        $status | should Be $true
		
	}

}

##  tests DNS connection
Describe 'Testing DNS(s) connection' {
	
	foreach ($DNSIPAddress in $networkinf.dnsserver.serveraddresses){

	$status = (Test-Connection -ComputerName $DNSIPAddress -Quiet -Count 1)

	
	It "DNS $($DNSIPAddress) should be available" {
        $status | should Be $true
		
	}
		}

}

##  tests random ip (ping)
Describe 'Testing 8.8.8.8' {
	
	$status = (Test-Connection -ComputerName 8.8.8.8 -Quiet -Count 1)

	
	It '8.8.8.8 should be available' {
        $status | should Be $true
		
	}

}

##  tests DNS query google.be IPv4
Describe 'Testing DNS(s) Query for google.be' {
	
	foreach ($DNSIPAddress in $networkinf.dnsserver.serveraddresses){

		try {       
			 $dnsRecord = Resolve-DnsName "google.be" -Server $DNSIPAddress -ErrorAction Stop | Where-Object {$_.Type -eq 'A'}        
			 $status = 'OK'
		 }  catch {        
			$status= 'NOT_OK' 
		 }    

	It "DNS query on $($DNSIPAddress) for google.be should be OK" {
        $status | should Be 'OK'
		
	}
		}

}

## test diskspace free
Describe 'Testing diskspace C drive free greater then 20GB' {
	
	$status =  (Get-WmiObject win32_logicaldisk -Filter "Drivetype=3" | Where-Object {$_.DeviceID -eq "C:"}).FreeSpace/1GB 

	
	It 'should be moe than 20GB left' {
        $status | should BeGreaterThan 20
		
	}

}


## Test ram free
Describe 'Testing RAM usage should be more than 2GB left' {
	
	$status =  (Get-Ciminstance Win32_OperatingSystem | Select-Object FreePhysicalMemory).FreePhysicalMemory/1mb

	It "Free RAM greater than 2GB currently is $($status)GB" {
        $status | should BeGreaterThan 2
		
	}

}

## check firewall Private enabled
Describe 'check firewall Private enabled' {
	
	$status =  (Get-NetFirewallProfile -Name Private | Select-Object enabled)

	It 'Private must be enabled' {
        $status.enabled | should Be $true
		
	}

}

## check firewall Public enabled
Describe 'check firewall public enabled' {
	
	$status =  (Get-NetFirewallProfile -Name Public | Select-Object enabled)

	It 'Public must be enabled' {
        $status.enabled | should Be $true
		
	}

}


## check if user quint exist 
Describe 'check user quint exists and is enabled' {
	
	try {       
			$checkuser = (Get-LocalUser quint -ErrorAction Stop).enabled   
			if($checkuser){			 
				$status = 'OK'
				}
			else{
				$status = 'NOT_ENABLED'
			 }
		 }  catch {        
			$status= 'NOT_EXIST' 
		 }    

	It 'user quint must exist and be enabled' {
        $status | should Be 'OK'
		
	}

}


## check KeyboardLayout 
Describe 'check keyboard' {
	
 	$status =  (Get-Culture | Where-Object {$_.LCID -eq "2067"})

	It 'Must be belgian period' {
        $status | should Be $true
		
	}


}

<#

Describe 'License'{
    It 'Time for trial'{
    $com = (Get-CimInstance -ClassName softwarelicensingproduct).GracePeriodRemaining
    $com | Should begreaterthan  0
    Write-Host 'You have ' $com ' minutes remaining on the trial edition'
}
}

#>
