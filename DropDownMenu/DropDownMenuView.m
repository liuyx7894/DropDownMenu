//
//  DropDownMenuViewController.m
//  DropDownMenu
//
//  Created by Louis Liu on 23/09/2016.
//  Copyright © 2016 Louis Liu. All rights reserved.
//

#import "DropDownMenuView.h"
#define checkLabelTag 100
#define BackColor [UIColor colorWithRed:244.0f/255.0f green:244.0f/255.0f blue:244.0f/255.0f alpha:1.0]
typedef enum:NSInteger
{
    DropDownMenuStatusOpen = 0,
    DropDownMenuStatusClose = 1,
    DropDownMenuStatusExchange = 2
}DropDownMenuStatus;

@implementation DropDownIndexPath

-(instancetype) initIndexPathWith:(NSInteger)menuIndex leftTableIndex:(NSInteger) leftTableIndex rightTableIndex:(NSInteger) rightTableIndex isLeftTable:(BOOL) isLeftTable{
    self = [super init];
    if (self) {
        _menuIndex = menuIndex;
        _isLeftTable = isLeftTable;
        _leftTableIndex = leftTableIndex;
        _rightTableIndex = rightTableIndex;
    }
    
    return self;
}


+(instancetype) indexPathWith:(NSInteger)menuIndex leftTableIndex:(NSInteger) leftTableIndex rightTableIndex:(NSInteger) rightTableIndex isLeftTable:(BOOL) isLeftTable{
    
    return [[DropDownIndexPath alloc] initIndexPathWith:menuIndex leftTableIndex:leftTableIndex rightTableIndex:rightTableIndex isLeftTable:isLeftTable];
}

@end


@interface DropDownMenuView ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (strong, nonatomic) UITableView *leftTableView;
@property (strong, nonatomic) UITableView *rightTableView;
@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) NSArray *menuTitleLables;
@property (strong, nonatomic) NSArray *menuTitleIndicators;
@property (strong, nonatomic) NSArray *menuTitleBGLayer;
@property (strong, nonatomic) NSMutableDictionary<NSNumber*, DropDownIndexPath *> *selectedIndexs;


@property (assign, nonatomic) NSInteger currentSelectedMenuIndex;
@property (assign, nonatomic) NSInteger numberOfMenu;
@property (assign, nonatomic) double menuLabelWidth;
@property (assign, nonatomic) NSInteger menuLabelHeight;
@property (assign, nonatomic) NSInteger rightTableViewWidht;
@property (assign, nonatomic) NSInteger menuViewHeight;
@property (assign, nonatomic) NSInteger selectedLeftTableIndex;
@property (assign, nonatomic) BOOL showingMenu;

@end

@implementation DropDownMenuView

-(void)setDelegate:(id<DropDownMenuDelegate> )delegate{
    _delegate = delegate;
    
    _numberOfMenu = [_delegate numberOfMenu];
    _menuLabelWidth = screenWidth/_numberOfMenu;
    _selectedIndexs = [[NSMutableDictionary alloc] initWithCapacity:_numberOfMenu];
    
    
    NSMutableArray *tmpTitles = [[NSMutableArray alloc] initWithCapacity:_numberOfMenu];
    NSMutableArray *tmpIndicators = [[NSMutableArray alloc] initWithCapacity:_numberOfMenu];
    NSMutableArray *tmpBGLayers = [[NSMutableArray alloc] initWithCapacity:_numberOfMenu];
    
    for(int i=0; i<_numberOfMenu; i++){
        CALayer *tmpBGLayer = [self creageMenuBGLayerWithIndex:i];
        UILabel *tmpLabel = [self createMenuTitleLabelWithIndex:i andParentLayer:tmpBGLayer];
        CAShapeLayer *tmpLayer = [self createMenuTitleIndicatorWithRect:i labelRect:tmpLabel.frame];
        
        
        [self.layer addSublayer:tmpBGLayer];
        [self addSubview: tmpLabel];
        [self.layer addSublayer: tmpLayer];
        
        [tmpTitles addObject:tmpLabel];
        [tmpIndicators addObject:tmpLayer];
        [tmpBGLayers addObject:tmpBGLayer];
    }
    
    _menuTitleLables = [tmpTitles copy];
    _menuTitleIndicators = [tmpIndicators copy];
    _menuTitleBGLayer = [tmpBGLayers copy];
    
}

- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, screenWidth, height)];
    if(self){
        _currentSelectedMenuIndex = -1;
        _selectedLeftTableIndex = -1;
        _menuLabelHeight = height;
        _rightTableViewWidht = screenWidth-100;
        _showingMenu= false;
        
        [self initTableViews];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onMenuTitleTapped:)]];
        
    }
    return self;
}



-(void)initTableViews{
    _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.origin.y+_menuLabelHeight, screenWidth, screenHeight)];
    [_containerView setBackgroundColor:[UIColor clearColor]];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapBackground:)];
    tapGesture.delegate = self;
    [_containerView addGestureRecognizer:tapGesture];
    
    
    _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_leftTableView setDelegate:self];
    [_leftTableView setDataSource:self];
    [_leftTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [_leftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [_leftTableView setSeparatorInset:UIEdgeInsetsMake(_leftTableView.separatorInset.top,
                                                       0,
                                                       _leftTableView.separatorInset.bottom,
                                                       _leftTableView.separatorInset.right)];
    [_leftTableView setSeparatorColor:seperatorColor];
    
    
    
    _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [_rightTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [_rightTableView setSeparatorColor:seperatorColor];
    [_rightTableView setDelegate:self];
    [_rightTableView setDataSource:self];
    [_rightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    [_containerView addSubview:_leftTableView];
    [_containerView addSubview:_rightTableView];
}

-(UILabel *) createMenuTitleLabelWithIndex:(NSInteger)index andParentLayer:(CALayer *)parentLayer{
    
    UILabel *label = [[UILabel alloc]initWithFrame: CGRectZero];
    [label setFont:[UIFont systemFontOfSize:14 weight:UIFontWeightLight]];
    [label setTag:index];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:[_delegate titleForMenuAtIndex:index]];
    
    [label setFrame:CGRectMake(_menuLabelWidth*index,
                               (_menuLabelHeight-_menuLabelHeight)/2,
                               _menuLabelWidth,
                               _menuLabelHeight)];
    
#pragma add seperator
    if(index>0){
        CALayer *verticalSeperator = [[CALayer alloc] init];
        [verticalSeperator setFrame:CGRectMake(0, 0, 1, _menuLabelHeight)];
        
        [verticalSeperator setBackgroundColor:seperatorColor.CGColor];
        
        [parentLayer addSublayer:verticalSeperator];
    }
    
    CALayer *horizontalSeperator = [[CALayer alloc]init];
    [horizontalSeperator setFrame:CGRectMake(0, _menuLabelHeight-1, _menuLabelWidth, 1)];
    
    [horizontalSeperator setBackgroundColor:seperatorColor.CGColor];
    [parentLayer addSublayer:horizontalSeperator];
    
    return label;
}

-(CAShapeLayer *) createMenuTitleIndicatorWithRect:(NSInteger)index labelRect:(CGRect)labelRect{
    
    CAShapeLayer *indicator = [[CAShapeLayer alloc]init];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(4, 5)];
    [path closePath];
    
    indicator.path = path.CGPath;
    indicator.lineWidth = 1;
    indicator.fillColor = indicatorColor.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(indicator.path, nil, indicator.lineWidth, kCGLineCapButt, kCGLineJoinMiter, indicator.miterLimit);
    indicator.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    
    indicator.position = CGPointMake((index+1)*_menuLabelWidth-10,
                                     labelRect.size.height/2+labelRect.origin.y);
    
    return indicator;
}

-(CALayer *) creageMenuBGLayerWithIndex:(NSInteger)index{
    CALayer *bgLayer = [[CALayer alloc]init];
    [bgLayer setFrame:CGRectMake(index*_menuLabelWidth, 0, _menuLabelWidth, _menuLabelHeight)];
    [bgLayer setBackgroundColor:defaultBGColor.CGColor];
    return bgLayer;
}

-(void)SingleTableViewHandler:(NSInteger)tappedIndex open:(BOOL)open status:(DropDownMenuStatus)status complete:(void(^)())complete{
    
    [self animeMenuWith:tappedIndex open:open complete:^{
        [self animeContainerViewWith:tappedIndex open:open status:status complete:^{
            
            if(open){
                [_leftTableView setFrame:CGRectMake(0, 0, screenWidth, 0)];//reset height
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                
                if(open){
                    _currentSelectedMenuIndex = tappedIndex;
                    
                    [_leftTableView reloadData];
                    [_leftTableView setFrame:CGRectMake(0, 0, screenWidth, _menuViewHeight)];
                    
                }else{
                    _currentSelectedMenuIndex = -1;
                    [_leftTableView setFrame:CGRectMake(0, 0, screenWidth, 0)];
                    
                }
                
            } completion:^(BOOL finished) {
                if(complete != nil){
                    complete();
                }
            }];
        }];
    }];
}

