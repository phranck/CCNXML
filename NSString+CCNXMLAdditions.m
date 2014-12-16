//
//  NSString+CCNXMLAdditions.m
//
//  Created by Frank Gregor on 24/01/14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2013 Frank Gregor, <phranck@cocoanaut.com>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the “Software”), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "NSString+CCNXMLAdditions.h"

@implementation NSString (CCNXMLAdditions)

- (NSString *)prefix {
   NSString *mappingPrefix = @"";
   NSArray *components = [self componentsSeparatedByString:@":"];
   if ([components count] > 0) {
      mappingPrefix = components[0];
   }
   return mappingPrefix;
}

- (NSString *)xmlEscapedString {
   NSDictionary *entities = @{
      @"&":    @"&amp;",
//      @"\"":   @"&quot;",
//      @"'":    @"&apos;",
      @">":    @"&gt;",
      @"<":    @"&lt;"
   };
   __block NSMutableString *xmlEscapedString = [NSMutableString stringWithString:self];
   [entities enumerateKeysAndObjectsUsingBlock:^(NSString *entity, NSString *replacement, BOOL *stop) {
      [xmlEscapedString replaceOccurrencesOfString:entity
                                        withString:replacement
                                           options:(NSLiteralSearch|NSCaseInsensitiveSearch|NSWidthInsensitiveSearch)
                                             range:NSMakeRange(0, [self length])];
   }];
   return xmlEscapedString;
}

@end
