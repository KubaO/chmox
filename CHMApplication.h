//
//  CHMApplication.h
//  chmox
//
//  Created by Stéphane on 2004-10-24.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CHMVersionChecker;

@interface CHMApplication : NSObject {
    CHMVersionChecker *_versionChecker;
}

- (IBAction) checkForUpdates: (id)sender;

@end
