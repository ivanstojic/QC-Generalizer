//
//  GeneralizerPlugin.h
//  Generalizer
//
//  Created by Ivan Stojic on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface GeneralizerPlugIn : QCPlugIn

/*
Declare here the properties to be used as input and output ports for the plug-in e.g.
@property double inputFoo;
@property (copy) NSString* outputBar;
You can access their values in the appropriate plug-in methods using self.inputFoo or self.inputBar
*/

@property double inputNumberOfPorts;
@property double inputNumberOfActive;

@property NSUInteger inputMode;

@property (retain) NSArray* outputs;

@end
