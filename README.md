iOS Ingress
===========

Fully playable Google's AR Game Ingress port for iOS

Newest IPA can be downloaded here: https://www.dropbox.com/s/q28f2bj2bgt2vxj/Ingress.ipa. You need to be developer or have jailbreak to install it.

TODO
----

- choosing faction (+GUI)
- better XM collecting
- speed and memory optimalizations
- GUI improvements (mainly 3.5" screen optimalization)
- linking portals
- maybe 3D Scanner?

Choosing faction
----------------

Choosing faction is not yet implemented, but you can choose by calling this method:

    API
        - (void)chooseFaction:(NSString *)faction completionHandler:(void (^)(void))handler;
        
        "ALIENS"        = enlightened
        "RESISTANCE"    = resistance

Video
-----

Gameplay video

http://youtu.be/Jewu0rpKrrU

Video of codename creating and intro which have been recently finished

http://youtu.be/jRi8PuquP50

Screenshots
-----------

![Screenshot 1](http://i.imgur.com/XJLt6wn.png)
![Screenshot 2](http://i.imgur.com/r21wnTc.png)
![Screenshot 3](http://i.imgur.com/FIYe6bm.png)
![Screenshot 4](http://i.imgur.com/V1r6eER.png)
![Screenshot 5](http://i.imgur.com/Joik8Qe.png)
![Screenshot 6](http://i.imgur.com/hLajkw3.png)
![Screenshot 7](http://i.imgur.com/uC9hXxk.png)

Attribution & License
---------------------

This project is licensed under the permissive ISC license. Parts imported from other projects remain under their respective licenses.
