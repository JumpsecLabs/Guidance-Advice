# SAM bad read permissions

We saw [some](https://twitter.com/jonasLyk/status/1417205166172950531) [Tweets](https://twitter.com/jeffmcjunkin/status/1417281315016122372) that seemed to evidence a number of Windows machines had badly set permissions that allowed any user to read the *SAM file*

## Why is this bad?

The SAM file should definitely NOT be readable by every user. This file can be abused by adversaries to facilitate privilege escalation and password theft of a macine

## How can I check if I am vulnerable?

Great question! We wrote a [short script](#SAM_Permissions_Check.ps1) that will help confirm or deny if your SAM file has bad permissions and therefore if your machine is vulnerable or not to this.

Please run the [script](#SAM_Permissions_Check.ps1) as Admin.

###### If Vulnerable
![Will highlight in RED](https://user-images.githubusercontent.com/49488209/126307912-1074a0e7-3228-4633-be1f-cc4374933980.png)

###### If Not Vulnerable
![Will highlight in GREEN](https://user-images.githubusercontent.com/49488209/126307983-5b1c1935-6982-4268-a136-675966f2ea87.png)

### Defences
As advised defences become avaliable, we will update this repo with guidance.