-(void)DoubleTableViewHandler:(NSInteger)tappedIndex open:(BOOL)open status:(DropDownMenuStatus)status complete:(void(^)())complete{
    
    [self animeMenuWith:tappedIndex open:open complete:^{
        [self animeContainerViewWith:tappedIndex open:open status:status complete:^{
            
            //reset height
            if(open){
                [_leftTableView setFrame:CGRectMake(0, 0, screenWidth-_rightTableViewWidht, 0)];
                [_rightTableView setFrame:CGRectMake(screenWidth-_rightTableViewWidht, 0, _rightTableViewWidht,0)];
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                
                if(open){
                    _currentSelectedMenuIndex = tappedIndex;
                    [_leftTableView reloadData];
                    [_rightTableView reloadData];
                    
                    [_leftTableView setFrame:CGRectMake(0,
                                                        0,
                                                        screenWidth-_rightTableViewWidht,
                                                        _menuViewHeight)];
                    
                    [_rightTableView setFrame:CGRectMake(screenWidth-_rightTableViewWidht,
                                                         0,
                                                         _rightTableViewWidht,
                                                         _menuViewHeight)];
                    
                }else{
                    _currentSelectedMenuIndex = -1;
                    
                    [_leftTableView setFrame:CGRectMake(0,
                                                        0,
                                                        screenWidth-_rightTableViewWidht,
                                                        0)];
                    [_rightTableView setFrame:CGRectMake(screenWidth-_rightTableViewWidht,
                                                         0,
                                                         _rightTableViewWidht,
                                                         0)];
                }
                
            } completion:^(BOOL finished) {
                if(complete != nil){
                    complete();
                }
            }];
        }];
    }];
}

-(void)CustomViewHandler:(NSInteger)tappedIndex open:(BOOL)open status:(DropDownMenuStatus)status complete:(void(^)())complete{
    UIView *customerView = nil;
    if([self.delegate respondsToSelector:@selector(viewForCustomViewAtIndex:)]){
        customerView = [_delegate viewForCustomViewAtIndex:tappedIndex];
    }
    
    assert(customerView != nil);
    if(open){
        [customerView setFrame:CGRectMake(0, 0, screenWidth, 0)];
        [_containerView addSubview:customerView];
    }
    
    [self animeMenuWith:tappedIndex open:open complete:^{
        [self animeContainerViewWith:tappedIndex open:open status:status complete:^{
            
            [UIView animateWithDuration:0.3 animations:^{
                
                if(open){
                    _currentSelectedMenuIndex = tappedIndex;
                    
                    [customerView setFrame:CGRectMake(0, 0, screenWidth, _menuViewHeight)];
                }else{
                    _currentSelectedMenuIndex = -1;
                    [customerView setFrame:CGRectMake(0, 0, screenWidth, 0)];
                }
                
            } completion:^(BOOL finished) {
                
                if(!open){
                    [customerView removeFromSuperview];
                }
                
                if(complete != nil){
                    complete();
                }
            }];
        }];
    }];
}

