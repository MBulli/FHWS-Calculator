//
//  Utilities.h
//  Calculator
//
//  Created by Markus on 23.04.14.
//  Copyright (c) 2014 MBulli. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline NSString* intToStr(int i)
{
    return [[NSNumber numberWithInt:i] stringValue];
}

static inline NSString* doubleToStr(double d)
{
    return [[NSNumber numberWithDouble:d] stringValue];
}