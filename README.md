iOS Ingress
===========

Google's AR Game Ingress port for iOS

Help
----

I need few invitations for testing activation and power cubes. If you have some, please send me email at studnicka(at)aacode.cz. Thank you.

Getting map data from API
-------------------------

I have big problems with this part. Ingress uses cell/tile IDs for getting data from API and I don't know how it works. Few examples are implemented by default in [API cellsAsHex]. If somebody knows how it works, please contact me.

Choosing faction
----------------

Choosing faction is not yet implemented, but you can choose by calling this method:

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
