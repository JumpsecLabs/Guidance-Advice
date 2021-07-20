# SAM bad read permissions

Recently, [some](https://twitter.com/jonasLyk/status/1417205166172950531) [Tweets](https://twitter.com/jeffmcjunkin/status/1417281315016122372)  seemed to evidence a number of Windows machines had badly set permissions that allowed any user to read the *SAM file*

###### UPDATE
This all applies to SECURTY and SYSTEM files too. Meaning an adversary with mimikatz and a shell in your internal network can trivally privesc AND steal credentials. 

Our original script originally scanned the SAM file and confirmed if vulnerable or not to permissions mistake. We have put together an [additional script](#Wider-permissions-check) that will scan all three files. This is overkill, as permissions for the SAM file are likely the same for the SYSTEM and SECURITY files too. But it's still nice to have the script confirm this. 

## Why is this bad?

The SAM file should definitely NOT be readable by every user. This file can be abused by adversaries to facilitate privilege escalation and password theft from users on a macine

## How can I check if I am vulnerable?

Great question! We wrote a [short script](SAM_Permissions_Check.ps1) that will help confirm or deny if your SAM file has bad permissions and therefore if your machine is vulnerable or not to this.

Please run the [script](SAM_Permissions_Check.ps1) as Admin.

### Usage
You can pull the script via `invoke-webrequest`, or just copy and paste it if your environment doesn't allow scripts to be pulled from the internet. 
```powershell
 Invoke-WebRequest -URI https://raw.githubusercontent.com/JumpsecLabs/Guidance-Advice/main/SAM_Permissions/SAM_Permissions_Check.ps1 -OutFile ./SAM_Permissions_Check.ps1  -usebasicparsing
```

And execute with
```powershell
.\SAM_Permissions_Check.ps1

#if you have permissions errors, try:
Unblock-File -path C:\path\to\SAM_Permissions_Check.ps1
powershell -exec bypass .\SAM_Permissions_Check.ps1
```

###### If Vulnerable
![Will highlight in RED](https://user-images.githubusercontent.com/49488209/126307912-1074a0e7-3228-4633-be1f-cc4374933980.png)

###### If Not Vulnerable
![Will highlight in GREEN](https://user-images.githubusercontent.com/49488209/126307983-5b1c1935-6982-4268-a136-675966f2ea87.png)

### One-liner alternative
If you just want a one-liner to chuck into a tool like Velociraptor then you can use this:
```powershell
$ErrorActionPreference = "SilentlyContinue" ;
if ((get-acl C:\windows\system32\config\sam).Access | 
? IdentityReference -match 'BUILTIN\\Users' | 
select -expandproperty filesystemrights | 
select-string 'Read'){write-host "May be vulnerable: Arbitrary Read permissions for SAM file"
}else { write-host "Does not seem to be vulnerable, SAM permissions are fine"}
```
![image](https://user-images.githubusercontent.com/49488209/126365217-d0915956-d1c1-4223-9521-2e82e6290e3d.png)


### Wider permissions check
If you leverage the [alternate script](wider_permissions_check.ps1) that scans all three SAN, SYSTEM, and SECURITY files' permissions, then your outputs should look like this:
![image](https://user-images.githubusercontent.com/49488209/126362385-9cca73f8-0a2a-4d53-9785-23eb09e62b3c.png)


### Defences
As advised defences become avaliable, we will update this repo with guidance.