-(void)showMenuByIndex:(NSInteger)index status:(DropDownMenuStatus)status complete:(void(^)())complete{
    DropDownMenuType currentType = [_delegate typeForMenuAtIndex:index];
    
    switch (currentType) {
        case DropDownMenuTypeSingleTableView:
            [self SingleTableViewHandler:index open:true status:status complete:complete];
            break;
            
        case DropDownMenuTypeDoubleTableView:
            [self DoubleTableViewHandler:index open:true status:status complete:complete];
            break;
            
        case DropDownMenuTypeCustomerView:
            [self CustomViewHandler:index open:true status:status complete:complete];
            break;
            
        default:
            break;
    }
}

-(void)hideMenuByIndex:(NSInteger)index status:(DropDownMenuStatus)status complete:(void(^)())complete{
    DropDownMenuType currentType = [_delegate typeForMenuAtIndex:index];
    
    switch (currentType) {
        case DropDownMenuTypeSingleTableView:
            [self SingleTableViewHandler:index open:false status:status complete:complete];
            break;
            
        case DropDownMenuTypeDoubleTableView:
            [self DoubleTableViewHandler:index open:false status:status complete:complete];
            break;
            
        case DropDownMenuTypeCustomerView:
            [self CustomViewHandler:index open:false status:status complete:complete];
            
            break;
            
        default:
            break;
    }
}
-(void)hideMenuByIndex:(NSInteger)index complete:(void(^)())complete{
    [self hideMenuByIndex:index status:DropDownMenuStatusClose complete:complete];
}

-(void) onMenuTitleTapped:(UITapGestureRecognizer *)sender{
    if(_showingMenu){
        return;
    }
    
    _showingMenu = true;
    CGPoint touchPoint = [sender locationInView:self];
    NSInteger tappedIndex = touchPoint.x / (screenWidth / _numberOfMenu);
    
    if ([_delegate respondsToSelector:@selector(heightForMenuViewAtIndex:)]) {
        _menuViewHeight = [_delegate heightForMenuViewAtIndex:tappedIndex];
    }else{
        _menuViewHeight = screenWidth*0.5;
    }
    
    DropDownMenuStatus menuStatus = [self currentMenuStatus:tappedIndex];
    
    switch (menuStatus) {
        case DropDownMenuStatusOpen:
        {
            [self showMenuByIndex:tappedIndex status:menuStatus complete:^{
                _showingMenu = false;
            }];
            
            break;
        }
        case DropDownMenuStatusClose:
        {
            [self hideMenuByIndex:tappedIndex status:menuStatus complete:^{
                _showingMenu = false;
            }];
            break;
        }
        case DropDownMenuStatusExchange:
        {
            [self hideMenuByIndex:_currentSelectedMenuIndex status:menuStatus complete:^{
                [self showMenuByIndex:tappedIndex status:menuStatus complete:^{
                    _showingMenu = false;
                }];
            }];
            break;
        }
    }
}

-(void)setSelectingByIndexs:(NSArray<DropDownIndexPath *>*) settingIndexs{
    if(_delegate == nil){
        NSLog(@"没有delegate  不能修改默认选项");
        return;
    }
    
    for (int i=0; i<settingIndexs.count; i++) {
        
        DropDownIndexPath *indexPath = settingIndexs[i];
        NSString *selectedTitle = [_delegate contentForRowAtIndexPath:indexPath];
        if(selectedTitle != nil){
            if([selectedTitle isEqualToString:@"全部"]){
                
                [((UILabel *) _menuTitleLables[indexPath.menuIndex]) setText:[_delegate titleForMenuAtIndex:indexPath.menuIndex]];
            }else{
                [((UILabel *) _menuTitleLables[indexPath.menuIndex]) setText:selectedTitle];
            }
            
            [_selectedIndexs setObject:indexPath forKey:[NSNumber numberWithInteger:indexPath.menuIndex]];
            
            if([_delegate typeForMenuAtIndex:indexPath.menuIndex] == DropDownMenuTypeDoubleTableView){
                _selectedLeftTableIndex = indexPath.leftTableIndex;
            }
        }
        
    }
}

