# iOS Hit

### Introduction

iOSHit is a library that encapsules some useful iOS functionallity together for
C++ programmers. Now including:

* [ads]        App banner support. iAdHelper is an optional helper class for
                   StartApp ADs, for more info see: http://www.startapp.com/
* [appirater]  App rating. Thanks to Arash Payan's Obj-C work, for more info
                   see: https://github.com/arashpayan/appirater/
* [gamecenter] Game center accessibility for leaboard and achievement.
* [native]     Miscellaneous such as
                   getting current language localization,
                   getting network reachability,
                   popping message box and question box.
* [share]      Sharing via SNS.
* [store]      IAP support.

### How to Use

1. Simply integrate modules you need into your project.
2. Call XXX::open() to initialize a module.
3. Call setDevId("XXX")/setAppId("YYY") if needed.
4. Write your invocation.
5. Call XXX::close() to dispose a module.

### TODO

Polishing documents.

Adding more useful modules?
