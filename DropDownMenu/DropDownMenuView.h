//
//  DropDownMenuViewController.h
//  DropDownMenu
//
//  Created by Louis Liu on 23/09/2016.
//  Copyright © 2016 Louis Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height
#define screenBounds [UIScreen mainScreen].bounds
//#define seperatorColor  [UIColor colorWithRed:175.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0]
#define seperatorColor  [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0]
//#define defaultBGColor  [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1.0]
#define defaultBGColor  [UIColor whiteColor]
#define selectedBGColor  [UIColor colorWithRed:227.0/255.0 green:227.0/255.0 blue:227.0/255.0 alpha:1.0]

//#define indicatorColor  [UIColor colorWithRed:175.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0]
#define indicatorColor  [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0]

#define selectedLabelColor  [UIColor colorWithRed:79.0/255.0 green:212.0/255.0 blue:154.0/255.0 alpha:1.0]
#define defaultLabelColor  [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]

typedef enum:NSInteger
{
    DropDownMenuTypeNone = -1,
    DropDownMenuTypeSingleTableView = 0,
    DropDownMenuTypeDoubleTableView = 1,
    DropDownMenuTypeCustomerView = 2
}DropDownMenuType;

@interface DropDownIndexPath : NSObject
@property(assign, nonatomic) NSInteger menuIndex;
@property(assign, nonatomic) NSInteger leftTableIndex;
@property(assign, nonatomic) NSInteger rightTableIndex;
@property(assign, nonatomic) BOOL isLeftTable;

-(instancetype) initIndexPathWith:(NSInteger)menuIndex leftTableIndex:(NSInteger) leftTableIndex rightTableIndex:(NSInteger) rightTableIndex isLeftTable:(BOOL) isLeftTable;
+(instancetype) indexPathWith:(NSInteger)menuIndex leftTableIndex:(NSInteger) leftTableIndex rightTableIndex:(NSInteger) rightTableIndex isLeftTable:(BOOL) isLeftTable;
@end


@protocol DropDownMenuDelegate <NSObject>

@required
-(DropDownMenuType) typeForMenuAtIndex:(NSInteger)index;
-(NSInteger) numberOfMenu;
-(NSInteger) numberOfRowInMenuAtIndexPath:(DropDownIndexPath *)indexPath ;
-(NSString *) titleForMenuAtIndex:(NSInteger )index;
-(NSString *) contentForRowAtIndexPath:(DropDownIndexPath *)indexPath;
-(void) didSelectDropDownMenuAt:(DropDownIndexPath *)indexPath;

@optional
-(double) heightForMenuViewAtIndex:(NSInteger)index;
-(UIView *) viewForCustomViewAtIndex:(NSInteger)index;

@end

@interface DropDownMenuView: UIView

@property (weak, nonatomic) id<DropDownMenuDelegate> delegate;


- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height;
- (void)hideMenuByIndex:(NSInteger)index complete:(void(^)())complete;
- (void)setSelectingByIndexs:(NSArray<DropDownIndexPath *>*) selectedIndexs;

@end
