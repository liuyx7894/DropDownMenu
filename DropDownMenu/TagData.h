//
//  TagData.h
//  DropDownMenu
//
//  Created by Louis Liu on 02/11/2016.
//  Copyright © 2016 Louis Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagData : NSObject


@property (assign, nonatomic) BOOL isMultipleSelection;
@property (strong, nonatomic)NSString *titleName;
@property (strong, nonatomic)NSArray<NSString *> *tagArray;

-(instancetype)initWith:(NSString *)title tagArray:(NSArray<NSString *>*)tagArray isMultipleSelection:(BOOL)isMultipleSelection;
@end
