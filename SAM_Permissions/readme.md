# SAM bad read permissions

Recently, [some](https://twitter.com/jonasLyk/status/1417205166172950531) [Tweets](https://twitter.com/jeffmcjunkin/status/1417281315016122372)  seemed to evidence a number of Windows machines had badly set permissions that allowed any user to read the *SAM file*

###### UPDATE
This all applies to SECURTY and SYSTEM files too. Meaning an adversary with mimikatz and a shell in your internal network can trivally privesc AND steal credentials. 

Our original script originally scanned the SAM file and confirmed if vulnerable or not to permissions mistake. We have put together an [additional script](#Wider-permissions-check) that will scan all three files. This is overkill, as permissions for the SAM file are likely the same for the SYSTEM and SECURITY files too. But it's still nice to have the script confirm this. 

## Why is this bad?

The SAM file should definitely NOT be readable by every user. This file can be abused by adversaries to facilitate privilege escalation and password theft from users on a macine.

You can read more about [the dangerous details behind this misconfiguration](https://www.kb.cert.org/vuls/id/506989)

## How can I check if I am vulnerable?

Great question! We wrote a [short script](SAM_Permissions_Check.ps1) that will help confirm or deny if your SAM, SECURITY, and SYSTEM files have bad permissions and therefore if your machine is vulnerable or not to this potential privesc.

Please run the [script](SAM_Permissions_Check.ps1) as Admin.

### Usage
You can pull the script via `invoke-webrequest`, or just copy and paste it if your environment doesn't allow scripts to be pulled from the internet. 
```powershell
 Invoke-WebRequest -URI https://raw.githubusercontent.com/JumpsecLabs/Guidance-Advice/main/SAM_Permissions/SAM_Permissions_Check.ps1 -OutFile ./SAM_Permissions_Check.ps1  -usebasicparsing
```

And execute as Admin.
```powershell
.\SAM_Permissions_Check.ps1

#if you have permissions errors, try:
Unblock-File -path C:\path\to\SAM_Permissions_Check.ps1
powershell -exec bypass .\SAM_Permissions_Check.ps1
```
If the machine is vulnerable, expect the RED warning text; if the machine isn't vulnerable, expect the GREEN warning text.

![vuln](https://user-images.githubusercontent.com/44196051/126726994-3d004065-9f7a-449f-bbcb-f1dd6ac02241.png)

![safe](https://user-images.githubusercontent.com/44196051/126726996-6cba88a8-a08a-4837-ad90-2a88cd3cf934.png)

##### Optional extra if you're vulnerable
We added the option if you are vulnerable to collect OS version and build details, to contribute to data gathering that is occuring on Twitter and other places. This aims to understand which OS versions exactly are vulnerable

![OS](https://user-images.githubusercontent.com/44196051/126727076-9aa48ae4-f227-4049-81de-7415d3e9e6b4.png)


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

### Defences
Latest workaround by [Microsoft can be found here](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-36934). There are two portions to this workaround:
* Change File Permissions - Easy
* Remediate Volume Shadow Service - Complicated

###### Change file permissions
This can be easily done with the following command. It does not appear to have negative impact on the OS:
```cmd
icacls %windir%\system32\config\*.* /inheritance:e
```
###### Remediate VSS
Changing this may present complications for your backup solutions. Please test this option on a control machine before attempting domain wide.

[TrueSec](https://blog.truesec.com/2021/07/20/hivenightmare-a-k-a-serioussam-local-privilege-escalation-in-windows/) have good guidance on manipulating the VSS for defence
