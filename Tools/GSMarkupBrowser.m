/* The GNUstep Markup Browser
   Copyright (C) 2002 Free Software Foundation, Inc.

   Written by: Nicola Pero <nicola@brainstorm.co.uk>
   Date: March 2002

   This file is part of GNUstep Renaissance

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   You should have received a copy of the GNU General Public
   License along with this program; see the file COPYING.LIB.
   If not, write to the Free Software Foundation,
   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
   */

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#ifdef GNUSTEP
/* When compiling on-site, on GNUstep the headers are not installed
 * yet.  */
# include "Renaissance.h"
#else
/* Here compiling on-site is simply not supported :-).  */
# include <Renaissance/Renaissance.h>
#endif

@interface Owner : NSObject
{
  NSString *fileName;
}

- (id) initWithFile: (NSString *)f;

- (void) takeValue: (id)anObject  forKey: (NSString*)aKey;

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;

@end


@implementation Owner 

- (id) initWithFile: (NSString *)f
{
  ASSIGN (fileName, f);
  return self;
}

- (void) dealloc
{
  RELEASE (fileName);
  [super dealloc];
}

- (void) takeValue: (id)anObject  forKey: (NSString*)aKey
{
  NSLog (@"Set value \"%@\" for key \"%@\" of NSOwner", anObject, aKey);
}

- (void)applicationDidFinishLaunching: (NSNotification *)aNotification;
{
  BOOL b;
  CREATE_AUTORELEASE_POOL (pool);

  NSLog (@"Loading %@", fileName);
 
  b = [NSBundle loadGSMarkupFile: fileName
		externalNameTable: [NSDictionary dictionaryWithObject: self
						 forKey: @"NSOwner"]
		withZone: NULL];

  RELEASE (pool);

  if (b)
    {
      NSLog (@"%@ loaded!", fileName);
    }
  else
    {
      NSLog (@"Could not load %@!", fileName);
      exit (1);
    }
}
@end

int main (void)
{
  CREATE_AUTORELEASE_POOL(pool);
  NSArray *args;
  Owner *owner;
  NSString *path;

  args = [[NSProcessInfo processInfo] arguments];
  
  if ([args count] < 2)
    {
#ifdef GNUSTEP
      NSLog (@"Usage: openapp GSMLBrowser file.gsmarkup\n");
#else
      NSLog (@"Usage: open GSMLBrowser.app file.gsmarkup\n");
#endif
      NSLog (@"Loads the file so you can see what it is like :-)\n");
      exit (0);
    }

  path = [args objectAtIndex: 1];
  
  if (![path isAbsolutePath])
    {
      path = [[[NSFileManager defaultManager] currentDirectoryPath]
	       stringByAppendingPathComponent: path];
    }

  [NSApplication sharedApplication];   

  owner = [[Owner alloc] initWithFile: path];

  [NSApp setDelegate: owner];
  [NSApp run];

  RELEASE (pool);
  return 0;
}