-(DropDownMenuStatus)currentMenuStatus:(NSInteger)tappedIndex{
    if(_currentSelectedMenuIndex == -1){
        return DropDownMenuStatusOpen;
    }else if(_currentSelectedMenuIndex == tappedIndex){
        return DropDownMenuStatusClose;
    }else{
        return DropDownMenuStatusExchange;
    }
}

-(void)animeMenuWith:(NSInteger)index open:(BOOL)open complete:(void(^)())complete{
    CAShapeLayer *indicator = _menuTitleIndicators[index];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = open ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    
    //change titleLabel color
    if(open){
        [((UILabel *)_menuTitleLables[index]) setTextColor:selectedLabelColor];
        indicator.fillColor = selectedLabelColor.CGColor;
    }else{
        [((UILabel *)_menuTitleLables[index]) setTextColor:defaultLabelColor];
        indicator.fillColor = indicatorColor.CGColor;
    }
    
    complete();
}

-(void)animeContainerViewWith:(NSInteger)index open:(BOOL)open status:(DropDownMenuStatus)status complete:(void(^)())complete{
    if(status == DropDownMenuStatusExchange){
        complete();
        return;
    }
    
    if(open){
        [self.superview addSubview:_containerView];
        complete();
        
        [UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            [_containerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        } completion:nil];
    }else{
        complete();
        [UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            [_containerView setBackgroundColor:[UIColor clearColor]];
        } completion:^(BOOL finished) {
            [_containerView removeFromSuperview];
        }];
    }
    
    
}

-(void) onTapBackground:(UITapGestureRecognizer *)sender{
    [self hideMenuByIndex:_currentSelectedMenuIndex status:DropDownMenuStatusClose complete:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_currentSelectedMenuIndex == -1){return 0;}
    
    
    DropDownMenuType currentType = [_delegate typeForMenuAtIndex:_currentSelectedMenuIndex];
    DropDownIndexPath *indexPath;
    
    if(currentType == DropDownMenuTypeSingleTableView){
        
        indexPath = [DropDownIndexPath indexPathWith:_currentSelectedMenuIndex
                                      leftTableIndex:section
                                     rightTableIndex:-1
                                         isLeftTable:true];
        
    }else if(currentType == DropDownMenuTypeDoubleTableView){
        DropDownIndexPath *selectedIndex = [_selectedIndexs objectForKey:[NSNumber numberWithInteger:_currentSelectedMenuIndex]];
        
        if(_leftTableView == tableView){
            indexPath = [DropDownIndexPath indexPathWith:_currentSelectedMenuIndex
                                          leftTableIndex:section
                                         rightTableIndex:-1
                                             isLeftTable:true];
        }else{
            indexPath = [DropDownIndexPath indexPathWith:_currentSelectedMenuIndex
                                          leftTableIndex:selectedIndex.leftTableIndex
                                         rightTableIndex:-1
                                             isLeftTable:false];
        }
        
    }
    
    return [_delegate numberOfRowInMenuAtIndexPath:indexPath];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if(_leftTableView == tableView){
        
        [self leftTableViewHandler:cell index:indexPath];
        
    }else if(_rightTableView == tableView){
        
        [self rightTableViewHandler:cell index:indexPath];
        
    }
    
    return cell;
}

