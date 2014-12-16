//
//  CNXMLReader.m
//
//  Created by Frank Gregor on 18.06.13.
//  Copyright (c) 2013 cocoa:naut. All rights reserved.
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


#import "CCNXMLReader.h"
#import "NSString+CCNXMLAdditions.h"


NSString *const CCNXMLParseErrorNotification                              = @"CCNXMLParseErrorNotification";
NSString *const CCNXMLValidationErrorNotification                         = @"CCNXMLValidationErrorNotification";
NSString *const CCNXMLFoundStartElementNotification                       = @"CCNXMLFoundStartElementNotification";
NSString *const CCNXMLFoundEndElementNotification                         = @"CCNXMLFoundEndElementNotification";

NSString *const CCNXMLNotificationUserInfoDictParserKey                   = @"CCNXMLNotificationUserInfoDictParserKey";
NSString *const CCNXMLNotificationUserInfoDictErrorKey                    = @"CCNXMLNotificationUserInfoDictErrorKey";
NSString *const CCNXMLNotificationUserInfoDictCurrentElementKey           = @"CCNXMLNotificationUserInfoDictCurrentElementKey";
NSString *const CCNXMLNotificationUserInfoDictCurrentElementAttributesKey = @"CCNXMLNotificationUserInfoDictCurrentElementAttributesKey";


@interface CCNXMLReader () {
    CCNXMLReaderParseSuccessHandler _successHandler;
    CCNXMLReaderParseFailureHandler _failureHandler;
}
@property (strong) NSXMLParser *XMLparser;
@property (strong) NSMutableString *foundCharacters;
@property (strong) NSMutableArray *elementStack;
@property (strong) NSMutableDictionary *documentNamespaces;
@property (strong) NSError *parseError;
@end

@implementation CCNXMLReader

#pragma mark - Initialization

- (id)init {
    self = [super init];
    if (self) {
        _successHandler         = nil;
        _failureHandler         = nil;

        self.parseError         = nil;
        self.XMLparser          = nil;
        self.elementStack       = [NSMutableArray array];
        self.foundCharacters    = [NSMutableString new];
        self.documentNamespaces = [NSMutableDictionary dictionary];
        self.rootElement        = nil;
    }
    return self;
}

- (instancetype)initWithContentsOfFile:(NSString *)xmlFilePath {
    return [self initWithFileURL:[NSURL fileURLWithPath:xmlFilePath]];
}

- (instancetype)initWithContentsOfString:(NSString *)string {
    self = [self init];
    if (self) {
        self.XMLparser = [[NSXMLParser alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    }
    return self;
}

- (instancetype)initWithFileURL:(NSURL *)theURL {
    self = [self init];
    if (self) {
        self.XMLparser = [[NSXMLParser alloc] initWithContentsOfURL:theURL];
    }
    return self;
}

- (void)parseUsingSuccessHandler:(CCNXMLReaderParseSuccessHandler)successHandler failure:(CCNXMLReaderParseFailureHandler)failureHandler {
    _successHandler = successHandler;
    _failureHandler = failureHandler;

    [self.XMLparser setDelegate:self];
    [self.XMLparser setShouldReportNamespacePrefixes:YES];
    [self.XMLparser setShouldProcessNamespaces:YES];
    [self.XMLparser setShouldResolveExternalEntities:NO];

    if (![self.XMLparser parse]) {
        if (_failureHandler) {
            _failureHandler(self.parseError);
        }
    }
}

#pragma mark - Accessors

- (void)setRootElement:(CCNXMLElement *)rootElement {
    if (![_rootElement isEqual:rootElement]) {
        _rootElement       = rootElement;
        _rootElement.root  = YES;
        _rootElement.level = 0;
    }
}

#pragma mark - NSXMLParser Delegate

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
    self.documentNamespaces[prefix] = namespaceURI;
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)currentElement namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributes {
    CCNXMLElement *element = [CCNXMLElement elementWithName:currentElement mappingPrefix:qualifiedName.prefix attributes:attributes];
    CCNXMLElement *parent  = [self.elementStack lastObject];
    self.foundCharacters   = [NSMutableString new];

    /// this is our root element
    if ([self.elementStack count] == 0) {
        self.rootElement       = element;
        self.rootElement.root  = YES;
        self.rootElement.level = 0;

        if (self.documentNamespaces) {
            __weak typeof(self) wSelf = self;
            [self.documentNamespaces enumerateKeysAndObjectsUsingBlock:^(NSString *prefix, NSString *namespaceURI, BOOL *stop) {
                [wSelf.rootElement addNamespaceWithPrefix:prefix namespaceURI:namespaceURI];
            }];
            self.documentNamespaces = [NSMutableDictionary dictionary];
        }
    }
    else {
        element.level = parent.level + 1;
        [parent addChild:element];
    }

    if (![[parent elementName] isEqualToString:currentElement])
        [self.elementStack addObject:element];

    NSDictionary *userInfo = @{
        CCNXMLNotificationUserInfoDictParserKey: parser,
        CCNXMLNotificationUserInfoDictCurrentElementKey: currentElement,
        CCNXMLNotificationUserInfoDictCurrentElementAttributesKey: attributes
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNXMLFoundStartElementNotification object:nil userInfo:userInfo];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (![string isEqualToString:CCNXMLEmptyString]) {
        [self.foundCharacters appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)currentElement namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)mappingPrefix {
    CCNXMLElement *lastElement = [self.elementStack lastObject];
    if ([[lastElement elementName] isEqualToString:currentElement]) {
        lastElement.value = self.foundCharacters;
        [self.elementStack removeObject:lastElement];
    }
    self.foundCharacters = nil;

    NSDictionary *userInfo = @{ CCNXMLNotificationUserInfoDictParserKey: parser, CCNXMLNotificationUserInfoDictCurrentElementKey: currentElement };
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNXMLFoundEndElementNotification object:nil userInfo:userInfo];

    // the case when we reach the documents end
    if ([self.elementStack count] == 0) {
        if (_successHandler) {
            _successHandler();
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSDictionary *userInfo = @{ CCNXMLNotificationUserInfoDictParserKey: parser, CCNXMLNotificationUserInfoDictErrorKey: parseError };
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNXMLParseErrorNotification object:nil userInfo:userInfo];

    self.parseError = parseError;
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
    NSDictionary *userInfo = @{ CCNXMLNotificationUserInfoDictParserKey: parser, CCNXMLNotificationUserInfoDictErrorKey: validError };
    [[NSNotificationCenter defaultCenter] postNotificationName:CCNXMLParseErrorNotification object:nil userInfo:userInfo];
    
    self.parseError = validError;
}

@end
