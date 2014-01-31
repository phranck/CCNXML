//
//  XMLElement.m
//
//  Created by Frank Gregor on 14.06.13.
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

#import "CNXMLElement.h"
#import "NSMutableString+CNXMLAdditions.h"


NSString *const CNXMLStringEmpty = @"";
static NSString *const CNXMLStartTagBeginFormatString = @"<%@%@%@";
static NSString *const CNXMLStartTagEndFormatString = @">";
static NSString *const CNXMLStartTagEndSelfClosingFormatString = @"/>";
static NSString *const CNXMLEndTagFormatString = @"</%@>";
static NSString *const CNXMLAttributePlaceholderFormatString = @" %@=\"%@\"";
static NSString *const CNXMLVersionAndEncodingHeaderString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";


@interface CNXMLElement () {
	NSString *_mappingPrefix;
	NSString *_elementName;
	NSString *_qualifiedName;
	NSMutableDictionary *_attributes;
	NSMutableArray *_children;
	NSMutableDictionary *_namespaces;
}
@property (strong, nonatomic) NSString *startTag;
@property (strong, nonatomic) NSString *endTag;
@end

@implementation CNXMLElement
#pragma mark - Inititialization

- (id)init {
	self = [super init];
	if (self) {
		_mappingPrefix = CNXMLStringEmpty;
		_attributes = [[NSMutableDictionary alloc] init];
		_qualifiedName = CNXMLStringEmpty;
		_namespaces = [[NSMutableDictionary alloc] init];

		_root = NO;
		_value = CNXMLStringEmpty;
		_startTag = CNXMLStringEmpty;
		_endTag = CNXMLStringEmpty;
		_children = [[NSMutableArray alloc] init];
        _level = 0;
	}
	return self;
}

#pragma mark - XML Element Creation

+ (instancetype)elementWithName:(NSString *)elementName mappingPrefix:(NSString *)mappingPrefix attributes:(NSDictionary *)attributes {
	return [[[self class] alloc] initWithName:elementName mappingPrefix:mappingPrefix attributes:attributes];
}

- (instancetype)initWithName:(NSString *)theName mappingPrefix:(NSString *)mappingPrefix attributes:(NSDictionary *)attributes {
	self = [self init];
	if (self) {
		_elementName = theName;
		_mappingPrefix = (mappingPrefix ? : CNXMLStringEmpty);
		_qualifiedName = ([_mappingPrefix isEqualToString:CNXMLStringEmpty] ? theName : [NSString stringWithFormat:@"%@:%@", _mappingPrefix, _elementName]);

		if (attributes)
			_attributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
		else
			_attributes = [[NSMutableDictionary alloc] init];
	}
	return self;
}

#pragma mark - Handling Namespaces

- (void)addNamespaceWithPrefix:(NSString *)thePrefix namespaceURI:(NSString *)theNamespaceURI {
	[_namespaces setObject:theNamespaceURI forKey:[NSString stringWithFormat:@"xmlns:%@", thePrefix]];
}

- (NSString *)prefixForNamespaceURI:(NSString *)theNamespaceURI {
	__block NSString *prefix = nil;
	[_namespaces enumerateKeysAndObjectsUsingBlock: ^(NSString *currentPrefix, NSString *currentNamespaceURI, BOOL *stop) {
	    if ([currentNamespaceURI isEqualToString:theNamespaceURI]) {
	        prefix = currentPrefix;
	        *stop = YES;
		}
	}];
	return prefix;
}

#pragma mark - XML Content Representation

- (NSString *)XMLString {
    return [self _XMLStringFormatted:YES];
}

- (NSString *)XMLStringMinified {
    return [self _XMLStringFormatted:NO];
}

- (NSString *)_XMLStringFormatted:(BOOL)isFormatted {
    NSMutableString *XMLString = [NSMutableString stringWithString:CNXMLStringEmpty];
    NSString *TAB = CNXMLStringEmpty, *CRLF = CNXMLStringEmpty;
    NSString *XMLStartTag = [self startTag];
    NSString *XMLEndTag = [self endTag];

    if (isFormatted) {
        TAB = [TAB stringByPaddingToLength:self.level withString:@"\t" startingAtIndex:0];
        CRLF = @"\n";
    }

    if (self.isRoot) {
        [XMLString appendString:CNXMLVersionAndEncodingHeaderString];
    }

    if ([self hasChildren]) {
        NSString *valueString = CNXMLStringEmpty;
        for (CNXMLElement *child in [self children]) {
		    valueString = [valueString stringByAppendingString:(isFormatted ? [child XMLString] : [child XMLStringMinified])];
        }

        [XMLString appendObjects:@[
                       CRLF, TAB, XMLStartTag,
                       TAB, valueString,
                       CRLF, TAB, XMLEndTag
                   ]];
	}
	else {
        if ([self isSelfClosing]) {
            [XMLString appendObjects:@[ CRLF, TAB, XMLStartTag ]];
        } else {
            [XMLString appendObjects:@[ CRLF, TAB, XMLStartTag, self.value, XMLEndTag ]];
        }
	}
    
	return XMLString;
}

#pragma mark - Handling XML Element Attributes

