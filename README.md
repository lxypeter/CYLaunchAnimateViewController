CYLaunchAnimateViewController
======================
A simple controller to make animate launch screen. It can be used as an introduction page or ad page when app is launched or reactived. It's extremely easy to use(Only two lines of code are required!).

Please check the .h to see how to customize anything

###Demo
There are some kinds of animation effects ready to be used.

![alt tag](http://i.imgur.com/DBnUaEq.gif) ![alt tag](http://i.imgur.com/qJ4z0QV.gif)
![alt tag](http://i.imgur.com/ofWbJPO.gif) ![alt tag](http://i.imgur.com/kGGAn4W.gif)
![alt tag](http://i.imgur.com/m5bRlwm.gif)

Please check the animation effect enum in CYLaunchAnimateViewController.h.

###How to use
The controller should be used in the AppDelegate.m:

- 1. Import CYLaunchAnimateViewController.h
```objc
  #import "CYLaunchAnimateViewController.h"
```
- 2. Initialize a customized launch view.
```objc
  //just an example
  UIView *launchView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
  /*
  * launchView setting...
  */
```
- 3. Initialize a CYLaunchAnimateViewController(Before the initialization, please make sure the keyWindow of application have been set.)
```objc
  CYLaunchAnimateViewController *launchController = [[CYLaunchAnimateViewController alloc]initWithContentView:launchView animateType:CYLaunchAnimateTypePointZoomOut showSkipButton:YES];
  [launchController show];
```

You don't have to used the contentView with screen size. View with any size is OK! And the view will be set in the center of screen automatically.

![alt tag](http://i.imgur.com/zXdzlEs.gif)
