//
//  TagButton.h
//  DropDownMenu
//
//  Created by Louis Liu on 21/11/2016.
//  Copyright © 2016 Louis Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OnSelectedTagCallback)(UIButton *sender, NSInteger level, NSInteger index, BOOL selected);
@interface TagButton : UIButton


- (instancetype)initWithFrame:(CGRect)frame level:(NSInteger)level index:(NSInteger)index title:(NSString *)title;

@property (strong, nonatomic) OnSelectedTagCallback onSelectedTagCallback;
@property (assign, nonatomic) NSInteger level;
@property (assign, nonatomic) NSInteger index;
@end
