//
//  DSSTPatternView.h
//  DSST
//
//  Created by Scott on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RRFDSSTController;

@interface RRFDSSTPatternView : NSView {
  RRFDSSTController *taskController;
	NSColorWell *position1;
	NSColorWell *position2;
	NSColorWell *position3;
	NSColorWell *position4;
	NSColorWell *position5;
	NSColorWell *position6;
	NSColorWell *position7;
	NSColorWell *position8;
	NSColorWell *position9;
}
@property(assign) IBOutlet RRFDSSTController *taskController;
@property(assign) IBOutlet NSColorWell * position1;
@property(assign) IBOutlet NSColorWell * position2;
@property(assign) IBOutlet NSColorWell * position3;
@property(assign) IBOutlet NSColorWell * position4;
@property(assign) IBOutlet NSColorWell * position5;
@property(assign) IBOutlet NSColorWell * position6;
@property(assign) IBOutlet NSColorWell * position7;
@property(assign) IBOutlet NSColorWell * position8;
@property(assign) IBOutlet NSColorWell * position9;

@end
