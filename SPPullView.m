//
//  SPPullView.m
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


#import "SPPullView.h"

@interface SPPullView()

@property (nonatomic, assign) PullViewState state;
@property (nonatomic, assign) PullViewStyle style;
@property (nonatomic, strong) UILabel *lastUpdatedLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

- (id) initWithScrollView:(UIScrollView *)scrollView andStyle:(PullViewStyle) style;
- (id) initWithTableView:(UITableView *) tableView andStyle:(PullViewStyle) style;

@end

#define TEXT_COLOR	 [UIColor colorWithRed:192/255.0 green:192/255.0 blue:192/255.0 alpha:1.0]
#define kPullViewStateNormal @"Pull down to refresh"
#define kPullViewStateReady @"Release to refresh"
#define kPullViewStateLoading @"Loading..."

@implementation SPPullView

@synthesize scrollView = _scrollView, tableView = _tableView, delegate = _delegate;
@synthesize state = _state, style = _style, lastUpdatedLabel = _lastUpdatedLabel, statusLabel = _statusLabel, activityView = _activityView;

+ (id) pullViewWithScrollView:(UIScrollView *)scrollView andStyle:(PullViewStyle)style
{
    return [[self alloc] initWithScrollView:scrollView andStyle:style];
}

+ (id) pullViewWithTableView:(UITableView *)tableView andStyle:(PullViewStyle)style
{
    return [[self alloc] initWithTableView:tableView andStyle:style];
}

- (id) initWithScrollView:(UIScrollView *)scrollView andStyle:(PullViewStyle)style
{
    CGRect frame = CGRectMake(0.0f, 0.0f - scrollView.bounds.size.height, scrollView.bounds.size.width, scrollView.bounds.size.height);
    
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.scrollView = scrollView;
        self.tableView = nil;
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];        
        
        if (style == PullViewStyleDefault) 
        {
            self.style = PullViewStyleDefault;
            
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
            
            self.lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
            self.lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
            self.lastUpdatedLabel.textColor = TEXT_COLOR;
            self.lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            self.lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.lastUpdatedLabel.backgroundColor = [UIColor clearColor];
            self.lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:self.lastUpdatedLabel];
            
            self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
            self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            self.statusLabel.textColor = TEXT_COLOR;
            self.statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            self.statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.statusLabel.backgroundColor = [UIColor clearColor];
            self.statusLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:self.statusLabel];
            
            self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.activityView.frame = CGRectMake(30.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
            [self addSubview:self.activityView];
            
            [self setState:PullViewStateNormal];
        }
        else if (style == PullViewStyleSimple) 
        {
            self.style = PullViewStyleSimple;
            
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.backgroundColor = [UIColor whiteColor];
            
            self.lastUpdatedLabel = nil;
            
            self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 38.0f, self.frame.size.width, 20.0f)];
            self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            self.statusLabel.textColor = TEXT_COLOR;
            self.statusLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
            self.statusLabel.backgroundColor = [UIColor clearColor];
            self.statusLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:self.statusLabel];
            
            self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.activityView.frame = CGRectMake(self.frame.size.width / 2 - 20.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
            [self addSubview:self.activityView];
            
            [self setState:PullViewStateNormal];
        }
    }
    return self;
}

- (id) initWithTableView:(UITableView *)tableView andStyle:(PullViewStyle)style
{
    CGRect frame = CGRectMake(0.0f, 0.0f - tableView.bounds.size.height, tableView.bounds.size.width, tableView.bounds.size.height);
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.tableView = tableView;
        self.scrollView = nil;
        [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];        
        
        if (style == PullViewStyleDefault) 
        {
            self.style = PullViewStyleDefault;
        
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
            
            self.lastUpdatedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 30.0f, self.frame.size.width, 20.0f)];
            self.lastUpdatedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.lastUpdatedLabel.font = [UIFont systemFontOfSize:12.0f];
            self.lastUpdatedLabel.textColor = TEXT_COLOR;
            self.lastUpdatedLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            self.lastUpdatedLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.lastUpdatedLabel.backgroundColor = [UIColor clearColor];
            self.lastUpdatedLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:self.lastUpdatedLabel];
            
            self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 48.0f, self.frame.size.width, 20.0f)];
            self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            self.statusLabel.textColor = TEXT_COLOR;
            self.statusLabel.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
            self.statusLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
            self.statusLabel.backgroundColor = [UIColor clearColor];
            self.statusLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:self.statusLabel];
            
            self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.activityView.frame = CGRectMake(30.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
            [self addSubview:self.activityView];
            
            [self setState:PullViewStateNormal];
        }
        else if (style == PullViewStyleSimple) 
        {
            self.style = PullViewStyleSimple;
            
            [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:NULL];
            
            self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.backgroundColor = [UIColor whiteColor];
            
            self.lastUpdatedLabel = nil;
            
            self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - 38.0f, self.frame.size.width, 20.0f)];
            self.statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            self.statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
            self.statusLabel.textColor = TEXT_COLOR;
            self.statusLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
            self.statusLabel.backgroundColor = [UIColor clearColor];
            self.statusLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:self.statusLabel];
            
            self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.activityView.frame = CGRectMake(self.frame.size.width / 2 - 20.0f, frame.size.height - 38.0f, 20.0f, 20.0f);
            [self addSubview:self.activityView];
            
            [self setState:PullViewStateNormal];
        }
    }
    return self;
}

