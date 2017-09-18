# Make VolumeUp, VolumeDown keys work
## Problem description
- Distributions affected:
    - Ubuntu Mate 16.04.3 LTS
- VolumeUp (Fn-F4) and VolumeDown (Fn-F3) keys are **detected** and produce OSD (On Screen Display), but the volume itself does not change
## Solutions explored
- [Media keys not working on ubuntuforums.org May-10-2014](https://ubuntuforums.org/showthread.php?t=2217890&s=f89de759d920dd5c2639d51e03a3131f&p=13019361#post13019361)
- [Volume buttons not working on lubuntu 16.04 fresh install on askubuntu.com Sep-07-2016](https://askubuntu.com/a/922795)

## Solution / workaround
- Open System --> Hardware --> Keyboard Shortcuts
- VolumeUp
    - Click on ```Add``` (new keyboard shortcut)
    - Give it a name like 'VolumeUp'
    - Command should be ```amixer -D pulse sset Master 5%+```
    - Click ```Apply```
    - Click on shortcut column of newly added shortcut (under ```Custom Shortcuts```)
    - Press Fn-F4
    - You will get a warning message indicating key is already assigned to ```Volume up```
    - Choose ```Reassign```
- VolumeDown
    - Click on ```Add``` (new keyboard shortcut)
    - Give it a name like 'VolumeDown'
    - Command should be ```amixer -D pulse sset Master 5%-```
    - Click ```Apply```
    - Click on shortcut column of newly added shortcut (under ```Custom Shortcuts```)
    - Press Fn-F3
    - You will get a warning message indicating key is already assigned to ```Volume down```
    - Choose ```Reassign```

## Shortcomings of solution
- Volume goes up and down perfectly, but you do not get the On Screen Display (OSD)
- OSD is produced from within mate-settings-daemon
- mate-settings-daemon is executing the wrong command, and does not provide:
    - A way to change the command executed for ```Volume up``` and ```Volume down``` events
    - A way to create the same or similar OSD for custom shortcuts created

# Conclusion
- This should be filed as an upstream bug against Ubuntu Mate / mate-settings-daemon
- If you use Ubuntu Mate and you have found a different / better solution, send me a pull request
