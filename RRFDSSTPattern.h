//
//  DSSTPattern.h
//  DSST
//
//  Created by Scott on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RRFDSSTPatternView;

@interface RRFDSSTPattern : NSObject {
	int patternPositions[9];
	RRFDSSTPatternView * patternView;
}
@property(nonatomic,retain) IBOutlet RRFDSSTPatternView * patternView;

-(void)generateRandomValidPattern;
-(BOOL)equalsPattern:(RRFDSSTPattern *)pattern;
-(int)getPatternPositionValueAtIndex:(int)i;
-(void)updateView;
-(void)setPatternPositionValueAtIndex:(int)i toValue:(int)value;
-(NSString *)stringValue;

@end
