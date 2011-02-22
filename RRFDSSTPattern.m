//
//  DSSTPattern.m
//  DSST
//
//  Created by Scott on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DSSTPattern.h"


@implementation DSSTPattern
@synthesize patternView;

-(id)init{
	if([super init]){
		int i;
		for(i=0;i<9;i++){
			patternPositions[i]=0;
		}
		return self;
	}
	return nil;
}

-(void)generateRandomValidPattern{
	int row1=(arc4random()%3);
	int row2=(arc4random()%3)+3;
	int row3=(arc4random()%3)+6;
	int i=0;
	for(i=0;i<9;i++){
		patternPositions[i]=0;
	}
	patternPositions[row1]=1;
	patternPositions[row2]=1;
	patternPositions[row3]=1;
}
-(BOOL)equalsPattern:(DSSTPattern *)pattern{
	int i=0;
	for(i=0;i<9;i++){
		if([self getPatternPositionValueAtIndex:i]!=[pattern getPatternPositionValueAtIndex:i]){
			return NO;
		}
	}
	return YES;
}
-(int)getPatternPositionValueAtIndex:(int)i{
	if(i>=0&&i<9){
		return patternPositions[i];
	}
	return -1;
}
-(void)setPatternPositionValueAtIndex:(int)i toValue:(int)value{
	if(i>=0&&i<9){
		if(value!=0){
			value=1;
		}
		patternPositions[i]=value;
	}
}

-(void)updateView{
	DSSTPatternView * theView=[self patternView];
	[[theView position1] setColor:(patternPositions[0]?[NSColor blackColor]:[NSColor whiteColor])];
	[[theView position2] setColor:(patternPositions[1]?[NSColor blackColor]:[NSColor whiteColor])];
	[[theView position3] setColor:(patternPositions[2]?[NSColor blackColor]:[NSColor whiteColor])];
	[[theView position4] setColor:(patternPositions[3]?[NSColor blackColor]:[NSColor whiteColor])];
	[[theView position5] setColor:(patternPositions[4]?[NSColor blackColor]:[NSColor whiteColor])];
	[[theView position6] setColor:(patternPositions[5]?[NSColor blackColor]:[NSColor whiteColor])];
	[[theView position7] setColor:(patternPositions[6]?[NSColor blackColor]:[NSColor whiteColor])];
	[[theView position8] setColor:(patternPositions[7]?[NSColor blackColor]:[NSColor whiteColor])];
	[[theView position9] setColor:(patternPositions[8]?[NSColor blackColor]:[NSColor whiteColor])];
}
-(NSString *)stringValue{
	NSMutableString * returnString=[[NSMutableString alloc] init];
	if(patternPositions[8]){
		[returnString appendString:@"9"];
	}
	if(patternPositions[7]){
		[returnString appendString:@"8"];
	}
	if(patternPositions[6]){
		[returnString appendString:@"7"];
	}
	if(patternPositions[5]){
		[returnString appendString:@"6"];
	}
	if(patternPositions[4]){
		[returnString appendString:@"5"];
	}
	if(patternPositions[3]){
		[returnString appendString:@"4"];
	}
	if(patternPositions[2]){
		[returnString appendString:@"3"];
	}
	if(patternPositions[1]){
		[returnString appendString:@"2"];
	}
	if(patternPositions[0]){
		[returnString appendString:@"1"];
	}
	return returnString;
  
}

@end
