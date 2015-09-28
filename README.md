podgetbt
========

<span>*podgetbt*</span> manages the download of podcast episodes. It was written in response to the lack of a small podcatcher that can handle podcasts distributed as bit torrents in a convenient way. It is implemented as a simple script without a GUI. So it can be run in the background and on small devices.

Before starting the downloads the script tries to free up disk space by deleting old episodes. Of course you can configure how long episodes should be kept.

Most of the required functionality already has been implemented elsewhere. So <span>*podgetbt*</span> relies on other tools. It requires

-   a *podcatcher* to download the episodes of the podcast or their torrents files (note this podcatcher is only expected to download the torrent file, which contains a description of the bit torrent, but not the audio content.);

-   a *bittorrent client* to handle bittorrent downloads;

-   an *audio file player*.

The default tools are [*podget*](http://podget.sourceforge.net) for the podcatcher, [*transmission-daemon*](http://www.transmissionbt.com) for the transmission client and [*mpd*](http://www.musicpd.org) for the audio file player. Currently <span>*podgetbt*</span> is tested only to work together with these tools.

Running
=======

The script is simply started without arguments.

Configuration
=============

As *podgetbt* uses other tools, the result of running podgetbt also depends on the configuration of these tools. In particular the podcasts and the download policies are configured with podget.

Configuration of other tools
----------------------------

In this section we give some short hints on how to configure the default tools. For details please refer to the documentation of the tools.

### *podget*

If *podget* is run the first time without an existing configuration, configuration default files are generated in `$HOME/.podget`. These files can then be adapted to your needs.

`podgetrc` is the main configuration file. In it `DIR_LIBRARY` is set to the path where podget places its downloads. You have to make sure, that this is set to the same path as `PODDIR` in <span>*podgetbt*</span>’s own configuration (see below). `CONFIG_SERVERLIST` is the name of the server list file also found in `$HOME/.podget`. This server list enumerates the podcasts that are to be checked for new episodes. For each podcast a line is to be added of the form

\<url\> \<cathegory\> \<cathegory\>

Here \<url\> refers to the URL of the feed to be downloaded. \<cathegory\> and \<name\> can be chosen freely. The episodes will then be placed in the directory `$DIR_LIBRARY`/\<cathegory\>/\<name\>. <span>*podgetbt*</span> later uses these names to create the name of the playlist with the new episodes. It is \<cathegory\>\_\<name\>`.m3u`.

### *transmission-daemon*

You find the configuration file in `/etc/transmission-daemon/setting.json`. Note, thath this file should only be modified when *transmission-daemon* is not running.

As *mpd* needs to update its sound library, before the new files can be played, it is a good idea to configure the *transmission-deamon* to trigger this update after a file has been downloaded from a torrent. This is possible, as *transmission-daemon* runs a script after finishing each download provided the configuration variable `script-torrent-done-enabled` is set to `true` and `script-torrent-done-filename` is set to the file containing the script. To update the data base of *mpd* the script file should contain the line

    mpc update

The directory where the downloads are placed is set in the variable `download-dir`. You can set it to the directory, where the audio player (*mpd*) finds its audio files. If you use *transmission-daemon* also to download other types of files than of course you should define a separate download directory and extend the above script to move podcast episodes to the proper place after each download.

### *mpd*

The configuration file of *mpd* is usually found in `/etc/mpd.conf`.

In order to cooperate with the other tools the directory, where *mpd* is looking for sound files has to be properly set. The variable name is `music_directory`.

### Configuring common directories

The following settings of directories should match

| Setting in *podgetbt*    | Other tool            | Setting           |
|:-------------------------|:----------------------|:------------------|
| `$PODDIR`                | *podget*              | `$DIR_LIBRARY`    |
| `$MP3DIR/$TORRENTSUBDIR` | *transmission-daemon* | `download-dir`    |
| `$MP3DIR`                | *mpd*                 | `music_directory` |

*podgetbt*
----------

A configuration file is searched in `/etc/podgetbt.conf` then in `$HOME/.config/podgetbt/conf`. The file is sourced as a bash script. So the configurtation variables must be set according the bash syntax. There are also some procedures that can be redefined if needed.

-   `MP3DIR`: The directory, where *podgetbt* move all audio files of the episodes. This only effects the files downloaded directly and not those from torrents. The directory `$MP3DIR` should be the one, where the audio player looks for the audio files. Default: `/var/lib/mpd/music`

-   `PODDIR`: The directory, where *podget* puts its downloads. The setting of this variable must match the setting of `$DIR_LIBRARY` of *podget*. *podget* is expected to leave a file in this directory containing a list of the episodes just downloaded. It should be last file of those matching the pattern `NEW*.m3u` in lexicographic order.

-   `PLAYLISTDIR`: The directory for playlists. If left unset it will be automatically set to the value of `MP3DIR`.

    For each podcast a playlist named `<category>\_<feed>.m3u` is created, where `<cathegory>` is the name of the cathegory of the podcast defined with *podget* and `<feed>` its feed name. This playlist contains all new episodes downloaded in the last run of this program.

    Furthremore, a playlist `podcasts.m3u` is maintained containing all episodes of all podcasts, that exist on the system. When *podgetbt* tries to free up space, it also consults `podcasts.m3u` for the files that might be deleted in case they reached their maximum age.

-   `TORRENTSUBDIR`: The name of a subdirectory in `$MP3DIR`. The audio files of torrents are expected to appear in `$MP3DIR/$TURRENTSUBDIR` after they have been downloaded by the torrent client.

-   `UNPLAYEDDAYS`: The number of days an unplayed podcast episode will be kept on the system. If more days have passed since the file modification time the file will be deleted.

-   `PLAYEDDAYS`: The number of days an played podcast episode will be kept on the system. If more days have passed since the file modification time the file will be deleted.

-   `PLAYEDLIST`: A playlist containing the episodes that have been played. This file is read to determin whether `$PLAYEDDAYS` or `$UNPLAYEDDAYS` is used to determine an episode has expired.

    If this file does not exist all episodes are treated as unplayed. You could configure your audio player to maintain this list or use a tool that does this. Of course, writing this file manually is also an option.

-   `UPDATELIB`: A command line that causes the library of your music player to be updated. The default is

        mpc update

    It is called after all episode files have been placed into `$MP3DIR`. The files downloaded form torrent are not observed. So the torrent client has to be configured to trigger the update after his downloads are completed.

-   `PODGETBTDIR`: Directory for all other files of <span>*podgetbt*</span> that have not been mentionned somewhere above. This directory is currently only used for a lock to prevent execution of several instances of <span>*podgetbt*</span> at the same time.

-   `VERBOSITY`: Verbosity of the program.


