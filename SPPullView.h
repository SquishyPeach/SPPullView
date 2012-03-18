//
//  SPPullView.h
//
//  Copyright (c) 2012 Squishy Peach Creative.
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

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


