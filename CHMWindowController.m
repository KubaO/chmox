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
// $Revision: 1.6 $
//

#import "WebKit/WebKit.h"
#import "CHMWindowController.h"
#import "CHMDocument.h"
#import "CHMTopic.h"

@implementation CHMWindowController

// Tab items
static NSString *TOC_TAB_ID = @"tocTab";
static NSString *SEARCH_TAB_ID = @"searchTab";
static NSString *FAVORITES_TAB_ID = @"favoritesTab";

// Toolbar items
static NSString *DRAWER_TOGGLE_TOOL_ID = @"chmox.drawerToggle";
static NSString *SMALLER_TEXT_TOOL_ID = @"chmox.smallerText";
static NSString *BIGGER_TEXT_TOOL_ID = @"chmox.biggerText";


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

    [self setupToolbar];

    int tabIndex;
    
    // Remove Search tab
    tabIndex = [_drawerView indexOfTabViewItemWithIdentifier:SEARCH_TAB_ID];
    if( tabIndex != NSNotFound ) {
	[_drawerView removeTabViewItem:[_drawerView tabViewItemAtIndex:tabIndex]];
    }

    // Remove Favorites tab
    tabIndex = [_drawerView indexOfTabViewItemWithIdentifier:FAVORITES_TAB_ID];
    if( tabIndex != NSNotFound ) {
	[_drawerView removeTabViewItem:[_drawerView tabViewItemAtIndex:tabIndex]];
    }
    
    [_drawer open];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
    return [[self document] title];
}

#pragma mark Toolbar related methods

- (void)setupToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
    [toolbar autorelease];
    [toolbar setDelegate:self];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [[self window ] setToolbar:toolbar];
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

#pragma mark Actions

- (IBAction)toggleDrawer:(id)sender
{
    [_drawer toggle:self];
}

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
        DRAWER_TOGGLE_TOOL_ID,
	SMALLER_TEXT_TOOL_ID,
	BIGGER_TEXT_TOOL_ID,
        NSToolbarSeparatorItemIdentifier,
        NSToolbarSpaceItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
//        NSToolbarPrintItemIdentifier,
        nil
        ];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar
{
    return [NSArray arrayWithObjects:
        DRAWER_TOGGLE_TOOL_ID,
	SMALLER_TEXT_TOOL_ID,
	BIGGER_TEXT_TOOL_ID,
        NSToolbarFlexibleSpaceItemIdentifier,
//        NSToolbarPrintItemIdentifier,
        nil
        ];
}


- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    
    if ( [itemIdentifier isEqualToString:DRAWER_TOGGLE_TOOL_ID] ) {
        [item setLabel:@"Drawer"];
        [item setPaletteLabel:[item label]];
        [item setImage:[NSImage imageNamed:@"toolbar-drawer"]];
        [item setTarget:self];
        [item setAction:@selector(toggleDrawer:)];
    }
    else if ( [itemIdentifier isEqualToString:SMALLER_TEXT_TOOL_ID] ) {
        [item setLabel:@"Smaller"];
        [item setPaletteLabel:[item label]];
        [item setImage:[NSImage imageNamed:@"toolbar-smaller"]];
        [item setTarget:_contentsView];
        [item setAction:@selector(makeTextSmaller:)];
    }
    else if ( [itemIdentifier isEqualToString:BIGGER_TEXT_TOOL_ID] ) {
        [item setLabel:@"Bigger"];
        [item setPaletteLabel:[item label]];
        [item setImage:[NSImage imageNamed:@"toolbar-bigger"]];
        [item setTarget:_contentsView];
        [item setAction:@selector(makeTextLarger:)];
    }
    
    return [item autorelease];
}

-(BOOL)validateToolbarItem:(NSToolbarItem*)toolbarItem
{
    NSString *itemIdentifier = [toolbarItem itemIdentifier];
    
    if ( [itemIdentifier isEqualToString:SMALLER_TEXT_TOOL_ID] ) {
	return [_contentsView canMakeTextSmaller];
    }
    else if ( [itemIdentifier isEqualToString:BIGGER_TEXT_TOOL_ID] ) {
	return [_contentsView canMakeTextLarger];
    }
    
    return YES;
}

@end
