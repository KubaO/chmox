//
//  CHMVersionChecker.h
//  chmox
//
//  Created by Stéphane on Wed Jul 14 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

extern NSString *AUTOMATIC_CHECK_PREF; // Key for user defaults.

@class MacPADSocket;

@interface CHMVersionChecker : NSWindowController {
    IBOutlet	NSPanel *_updateAvailableWindow;
    IBOutlet	NSPanel *_upToDateWindow;
    IBOutlet	NSPanel *_cannotCheckWindow;
    IBOutlet	NSButton *_preferenceButton1;
    IBOutlet	NSButton *_preferenceButton2;
    IBOutlet	NSButton *_preferenceButton3;
    
    IBOutlet	NSTextField *_updateDescriptionTextField;
    
    MacPADSocket *_macPAD;
    bool _isAutomaticCheck;
}

- (void)checkForNewVersion;
- (void)automaticallyCheckForNewVersion;

- (IBAction)closeWindow:(id)sender;
- (IBAction)update:(id)sender;
- (IBAction)changePreference:(id)sender;

- (BOOL)shouldAutomaticallyCheckForNewVersion;
- (BOOL)shouldNotifyLackOfNewVersion;
- (void)updateNewVersionAvailability:(BOOL)isNewVersionAvailable;

@end
