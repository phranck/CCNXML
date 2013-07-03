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


#import "CNXMLReader.h"


@interface CNXMLReader () {
	NSXMLParser *_XMLparser;
	NSMutableArray *_elementStack;
	NSMutableString *_foundCharacters;
	NSString *_elementName;
}
@end

@implementation CNXMLReader

- (id)init {
	self = [super init];
	if (self) {
		_XMLparser = nil;
		_elementStack = [NSMutableArray new];
		_foundCharacters = [NSMutableString stringWithString:CNStringEmpty];

		_rootElement = nil;
	}
	return self;
}

#pragma mark - XML Document Creation

+ (instancetype)documentWithContentsOfFile:(NSString *)xmlFilePath {
	return [[[self class] alloc] initWithContentsOfFile:xmlFilePath];
}

- (instancetype)initWithContentsOfFile:(NSString *)xmlFilePath {
	self = [self init];
	if (self) {
		NSURL *xmlURL = [NSURL fileURLWithPath:xmlFilePath];
		_XMLparser = [[NSXMLParser alloc] initWithContentsOfURL:xmlURL];
		[self configureAndStartParser];
	}
	return self;
}

+ (instancetype)documentWithContentsOfString:(NSString *)string {
	return [[[self class] alloc] initWithContentsOfString:string];
}

- (instancetype)initWithContentsOfString:(NSString *)string {
	self = [self init];
	if (self) {
		_XMLparser = [[NSXMLParser alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		[self configureAndStartParser];
	}
	return self;
}

+ (instancetype)documentWithRootElementName:(NSString *)elementName mappingPrefix:(NSString *)mappingPrefix namespaceURI:(NSString *)namespaceURI {
	return [[[self class] alloc] initWithRootElementName:elementName mappingPrefix:mappingPrefix namespaceURI:namespaceURI];
}

- (instancetype)initWithRootElementName:(NSString *)elementName mappingPrefix:(NSString *)mappingPrefix namespaceURI:(NSString *)namespaceURI {
	self = [self init];
	if (self) {
		_rootElement = [CNXMLElement elementWithName:elementName mappingPrefix:mappingPrefix namespaceURI:namespaceURI attributes:nil];
	}
	return self;
}

#pragma mark - Private Helper

- (void)configureAndStartParser {
	[_XMLparser setDelegate:self];
	[_XMLparser setShouldReportNamespacePrefixes:YES];
	[_XMLparser setShouldProcessNamespaces:YES];
	[_XMLparser parse];
}

#pragma mark - Accessors

- (void)setRootElement:(CNXMLElement *)rootElement {
	if (![_rootElement isEqual:rootElement]) {
		_rootElement = rootElement;
		_rootElement.root = YES;
	}
}

#pragma mark - XML Content Representation

- (NSString *)xmlStringRepresentation {
	NSString *documentString = nil;
	if (self.rootElement != nil) {
		documentString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
		documentString = [documentString stringByAppendingString:[self.rootElement xmlStringRepresentation]];
	}
	return documentString;
}

- (NSData *)xmlDataRepresentation {
	return [[self xmlStringRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - NSXMLParser Delegate

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
	_mappingPrefix = prefix;
	_namespaceURI = namespaceURI;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)currentElement namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributes {
	CNXMLElement *element = [CNXMLElement elementWithName:currentElement mappingPrefix:self.mappingPrefix namespaceURI:self.namespaceURI attributes:attributes];
	CNXMLElement *parent = [_elementStack lastObject];

	/// this is our root element
	if ([_elementStack count] == 0) {
		_elementName = currentElement;
		self.rootElement = element;
		self.rootElement.root = YES;
	}
	else {
		[parent addChild:element];
	}

	if (![[parent elementName] isEqualToString:currentElement])
		[_elementStack addObject:element];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)currentElement namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)mappingPrefix {
	CNXMLElement *lastElement = [_elementStack lastObject];
	if ([[lastElement elementName] isEqualToString:currentElement]) {
		lastElement.value = [_foundCharacters copy];
		[_elementStack removeObject:lastElement];
		_foundCharacters = [NSMutableString stringWithString:CNStringEmpty];
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (![string isEqualToString:CNStringEmpty]) {
		[_foundCharacters appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	//NSLog(@"parseErrorOccurred: %@", parseError);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
	//NSLog(@"validationErrorOccurred: %@", validError);
}

@end
