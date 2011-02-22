//
//  DSSTPattern.h
//  DSST
//
//  Created by Scott on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DSSTPatternView.h"

@interface DSSTPattern : NSObject {
	int patternPositions[9];
	DSSTPatternView * patternView;
}
@property(nonatomic,retain) IBOutlet DSSTPatternView * patternView;

-(void)generateRandomValidPattern;
-(BOOL)equalsPattern:(DSSTPattern *)pattern;
-(int)getPatternPositionValueAtIndex:(int)i;
-(void)updateView;
-(void)setPatternPositionValueAtIndex:(int)i toValue:(int)value;
-(NSString *)stringValue;

@end
