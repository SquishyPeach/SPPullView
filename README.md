What Is It
==========

SPPullView is a simple pull to refresh implementation using a UIScrollView.  Similar to refresh views used by the New York Times, Facebook, and Sparrow.  Updated for ARC support and based off of [Pull To Refresh View](https://github.com/chpwn/PullToRefreshView).  See example image from New York Times app below.

![New York Times PullView](http://imgur.com/vJlVI.png)


How To Get Started
==================

-  Download SPPullView and add SPPullView.h and SPPullView.m to your project
-  Import SPPullView.h to your class
-  Create an instance variable for SPPullView in your classes .h like this and synthesize it in your .m
-  In your viewDidLoad (or wherever you'd like) create the PullView and pass in the UIScrollView you are using

SPPullView now has a style property (PullViewStyleDefault and PullViewStyleSimple) that can be passed in init to change the style of the PullView.  If you don't pass in a property or use the old init method it will just load the default Style.  However the new styles can be accessed as such:

``` 
self.pullView = [SPPullView pullViewWithScrollView:self.scrollView andStyle:PullViewStyleSimple];
```

This returns solely cosmetic changes, such as the removal of the last updated method.  Also it replaces the loading text with the Activity View.  

``` 
self.pullView = [SPPullView pullViewWithScrollView:self.scrollView];
```

-  If needed add yourself as a delegate of the PullView (Make sure to register as a SPPullViewDelegate in your .h)

``` 
self.pullView.delegate = self;
```

-  Then just add the pullView to your UIScrollView

``` 
[self.scrollView addSubview:self.pullView];
```

-  The only thing you need to worry about is letting the PullView know when your data is done loading, just as simple as calling

``` 
[self.pullView finishedLoading];
```

Delegate Methods
================

``` 
//Called when the user pulls to refresh (this is when you should update your data)
- (void) pullViewShouldRefresh: (SPPullView *) view;
```