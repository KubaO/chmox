//
// Chmox a CHM file viewer for Mac OS X
// Copyright (c) 2004 Stéphane Boisson.
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
// $Revision: 1.4 $
//

#import "WebKit/WebKit.h"
#import "CHMWindowController.h"
#import "CHMDocument.h"
#import "CHMTopic.h"

@implementation CHMWindowController


- (void)updateToolTipRects
{
    [_tocView removeAllToolTips];
    NSRange range = [_tocView rowsInRect:[_tocView visibleRect]];
    
    for( int index = range.location; index < NSMaxRange( range ); ++index ) {
	[_tocView addToolTipRect:[_tocView rectOfRow:index] owner:self userData:NULL];
    }
}

#pragma mark NSWindowController overrided method

- (void)windowDidLoad
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[[self document] currentLocation]];
    [[_contentsView mainFrame] loadRequest:request];

    [self setWindowFrameAutosaveName:[[self document] uniqueId]];
    [self setShouldCloseDocument:YES];
    
    [_contentsView setPolicyDelegate:self];
    [_contentsView setFrameLoadDelegate:self];   
// [_contentsView setUIDelegate:self];
    
    [_tocView setDataSource:[[self document] tableOfContents]];
    [_tocView setDelegate:self];
    [self updateToolTipRects];

    // [self setupToolbar];

    [_drawer open];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
    return [[self document] title];
}

#pragma mark Toolbar related methods

- (void)toggleDrawer {
    NSLog( @"Toggle drawer" );
    [_drawer toggle:self];
}

- (void)setupToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
    [toolbar autorelease];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [[self window ] setToolbar:[toolbar autorelease]];
}

#pragma mark WebPolicyDelegate

// Open external URLs in external viewer
- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation
	request:(NSURLRequest *)request
	  frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    NSLog( @"decidePolicyForNavigationAction: %@ %@", request, actionInformation );
    
    if( [[[request URL] scheme] isEqualToString:@"chmox-internal"] ) {
	[listener use];
    }

    [listener ignore];
    [[NSWorkspace sharedWorkspace] openURL:[request URL]];
}


#pragma mark WebFrameLoadDelegate

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
//	[backButton setEnabled:[sender canGoBack]];
//	[forwardButton setEnabled:[sender canGoForward]];
    }
}


#pragma mark WebUIDelegate 

- (NSArray *)webView:(WebView *) sendercontextMenuItemsForElement:(NSDictionary *)element
    defaultMenuItems:(NSArray *)defaultMenuItems
{
    NSLog( @"mouseDidMoveOverElement: %@", element );
    return defaultMenuItems;
}

- (void)webView:(WebView *)sender mouseDidMoveOverElement:(NSDictionary *)elementInformation
  modifierFlags:(unsigned int)modifierFlags
{
    //NSLog( @"mouseDidMoveOverElement: %@", elementInformation );
}

#pragma mark NSToolTipOwner

- (NSString *)view:(NSView *)view
  stringForToolTip:(NSToolTipTag)tag
	     point:(NSPoint)point
	  userData:(void *)userData
{
    if( view == _tocView ) {
	int row = [_tocView rowAtPoint:point];
	
	if( row >= 0 ) {
	    return [[_tocView itemAtRow:row] name];
	}
    }
    
    return nil;
}

#pragma mark NSOutlineView delegate

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    // Change icon
}

#pragma mark NSOutlineView actions

- (IBAction)displayTopic:(id)sender
{
    int selectedRow = [_tocView selectedRow];
    
    if( selectedRow >= 0 ) {
	CHMTopic *topic = [_tocView itemAtRow:selectedRow];
	NSURL *location = [topic location];
	
	if( location ) {
	    [[_contentsView mainFrame] loadRequest:[NSURLRequest requestWithURL:location]];
	}
    }
}


#pragma mark NSToolbar

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
        @"ToggleDrawer",
        NSToolbarSeparatorItemIdentifier,
        NSToolbarSpaceItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarPrintItemIdentifier,
        nil
        ];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
        @"ToggleDrawer",
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarPrintItemIdentifier,
        nil
        ];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    
    if ( [itemIdentifier isEqualToString:@"ToggleDrawer"] ) {
        [item setLabel:@"Options"];
        [item setPaletteLabel:[item label]];
        [item setImage:[NSImage imageNamed:@"ToggleDrawer"]];
        [item setTarget:self];
        [item setAction:@selector(toggleDrawer:)];
    } else if ( [itemIdentifier isEqualToString:@"RemoveItem"] ) {
        [item setLabel:@"Remove Record"];
        [item setPaletteLabel:[item label]];
//        [item setImage:[NSImage imageNamed:@"Remove"]];
//        [item setTarget:self];
//        [item setAction:@selector(deleteRecord:)];
    }
    
    return [item autorelease];
}


@end
