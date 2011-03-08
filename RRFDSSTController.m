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
#import "RRFDSSTPattern.h"

#define RRFLogToTemp(fmt, ...) [delegate logStringToDefaultTempFile:[NSString stringWithFormat:fmt,##__VA_ARGS__]]
#define RRFLogToFile(filename,fmt, ...) [delegate logString:[NSString stringWithFormat:fmt,##__VA_ARGS__] toDirectory:[delegate tempDirectory] toFile:filename]
#define RRFPathToTempFile(filename) [[delegate tempDirectory] stringByAppendingPathComponent:filename]

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
  [self regeneratePatterns];
  [self clearUserPattern:nil];
  [[[self view] window] makeFirstResponder:(NSView *)[userPattern patternView]];
  [self startAppTimer];
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
  // remove queued log entries
  [[NSFileManager defaultManager] removeItemAtPath:[[delegate tempDirectory] stringByAppendingPathComponent:RRFDSSTLogSinceLastRecPointKey] error:nil];
  // TODO: get time and whozits
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
- (void)setDelegate: (id <TKComponentBundleDelegate>)aDelegate {
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
  // resetLimit = 25;
  resetLimit = [[definition valueForKey:RRFDSSTResetLimitKey] integerValue];
  totalAppSeconds = [[definition valueForKey:RRFDSSTTaskDurationKey] integerValue];
  DLog(@"I want to run for %d seconds",totalAppSeconds);
  totalAppMicroseconds = 0;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearUserPattern:) name:@"clearUserPattern" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitWithNotification:) name:@"exitWithNotification" object:nil];
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
  // we will need to recover if our raw data file exists
  return [[NSFileManager defaultManager] fileExistsAtPath:RRFPathToTempFile([self rawDataFile])];
}

/**
 Perform any and all finalization required by component
 */
