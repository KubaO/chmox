//
//  CHMApplication.m
//  chmox
//
//  Created by Stéphane on 2004-10-24.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "CHMApplication.h"
#import "CHMVersionChecker.h"


@implementation CHMApplication

-(void) dealloc {
    [_versionChecker release];
}

-(void) awakeFromNib {
}

#pragma mark Startup and Shutdown
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    _versionChecker = [[CHMVersionChecker alloc] init];
    [_versionChecker automaticallyCheckForNewVersion];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
}

#pragma mark Menu bar actions

- (IBAction) checkForUpdates: (id)sender {
    [_versionChecker checkForNewVersion];
}

@end
