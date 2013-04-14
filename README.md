iOS Ingress
===========

Google's AR Game Ingress port for iOS

Getting map data from API
-------------------------

I have big problems with this part. Ingress uses cell/tile IDs for getting data from API and I don't know how it works. Few examples from Czech republic are implemented by default in [API cellsAsHex]. Help with this would be nice.

You can get cellsIDs by catching Android app's communication.

Storyboard
----------

You need to install font **Coda-Regular.ttf** to open Storyboard.

Choosing faction
----------------

    API
        - (void)chooseFaction:(NSString *)faction completionHandler:(void (^)(void))handler;
        
        "ALIENS"        = enlightened
        "RESISTANCE"    = resistance

Screenshots
-----------

![Screenshot 1](http://i.imgur.com/Od5sVxh.jpg)
![Screenshot 2](http://i.imgur.com/r21wnTc.png)
![Screenshot 3](http://i.imgur.com/FIYe6bm.png)
![Screenshot 4](http://i.imgur.com/V1r6eER.png)
![Screenshot 5](http://i.imgur.com/Joik8Qe.png)

Attribution & License
---------------------

This project is licensed under the permissive ISC license. Parts imported from other projects remain under their respective licenses.
