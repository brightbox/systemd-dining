# Dining Philosophers using systemd

## Installation

From an Ubuntu LTS server logged in as the admin user and run the setup script

    ubuntu@srv-2q8eh:~/systemd-dining$ sudo ./setup.sh
    Adding required packages
    ...
    Installing simulation

## Run the simulation

   ubuntu@srv-hgy08:~$ systemctl --user start thinking.target 

## View the simulation

    ubuntu@srv-hgy08:~$ journalctl -f
    Nov 20 11:19:49 srv-hgy08 systemd[2257]: Started thinking.timer - Thinking Period.
    Nov 20 11:19:49 srv-hgy08 systemd[2257]: Starting contemplation.service - Contemplation...
    Nov 20 11:19:49 srv-hgy08 contemplation[2336]: Currently contemplating the enigmatic nature of reality: the existential
    Nov 20 11:19:49 srv-hgy08 contemplation[2336]: grasp for an elusive fork, the categorical imperative of simulated
    Nov 20 11:19:49 srv-hgy08 contemplation[2336]: existence, and the irony in questioning the true essence of the held
    Nov 20 11:19:49 srv-hgy08 contemplation[2336]: object.
    Nov 20 11:19:49 srv-hgy08 systemd[2257]: Finished contemplation.service - Contemplation.
    Nov 20 11:19:49 srv-hgy08 systemd[2257]: Reached target thinking.target - Thinking....

## Stop the simulation

    ubuntu@srv-hgy08:~$ systemctl --user stop thinking.target hungry.target eating.target
