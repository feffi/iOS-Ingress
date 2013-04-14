iOS Ingress
===========

Google's AR Game Ingress port for iOS

Account activation
------------------

a) Via Android device

b) Via few API calls

    1) Send handshake with parameter "activationCode" with value of your activation code

    2) Send handshake with parameter "tosAccepted" with value "1" as you agree with Terms of Service (http://www.ingress.com/terms)

    3) Choose nickname
    
    API
        - (void)validateNickname:(NSString *)nickname completionHandler:(void (^)(void))handler;
        - (void)persistNickname:(NSString *)nickname completionHandler:(void (^)(void))handler;

    3) Choose faction
    
    API
        - (void)chooseFaction:(NSString *)faction completionHandler:(void (^)(void))handler;
        
        "ALIENS"        = enlightened
        "RESISTANCE"    = resistance

Getting map data from API
-------------------------

I have big problems with this part. Ingress uses cell/tile IDs for getting data from API and I don't know how it works. Few examples from Czech republic are implemented by default in [API cellsAsHex]. Help with this would be nice.

You can get cellsIDs by catching Android app's communication.

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
