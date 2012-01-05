//
//  GeneralizerPlugIn.m
//  Generalizer
//
//  Created by Ivan Stojic on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

/* It's highly recommended to use CGL macros instead of changing the current context for plug-ins that perform OpenGL rendering */
#import <OpenGL/CGLMacro.h>

#import "GeneralizerPlugIn.h"

#define	kQCPlugIn_Name				@"Generalizer"
#define	kQCPlugIn_Description		@"Generalizer twiddles a flexible number of outputs..."

@implementation GeneralizerPlugIn

/*
Here you need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation
@dynamic inputFoo, outputBar;
*/

@dynamic inputNumberOfPorts;
@dynamic inputNumberOfActive;

@dynamic inputMode;

@dynamic outputs;

+ (NSDictionary *)attributes
{
	/*
	Return a dictionary of attributes describing the plug-in (QCPlugInAttributeNameKey, QCPlugInAttributeDescriptionKey...).
	*/
	
	return [NSDictionary dictionaryWithObjectsAndKeys:kQCPlugIn_Name, QCPlugInAttributeNameKey, kQCPlugIn_Description, QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
	/*
	Specify the optional attributes for property based ports (QCPortAttributeNameKey, QCPortAttributeDefaultValueKey...).
	*/
    
    if ([key isEqualToString:@"inputMode"]) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                [NSNumber numberWithInt:0], QCPortAttributeMinimumValueKey,
                [NSArray arrayWithObjects:@"All off", @"All on", @"Sequential", @"Random", nil], QCPortAttributeMenuItemsKey,
                [NSNumber numberWithInt:3], QCPortAttributeMaximumValueKey,
                nil];
    }
	
	return nil;
}

+ (QCPlugInExecutionMode)executionMode
{
	/*
	Return the execution mode of the plug-in: kQCPlugInExecutionModeProvider, kQCPlugInExecutionModeProcessor, or kQCPlugInExecutionModeConsumer.
	*/
	
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode)timeMode
{
	/*
	Return the time dependency mode of the plug-in: kQCPlugInTimeModeNone, kQCPlugInTimeModeIdle or kQCPlugInTimeModeTimeBase.
	*/
	
	return kQCPlugInTimeModeTimeBase;
}

- (id)init
{
	self = [super init];
	if (self) {
		/*
		Allocate any permanent resource required by the plug-in.
		*/
	}
	
	return self;
}

- (void)finalize
{
	/*
	Release any non garbage collected resources created in -init.
	*/
	
	[super finalize];
}


@end

@implementation GeneralizerPlugIn (Execution)

- (BOOL)startExecution:(id <QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/
	
	return YES;
}

- (void)enableExecution:(id <QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	*/
}

- (BOOL)execute:(id <QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/
    

    NSMutableArray *a = [[NSMutableArray alloc] init];
    
    if (self.inputMode == 0) {
        for (int i = 0; i < self.inputNumberOfPorts; i++) {
            [a addObject:[NSNumber numberWithInt:0]];
        }
        
    } else if (self.inputMode == 1) {
        for (int i = 0; i < self.inputNumberOfPorts; i++) {
            [a addObject:[NSNumber numberWithInt:1]];
        }
        
    } else if (self.inputMode == 2) {
        int start = fmod(time, self.inputNumberOfPorts);
        
        for (int i = 0; i < self.inputNumberOfPorts; i++) {
            int value = (i > start && i <= start + self.inputNumberOfActive) ||
                (start + self.inputNumberOfActive >= self.inputNumberOfPorts && i <= fmod(start + self.inputNumberOfActive, self.inputNumberOfPorts)) ? 1 : 0;
            [a addObject:[NSNumber numberWithInt:value]];            
        }
    } else if (self.inputMode == 3) {
        srandom(time);
        
        for (int i = 0; i < self.inputNumberOfPorts; i++ ) {
            [a addObject:[NSNumber numberWithInt:0]];            
        }
        
        int f = self.inputNumberOfActive;
        
        while (f > 0) {
            int r = fmod(random(), self.inputNumberOfPorts);
            
            if ([[a objectAtIndex:r] isEqualToNumber:[NSNumber numberWithInt:0]]) {
                f--;
                [a replaceObjectAtIndex:r withObject:[NSNumber numberWithInt:1]];
            }
        }
    }
    
    self.outputs = a;
	
	return YES;
}

- (void)disableExecution:(id <QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/
}

- (void)stopExecution:(id <QCPlugInContext>)context
{
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/
}

@end
