//
//  ImitateRequestManager.h
//  GemGCDDemo
//
//  Created by GemShi on 2017/3/2.
//  Copyright © 2017年 GemShi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^Block)(BOOL);

@interface ImitateRequestManager : NSObject

@property(nonatomic,copy)Block block;

-(void)ImitateRequestWith:(Block)blk AndStatues:(BOOL)statues;

@end
