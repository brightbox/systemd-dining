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

## Design overview

We'll be using a variant of the Chandry/Misra "hygiene" solution to
the Dining Philosophers problem.

Each philosopher is a separate user ID on the server and sits in its
own unix group. It is also a member of the `philosophers` group which
has access to the dining room at /home/share/dining-room.

The philosophers run autonomously and take their seats once the
dining-room is open (writable by group `philosophers`). Seats are
dynamically allocated on a first come first served basis with each
philosopher grabbing the first seat they can by creating a file in the
dining room with their seat number on it that nobody else can write to.

Once a philosopher has taken a seat they will pick up a fork by creating
a fork file with their name on it and the number of the *next* seat
position. The philosopher in seat #1 will exercise their head of the
table privilege and take fork #1 as well. This sets the fork graph up to be
acyclical - ensuring the system will make progress.

The philosophers now enter the thinking state, contemplating a proposition
from their project file, and set a time in the future when they will
become hungry.

Once a philosopher reaches the hungry target, they check if they have
both forks. If not they email the relevant dining neighbour(s) a "fork
request" asking for the shared fork.

A sendmail `.forward` file runs a mail processor for each email received.

For each fork request related to a sender
- if we are thinking and we have the fork, we delete the fork and send a fork response back.
- otherwise we ignore the request

For each fork response received a fork is created. Forks can only be
acquired as a result of a fork response and thereby with permission
of the neighbour. This both maintains the acyclical nature of the fork
graph and avoids starvation (systemically and metaphorically).

Once a philosopher has two forks they enter the eating state and
set a time in the future when they will start thinking again.

A philosopher will check whether to start eating as soon as they become
hungry and thereafter when they receive a fork response.

Before they enter the thinking state, the forks are deleted and they
are transferred to neighbours by sending them a fork response.

## Installation

From an Ubuntu LTS server logged in as the admin user and run the setup script

    ubuntu@srv-2q8eh:~$ git clone --depth 1 git@github.com:brightbox/systemd-dining.git
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

Follow a philosopher's activity in real time

    ubuntu@srv-4mujm:~$ npcjournal -f hegel
    Nov 19 14:10:30 mail-tasks[1072039]: Received fork response from hume
    Nov 19 14:10:30 mail-tasks[1072039]: Acquired fork #8
    Nov 19 14:10:30 fork-check[1072079]: I have two clean forks
    Nov 19 14:10:30 consumption[1072134]: Eating...
    Nov 19 14:10:35 fork-release[1072229]: Cleaning forks
    Nov 19 14:10:35 fork-release[1072229]: Transferring forks
    Nov 19 14:10:35 fork-release[1072257]: Giving wittgenstein a clean shared fork
    Nov 19 14:10:35 fork-release[1072257]: Giving hume a clean shared fork
    ...

Look at today's contemplations for a philosopher

    ubuntu@srv-4mujm:~$ npcjournal --since=today --identifier=contemplation hegel | more
    Nov 19 00:00:39 contemplation[368515]: Currently contemplating the idea that contradiction and conflict are
    Nov 19 00:00:39 contemplation[368515]: inherent in the development of ideas and societies.
    Nov 19 00:01:32 contemplation[370247]: Currently contemplating the belief that reality is rational, and reason
    Nov 19 00:01:32 contemplation[370247]: is the ultimate essence of the world.
    Nov 19 00:03:08 contemplation[372866]: Currently contemplating the idea that contradiction and conflict are
    Nov 19 00:03:08 contemplation[372866]: inherent in the development of ideas and societies.

Get the gory details at systemd unit level

    ubuntu@srv-4mujm:~$ journalctl _UID=$(id -u kant) --since today
    Nov 19 14:16:46 srv-4mujm systemd[98014]: Starting Clean Fork Check...
    Nov 19 14:16:47 srv-4mujm systemd[98014]: fork-check.service: Main process exited, code=exited, status=75/TEMPFAIL
    Nov 19 14:16:47 srv-4mujm systemd[98014]: fork-check.service: Failed with result 'exit-code'.
    Nov 19 14:16:47 srv-4mujm systemd[98014]: Failed to start Clean Fork Check.
    Nov 19 14:16:47 srv-4mujm systemd[98014]: fork-check.service: Triggering OnFailure= dependencies.
    Nov 19 14:16:47 srv-4mujm systemd[98014]: Starting Neighbour Fork Request...
    Nov 19 14:16:47 srv-4mujm fork-request[1088801]: I don't have fork #11
    Nov 19 14:16:47 srv-4mujm fork-request[1088833]: Asking hobbes for the shared fork
    Nov 19 14:16:47 srv-4mujm sendmail[1088845]: 3AJEGlXl1088845: from=kant@srv-4mujm.gb1.brightbox.com, size=110, class=0, nrcpts=1, ...
    Nov 19 14:16:47 srv-4mujm sendmail[1088845]: 3AJEGlXl1088845: to=hobbes, ctladdr=kant@srv-4mujm.gb1.brightbox.com (1001/1002), ...
    Nov 19 14:16:47 srv-4mujm systemd[98014]: Finished Neighbour Fork Request.

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
