////////////////////////////////////////////////////////////////////////////////
//  RRFDSSTController.m
//  RRFDSST
//  ----------------------------------------------------------------------------
//  Author: Scott Southerland (ported by Travis Nesland)
//  Created: 2/22/11
//  Copyright 2011, Residential Research Facility,
//  University of Kentucky. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////
#import "RRFDSSTController.h"

#define RRFLogToTemp(fmt, ...) [delegate logStringToDefaultTempFile:[NSString stringWithFormat:fmt,##__VA_ARGS__]]

@implementation RRFDSSTController
@synthesize delegate,definition,errorLog,view;  // add any member that has a 
                                                //property
@synthesize pattern1;
@synthesize pattern2;
@synthesize pattern3;
@synthesize pattern4;
@synthesize pattern5;
@synthesize pattern6;
@synthesize pattern7;
@synthesize pattern8;
@synthesize pattern9;
@synthesize userPattern;
@synthesize userChallengeLabel;
@synthesize pointsLabel;
@synthesize currentChallenge;
@synthesize currentRow;
@synthesize currentTrialIsStillValid;
@synthesize numberOfPoints;
@synthesize clearSeconds;
@synthesize clearMicroSeconds;
@synthesize numberOfTrialsSinceLastReset;
@synthesize resetLimit;
@synthesize totalNumberOfTrials;
@synthesize waitingToClear;
@synthesize currentRunHeaderOffset;
@synthesize totalAppSeconds;
@synthesize totalAppMicroseconds;
@synthesize crashRecoverySeconds;
@synthesize crashRecoveryMicroseconds;

#pragma mark HOUSEKEEPING METHODS
/**
 Give back any memory that may have been allocated by this bundle
 */
- (void)dealloc {
  [errorLog release];
  // any additional release calls go here
  // ...
  [super dealloc];
}

#pragma mark REQUIRED PROTOCOL METHODS

/**
 Start the component - will receive this message from the component controller
 */
- (void)begin {
    
}

/**
 Return a string representation of the data directory
 */
- (NSString *)dataDirectory {
  NSString *temp = nil;
  if(temp = [definition valueForKey:RRFDSSTDataDirectoryKey]) {
    return [temp stringByStandardizingPath];    // return standardized path if
                                                // we have one
  } else {
    return nil;                                 // otherwise, return nil
  }
}

/**
 Return a string object representing all current errors in log form
 */
- (NSString *)errorLog {
  return errorLog;
}

/**
 Perform any and all error checking required by the component - return YES if 
 passed
 */
- (BOOL)isClearedToBegin {
  return YES; // this is the default; change as needed
}

/**
 Returns the file name containing the raw data that will be appended to the data
 file
 */
- (NSString *)rawDataFile {
  return [delegate defaultTempFile]; // this is the default implementation
}

/**
 Perform actions required to recover from crash using the given raw data passed
 as string
 */
- (void)recover {
  // if no recovery is needed, nothing need be done here
}

/**
 Accept assignment for the component definition
 */
- (void)setDefinition: (NSDictionary *)aDictionary {
  definition = aDictionary;
}

/**
 Accept assignment for the component delegate - The component controller will 
 assign itself as the delegate
 Note: The new delegate must adopt the TKComponentBundleDelegate protocol
 */
- (void)setDelegate: (id <TKComponentBundleDelegate> )aDelegate {
  delegate = aDelegate;
}

/**
 Perform any and all initialization required by component - load any nib files 
 and perform all required initialization
 */
- (void)setup {
  [self setErrorLog:@""]; // clear the error log
  // WHAT NEEDS TO BE INITIALIZED BEFORE THIS COMPONENT CAN OPERATE?
  // ...
  waitingToClear = YES;
  currentRow = 3;
  numberOfPoints = 0;
  totalNumberOfTrials = 0;
  resetLimit = 25;
  totalAppSeconds = 120; // TODO: paramaterize totalAppSeconds
  totalAppMicroseconds = 0;
  [[NSNotificationCenter defaultCenter] addObserver:@selector(clearUserPattern:) name:@"clearUserPattern" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:@selector(exitWithNotification:) selector:@"exitWithNotification" object:nil];
  // LOAD NIB
  // ...
  if([NSBundle loadNibNamed:RRFDSSTMainNibNameKey owner:self]) {
    // SETUP THE INTERFACE VALUES
    // ...
    
  } else {
    // nib did not load, so throw error
    [self registerError:@"Could not load Nib file"];
  }
}

/**
 Return YES if component should perform recovery actions
 */
- (BOOL)shouldRecover {
  //TODO: return yes if our recovery plist exists
  return NO;  // this is the default; change if needed
}

/**
 Perform any and all finalization required by component
 */
- (void)tearDown {
  // any finalization should be done here:
  // ...
  // remove any temporary data files (uncomment below to use default)
  /*
  NSError *tFileMoveError = nil;
  [[NSFileManager defaultManager] removeItemAtPath:[delegate defaultTempFile]
                                             error:&tFileMoveError];
  if(tFileMoveError) {
    ELog(@"%@",[tFileMoveError localizedDescription]);
    [tFileMoveError release]; tFileMoveError=nil;
  }
   */
  // de-register any possible notifications
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 Return the name of the current task
 */
- (NSString *)taskName {
  return [definition valueForKey:RRFDSSTTaskNameKey];
}

/**
 Return the main view that should be presented to the subject
 */
- (NSView *)mainView {
  return view;
}

#pragma mark OPTIONAL PROTOCOL METHODS
/** Uncomment and implement the following methods if desired */
/**
 Run header if something other than default is required
 */
//- (NSString *)runHeader {
//
//}
/**
 Session header if something other than default is required
 */
//- (NSString *)sessionHeader {
//
//}
/**
 Summary data if desired
 */
//- (NSString *)summary {
//
//}
        
#pragma mark ADDITIONAL METHODS
/** Add additional methods required for operation */
- (void)registerError: (NSString *)theError {
    // append the new error to the error log
    [self setErrorLog:[[errorLog stringByAppendingString:theError] stringByAppendingString:@"\n"]];
}

#pragma mark Preference Keys
// HERE YOU DEFINE KEY REFERENCES FOR ANY PREFERENCE VALUES
// ex: NSString * const RRFDSSTNameOfPreferenceKey = @"RRFDSSTNameOfPreference"
NSString * const RRFDSSTTaskNameKey = @"RRFDSSTTaskName";
NSString * const RRFDSSTDataDirectoryKey = @"RRFDSSTDataDirectory";

#pragma mark Internal Strings
// HERE YOU DEFINE KEYS FOR CONSTANT STRINGS //
///////////////////////////////////////////////
NSString * const RRFDSSTMainNibNameKey = @"RRFDSSTMainNib";
        
@end
