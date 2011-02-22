//
//  DSSTPatternView.h
//  DSST
//
//  Created by Scott on 1/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DSSTPatternView : NSView {
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
@property(nonatomic,retain) IBOutlet NSColorWell * position1;
@property(nonatomic,retain) IBOutlet NSColorWell * position2;
@property(nonatomic,retain) IBOutlet NSColorWell * position3;
@property(nonatomic,retain) IBOutlet NSColorWell * position4;
@property(nonatomic,retain) IBOutlet NSColorWell * position5;
@property(nonatomic,retain) IBOutlet NSColorWell * position6;
@property(nonatomic,retain) IBOutlet NSColorWell * position7;
@property(nonatomic,retain) IBOutlet NSColorWell * position8;
@property(nonatomic,retain) IBOutlet NSColorWell * position9;

@end
