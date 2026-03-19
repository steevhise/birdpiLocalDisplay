# birdpiLocalDisplay
Building on the <a href="https://github.com/birdnet-team">Birdnet</a> <a href="https://github.com/Nachtzuster/BirdNET-Pi">BirdNet-Pi project</a>, this is a set of scripts for displaying latest detections locally on the Pi's HDMI monitor via the framebuffer.

The Birdnet-Pi project focuses on the web UI and/or cloud-based, or at least external platforms, for notifying users about detections. I wanted a way to hang my birdpi on our living room wall and let us see look over and see the latest detection on an hdmi monitor. But, I didn't want the overhead of running an X Server on the pi. So, here I use directly writing to the console framebuffer device an image generated with ImageMagick that contains a photo, the bird name, detection time, and confidence rating, for the latest detection. It's very simple code, the only external data used is via the <a href="https://github.com/tustoz/ornithophile">Ornithophile</a> API, for fetching the photo.



![IMG_8122](https://github.com/user-attachments/assets/0480f58f-ee95-4cad-81f0-268dc7058c4a)

<h2>Usage</h2>
Put this in your crontab:

```
# check for latest bird and display it on screen. ( every min)
* * * * *	~/BirdNET-Pi/scripts/birdimage.sh > /dev/null 2>&1
```

This will run every minute, and the birdimage.sh script will display any detection that happened in the last minute.
