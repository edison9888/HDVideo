//
//  ClassUtil.h
//  HDVideo
//
//  Created by Perry on 11-11-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@interface ClassUtil : NSObject {
    
}

+ (void)swizzleSelector:(SEL)orig ofClass:(Class)c withSelector:(SEL)new;

@end