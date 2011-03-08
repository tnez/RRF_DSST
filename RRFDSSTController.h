////////////////////////////////////////////////////////////////////////////////
//  RRFDSSTController.h
//  RRFDSST
//  ----------------------------------------------------------------------------
//  Author: Travis Nesland
//  Created: 2/22/11
//  Copyright 2011, Residential Research Facility,
//  University of Kentucky. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////
#import <Cocoa/Cocoa.h>
#import <TKUtility/TKUtility.h>
@class RRFDSSTPattern;

@interface RRFDSSTController : NSObject <TKComponentBundleLoading> {

  // PROTOCOL MEMBERS //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////    
  NSDictionary                                                *definition;
  id <TKComponentBundleDelegate>                              delegate;
  NSString                                                    *errorLog;
  IBOutlet NSView                                             *view;

  // ADDITIONAL MEMBERS ////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  RRFDSSTPattern * pattern1;
	RRFDSSTPattern * pattern2;
	RRFDSSTPattern * pattern3;
	RRFDSSTPattern * pattern4;
	RRFDSSTPattern * pattern5;
	RRFDSSTPattern * pattern6;
	RRFDSSTPattern * pattern7;
	RRFDSSTPattern * pattern8;
	RRFDSSTPattern * pattern9;
	RRFDSSTPattern * userPattern;
	NSTextField * userChallengeLabel;
	NSTextField * pointsLabel;
	NSInteger currentChallenge;
	NSInteger currentRow;
	NSInteger numberOfPoints;
	NSInteger totalNumberOfTrials;
	BOOL currentTrialIsStillValid;
	NSUInteger clearSeconds;
	NSUInteger clearMicroSeconds;
	NSInteger numberOfTrialsSinceLastReset;
	NSInteger resetLimit;
	BOOL waitingToClear;
	NSUInteger totalAppSeconds;
	NSUInteger totalAppMicroseconds;
	NSUInteger crashRecoverySeconds;
	NSUInteger crashRecoveryMicroseconds;
  TKTime start;
}

// PROTOCOL PROPERTIES /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@property (assign)              NSDictionary                    *definition;
@property (assign)              id <TKComponentBundleDelegate>  delegate;
@property (nonatomic, retain)   NSString                        *errorLog;
@property (assign)              IBOutlet NSView                 *view;

// ADDITIONAL PROPERTIES ///////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@property(readwrite) NSUInteger crashRecoverySeconds;
@property(readwrite) NSUInteger crashRecoveryMicroseconds;
@property(readwrite) NSUInteger totalAppMicroseconds;
@property(readwrite) NSUInteger totalAppSeconds;
@property(readwrite) BOOL waitingToClear;
@property(readwrite) NSInteger totalNumberOfTrials;
@property(readwrite) NSUInteger clearSeconds;
@property(readwrite) NSUInteger clearMicroSeconds;
@property(readwrite) NSInteger numberOfPoints;
@property(readwrite) NSInteger numberOfTrialsSinceLastReset;
@property(readwrite) NSInteger resetLimit;
@property(assign) IBOutlet RRFDSSTPattern * pattern1;
@property(assign) IBOutlet RRFDSSTPattern * pattern2;
@property(assign) IBOutlet RRFDSSTPattern * pattern3;
@property(assign) IBOutlet RRFDSSTPattern * pattern4;
@property(assign) IBOutlet RRFDSSTPattern * pattern5;
@property(assign) IBOutlet RRFDSSTPattern * pattern6;
@property(assign) IBOutlet RRFDSSTPattern * pattern7;
@property(assign) IBOutlet RRFDSSTPattern * pattern8;
@property(assign) IBOutlet RRFDSSTPattern * pattern9;
@property(assign) IBOutlet RRFDSSTPattern * userPattern;
@property(assign) IBOutlet NSTextField * userChallengeLabel;
@property(assign) IBOutlet NSTextField * pointsLabel;	
@property(readwrite)NSInteger currentChallenge;
@property(readwrite)NSInteger currentRow;
@property(readwrite) BOOL currentTrialIsStillValid;

#pragma mark REQUIRED PROTOCOL METHODS
/**
 Start the component - will receive this message from the component controller
 */
