//
//  TagFilterViewController.m
//  DropDownMenu
//
//  Created by Louis Liu on 02/11/2016.
//  Copyright © 2016 Louis Liu. All rights reserved.
//

#import "TagFilterView.h"
#import "TagData.h"
#import "TagButton.h"

#define kBottomBarHeight 44
#define kBottomConfirmBtnHeight 30
#define kTagButtonWidth 90
#define kTagButtonHeight 30
#define kTagButtonLeftRightOffset 30
#define kTagButtonTopBottomOffset 20
#define kTitleLableHeight 20
#define kEdgeOffset 15
#define numberOfTagOnLine 3
#define defaultColor [UIColor colorWithRed:86/255.0 green:211/255.0 blue:155/255.0 alpha:1.0]

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

@interface TagFilterView()
@property (weak, nonatomic) NSArray<TagData *> *tagList;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *bottomBarView;
@property (strong, nonatomic) NSMutableArray<NSMutableArray<NSNumber *> *> *selectedLevelIndexs;//[level[index]]
@property (strong, nonatomic) UIButton *resetBtn;
@property (strong, nonatomic) UIButton *confirmBtn;

@end

@implementation TagFilterView


- (instancetype)initWith:(CGRect)frame tagList:(NSArray<TagData *> *)tagList
{
    self = [super init];
    if (self) {
        self.frame = frame;
        [self setBackgroundColor:[UIColor whiteColor]];
        self.clipsToBounds = true;
        [self initTags:tagList];
    }
    return self;
}

-(void)initTags:(NSArray<TagData *> *)tagList{
    
    self.tagList = tagList;
    _selectedLevelIndexs = [[NSMutableArray alloc]initWithCapacity:tagList.count];
    
    CGRect contentFrame = self.frame;
    contentFrame.size.height -= kBottomBarHeight;
    
    //initial  tagContainer
    _scrollView = [[UIScrollView alloc]initWithFrame:contentFrame];

    CGFloat lastestY = 0;
    for (int i=0; i<tagList.count; i++) {
        _selectedLevelIndexs[i] = [[NSMutableArray alloc] init];
        lastestY = [self appendTagList:_scrollView level:i latestY:lastestY];
    }
    
    [_scrollView setContentSize:CGSizeMake(screenWidth, lastestY+kEdgeOffset)];//加上底部间距
    [self addSubview:_scrollView];
    
    //initial  BottomBar
    [self initialBottomBar];
}

-(void)initialBottomBar{
    
    _bottomBarView = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-kBottomBarHeight, screenWidth, kBottomBarHeight)];
    [self addSubview:_bottomBarView];
    
    [_bottomBarView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_bottomBarView.layer setBorderWidth:0.5];
    //[_bottomBarView setBackgroundColor:[UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0]];
    
//    UIView *seperator = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
//    [seperator setBackgroundColor:[UIColor lightGrayColor]];
//    [_bottomBarView addSubview:seperator];

    _resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(kEdgeOffset*2, 0, 100, kBottomBarHeight)];
    [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
    [_resetBtn setTitleColor:defaultColor forState:UIControlStateNormal];
    [_resetBtn addTarget:self action:@selector(resetForm) forControlEvents:UIControlEventTouchUpInside];
    [_bottomBarView addSubview:_resetBtn];
    
    _confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-kEdgeOffset*2-100,
                                                                      (kBottomBarHeight-kBottomConfirmBtnHeight)/2,
                                                                      100,
                                                                      kBottomConfirmBtnHeight)];
    [_confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
    [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmBtn setBackgroundColor:defaultColor];
    [_confirmBtn addTarget:self action:@selector(conformValues) forControlEvents:UIControlEventTouchUpInside];
//    [_confirmBtn.layer setCornerRadius:kBottomConfirmBtnHeight/2];
//    [_confirmBtn.layer setMasksToBounds:true];
//    
    [_bottomBarView addSubview:_confirmBtn];
    
}

-(void)resetForm{
    
    for (int level=0; level<_selectedLevelIndexs.count; level++) {
        NSMutableArray<NSNumber *> *selectIndexs = _selectedLevelIndexs[level];
        
        for (NSNumber *index in selectIndexs) {
            TagButton *btn = [self findeButtonByLevel:level andIndex:index.integerValue];
            if(btn!=nil){
                [btn setSelected:false];
            }
        }
        [selectIndexs removeAllObjects];
    }
    
    [self calculateConfirmCount];
}