- (void)tearDown {
  // any finalization should be done here...

  // remove any temporary data files (uncomment below to use default)
  NSError *tFileMoveError = nil;
  [[NSFileManager defaultManager] removeItemAtPath:RRFPathToTempFile([self rawDataFile]) error:&tFileMoveError];
  if(tFileMoveError) {
    ELog(@"%@",[tFileMoveError localizedDescription]);
    [tFileMoveError release]; tFileMoveError=nil;
  }

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
- (void)dequeueTempLogEntries {
  DLog(@"Starting to dequeue log entries");
  // if queued log entries exist
  if([[NSFileManager defaultManager] fileExistsAtPath:RRFPathToTempFile(RRFDSSTLogSinceLastRecPointKey)]) {
    // get the contents of the file
    NSString *contents = [NSString stringWithContentsOfFile:RRFPathToTempFile(RRFDSSTLogSinceLastRecPointKey)];
    // append 
    RRFLogToTemp(@"%@",contents);
    // then delete the queue log
    [[NSFileManager defaultManager] removeItemAtPath:RRFPathToTempFile(RRFDSSTLogSinceLastRecPointKey) error:nil];
  }
  DLog(@"Finished dequeueing log entries");
}
    
- (void)registerError: (NSString *)theError {
    // append the new error to the error log
    [self setErrorLog:[[errorLog stringByAppendingString:theError] stringByAppendingString:@"\n"]];
}

-(void)clearUserPattern:(NSNotification *)aNotification {
	currentRow=3;
	if(currentTrialIsStillValid){
		numberOfPoints++;
		[[self pointsLabel] setStringValue:[NSString stringWithFormat:@"Points:%d",numberOfPoints]];
	}
	int rand;
	do{
		rand=(arc4random()%9)+1;
	}while(rand==currentChallenge);
	currentChallenge=rand;
	[userChallengeLabel setIntegerValue:currentChallenge];
  
	int i=0;
	for(i=0;i<9;i++){
		[[self userPattern] setPatternPositionValueAtIndex:i toValue:0];
	}
	[[self userPattern] updateView];
	[self updateRunHeader];
	//[self logString:[NSString stringWithFormat:@"\nPattern:\t%@\n",[[self currentChallengePattern] stringValue]]];
  RRFLogToFile(RRFDSSTLogSinceLastRecPointKey,@"\nPattern:\t%@",[[self currentChallengePattern] stringValue]);
	waitingToClear=NO;
	currentTrialIsStillValid=YES;	
}

-(RRFDSSTPattern *)currentChallengePattern{
	if(currentChallenge==1){
		return [self pattern1];
	}else if(currentChallenge==2){
		return [self pattern2];
	}else if(currentChallenge==3){
		return [self pattern3];
	}else if(currentChallenge==4){
		return [self pattern4];
	}else if(currentChallenge==5){
		return [self pattern5];
	}else if(currentChallenge==6){
		return [self pattern6];
	}else if(currentChallenge==7){
		return [self pattern7];
	}else if(currentChallenge==8){
		return [self pattern8];
	}else if(currentChallenge==9){
		return [self pattern9];
	}
	return nil;
}

-(void)delayedClear{
	waitingToClear=YES;
	[self startClearTimer];
}

- (void)exitWithNotification: (NSNotification *)aNote {
  DLog(@"Message Received");  
  [[view window] makeFirstResponder:nil]; // stop accepting responses
  [self dequeueTempLogEntries];           // grab any queued log entries
  [self updateRegistryFile];
  [delegate componentDidFinish:self];     // notify component (we have finished)
}

- (void)logPatterns {
  // dequeue any queued log entries
  [self dequeueTempLogEntries];  
  // log to datafile
  RRFLogToTemp(@"\nPattern1:\t%@\nPattern2:\t%@\nPattern3:\t%@\nPattern4:\t%@\nPattern5:\t%@\nPattern6:\t%@\nPattern7:\t%@\nPattern8:\t%@\nPattern9:\t%@\n",
               [pattern1 stringValue],
               [pattern2 stringValue],
               [pattern3 stringValue],
               [pattern4 stringValue],
               [pattern5 stringValue],
               [pattern6 stringValue],
               [pattern7 stringValue],
               [pattern8 stringValue],
               [pattern9 stringValue]);
  // let's log nesc recovery info at each pattern reset...
  // this will be our recovery point if needed
  [self updateRegistryFile];
}

-(void)regeneratePatterns{
  // get new patterns
	do{
		[pattern1 generateRandomValidPattern];
		[pattern2 generateRandomValidPattern];
		[pattern3 generateRandomValidPattern];
		[pattern4 generateRandomValidPattern];
		[pattern5 generateRandomValidPattern];
		[pattern6 generateRandomValidPattern];
		[pattern7 generateRandomValidPattern];
		[pattern8 generateRandomValidPattern];
		[pattern9 generateRandomValidPattern];
	}while(![self validPatternLayout]);
  // update views
	[pattern1 updateView];
	[pattern2 updateView];
	[pattern3 updateView];
	[pattern4 updateView];
	[pattern5 updateView];
	[pattern6 updateView];
	[pattern7 updateView];
	[pattern8 updateView];
	[pattern9 updateView];
  // record new patterns
	[self logPatterns];
	// reset this
	numberOfTrialsSinceLastReset=0;
}

- (void)startAppTimer {
  // start app timer
	NSNotification * exitWithNotification =[NSNotification notificationWithName:@"exitWithNotification" object:self];
  // register notification w/ the timer
	[[(TKComponentController *)delegate timer] registerEventWithNotification:exitWithNotification inSeconds:totalAppSeconds microSeconds:totalAppMicroseconds];    
  // grab start timer for use in latency calcs
  start = current_time_marker();
}

- (void)startClearTimer{	
	NSNotification * clearUserPattern=[NSNotification notificationWithName:@"clearUserPattern" object:self];
	// 0.1 Seconds or 100 milliseconds
	NSUInteger microSecondsTilClear=(1000*100);
	[[(TKComponentController *)delegate timer] registerEventWithNotification:clearUserPattern inSeconds:(NSUInteger)0 microSeconds:(NSUInteger)microSecondsTilClear];
}

- (void)updateRegistryFile {
  NSArray *aPatterns = [NSArray arrayWithObjects:[pattern1 stringValue],
                        [pattern2 stringValue],
                        [pattern3 stringValue],
                        [pattern4 stringValue],
                        [pattern5 stringValue],
                        [pattern6 stringValue],
                        [pattern7 stringValue],
                        [pattern8 stringValue],
                        [pattern9 stringValue],nil];
  [delegate setValue:aPatterns forRunRegistryKey:RRFDSSTLastPatternKey];
  [delegate setValue:[NSDate date] forRunRegistryKey:RRFDSSTLastKnownTimeKey];
  [delegate setValue:[NSNumber numberWithInteger:numberOfPoints] forRunRegistryKey:RRFDSSTTrialsCorrectCountKey];
  [delegate setValue:[NSNumber numberWithInteger:totalNumberOfTrials] forRunRegistryKey:RRFDSSTTrialsCountKey];
}

-(void) updateRunHeader{
	//NSString * runHeaderString = [NSString stringWithFormat:@"Run:\t%03d\tTotal Trials:\t%10d\t# Correct:\t%10d\t# Incorrect:\t%10d\tPercentage Correct:\t%06.2f%%\n\n",[self runNumber],[self totalNumberOfTrials],[self numberOfPoints],[self totalNumberOfTrials]-[self numberOfPoints],(totalNumberOfTrials>0?(float)((float)100*[self numberOfPoints])/((float)[self totalNumberOfTrials]):0)];
	//[[TKLogging mainLogger] queueLogMessage:[[TKLogging getCurrentAppDirectory] stringByAppendingPathComponent:dataDirectory] file:fileName contentsOfString:runHeaderString overWriteOnFirstWrite:NO withOffset:[self currentRunHeaderOffset]];
	//[[TKLogging crashRecoveryLogger] queueLogMessage:[[TKLogging getCurrentAppDirectory] stringByAppendingPathComponent:dataDirectory] file:crashRecoveryFileName contentsOfString:runHeaderString overWriteOnFirstWrite:NO withOffset:[self currentRunHeaderOffset]];
  DLog(@"This is where Scott was updating run header");
  // if we want to recover to specific trial, we should update counts and time here...
  // if instead we are going to recover to last reset, we do not need to do anything here
}
-(void)userDidInputCharacters:(NSString*)characters{
	if(waitingToClear){
		return;
	}
  TKTime latency = time_since(start); // mark the time
	RRFDSSTPattern * challengePattern=[self currentChallengePattern];
	if([characters integerValue]==0){
		if(currentRow==3){
			[[self userPattern] setPatternPositionValueAtIndex:6 toValue:1];
			[[self userPattern] setPatternPositionValueAtIndex:7 toValue:1];
			[[self userPattern] setPatternPositionValueAtIndex:8 toValue:1];
		}else if(currentRow==2){
			[[self userPattern] setPatternPositionValueAtIndex:3 toValue:1];
			[[self userPattern] setPatternPositionValueAtIndex:4 toValue:1];
			[[self userPattern] setPatternPositionValueAtIndex:5 toValue:1];
		}else{
			[[self userPattern] setPatternPositionValueAtIndex:0 toValue:1];
			[[self userPattern] setPatternPositionValueAtIndex:1 toValue:1];
			[[self userPattern] setPatternPositionValueAtIndex:2 toValue:1];
		}
		currentTrialIsStillValid=NO;
	}else{
		NSInteger number=[characters integerValue];
		if(currentRow==3){
			if(number>6&&[challengePattern getPatternPositionValueAtIndex:(number-1)]==1){
				//highlight it
				[[self userPattern] setPatternPositionValueAtIndex:(number-1) toValue:1];
			}else{
				[[self userPattern] setPatternPositionValueAtIndex:6 toValue:1];
				[[self userPattern] setPatternPositionValueAtIndex:7 toValue:1];
				[[self userPattern] setPatternPositionValueAtIndex:8 toValue:1];
				currentTrialIsStillValid=NO;
			}
		}else if(currentRow==2){
			if(number<7&&number>3&&[challengePattern getPatternPositionValueAtIndex:(number-1)]==1){
				[[self userPattern] setPatternPositionValueAtIndex:(number-1) toValue:1];
			}else{
        [[self userPattern] setPatternPositionValueAtIndex:3 toValue:1];
				[[self userPattern] setPatternPositionValueAtIndex:4 toValue:1];
				[[self userPattern] setPatternPositionValueAtIndex:5 toValue:1];
				currentTrialIsStillValid=NO;
			}
		}else if(currentRow==1){
			if(number<4&&number>0&&[challengePattern getPatternPositionValueAtIndex:(number-1)]==1){
				[[self userPattern] setPatternPositionValueAtIndex:(number-1) toValue:1];
			}else{
				[[self userPattern] setPatternPositionValueAtIndex:0 toValue:1];
				[[self userPattern] setPatternPositionValueAtIndex:1 toValue:1];
				[[self userPattern] setPatternPositionValueAtIndex:2 toValue:1];
				currentTrialIsStillValid=NO;
			}
		}
	}
	//[self logString:[NSString stringWithFormat:@"Key%d:\t%@\nTime%d:\t%d.%06d\n",(4-currentRow),characters,(4-currentRow),[[TKTimer appTimer] seconds],[[TKTimer appTimer] microseconds]]];
  RRFLogToFile(RRFDSSTLogSinceLastRecPointKey,@"Key%d:\t%@\nTime%d:\t%d.%06d",(4-currentRow),characters,(4-currentRow),latency.seconds,latency.microseconds);
	[[self userPattern] updateView];
	currentRow--;
	if(currentRow==0){
		[self delayedClear];
		totalNumberOfTrials++;
		numberOfTrialsSinceLastReset++;
		if(numberOfTrialsSinceLastReset==resetLimit){
			[self regeneratePatterns];
		}
	}
}

-(BOOL)validPatternLayout{
	if([pattern2 equalsPattern:pattern1]){
		return NO;
	}else if([pattern3 equalsPattern:pattern1]||[pattern3 equalsPattern:pattern2]){
		return NO;
	}else if([pattern4 equalsPattern:pattern1]||[pattern4 equalsPattern:pattern2]||[pattern4 equalsPattern:pattern3]){
		return NO;
	}else if([pattern5 equalsPattern:pattern1]||[pattern5 equalsPattern:pattern2]||[pattern5 equalsPattern:pattern3]||[pattern5 equalsPattern:pattern4]){
		return NO;
	}else if([pattern6 equalsPattern:pattern1]||[pattern6 equalsPattern:pattern2]||[pattern6 equalsPattern:pattern3]||[pattern6 equalsPattern:pattern4]||[pattern6 equalsPattern:pattern5]){
		return NO;
	}else if([pattern7 equalsPattern:pattern1]||[pattern7 equalsPattern:pattern2]||[pattern7 equalsPattern:pattern3]||[pattern7 equalsPattern:pattern4]||[pattern7 equalsPattern:pattern5]||[pattern7 equalsPattern:pattern6]){
		return NO;
	}else if([pattern8 equalsPattern:pattern1]||[pattern8 equalsPattern:pattern2]||[pattern8 equalsPattern:pattern3]||[pattern8 equalsPattern:pattern4]||[pattern8 equalsPattern:pattern5]||[pattern8 equalsPattern:pattern6]||[pattern8 equalsPattern:pattern7]){
		return NO;
	}else if([pattern9 equalsPattern:pattern1]||[pattern9 equalsPattern:pattern2]||[pattern9 equalsPattern:pattern3]||[pattern9 equalsPattern:pattern4]||[pattern9 equalsPattern:pattern5]||[pattern9 equalsPattern:pattern6]||[pattern9 equalsPattern:pattern7]||[pattern9 equalsPattern:pattern8]){
		return NO;
	}
	return YES;
}

#pragma mark Preference Keys
// HERE YOU DEFINE KEY REFERENCES FOR ANY PREFERENCE VALUES
// ex: NSString * const RRFDSSTNameOfPreferenceKey = @"RRFDSSTNameOfPreference"
NSString * const RRFDSSTTaskNameKey = @"RRFDSSTTaskName";
NSString * const RRFDSSTDataDirectoryKey = @"RRFDSSTDataDirectory";
NSString * const RRFDSSTTaskDurationKey = @"RRFDSSTDuration";
NSString * const RRFDSSTResetLimitKey = @"RRFDSSTResetLimit";

#pragma mark Registry Keys
NSString * const RRFDSSTLastKnownTimeKey = @"LastKnownTime";
NSString * const RRFDSSTLastPatternKey = @"LastPattern";
NSString * const RRFDSSTTrialsCorrectCountKey = @"TrialsCorrectCount";
NSString * const RRFDSSTTrialsCorrectPercentageKey = @"TrialsCorrectPercentage";
NSString * const RRFDSSTTrialsCountKey = @"TotalTrials";

#pragma mark Internal Strings
// HERE YOU DEFINE KEYS FOR CONSTANT STRINGS //
///////////////////////////////////////////////
NSString * const RRFDSSTLogSinceLastRecPointKey = @"logSinceLastRecPoint.txt";
NSString * const RRFDSSTMainNibNameKey = @"RRFDSSTMainNib";
        
@end
