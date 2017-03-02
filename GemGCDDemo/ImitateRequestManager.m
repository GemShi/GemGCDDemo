//
//  ImitateRequestManager.m
//  GemGCDDemo
//
//  Created by GemShi on 2017/3/2.
//  Copyright © 2017年 GemShi. All rights reserved.
//

#import "ImitateRequestManager.h"

@implementation ImitateRequestManager

-(void)ImitateRequestWith:(Block)blk AndStatues:(BOOL)statues
{
    self.block = blk;
    if (statues) {
        self.block(YES);
    }else{
        self.block(NO);
    }
}

@end
