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
// $Revision: 1.1.1.1 $
//

#import <Foundation/Foundation.h>

@class CHMTableOfContents;
struct chmFile;

@interface CHMContainer : NSObject {
    struct chmFile *_handle;
    NSString *_uniqueId;
    
    NSString *_path;
    NSString *_title;
    NSURL *_baseURL;
    NSURL *_homeURL;
    NSString *_tocPath;
    NSString *_indexPath;
    CHMTableOfContents *_toc;
}

+ (id)containerWithContentsOfFile:(NSString *)path;
+ (id)containerForUniqueId:(NSString *)uniqueId;

- (id)initWithContentsOfFile:(NSString *)path;

- (NSData *)dataWithContentsOfObject: (NSString *)objectPath;
- (NSString *)stringWithContentsOfObject: (NSString *)objectPath;
- (NSData *)dataWithTableOfContents;

- (BOOL)loadMetadata;

- (NSString *)title;
- (NSString *)uniqueId;
- (CHMTableOfContents *)tableOfContents;
- (NSURL *)baseURL;
- (NSURL *)homeURL;

@end
