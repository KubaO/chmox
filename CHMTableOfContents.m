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
// $Revision: 1.1.1.1 $
//

#import "CHMTableOfContents.h"
#import "CHMContainer.h"
#import "CHMTopic.h"

#import <libxml/HTMLparser.h>


@implementation CHMTableOfContents

typedef struct {
    // Context
    CHMContainer *container;
    CHMTableOfContents *toc;
    NSMutableArray *topicStack;
    
    // Topic properties
    NSString *name;
    NSString *path;
} TOCBuilderContext;

static void createNewTopic( TOCBuilderContext *context );
static void documentDidStart( TOCBuilderContext *toc );
static void documentDidEnd( TOCBuilderContext *toc );
static void elementDidStart( TOCBuilderContext *toc, const xmlChar *name, const xmlChar **atts );
static void elementDidEnd( TOCBuilderContext *toc, const xmlChar *name );


static htmlSAXHandler saxHandler = {
    NULL, /* internalSubset */
    NULL, /* isStandalone */
    NULL, /* hasInternalSubset */
    NULL, /* hasExternalSubset */
    NULL, /* resolveEntity */
    NULL, /* getEntity */
    NULL, /* entityDecl */
    NULL, /* notationDecl */
    NULL, /* attributeDecl */
    NULL, /* elementDecl */
    NULL, /* unparsedEntityDecl */
    NULL, /* setDocumentLocator */
    (startDocumentSAXFunc) documentDidStart, /* startDocument */
    (endDocumentSAXFunc) documentDidEnd, /* endDocument */
    (startElementSAXFunc) elementDidStart, /* startElement */
    (endElementSAXFunc) elementDidEnd, /* endElement */
    NULL, /* reference */
    NULL, /* characters */
    NULL, /* ignorableWhitespace */
    NULL, /* processingInstruction */
    NULL, /* comment */
    NULL, /* xmlParserWarning */
    NULL, /* xmlParserError */
    NULL, /* xmlParserError */
    NULL, /* getParameterEntity */
};

#pragma mark Lifecycle

- (id)initWithContainer:(CHMContainer *)container
{
    if( self = [super init] ) {
	rootTopics = [[NSMutableArray alloc] init];
	branchTopics = [[NSMutableDictionary alloc] init];

	TOCBuilderContext context = {
	    container, self, [[NSMutableArray alloc] init],
	    nil, nil
	};
	
	NSData *tocData = [container dataWithTableOfContents];
	NSLog( @"TOC: %@", [NSString stringWithCString:[tocData bytes] length:[tocData length]] );
	
	// XML_CHAR_ENCODING_NONE / XML_CHAR_ENCODING_UTF8 / XML_CHAR_ENCODING_8859_1
	htmlParserCtxtPtr parser = htmlCreatePushParserCtxt( &saxHandler, &context,
							     [tocData bytes], [tocData length],
							     NULL, XML_CHAR_ENCODING_8859_1 );
	htmlParseChunk( parser, [tocData bytes], 0, 1 );
	[context.topicStack release];

	htmlDocPtr doc = parser->myDoc;
	htmlFreeParserCtxt( parser );
	if( doc ) {
	    xmlFreeDoc( doc );
	}

    }
    
    return self;
}


- (void) dealloc
{
    [rootTopics release];
    [branchTopics release];
}

#pragma mark libxml SAX handler implementation

static void documentDidStart( TOCBuilderContext *context )
{
    NSLog( @"SAX:documentDidStart" );
}

static void documentDidEnd( TOCBuilderContext *context )
{
    NSLog( @"SAX:documentDidEnd" );
}

static void elementDidStart( TOCBuilderContext *context, const xmlChar *name, const xmlChar **atts )
{
    //NSLog( @"SAX:elementDidStart %s", name );

    if( !strcasecmp( "ul", name ) && context->name ) {
	createNewTopic( context );
    }
    else if( !strcasecmp( "li", name ) ) {
	// Opening depth level
	context->name = nil;
	context->path = nil;
    }
    else if( !strcasecmp( "param", name ) && ( atts != NULL )) {
	// Topic properties
	const xmlChar *type = NULL;
	const xmlChar *value = NULL;
	
	for( int index = 0; atts[ index ] != NULL ; index += 2 ) {
	    if( !strcasecmp( "name", atts[ index ] ) ) {
		type = atts[ index + 1 ];
	    }
	    else if( !strcasecmp( "value", atts[ index ] ) ) {
		value = atts[ index + 1 ];
	    }
	}
	
	if( ( type != NULL ) && ( value != NULL ) ) {
	    if( !strcasecmp( "Name", type ) ) {
		// Name of the topic
		context->name = [[NSString alloc] initWithUTF8String:value];
	    }
	    else if( !strcasecmp( "Local", type ) ) {
		// Path of the topic
		context->path = [[NSString alloc] initWithUTF8String:value];
	    }
	    else {
		NSLog( @"type=%s  value=%s", type, value );
	    }
	}
    }
}

static void elementDidEnd( TOCBuilderContext *context, const xmlChar *name )
{
    if( !strcasecmp( "li", name ) && context->name ) {
	// New complete topic
	createNewTopic( context );
    }
    else if( !strcasecmp( "ul", name ) ) {
	// Closing depth level
    }
}

static void createNewTopic( TOCBuilderContext *context )
{
    NSLog( @"Topic: %@ %@", context->path, context->name );

    NSURL *location = nil;
    
    if( context->path ) {
	location = [NSURL URLWithString:context->path relativeToURL:[context->container baseURL]];
    }

    CHMTopic *topic = [[CHMTopic alloc] initWithName:context->name location:location];
    
    [context->name release];
    [context->path release];
    context->name = nil;
    context->path = nil;
}


#pragma mark NSOutlineViewDataSource implementation

- (int)outlineView:(NSOutlineView *)outlineView
    numberOfChildrenOfItem:(id)item
{
    NSArray *topics = item? [branchTopics objectForKey:item] : rootTopics;
    return [topics count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
    return [branchTopics objectForKey:item] != nil;
}

- (id)outlineView:(NSOutlineView *)outlineView
	    child:(int)index
	   ofItem:(id)item
{
    NSArray *topics = item? [branchTopics objectForKey:item] : rootTopics;
    return [topics objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView
    objectValueForTableColumn:(NSTableColumn *)tableColumn
	   byItem:(id)item
{
    return item;
}

@end
