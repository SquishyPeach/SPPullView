//
//  SPPullView.h
//  Sports
//
//  Created by Scott Petit on 3/18/12.
//  Copyright (c) 2012 Squishy Peach Creative. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum 
{
    PullViewStateNormal = 0,
	PullViewStateReady,
	PullViewStateLoading
} PullViewState;

@protocol PullViewDelegate;

@interface SPPullView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) id <PullViewDelegate> delegate;

- (void) refreshLastUpdatedDate;
- (void) finishedLoading;

+ (id) pullViewWithScrollView:(UIScrollView *) scrollView;
- (id) initWithScrollView:(UIScrollView *)scrollView;

@end

@protocol  PullViewDelegate <NSObject>

@optional
- (void) pullViewShouldRefresh:(SPPullView *) view;
- (NSDate *) pullViewLastUpdated:(SPPullView *) view;

@end


