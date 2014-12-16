//
//  CCNXML.h
//
//  Created by Frank Gregor on 31.01.14.
//  Copyright (c) 2014 cocoa:naut. All rights reserved.
//

/*
 The MIT License (MIT)
 Copyright © 2014 Frank Gregor, <phranck@cocoanaut.com>

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


#import "CCNXMLElement.h"
#import "CCNXMLReader.h"

#import "NSString+CCNXMLAdditions.h"
#import "NSMutableString+CCNXMLAdditions.h"


#ifndef CCNXML_h
#define CCNXML_h

/**
 XML parse error notification

 * The notification object is nil
 * The userInfo dictionary has two entries:
 1. CCNXMLNotificationUserInfoDictParserKey                       (NSXMLParser object with the current parser)
 2. CCNXMLNotificationUserInfoDictErrorKey                        (NSError object with the parse error)
 */
FOUNDATION_EXPORT NSString *const CCNXMLParseErrorNotification;

/**
 XML validation error notification

 * The notification object is nil
 * The userInfo dictionary has two entries:
 1. CCNXMLNotificationUserInfoDictParserKey                       (NSXMLParser object with the current parser)
 2. CCNXMLNotificationUserInfoDictErrorKey                        (NSError object with the validation error)
 */
FOUNDATION_EXPORT NSString *const CCNXMLValidationErrorNotification;

/**
 XML parser start element found notification

 * The notification object is nil
 * The userInfo dictionary has two entries:
 1. CCNXMLNotificationUserInfoDictParserKey                       (NSXMLParser object with the current parser)
 2. CCNXMLNotificationUserInfoDictCurrentElementKey               (NSString object with the current element)
 3. CCNXMLNotificationUserInfoDictCurrentElementAttributesKey     (NSDictionary object with the element attributes)

 NOTE: Be careful using this notification! It may slow down your parse performance.
 */
FOUNDATION_EXPORT NSString *const CCNXMLFoundStartElementNotification;

/**
 XML parser start element found notification

 * The notification object is nil
 * The userInfo dictionary has two entries:
 1. CCNXMLNotificationUserInfoDictParserKey                       (NSXMLParser object with the current parser)
 2. CCNXMLNotificationUserInfoDictCurrentElementKey               (NSString object with the current element)

 NOTE: Be careful using this notification! It may slow down your parse performance.
 */
FOUNDATION_EXPORT NSString *const CCNXMLFoundEndElementNotification;



// NSNotificationCenter userInfo dictionary keys
FOUNDATION_EXPORT NSString *const CCNXMLNotificationUserInfoDictParserKey;
FOUNDATION_EXPORT NSString *const CCNXMLNotificationUserInfoDictErrorKey;
FOUNDATION_EXPORT NSString *const CCNXMLNotificationUserInfoDictCurrentElementKey;
FOUNDATION_EXPORT NSString *const CCNXMLNotificationUserInfoDictCurrentElementAttributesKey;



#endif
