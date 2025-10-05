Userctl
Targetctl

What is Userctl?
Userctl tries to implement a few basic function, from systemctl --user 
Right now it has 3 functions
Import environemnt
get environment 
run

import-environment
Import environment is simply a script that gatters user environment variables, it saves those and they can be invoked to a user with set-environemnt.

set-environment
This get called, when the user got logged in, mostly via pam, it takes all variables from import environment and export those for the user, as optional argument you can pass a script or programm that should be run in the user context.
The syntax is userctl set-environment optional_program

run
The third is the function run, it simply executes a script or program in the user context and mostly get execute from a pam configuration

Add it to pam configuration
If you want to exec get-environemnt or run, you simply put in the pam configuration add the end from the pam file, this line:
```session optional pam_exec.so type=open_session /usr/bin/userctl set-environment optional_program```
Both set-environment and user is more sutiable for greeters, where systemctl --user is more often used.
Be aware, that set-environment and run, get's executed as the user, which runs the script, you can run the script with a other user with runuser -l USER -c COMMAND, but this makes only sense for set-environment and not for run
If you need more functions from systemctl --user, feel free to contact me and I try to built it in this script

What is Targetctl?
It tries to build in targets to runit..Right now it's very basic, you can set a target, so basically say, this target now get's triggered or wait if till a target get's triggered. It has two commands:

targetctl set TARGETNAME
If you put this in your runit file, the script will trigger all this target. If you need, multiple runit services, to start in the middle of a runit service for example, you can put in the middle of your service file targetctl set environmentload and all services that waits for that target get executed in the next 0.5 seconds

targetctl get TARGETNAME
It's basically the counterpart of set, put this in a service file and the all lines under this line, will be executed after the target is set. If you have a runit service that should load environemnts you can put on top targetctl get environmentload and the service will be executed after the target was set

ToDo, I will add in the future, that there is the possibility for multi targets, this means basically, that numerous runit services need to trigger a target and after all services startet, that trigger the same target, then the target would be set

Why Do I add these?
It's pretty simple, the Linux Desktop got more complicated and systemd is more and more a part of it. It is sometimes a Pain in the Ass to find workarounds to simulate, the order of things to run, on other systems, systemd is doing that, with targets. targetctl is a basically an extension script for runit, to make it fit more in the modern world. systemctl --user is also more and more implemented and this userctl should help to make it easier to replace systemctl --user. Both Scripts are very simple, but I plan to built in a few more functions, but I will try to not bloat it. If you have a good Idea or something you wish, to make the work with runit easier and better, write the suggestion to me and I try to implement it