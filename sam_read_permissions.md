# SAM bad read permissions


There were [some](https://twitter.com/jonasLyk/status/1417205166172950531) [Tweets](https://twitter.com/jeffmcjunkin/status/1417281315016122372) that we saw Monday night. In these tweets, there seemed to be evidence that a number of Windows machines had badly set permissions that allowed any user to read the SAM file

![image](https://user-images.githubusercontent.com/49488209/126306883-a15c7fd4-efe8-4573-9d8a-73241b791d6d.png)
![image](https://user-images.githubusercontent.com/49488209/126306928-571e0114-076a-4658-a953-a66fd037a051.png)


## Why is this bad?

The SAM file should definitely NOT be readable by every user. This file can be abused by adversaries to facilitate privilege escalation and password theft of a macine

## How can I check if I am vulnerable?

Great question! We wrote a short script that will help confirm or deny if your SAM file has bad permissions and therefore if your machine is vulnerable or not to this.

##### If Vulnerable
![Will highlight in RED](https://user-images.githubusercontent.com/49488209/126307912-1074a0e7-3228-4633-be1f-cc4374933980.png)

##### If Not Vulnerable
![Will highlight in GREEN](https://user-images.githubusercontent.com/49488209/126307983-5b1c1935-6982-4268-a136-675966f2ea87.png)
