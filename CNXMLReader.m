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


#import "NSString+CNXMLAdditions.h"
#import "CNXMLReader.h"


@interface CNXMLReader () {
	NSXMLParser *_XMLparser;
	NSMutableArray *_elementStack;
	NSMutableString *_foundCharacters;
}
@property (strong) NSString *currentElementName;
@end

@implementation CNXMLReader

- (id)init {
	self = [super init];
	if (self) {
		_XMLparser = nil;
		_elementStack = [[NSMutableArray alloc] init];
		_foundCharacters = [NSMutableString stringWithString:CNXMLStringEmpty];

        _currentElementName = nil;
		_rootElement = nil;
	}
	return self;
}

- (instancetype)initWithContentsOfFile:(NSString *)xmlFilePath {
	return [self initWithFileURL:[NSURL fileURLWithPath:xmlFilePath]];
}

- (instancetype)initWithContentsOfString:(NSString *)string {
	self = [self init];
	if (self) {
		_XMLparser = [[NSXMLParser alloc] initWithData:[string dataUsingEncoding:NSUTF8StringEncoding]];
		[self configureAndStartParser];
	}
	return self;
}

- (instancetype)initWithFileURL:(NSURL *)theURL {
	self = [self init];
	if (self) {
		_XMLparser = [[NSXMLParser alloc] initWithContentsOfURL:theURL];
		[self configureAndStartParser];
	}
	return self;
}

#pragma mark - XML Document Creation

+ (instancetype)documentWithContentsOfFile:(NSString *)xmlFilePath {
	return [[[self class] alloc] initWithContentsOfFile:xmlFilePath];
}

+ (instancetype)documentWithContentsOfString:(NSString *)string {
	return [[[self class] alloc] initWithContentsOfString:string];
}

+ (instancetype)documentWithFileURL:(NSURL *)theURL {
    return [[[self class] alloc] initWithFileURL:theURL];
}

//+ (instancetype)documentWithRootElementName:(NSString *)elementName namespaces:(NSDictionary *)documentNamespaces attributes:(NSDictionary *)attributes {
//	return [[[self class] alloc] initWithRootElementName:elementName namespaces:documentNamespaces attributes:attributes];
//}
//
//- (instancetype)initWithRootElementName:(NSString *)elementName namespaces:(NSDictionary *)documentNamespaces attributes:(NSDictionary *)attributes {
//	self = [self init];
//	if (self) {
//        _documentNamespaces = [NSMutableDictionary dictionaryWithDictionary:documentNamespaces];
//
//		_rootElement = [CNXMLElement elementWithName:elementName mappingPrefix:mappingPrefix attributes:nil];
//		_rootElement = [CNXMLElement elementWithName:elementName mappingPrefix:<#(NSString *)#> attributes:<#(NSDictionary *)#>];
//	}
//	return self;
//}

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

#pragma mark - NSXMLParser Delegate

- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI {
//    NSLog(@"didStartMappingPrefix: %@", prefix);
//    [_documentNamespaces setObject:namespaceURI forKey:prefix];
}

- (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix {
//    NSLog(@"didEndMappingPrefix: %@", prefix);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)currentElement namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributes {
//    NSLog(@"didStartElement: %@, qualifiedName: %@, attributes: %@", currentElement, qualifiedName, attributes);

    self.currentElementName = currentElement;

	CNXMLElement *element = [CNXMLElement elementWithName:self.currentElementName mappingPrefix:qualifiedName.prefix attributes:attributes];
	CNXMLElement *parent = [_elementStack lastObject];

	/// this is our root element
	if ([_elementStack count] == 0) {
		self.rootElement = element;
		self.rootElement.root = YES;
        self.rootElement.level = 0;
	}
	else {
        element.level = parent.level + 1;
		[parent addChild:element];
	}

	if (![[parent elementName] isEqualToString:currentElement])
		[_elementStack addObject:element];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)currentElement namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)mappingPrefix {
//    NSLog(@"didEndElement: %@, namespaceURI: %@, mappingPrefix: %@", currentElement, namespaceURI, mappingPrefix);
	CNXMLElement *lastElement = [_elementStack lastObject];
	if ([[lastElement elementName] isEqualToString:currentElement]) {
		lastElement.value = _foundCharacters;
		[_elementStack removeObject:lastElement];
		_foundCharacters = [NSMutableString stringWithString:CNXMLStringEmpty];
	}
    self.currentElementName = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (![string isEqualToString:CNXMLStringEmpty]) {
        if ([self.currentElementName isEqualToString:F4ElementNameParagraph]) {
            [_foundCharacters appendString:string];
        }
	}
    else {
		_foundCharacters = [NSMutableString stringWithString:CNXMLStringEmpty];
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	//NSLog(@"parseErrorOccurred: %@", parseError);
}

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validError {
	//NSLog(@"validationErrorOccurred: %@", validError);
}

@end