- (void)begin;

/**
 Return a string representation of the data directory
 */
- (NSString *)dataDirectory;

/**
 Return a string object representing all current errors in log form
 */
- (NSString *)errorLog;

/**
 Perform any and all error checking required by the component - return YES if
 passed
 */
- (BOOL)isClearedToBegin;

/**
 Returns the file name containing the raw data that will be appended to the 
 data file
 */
- (NSString *)rawDataFile;

/**
 Perform actions required to recover from crash using the given raw data passed 
 as string
 */
- (void)recover;

/**
 Accept assignment for the component definition
 */
- (void)setDefinition: (NSDictionary *)aDictionary;

/**
 Accept assignment for the component delegate - The component controller will 
 assign itself as the delegate
 Note: The new delegate must adopt the TKComponentBundleDelegate protocol
 */
- (void)setDelegate: (id <TKComponentBundleDelegate>)aDelegate;

/**
 Perform any and all initialization required by component - load any nib files
 and perform all required initialization
 */
- (void)setup;

/**
 Return YES if component should perform recovery actions
 */
- (BOOL)shouldRecover;

/**
 Return the name for the current task
 */
- (NSString *)taskName;

/**
 Perform any and all finalization required by component
 */
- (void)tearDown;

/**
 Return the main view that should be presented to the subject
 */
- (NSView *)mainView;

#pragma mark OPTIONAL PROTOCOL METHODS
// UNCOMMENT ANY OF THE FOLLOWING METHODS IF THEIR BEHAVIOR IS DESIRED
////////////////////////////////////////////////////////////////////////////////
/**
 Run header if something other than default is required
 */
//- (NSString *)runHeader;

/**
 Session header if something other than default is required
 */
//- (NSString *)sessionHeader;

/**
 Summary data if desired
 */
//- (NSString *)summary;

#pragma mark ADDITIONAL METHODS
// PLACE ANY NON-PROTOCOL METHODS HERE //
/////////////////////////////////////////
/**
 Add the error to an ongoing error log
 */
- (void)dequeueTempLogEntries;
- (void)registerError: (NSString *)theError;
- (void)clearUserPattern:(NSNotification *)aNotification;
- (RRFDSSTPattern *)currentChallengePattern;
- (void)delayedClear;
- (void)exitWithNotification: (NSNotification *)aNote;
- (void)logPatterns;
- (void)regeneratePatterns;
- (void)startAppTimer;
- (void)startClearTimer;
- (void)userDidInputCharacters:(NSString*)characters;
- (void)updateRegistryFile;
- (void)updateRunHeader;
- (BOOL)validPatternLayout;

#pragma mark Preference Keys
// HERE YOU DEFINE KEY REFERENCES FOR ANY PREFERENCE VALUES
// ex: NSString * const RRFDSSTNameOfPreferenceKey;
////////////////////////////////////////////////////////////////////////////////
NSString * const RRFDSSTTaskNameKey;
NSString * const RRFDSSTDataDirectoryKey;
NSString * const RRFDSSTTaskDurationKey;
NSString * const RRFDSSTResetLimitKey;

#pragma mark Registry Keys
NSString * const RRFDSSTLastKnownTimeKey;
NSString * const RRFDSSTLastPatternKey;
NSString * const RRFDSSTTrialsCorrectCountKey;
NSString * const RRFDSSTTrialsCorrectPercentageKey;
NSString * const RRFDSSTTrialsCountKey;

#pragma mark Internal Strings
// HERE YOU DEFINE KEYS FOR CONSTANT STRINGS
////////////////////////////////////////////////////////////////////////////////
NSString * const RRFDSSTLogSinceLastRecPointKey;
NSString * const RRFDSSTMainNibNameKey;

#pragma mark Enumerated Values
// HERE YOU CAN DEFINE ENUMERATED VALUES
// ex:
// enum {
//  RRFDSSTSomeDescriptor          = 0,
//  RRFDSSTSomeOtherDescriptor     = 1,
//  RRFDSSTAnotherDescriptor       = 2
// }; typedef NSInteger RRFDSSTBlanketDescriptor;
////////////////////////////////////////////////////////////////////////////////

@end