-(void)conformValues{
    NSLog(@"%@", _selectedLevelIndexs);
}

-(CGFloat)appendTagList:(UIScrollView *)container level:(int)level latestY:(CGFloat)latestY{
    
    NSArray<NSString *> *tagArray = _tagList[level].tagArray;
    CGFloat tempY = 0;
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, latestY+kEdgeOffset, 200, kTitleLableHeight)];
   
    [titleLabel setFont:[UIFont systemFontOfSize:16]];
    titleLabel.text = _tagList[level].titleName;
    [container addSubview:titleLabel];
    
    CGFloat buttonWidth = (screenWidth-(kEdgeOffset*2)-(kTagButtonLeftRightOffset*2))/numberOfTagOnLine;
    
    for (int tagIndex=0; tagIndex<tagArray.count; tagIndex++) {
        
        int column = tagIndex%numberOfTagOnLine;
        int row = tagIndex/numberOfTagOnLine;
        
        CGRect btnRect = CGRectMake((column*(buttonWidth+kTagButtonLeftRightOffset))+kEdgeOffset,
                                    (row*(kTagButtonHeight+kTagButtonTopBottomOffset))+(titleLabel.frame.origin.y+kTitleLableHeight*2),
                                    buttonWidth,
                                    kTagButtonHeight);
        TagButton *btn = [[TagButton alloc]initWithFrame:btnRect level:level index:tagIndex title:tagArray[tagIndex]];
        
        btn.onSelectedTagCallback = ^(UIButton *sender, NSInteger level, NSInteger index, BOOL selected){

            [self onTagTappedCallback:sender level:level index:index selected:selected];
        };
        
        [container addSubview:btn];
        tempY = btn.frame.origin.y + btn.frame.size.height;
    }
    
    return tempY;
}

-(void)onTagTappedCallback:(UIButton *)btn level:(NSInteger)level index:(NSInteger)index selected:(BOOL)selected{
    
    TagData *currentData = _tagList[level];
    NSMutableArray<NSNumber *> *selectedIndexs = _selectedLevelIndexs[level];
    
    if(!currentData.isMultipleSelection ){
        for (NSNumber *index in selectedIndexs) {
            TagButton *btn = [self findeButtonByLevel:level andIndex:index.integerValue];
            if(btn!=nil){
                [btn setSelected:false];
            }
        }
        [selectedIndexs removeAllObjects];
    }else{

        if(index == 0){//当点击全选时清空其余选项
            for (NSNumber *index in selectedIndexs) {
                TagButton *btn = [self findeButtonByLevel:level andIndex:index.integerValue];
                if(btn!=nil){
                    [btn setSelected:false];
                }
            }
            [selectedIndexs removeAllObjects];
        }else{//当点击其余时如果有全选 则把全选移除
            for (NSNumber *index in selectedIndexs) {
                if(index.integerValue == 0){//说明有全选
                    TagButton *btn = [self findeButtonByLevel:level andIndex:index.integerValue];
                    if(btn!=nil){
                        [btn setSelected:false];
                    }
                    [selectedIndexs removeObject:index];
                }
            }
        }
    }
    
    if(selected){
        [selectedIndexs addObject:[NSNumber numberWithInteger:index]];
    }else{
        [selectedIndexs removeObject:[NSNumber numberWithInteger:index]];
    }
    [self calculateConfirmCount];
}

-(void)calculateConfirmCount{
    int totalCount = 0;
    for (int i=0; i<_selectedLevelIndexs.count; i++) {
        totalCount += _selectedLevelIndexs[i].count;
    }
    if(totalCount>0){
        [_confirmBtn setTitle:[NSString stringWithFormat:@"确认( %i )", totalCount]  forState:UIControlStateNormal];
    }else{
        [_confirmBtn setTitle:[NSString stringWithFormat:@"确认"]  forState:UIControlStateNormal];
    }
}

-(TagButton *)findeButtonByLevel:(NSInteger)level andIndex:(NSInteger)index{
    
    for (UIView *view in _scrollView.subviews) {
        if([view isKindOfClass:[TagButton class]]){
            TagButton *tmp = (TagButton *)view;
            if(tmp.level == level && tmp.index == index){
                return tmp;
            }
        }
    }
    return nil;
}
@end
