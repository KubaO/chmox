//
// Chmox a CHM file viewer for Mac OS X
// Copyright (c) 2004 St�phane Boisson.
//
// Chmox is free software; you can redistribute it and/or modify it
// under the terms of the GNU Lesser General Public License as published
// by the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.
//
// Chmox is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with Foobar; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
// $Revision: 1.3 $
//

#import "CHMApplication.h"
#import "CHMVersionChecker.h"
#import "CHMURLProtocol.h"


@implementation CHMApplication

-(void) dealloc {
    [_versionChecker release];
    [super dealloc];
}

-(void) awakeFromNib {
}

#pragma mark Startup and Shutdown
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    [NSURLProtocol registerClass:[CHMURLProtocol class]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    _versionChecker = [[CHMVersionChecker alloc] init];
    [_versionChecker automaticallyCheckForNewVersion];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [NSURLProtocol unregisterClass:[CHMURLProtocol class]];
}

#pragma mark Menu bar actions

- (IBAction) checkForUpdates: (id)sender {
    [_versionChecker checkForNewVersion];
}

@end
