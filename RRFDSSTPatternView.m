//
//  DSSTPatternView.m
//  DSST
//
//  Created by Scott on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RRFDSSTPatternView.h"
#import "RRFDSSTController.h"

@implementation RRFDSSTPatternView
@synthesize taskController;
@synthesize position1;
@synthesize position2;
@synthesize position3;
@synthesize position4;
@synthesize position5;
@synthesize position6;
@synthesize position7;
@synthesize position8;
@synthesize position9;

- (id)initWithFrame:(NSRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code here.
  }
  return self;
}

- (void)drawRect:(NSRect)rect {
  // Drawing code here.
}

-(void)keyDown:(NSEvent *)event{
  
	if(![[event characters] isEqualToString:@""]&&![event isARepeat]){
		[taskController userDidInputCharacters:[event characters]] ;
	}
  
}

@end

