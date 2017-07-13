//
//  TagFilterViewController.h
//  DropDownMenu
//
//  Created by Louis Liu on 02/11/2016.
//  Copyright © 2016 Louis Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagData.h"

@interface TagFilterView : UIView
- (instancetype)initWith:(CGRect)frame tagList:(NSArray<TagData *> *)tagList;
@end
