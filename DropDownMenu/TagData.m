//
//  TagData.m
//  DropDownMenu
//
//  Created by Louis Liu on 02/11/2016.
//  Copyright © 2016 Louis Liu. All rights reserved.
//

#import "TagData.h"

@implementation TagData

-(instancetype)initWith:(NSString *)title tagArray:(NSArray<NSString *>*)tagArray isMultipleSelection:(BOOL)isMultipleSelection{
    self.titleName = title;
    self.tagArray = tagArray;
    self.isMultipleSelection = isMultipleSelection;
    return self;
}
@end