- (void)setValue:(id)theValue forAttribute:(NSString *)theAttribute {
	if (theAttribute != nil && ![theAttribute isEqualToString:CNXMLStringEmpty])
		[_attributes setObject:theValue forKey:theAttribute];
}

- (id)valueForAttribute:(NSString *)theAttribute {
	id attributeValue = nil;
	if (_attributes && [_attributes count] > 0 &&
	    ![theAttribute isEqualToString:CNXMLStringEmpty]) {
		attributeValue = [_attributes objectForKey:theAttribute];
	}
	return attributeValue;
}

- (void)removeAttribute:(NSString *)theAttribute {
	if (theAttribute != nil && ![theAttribute isEqualToString:CNXMLStringEmpty] &&
	    [_attributes objectForKey:theAttribute])
		[_attributes removeObjectForKey:theAttribute];
}

- (NSString *)attributesString {
	__block NSString *attributesString = CNXMLStringEmpty;
	if ([_attributes count] > 0) {
		[_attributes enumerateKeysAndObjectsUsingBlock: ^(id attributeName, id attributeValue, BOOL *stop) {
		    attributesString = [attributesString stringByAppendingFormat:CNXMLAttributePlaceholderFormatString, attributeName, attributeValue];
		}];
	}
	return attributesString;
}

- (BOOL)hasAttribute:(NSString *)theAttribute {
	__block BOOL hasAttribute = NO;
    for (NSString *currentAttribute in _attributes) {
	    if ([currentAttribute isEqualToString:theAttribute]) {
	        hasAttribute = YES;
	        break;
		}
    }
	return hasAttribute;
}

#pragma mark - Handling Child Elements

- (void)addChild:(CNXMLElement *)theChild {
	if (theChild != nil)
		[_children addObject:theChild];
}

- (void)removeChild:(CNXMLElement *)theChild {
	if ([_children count] > 0) {
		[_children removeObject:theChild];
	}
}

- (void)removeChildWithName:(NSString *)theChildName {
	__block CNXMLElement *childToRemove = nil;
	[_children enumerateObjectsUsingBlock: ^(CNXMLElement *currentChild, NSUInteger idx, BOOL *stop) {
	    if ([currentChild.elementName isEqualToString:theChildName]) {
	        childToRemove = currentChild;
	        *stop = YES;
		}
	}];
	if (childToRemove)
		[_children removeObject:childToRemove];
}

- (void)removeChildWithAttributes:(NSDictionary *)attibutes {
	__block CNXMLElement *childToRemove = nil;
	[_children enumerateObjectsUsingBlock: ^(CNXMLElement *child, NSUInteger idx, BOOL *stop) {
	    if ([child.attributes isEqualToDictionary:attibutes]) {
	        childToRemove = child;
	        *stop = YES;
		}
	}];
	if (childToRemove)
		[_children removeObject:childToRemove];
}

- (void)removeAllChildren {
	[_children removeAllObjects];
}

- (void)enumerateChildrenUsingBlock:(void (^)(CNXMLElement *child, NSUInteger idx, BOOL *stop))block {
	[_children enumerateObjectsUsingBlock: ^(CNXMLElement *currentChild, NSUInteger idx, BOOL *stop) {
	    block(currentChild, idx, stop);
	}];
}

- (void)enumerateChildWithName:(NSString *)elementName usingBlock:(void (^)(CNXMLElement *child, NSUInteger idx, BOOL isLastChild, BOOL *stop))block {
	CNXMLElement *enumElement = [self childWithName:elementName];
	NSInteger lastChildIndex = 0;
	if ([[enumElement children] count] > 0)
		lastChildIndex = [[enumElement children] count] - 1;

	[enumElement enumerateChildrenUsingBlock: ^(CNXMLElement *child, NSUInteger idx, BOOL *stop) {
	    block(child, idx, (lastChildIndex == idx), stop);
	}];
}

- (CNXMLElement *)childWithName:(NSString *)theChildName {
	__block CNXMLElement *requestedChild = nil;
	[self enumerateChildrenUsingBlock: ^(CNXMLElement *child, NSUInteger idx, BOOL *stop) {
	    if ([child.elementName isEqualToString:theChildName]) {
	        requestedChild = child;
	        *stop = YES;
		}
	}];
	return requestedChild;
}

#pragma mark - Public Custom Accessors

- (BOOL)hasChildren {
    return (_children && [_children count] > 0);
}

#pragma mark - Private Custom Accessors

- (NSString *)startTag {
	_startTag = [NSString stringWithFormat:CNXMLStartTagBeginFormatString, _qualifiedName, [self attributesString], ([self isSelfClosing] ? CNXMLStartTagEndSelfClosingFormatString : CNXMLStartTagEndFormatString)];
	return _startTag;
}

- (NSString *)endTag {
	if (![self isSelfClosing]) {
		_endTag = [NSString stringWithFormat:CNXMLEndTagFormatString, _qualifiedName];
	}
	return _endTag;
}

#pragma mark - Private Helper

- (BOOL)isSelfClosing {
	return (![self hasChildren] && [[self whitespaceAndNewlineTrimmedValue] isEqualToString:CNXMLStringEmpty]);
}

- (NSString *)whitespaceAndNewlineTrimmedValue {
	return [self.value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
