iOS Ingress
===========

Google's AR Game Ingress port for iOS

Help
----

I need few invitations for testing activation and also some power cubes. If you have some, please send me email at studnicka(at)aacode.cz. Thank you.

Getting map data from API
-------------------------

**This is temporary fixed by loading data from intel instead of API, so IITC's script can be used. But still needs to be fixed, because this solution is super slow and doesn't load XM and dropped items.**

I have big problems with this part. Ingress uses cell/tile IDs for getting data from API and I don't know how it works. If somebody knows how it works, please contact me at studnicka(at)aacode.cz. Thank you.

Few examples for New York (40.714021,-74.00588):

89c25a1750000000
89c25a1050000000
89c25a1910000000
89c25a1a10000000
89c25a1710000000
89c25a1850000000
89c25a1110000000
89c25a1a50000000
89c25a16d0000000
89c25a10d0000000
89c25a1990000000
89c25a1a90000000
89c25a1790000000
89c25a1090000000
89c25a19d0000000
89c25a1bd0000000
89c25a1830000000
89c25a1070000000
89c25a1a30000000
89c25a1770000000
89c25a1970000000
89c25a1130000000
89c25a1a70000000
89c25a1730000000
89c25a10f0000000
89c25a19b0000000
89c25a10b0000000
89c25a19f0000000
89c25a17b0000000

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