#pragma mark Setter for Pull View State

- (void) setState:(PullViewState) state 
{
    _state = state;
    
	switch (_state) 
    {
        case PullViewStateReady:
            if (self.style == PullViewStyleSimple) 
                self.statusLabel.hidden = NO;
            
            self.statusLabel.text = kPullViewStateReady;
            [self showActivity:NO animated:NO];
            if (self.scrollView) 
                self.scrollView.contentInset = UIEdgeInsetsZero;
            else if (self.tableView)
                self.tableView.contentInset = UIEdgeInsetsZero;
			break;
            
        case PullViewStateNormal:
            if (self.style == PullViewStyleSimple) 
                self.statusLabel.hidden = NO;
            
            self.statusLabel.text = kPullViewStateNormal;
            [self showActivity:NO animated:NO];
            [self refreshLastUpdatedDate];
            if (self.scrollView) 
                self.scrollView.contentInset = UIEdgeInsetsZero;
            else if (self.tableView)
                self.tableView.contentInset = UIEdgeInsetsZero;
			break;
            
        case PullViewStateLoading:
            if (self.style == PullViewStyleSimple) 
                self.statusLabel.hidden = YES;
            
            [self showActivity:YES animated:YES];
            if (self.scrollView)
                self.scrollView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
            else if (self.tableView)
                self.tableView.contentInset = UIEdgeInsetsMake(60.0f, 0.0f, 0.0f, 0.0f);
			break;
            
		default:
			break;
	}
}

#pragma mark UIScrollView Checking

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context 
{
    if ([keyPath isEqualToString:@"contentOffset"]) 
    {
        if (self.scrollView) 
        {
            if (self.scrollView.isDragging) 
            {
                if (self.state == PullViewStateReady) 
                {
                    if (self.scrollView.contentOffset.y > -65.0f && self.scrollView.contentOffset.y < 0.0f) 
                        [self setState:PullViewStateNormal];
                } 
                else if (self.state == PullViewStateNormal) 
                {
                    if (self.scrollView.contentOffset.y < -65.0f)
                        [self setState:PullViewStateReady];
                } 
                else if (self.state == PullViewStateLoading) 
                {
                    if (self.scrollView.contentOffset.y >= 0)
                        self.scrollView.contentInset = UIEdgeInsetsZero;
                    else
                        self.scrollView.contentInset = UIEdgeInsetsMake(MIN(-self.scrollView.contentOffset.y, 60.0f), 0, 0, 0);
                }
            } 
            else 
            {
                if (self.state == PullViewStateReady) 
                {
                    [UIView animateWithDuration:0.2f animations:^
                     {
                         [self setState:PullViewStateLoading]; 
                     }];
                    
                    if ([self.delegate respondsToSelector:@selector(pullViewShouldRefresh:)])
                        [self.delegate pullViewShouldRefresh:self];
                }
            }
        }
        else if (self.tableView)
        {
            if (self.tableView.isDragging) 
            {
                if (self.state == PullViewStateReady) 
                {
                    if (self.tableView.contentOffset.y > -65.0f && self.tableView.contentOffset.y < 0.0f) 
                        [self setState:PullViewStateNormal];
                } 
                else if (self.state == PullViewStateNormal) 
                {
                    if (self.tableView.contentOffset.y < -65.0f)
                        [self setState:PullViewStateReady];
                } 
                else if (self.state == PullViewStateLoading) 
                {
                    if (self.tableView.contentOffset.y >= 0)
                        self.tableView.contentInset = UIEdgeInsetsZero;
                    else
                        self.tableView.contentInset = UIEdgeInsetsMake(MIN(-self.scrollView.contentOffset.y, 60.0f), 0, 0, 0);
                }
            } 
            else 
            {
                if (self.state == PullViewStateReady) 
                {
                    [UIView animateWithDuration:0.2f animations:^
                     {
                         [self setState:PullViewStateLoading]; 
                     }];
                    
                    if ([self.delegate respondsToSelector:@selector(pullViewShouldRefresh:)])
                        [self.delegate pullViewShouldRefresh:self];
                }
            }
        }
        
    }
}

- (void)refreshLastUpdatedDate 
{
    if (self.style != PullViewStyleSimple) 
    {
        NSDate *date = [NSDate date];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setAMSymbol:@"AM"];
        [formatter setPMSymbol:@"PM"];
        [formatter setDateFormat:@"MM/dd/yy h:mm a"];
        self.lastUpdatedLabel.text = [NSString stringWithFormat:@"Last Updated: %@", [formatter stringFromDate:date]];
    }
}

- (void) showActivity:(BOOL)shouldShow animated:(BOOL)animated 
{
    if (shouldShow) 
        [self.activityView startAnimating];
    else 
        [self.activityView stopAnimating];
}

- (void) finishedLoading 
{
    if (self.state == PullViewStateLoading) 
    {
        [UIView animateWithDuration:0.3f animations:^
         {
             [self setState:PullViewStateNormal];
         }];
    }
}

#pragma mark Dealloc

- (void) dealloc 
{
	[self.scrollView removeObserver:self forKeyPath:@"contentOffset"];  
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

@end