-(void)leftTableViewHandler:(UITableViewCell *)cell index:(NSIndexPath *)index{
    
    DropDownMenuType currentType = [_delegate typeForMenuAtIndex:_currentSelectedMenuIndex];
    DropDownIndexPath *selectedLeftIndex = [_selectedIndexs objectForKey:[NSNumber numberWithInteger:_currentSelectedMenuIndex]];
    UILabel *checkMarkLabel = [self getCheckMarkLabelBy:cell];
    
    DropDownIndexPath *currentIndex = [DropDownIndexPath indexPathWith:_currentSelectedMenuIndex
                                                        leftTableIndex:index.row
                                                       rightTableIndex:-1
                                                           isLeftTable:true];
    if(currentType == DropDownMenuTypeSingleTableView){
        if(selectedLeftIndex != nil && selectedLeftIndex.leftTableIndex == index.row){
            
            [checkMarkLabel setHidden:false];
            [_leftTableView selectRowAtIndexPath:[NSIndexPath
                                                  indexPathForRow:index.row
                                                  inSection:0]
                                        animated:false
                                  scrollPosition:UITableViewScrollPositionNone];
            
        }else{
            [checkMarkLabel setHidden:true];
        }
        
    }else if(currentType == DropDownMenuTypeDoubleTableView){
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
        if(selectedLeftIndex != nil){
            if(selectedLeftIndex.leftTableIndex == index.row){//default cell bg color
                myBackView.backgroundColor = [UIColor whiteColor];
            }else{
                myBackView.backgroundColor = BackColor;
            }
        }else{
            if(index.row == 0){
                myBackView.backgroundColor = [UIColor whiteColor];
            }else{
                myBackView.backgroundColor = BackColor;
            }
            
        }
        [cell setBackgroundView:myBackView];
        
        [_leftTableView selectRowAtIndexPath:[NSIndexPath
                                              indexPathForRow:selectedLeftIndex.leftTableIndex
                                              inSection:0]
                                    animated:false
                              scrollPosition:UITableViewScrollPositionNone];
        [checkMarkLabel setHidden:true];
        
    }
    
    //setup cell data
    cell.textLabel.backgroundColor = [UIColor clearColor];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.text = [_delegate contentForRowAtIndexPath:currentIndex];
}

-(void)rightTableViewHandler:(UITableViewCell *)cell index:(NSIndexPath *)index{
    
    DropDownMenuType currentType = [_delegate typeForMenuAtIndex:_currentSelectedMenuIndex];
    DropDownIndexPath *selectedIndex = [_selectedIndexs objectForKey:[NSNumber numberWithInteger:_currentSelectedMenuIndex]];
    UILabel *checkMarkLabel = [self getCheckMarkLabelBy:cell];
    
    DropDownIndexPath *currentIndex = [DropDownIndexPath indexPathWith:
                                       _currentSelectedMenuIndex
                                                        leftTableIndex:selectedIndex.leftTableIndex
                                                       rightTableIndex:index.row
                                                           isLeftTable:false];
    
    if(currentType == DropDownMenuTypeDoubleTableView){
        
        if(selectedIndex != nil
           && selectedIndex.leftTableIndex == _selectedLeftTableIndex
           && selectedIndex.rightTableIndex == index.row){
            
            [checkMarkLabel setHidden:false];
            
        }else{
            [checkMarkLabel setHidden:true];
        }
    }
    //setup cell data
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.text = [_delegate contentForRowAtIndexPath:currentIndex];
    
}

