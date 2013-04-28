iOS Ingress
===========

Google's AR Game Ingress port for iOS

Video
-----

Video of codename creating and intro which have been recently finished

http://youtu.be/jRi8PuquP50

Getting map data from API
-------------------------

**Got it now, it's s2-geometry-library (https://code.google.com/p/s2-geometry-library-java/)**

**This is temporary fixed by loading data from intel instead of API, so IITC's script can be used. But still needs to be fixed, because this solution is super slow and doesn't load XM and dropped items.**

~~I have big problems with this part. Ingress uses cell/tile IDs for getting data from API and I don't know how it works.~~

Choosing faction
----------------

Choosing faction is not yet implemented, but you can choose by calling this method:

    API
        - (void)chooseFaction:(NSString *)faction completionHandler:(void (^)(void))handler;
        
        "ALIENS"        = enlightened
        "RESISTANCE"    = resistance

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
