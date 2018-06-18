//
//  ViewController.h
//  MySweeper
//
//  Created by aadebuger on 2018/5/19.
//  Copyright © 2018年 aadebuger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *headingLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *newangleLabel;
- (void) handleButtonClicked:(id)sender ;
@end

