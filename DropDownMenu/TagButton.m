//
//  TagButton.m
//  DropDownMenu
//
//  Created by Louis Liu on 21/11/2016.
//  Copyright © 2016 Louis Liu. All rights reserved.
//

#import "TagButton.h"

#define defaultColor [UIColor colorWithRed:86/255.0 green:211/255.0 blue:155/255.0 alpha:1.0]

@interface TagButton ()

@property (assign, nonatomic) BOOL isSelected;
@end

@implementation TagButton

- (instancetype)initWithFrame:(CGRect)frame level:(NSInteger)level index:(NSInteger)index title:(NSString *)title
{
    self = [super initWithFrame:frame];
    if (self) {
        _level = level;
        _index = index;
        _isSelected = false;
        [self setTitle:title forState:UIControlStateNormal];
        
        
        [self.titleLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightLight]];
        [self.layer setBorderColor:defaultColor.CGColor];
        [self.layer setCornerRadius:frame.size.height/2];
        [self.layer setMasksToBounds:YES];
        [self.layer setBorderWidth:0.5];
        
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [self addTarget:self action:@selector(onTappedTag:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

-(void)setSelected:(BOOL)selected{
    _isSelected = selected;
    
    if(_isSelected){
        [self setBackgroundColor:defaultColor];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

-(void)onTappedTag:(UIButton *)sender{
    
    _isSelected = !_isSelected;
    [self setSelected:_isSelected];
    
    if(_onSelectedTagCallback != nil){
        _onSelectedTagCallback(self, _level, _index, _isSelected);
    }
}
@end
