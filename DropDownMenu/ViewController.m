//
//  ViewController.m
//  DropDownMenu
//
//  Created by Louis Liu on 23/09/2016.
//  Copyright © 2016 Louis Liu. All rights reserved.
//

#import "ViewController.h"
#import "DropDownMenuView.h"
#import "TagFilterView.h"
#import "TagData.h"
@interface ViewController ()<DropDownMenuDelegate>
@property (strong, nonatomic) NSArray *oneTableViewDataSource;
@property (strong, nonatomic) NSArray *menuTitles;
@property (strong, nonatomic) NSArray<TagData *> *tagList;
@property (strong, nonatomic) NSDictionary *doubleTableViewDataSource;
@property (strong, nonatomic) TagFilterView *tagFilterView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _menuTitles = @[@"类型", @"地区", @"筛选"];
    
    _oneTableViewDataSource = @[@"2323", @"露营", @"滑翔", @"CS",
                                @"烧烤", @"XBox", @"Party", @"GoPro",
                                @"PS4 Pro", @"XBox Slim"];
    _doubleTableViewDataSource =  @{@"周边":@[@"亦庄", @"朝阳", @"保定", @"廊坊", @"唐山", @"张家口",
                                            @"承德", @"天津", @"呼和浩特", @"平遥古城"],
                                    @"国内":@[@"北京", @"上海", @"23", @"深圳", @"长沙", @"石家庄", @"杭州",
                                             @"广州", @"无锡", @"成都", @"什么鬼"],
                                    @"国外":@[@"西雅图", @"澳大利亚", @"迪拜", @"普吉岛", @"冰岛", @"哥伦比亚",
                                             @"好望角", @"巴黎", @"东京", @"大阪", @"关西", @"伦敦",
                                             @"柏林", @"悉尼", @"华盛顿"]};
    TagData *timeData = [[TagData alloc]initWith:@"行程天数"
                                        tagArray:@[@"不限", @"1天", @"2-3天", @"4-5天", @"6天以上"]
                             isMultipleSelection:false];
    TagData *dayData = [[TagData alloc]initWith:@"出行时间"
                                       tagArray:@[@"不限", @"1月", @"2月", @"3月", @"4月", @"5月", @"6月", @"7月",
                                                  @"中秋节", @"春节", @"十一节", @"五一节", @"光棍节"]
                            isMultipleSelection:true];
    _tagList = @[timeData, dayData];
    _tagFilterView = [[TagFilterView alloc]initWith:CGRectMake(0, 0, screenWidth, screenHeight*0.6) tagList:_tagList];
    
    DropDownMenuView *menuView = [[DropDownMenuView alloc]initWithOrigin:CGPointMake(0, 64) andHeight:44];
    menuView.delegate = self;

    [self.view addSubview:menuView];
    [self.view setBackgroundColor:[UIColor whiteColor]];

}


-(DropDownMenuType) typeForMenuAtIndex:(NSInteger)index{
    
    if(index == 0){
        return DropDownMenuTypeSingleTableView;
    }else if(index == 1){
        return DropDownMenuTypeDoubleTableView;
    }else if(index == 2){
        return DropDownMenuTypeCustomerView;
    }
    return DropDownMenuTypeNone;
}

-(UIView *) viewForCustomViewAtIndex:(NSInteger)index{
    
    if(index == 2){
        return _tagFilterView;
    }
    
    return nil;
}

-(NSInteger) numberOfMenu{
    return [_menuTitles count];
}

-(NSInteger) numberOfRowInMenuAtIndexPath:(DropDownIndexPath *)indexPath{
    DropDownMenuType currentType = [self typeForMenuAtIndex:indexPath.menuIndex];
    
    if(currentType == DropDownMenuTypeSingleTableView){
        return [_oneTableViewDataSource count];
    }else if(currentType == DropDownMenuTypeDoubleTableView){
        if(indexPath.isLeftTable){
            return [[_doubleTableViewDataSource allKeys]count];
        }else{
            return [[[_doubleTableViewDataSource allValues]
                     objectAtIndex:indexPath.leftTableIndex] count];
        }
    }
    return 0;
}

-(NSString *) titleForMenuAtIndex:(NSInteger )index{
    return _menuTitles[index];
}

-(NSString *) contentForRowAtIndexPath:(DropDownIndexPath *)indexPath{
    DropDownMenuType currentType = [self typeForMenuAtIndex:indexPath.menuIndex];
    
    if(currentType == DropDownMenuTypeSingleTableView){
        return [_oneTableViewDataSource objectAtIndex:indexPath.leftTableIndex];
    }else if(currentType == DropDownMenuTypeDoubleTableView){
        
        if(indexPath.isLeftTable){
            return [[_doubleTableViewDataSource allKeys] objectAtIndex:indexPath.leftTableIndex];
        }else{
            return [[[_doubleTableViewDataSource allValues]
                     objectAtIndex:indexPath.leftTableIndex] objectAtIndex:indexPath.rightTableIndex];
        }
    }
    return nil;
}

-(double) heightForMenuViewAtIndex:(NSInteger)index{
    
//    if(index==2){
//        return 450;
//    }else{
        return screenHeight*0.6;
//    }
    
}

-(void) didSelectDropDownMenuAt:(DropDownIndexPath *)indexPath{
    NSLog(@"点击了第%i个Menu,左边table第%i行， 右边table第%i行", indexPath.menuIndex, indexPath.leftTableIndex, indexPath.rightTableIndex);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
