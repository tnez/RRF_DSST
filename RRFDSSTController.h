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

@interface RRFDSSTController : NSObject <TKComponentBundleLoading> {

  // PROTOCOL MEMBERS //////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////    
  NSDictionary                                                *definition;
  id                                                          delegate;
  NSString                                                    *errorLog;
  IBOutlet NSView                                             *view;

  // ADDITIONAL MEMBERS ////////////////////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  DSSTPattern * pattern1;
	DSSTPattern * pattern2;
	DSSTPattern * pattern3;
	DSSTPattern * pattern4;
	DSSTPattern * pattern5;
	DSSTPattern * pattern6;
	DSSTPattern * pattern7;
	DSSTPattern * pattern8;
	DSSTPattern * pattern9;
	DSSTPattern * userPattern;
	NSTextField * userChallengeLabel;
	NSTextField * pointsLabel;
	NSInteger currentChallenge;
	NSInteger currentRow;
	NSInteger numberOfPoints;
	NSInteger totalNumberOfTrials;
	BOOL currentTrialIsStillValid;
	TKTimer * appTimer;
	NSUInteger clearSeconds;
	NSUInteger clearMicroSeconds;
	NSInteger numberOfTrialsSinceLastReset;
	NSInteger resetLimit;
	NSString * subjectID;
	NSString * studyDay;
	BOOL waitingToClear;
	NSNumber * currentRunHeaderOffset;
	NSString * fileName;
	NSString * crashRecoveryFileName;
	NSUInteger totalAppSeconds;
	NSUInteger totalAppMicroseconds;
	NSUInteger crashRecoverySeconds;
	NSUInteger crashRecoveryMicroseconds;
	NSUInteger runNumber;
	NSString * dataDirectory;  
}

// PROTOCOL PROPERTIES /////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@property (assign)              NSDictionary                    *definition;
@property (assign)              id <TKComponentBundleLoading>   delegate;
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
@property(nonatomic,retain) NSString * crashRecoveryFileName;
@property(nonatomic,retain) NSNumber * currentRunHeaderOffset;
@property(nonatomic,retain) TKTimer * appTimer;
@property(nonatomic,retain) NSString * subjectID;
@property(nonatomic,retain) NSString * studyDay;
@property(nonatomic,retain) IBOutlet DSSTPattern * pattern1;
@property(nonatomic,retain) IBOutlet DSSTPattern * pattern2;
@property(nonatomic,retain) IBOutlet DSSTPattern * pattern3;
@property(nonatomic,retain) IBOutlet DSSTPattern * pattern4;
@property(nonatomic,retain) IBOutlet DSSTPattern * pattern5;
@property(nonatomic,retain) IBOutlet DSSTPattern * pattern6;
@property(nonatomic,retain) IBOutlet DSSTPattern * pattern7;
@property(nonatomic,retain) IBOutlet DSSTPattern * pattern8;
@property(nonatomic,retain) IBOutlet DSSTPattern * pattern9;
@property(nonatomic,retain) IBOutlet DSSTPattern * userPattern;
@property(nonatomic,retain) IBOutlet NSWindow * theWindow;
@property(nonatomic,retain) IBOutlet NSTextField * userChallengeLabel;
@property(nonatomic,retain) IBOutlet NSTextField * pointsLabel;	
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
- (void)setDelegate: (id <TKComponentBundleDelegate> )aDelegate;

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
- (void)registerError: (NSString *)theError;
// begin: Scott's methods
-(BOOL)validPatternLayout;
-(void)userDidInputCharacters:(NSString*)characters;
-(DSSTPattern *)currentChallengePattern;
-(void)clearUserPattern:(NSNotification *)aNotification;
-(void)delayedClear;
-(void)startAppTimer;
-(void)exitWithNotification:(NSNotification *) aNotification;
-(void)logString:(NSString *)string;
-(void)regeneratePatterns;
-(void)readStartupInfo;
-(void)terminate;
-(void)logPatterns;
-(void)updateRunHeader;
-(BOOL)attemptCrashRecovery;
-(BOOL)setupNewRun;
// end: Scott's methods

#pragma mark Preference Keys
// HERE YOU DEFINE KEY REFERENCES FOR ANY PREFERENCE VALUES
// ex: NSString * const RRFDSSTNameOfPreferenceKey;
////////////////////////////////////////////////////////////////////////////////
NSString * const RRFDSSTTaskNameKey;
NSString * const RRFDSSTDataDirectoryKey;

#pragma mark Internal Strings
// HERE YOU DEFINE KEYS FOR CONSTANT STRINGS
////////////////////////////////////////////////////////////////////////////////
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
