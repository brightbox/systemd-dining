# Dining Philosophers using systemd.

The dining philosophers problem is a classic in Computer Science that
illustrates the major issues with concurrency.

Most people immediately reach for their favourite programming language
to attack this problem but here we're going to do something different.

The Linux operating system is a multi-user concurrent system which is
designed to have separate people using it all at the same time. Most of
this remains unused these days.

So I thought it would be fun to bring back the multi-user power of Unix
via a set of NPCs fighting over some rather fiddly pasta, while driving
the characters using the user level systemd functions.

All while allowing the real world adminstrator to watch each user via
the logging systems.

We're going to use classic Unix tools from the archives and give the
Unix Programming Environment a work out it hasn't seen for a good while.

## Installation

From an Ubuntu LTS server logged in as the admin user and run the setup script

    ubuntu@srv-2q8eh:~$ git clone git@github.com:brightbox/systemd-dining.git
    Cloning into 'systemd-dining'...
    ...
    ubuntu@srv-2q8eh:~$ cd systemd-dining/
    ubuntu@srv-2q8eh:~/systemd-dining$ sudo ./setup.sh
    Adding required packages
    ...
    Installing simulation

## Run the simulation

Create the philosophers

    ubuntu@srv-2q8eh:~/systemd-dining$ xargs -L 1 sudo /usr/local/sbin/create_philosopher < philosophers

Open the dining room

    ubuntu@srv-5o1ic:~/systemd-dining$ sudo open_dining_room

## Stop the simulation

Close the dining room

    ubuntu@srv-5o1ic:~/systemd-dining$ sudo close_dining_room

Remove the philosophers

    ubuntu@srv-2q8eh:~/systemd-dining$ awk '{print $1}' philosophers | xargs sudo /usr/local/sbin/remove_philosopher

## Interesting things to look at

Check a philosopher's activity

    ubuntu@srv-5o1ic:~/systemd-dining$ npcjournal hegel
    Nov 14 09:15:33 srv-5o1ic select-seat[7048]: The Dining Room is open. Looking for a seat.
    Nov 14 09:15:33 srv-5o1ic select-seat[7048]: I have seat #6
    Nov 14 09:15:33 srv-5o1ic select-seat[7048]: Acquired fork #7

Look at today's contemplations for a philosopher

    ubuntu@srv-4mujm:~$ npcjournal --since=today --identifier=contemplation hegel | more
    Nov 19 00:00:39 contemplation[368515]: Currently contemplating the idea that contradiction and conflict are
    Nov 19 00:00:39 contemplation[368515]: inherent in the development of ideas and societies.
    Nov 19 00:01:32 contemplation[370247]: Currently contemplating the belief that reality is rational, and reason
    Nov 19 00:01:32 contemplation[370247]: is the ultimate essence of the world.
    Nov 19 00:03:08 contemplation[372866]: Currently contemplating the idea that contradiction and conflict are
    Nov 19 00:03:08 contemplation[372866]: inherent in the development of ideas and societies.

See the philsopher's details and what they are thinking about

    $ finger hume
    Login: hume           			        Name: David Hume
    Directory: /home/hume               	Shell: /bin/bash
    Never logged in.
    Mail forwarded to |/usr/local/bin/mail-processor
    No mail.
    Project:
    the empirical foundation of knowledge and the idea that all ideas derive from sensory impressions.
    the notion that causation is not a necessary connection but a habitual association based on experience.
    the self as a bundle of perceptions, with no enduring and unchanging identity.
    the principle that reason is the slave of the passions, and moral judgments are driven by sentiment.
    the idea that miracles, as violations of natural laws, are inherently improbable and should be met with skepticism.
    the understanding that probability is the guide of life, shaping our beliefs and actions based on likelihood.
    the distinction between 'is' and 'ought,' recognizing that moral values cannot be derived from factual statements.
    the empiricist view that all knowledge originates in experience, rejecting innate ideas as a source of understanding.
    the skeptical position that we can never know the true nature of things, only their appearances.
    the constant flux of impressions and ideas, emphasizing the impermanence and transience of all mental phenomena.
    No Plan.
