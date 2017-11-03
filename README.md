TaraniTunes
===========

*Awesome music player for FrSky Taranis radios.*

Compatible with FrSky's [Taranis Q X7](https://www.frsky-rc.com/product/taranis-q-x7-2), [Taranis X9D](https://www.frsky-rc.com/product/taranis-x9d-plus-2) and their variants.
You need at least [OpenTX](http://www.open-tx.org) 2.2.

* Taranis Q X7  
  ![Taranis Q X7](Screenshots/TaraniTunesQX7.png)
* Taranis X9D  
  ![Taranis X9D](Screenshots/TaraniTunesX9D.png)


Installation instructions
-------------------------

**I will try to add a video explaining TaraniTunes' installation and usage in the future**

The “[Example](Example)” folder contains an exemple of the Taranis' SD card structure you must follow. It works, you can, if you want, merge it with your Taranis' current SD card content.

1. On your computer:
	1. Edit [`iTunes.lua`](iTunes.lua) according to your preferences if needed then put iTunes.lua in `/SCRIPT/TELEMETRY`.
	2. Create a [`playlist.txt`](Example/SOUNDS/playlist.txt) file in `/SOUNDS` where each line must be formatted like this: `Song name:SONG_FILENAME` where `SONG_FILENAME` must be 6 characters or less. Don't end the file with a newline! Look at [Example/SOUNDS/playlist.txt](Example/SOUNDS/playlist.txt) for an example of formatting.
	3. Put your corresponding songs `SONG_FILENAME.wav` in `/SOUNDS/en` if your radio is in English (otherwise replace `en` with your language, where you put your other sound files). They must be encoded in Microsoft WAV 16-bits signed PCM at a 32 kHz sampling rate, you can use [Audacity](http://www.audacityteam.org/) to do that, it works great.

2. On your Taranis (I'm going to explain how I setup my radio)
	1. Go to “DISPLAY” model's setting screen, set a screen to “Script” mode and choose “iTunes”.  
	![Display settings](Screenshots/DisplaySettings.png)
	2. Set “LOGICAL SWITCHES” model's setting screen as follow:  
	![Logical switches settings](Screenshots/LogicalSwitchesSettings.png)
	3. Set “FLIGHT MODES” model's setting screen as follow:  
	![Flight modes settings](Screenshots/FlightModesSettings.png)  
	In fact, put every throttle trims to “`--`” for every flight mode you use.

There you go! Next section will explain you how to use TaraniTunes.

Usage
-----

From the main menu, hold “Page” to access TaraniTunes. If everything has been setup correctly, your songs should appear, otherwise:

* If you modified your [`iTunes.lua`](iTunes.lua), maybe some configuration values are wrong.
* The `playlist.txt` syntax may be wrong. Be sure to put the song name, then the colon “:”, then the song filename of 6 characters maximum. Also make sure there is no empty line at the end, or you will get a “CPU Limit” error, yeah I probably need to fix that…

1. Use the rotary encoder (Q X7) or the “+”/“-” buttons to sweep through songs.
2. Press “Enter” to choose a song to play.
3. Put the “SD” switch in the middle position to start playing. Put it back in the up position to stop.
4. If you select another song, you have to stop and start playback (“SD” up then center again). I'm sorry I can't do it any other way…
5. Put “SD” in the down position to select a random song from your playlist. Stop and start playback to play it.
6. You can press throttle trims down and up to play next and previous song respectively. You still have to stop and start playback to play it.


Todo
----

* Automatically play next music after one is finished (maybe skip to next song when already 30 seconds have been played?)


Suggestions for OpenTX's API
----------------------------

* Constants to determine the radio type, useful when calculating switche's index because in special functions, logical switch 1 have the index 51 on Taranis X9D and 39 on Taranis Q X7.
* A function called when entering a telemetry screen. Useful to draw the screen *only* when needed and not every frame. Without that variable, when entering the telemetry screen more than once, the screen stays stuck onto the main screen.
* `table.insert(table, value)` doesn't seem to work, need to use `table[#table + 1] = value` instead.