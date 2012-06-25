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
    PullViewStyleDefault,
    PullViewStyleSimple
} PullViewStyle;

typedef enum 
{
   	PullViewStateNormal = 0,
	PullViewStateReady,
	PullViewStateLoading
} PullViewState;

@class SPPullView;

@protocol  SPPullViewDelegate <NSObject>

- (void) pullViewShouldRefresh:(SPPullView *) view;

@end

@interface SPPullView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id <SPPullViewDelegate> delegate;

+ (id) pullViewWithScrollView:(UIScrollView *)scrollView andStyle:(PullViewStyle) style;
+ (id) pullViewWithTableView:(UITableView *) tableView andStyle:(PullViewStyle) style;

- (void) refreshLastUpdatedDate;
- (void) finishedLoading;

@end