-(UILabel *)getCheckMarkLabelBy:(UITableViewCell *)cell{
    UILabel *checkLabel;
    if([cell viewWithTag:checkLabelTag] == nil){
        checkLabel = [[UILabel alloc]initWithFrame:CGRectMake(
                                                              cell.frame.size.width -
                                                              cell.frame.size.height,
                                                              0,
                                                              cell.frame.size.height,
                                                              cell.frame.size.height)];
        checkLabel.tag = checkLabelTag;
        [checkLabel setFont:[UIFont systemFontOfSize:25]];
        checkLabel.text = @"✓";
        [checkLabel setTextColor:selectedLabelColor];
        [cell addSubview:checkLabel];
        
        UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
        myBackView.backgroundColor = BackColor;
        [cell setSelectedBackgroundView:myBackView];
        
    }else{
        checkLabel = [cell viewWithTag:checkLabelTag];
        [checkLabel setFrame:CGRectMake(
                                        cell.frame.size.width -
                                        cell.frame.size.height,
                                        0,
                                        cell.frame.size.height,
                                        cell.frame.size.height)];
    }
    
    return checkLabel;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger tmpMenuIndex = _currentSelectedMenuIndex;
    DropDownMenuType currentType = [_delegate typeForMenuAtIndex:tmpMenuIndex];
    DropDownIndexPath *currentIndex;
    UILabel *label = [_menuTitleLables objectAtIndex:tmpMenuIndex];
    
    if([_selectedIndexs objectForKey:[NSNumber numberWithInteger:tmpMenuIndex]] == nil){
        
        if(currentType == DropDownMenuTypeDoubleTableView){
            
            currentIndex = [DropDownIndexPath indexPathWith:tmpMenuIndex leftTableIndex:0 rightTableIndex:-1 isLeftTable:false];
            
        }else{
            currentIndex = [DropDownIndexPath indexPathWith:tmpMenuIndex leftTableIndex:-1 rightTableIndex:-1 isLeftTable:true];
        }
        
    }else{
        currentIndex = [_selectedIndexs objectForKey:[NSNumber numberWithInteger:tmpMenuIndex]];
    }
    
    if(currentType == DropDownMenuTypeSingleTableView){
        
        currentIndex.leftTableIndex = indexPath.row;
        NSString *currentContent = [_delegate contentForRowAtIndexPath:currentIndex];
        
        if([currentContent isEqualToString:@"全部"]){
            [label setText:[_delegate titleForMenuAtIndex:currentIndex.menuIndex]];
        }else{
            [label setText:[_delegate contentForRowAtIndexPath:currentIndex]];
        }
        
        [_selectedIndexs setObject:currentIndex forKey:[NSNumber numberWithInteger:tmpMenuIndex]];
        
        
        [_delegate didSelectDropDownMenuAt:currentIndex];
        [self hideMenuByIndex:tmpMenuIndex status:DropDownMenuStatusClose complete:nil];
        
    }else if(currentType == DropDownMenuTypeDoubleTableView && tableView == _leftTableView){
        
        currentIndex.leftTableIndex = indexPath.row;
        currentIndex.isLeftTable = false;
        [_selectedIndexs setObject:currentIndex forKey:[NSNumber numberWithInteger:tmpMenuIndex]];
        [_leftTableView reloadData];
        [_rightTableView reloadData];
        
    }else if(currentType == DropDownMenuTypeDoubleTableView && tableView == _rightTableView){
        
        _selectedLeftTableIndex = _leftTableView.indexPathForSelectedRow.row;
        currentIndex.leftTableIndex = _leftTableView.indexPathForSelectedRow.row;
        currentIndex.rightTableIndex = indexPath.row;
        
        
        NSString *currentContent = [_delegate contentForRowAtIndexPath:currentIndex];
        
        if([currentContent isEqualToString:@"全部"]){
            [label setText:[_delegate titleForMenuAtIndex:currentIndex.menuIndex]];
        }else{
            [label setText:[_delegate contentForRowAtIndexPath:currentIndex]];
        }
        
        [_selectedIndexs setObject:currentIndex forKey:[NSNumber numberWithInteger:tmpMenuIndex]];
        
        
        [_delegate didSelectDropDownMenuAt:currentIndex];
        [self hideMenuByIndex:tmpMenuIndex status:DropDownMenuStatusClose complete:nil];
    }
}



-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if(touch.view != _containerView){//不是container 不让container接受事件不收起键盘
        return false;
    }
    return true;
}

@end
