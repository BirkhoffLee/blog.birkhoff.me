---
title: 'Forza Horizon 4 PC won''t launch, or says sign-in needed'
tags:
permalink: forza-horizon-4-pc-wont-launch-or-says-sign-in-needed
id: 5bb2643795c91c00010ae1b9
updated: '2018-10-02 02:27:11'
date: 2018-10-02 02:15:19
---

So today I excitedly opened up my pre-ordered Forza Horizon 4 and seems that the splash screen shows up for 4 seconds, disappears and the game won't launch.

I've searched on Internet and found out you need to download a random app from the Microsoft Store app and the game launches.

> Note that you will need to have RTSS application detection level set to None (globally) if you have that installed.

It wasn't the end. When the beautiful music started, the awesome graphics showed up, I immediately pressed Y on my Xbox One controller. The game still won't let me play. It's a $60 game and I shouldn't be treated like this. Luckily I found another fix on the internet, it turns out that you need to do the following steps to get everything working.

1. Press Windows key + X
2. Then click Windows Powershell (Admin)
3. Now type the following commands and hit Enter key

```
$ Get-AppxPackage *windowsstore* | Remove-AppxPackage
$ Get-AppxPackage *xboxapp* | Remove-AppxPackage
$ Get-AppxPackage -AllUsers| Foreach {Add-AppxPackage -DisableDevelopmentMode -Register “$($_.InstallLocation)\AppXManifest.xml”}
```

4. Open Xbox app, and you should be able to sign in and play. Enjoy!

# References
https://answers.microsoft.com/en-us/windows/forum/windows_10-windows_store/xbox-app-error-0x406/09dc12db-97ee-4907-89b8-3a2b7ebe1507
https://www.reddit.com/r/forza/comments/8idqey/forza_7_doesnt_start_on_pc/
