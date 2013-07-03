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


NSString *CNStringEmpty = @"";

@interface CNXMLElement () {
	NSString *_mappingPrefix;
	NSString *_namespaceURI;
	NSString *_elementName;
	NSMutableDictionary *_attributes;

	NSString *_startTag;
	NSString *_endTag;
	NSMutableArray *_childs;
	NSString *_stringRepresentation;
}
@end

@implementation CNXMLElement
#pragma mark - Inititialization

- (id)init {
	self = [super init];
	if (self) {
		_attributes = [NSMutableDictionary new];
		_root = NO;
		_value = CNStringEmpty;
		_startTag = CNStringEmpty;
		_endTag = CNStringEmpty;
		_mappingPrefix = CNStringEmpty;
		_namespaceURI = CNStringEmpty;
		_childs = [NSMutableArray new];
		_stringRepresentation = CNStringEmpty;
	}
	return self;
}

#pragma mark - XML Element Creation

+ (instancetype)elementWithName:(NSString *)elementName mappingPrefix:(NSString *)mappingPrefix namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes {
	return [[[self class] alloc] initWithName:elementName mappingPrefix:mappingPrefix namespaceURI:namespaceURI attributes:attributes];
}

- (instancetype)initWithName:(NSString *)elementName mappingPrefix:(NSString *)mappingPrefix namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes {
	self = [self init];
	if (self) {
		_mappingPrefix = mappingPrefix;
		_namespaceURI = namespaceURI;
		_elementName = elementName;
		_attributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
	}
	return self;
}

#pragma mark - XML Content Representation

- (NSString *)xmlStringRepresentation {
	_stringRepresentation = [self startTag];

	if (![[self trimmedValue] isEqualToString:CNStringEmpty]) {
		_stringRepresentation = [_stringRepresentation stringByAppendingString:self.value];
	}
	else {
		[_childs enumerateObjectsUsingBlock: ^(CNXMLElement *child, NSUInteger idx, BOOL *stop) {
		    _stringRepresentation = [_stringRepresentation stringByAppendingString:[child xmlStringRepresentation]];
		}];
	}

	_stringRepresentation = [_stringRepresentation stringByAppendingString:[self endTag]];

	return _stringRepresentation;
}

#pragma mark - Handling XML Element Attributes

- (void)setValue:(id)attributeValue forAttribute:(NSString *)attributeName {
	if (attributeName != nil && ![attributeName isEqualToString:CNStringEmpty])
		[_attributes setObject:attributeValue forKey:attributeName];
}

- (id)valueForAttribute:(NSString *)attributeName {
	__block id attributeValue = nil;
	if (_attributes && [_attributes count] > 0 && ![attributeName isEqualToString:CNStringEmpty]) {
		attributeValue = [_attributes objectForKey:attributeName];
	}
	return attributeValue;
}

- (void)removeAttribute:(NSString *)attributeName {
	if (attributeName != nil && ![attributeName isEqualToString:CNStringEmpty] && [_attributes objectForKey:attributeName])
		[_attributes removeObjectForKey:attributeName];
}

- (NSString *)attributesStringRepresentation {
	__block NSString *attributesString = CNStringEmpty;
	if ([_attributes count] > 0) {
		[_attributes enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
		    attributesString = [attributesString stringByAppendingFormat:@" %@=\"%@\"", key, obj];
		}];
	}
	return attributesString;
}

#pragma mark - Handling Child Elements

- (void)addChild:(CNXMLElement *)childElement {
	if (childElement != nil)
		[_childs addObject:childElement];
}

- (void)removeChild:(CNXMLElement *)childElement {
	if ([_childs count] > 0) {
		[_childs removeObject:childElement];
	}
}

- (void)removeChildWithName:(NSString *)elementName {
	__block CNXMLElement *childToRemove = nil;
	[_childs enumerateObjectsUsingBlock: ^(CNXMLElement *currentChild, NSUInteger idx, BOOL *stop) {
	    if ([currentChild.elementName isEqualToString:elementName]) {
	        childToRemove = currentChild;
	        *stop = YES;
		}
	}];
	if (childToRemove)
		[_childs removeObject:childToRemove];
}

- (void)removeChildWithAttributes:(NSDictionary *)attibutes {
	__block CNXMLElement *childToRemove = nil;
	[_childs enumerateObjectsUsingBlock: ^(CNXMLElement *child, NSUInteger idx, BOOL *stop) {
	    if ([child.attributes isEqualToDictionary:attibutes]) {
	        childToRemove = child;
	        *stop = YES;
		}
	}];
	if (childToRemove)
		[_childs removeObject:childToRemove];
}

- (void)removeAllChilds {
	[_childs removeAllObjects];
}

- (void)enumerateChildsUsingBlock:(void (^)(CNXMLElement *child, BOOL *stop))block {
	[_childs enumerateObjectsUsingBlock: ^(CNXMLElement *currentChild, NSUInteger idx, BOOL *stop) {
	    block(currentChild, stop);
	}];
}

- (void)enumerateChildWithName:(NSString *)elementName usingBlock:(void (^)(CNXMLElement *child, NSUInteger idx, BOOL isLastChild, BOOL *stop))block {
	NSInteger lastChildIndex = 0;
	if ([_childs count] > 0) {
		lastChildIndex = [_childs count] - 1;
	}

	[_childs enumerateObjectsUsingBlock: ^(CNXMLElement *currentChild, NSUInteger idx, BOOL *stop) {
	    if ([currentChild.elementName isEqualToString:elementName]) {
	        [currentChild enumerateChildsUsingBlock: ^(CNXMLElement *child, BOOL *stop) {
	            block(child, idx, (lastChildIndex == idx), stop);
			}];
	        *stop = YES;
		}
	}];
}

- (CNXMLElement *)childWithName:(NSString *)elementName {
	__block CNXMLElement *requestedChild;
	[self enumerateChildsUsingBlock: ^(CNXMLElement *currentChild, BOOL *stop) {
	    if ([currentChild.elementName isEqualToString:elementName]) {
	        requestedChild = currentChild;
	        *stop = YES;
		}
	}];
	return requestedChild;
}

#pragma mark - Accessors

- (NSString *)mappingPrefix {
	return _mappingPrefix;
}

- (NSString *)namespaceURI {
	return _namespaceURI;
}

- (NSString *)elementName {
	return _elementName;
}

#pragma mark - Private Helper

- (BOOL)hasNameSpace {
	return (_mappingPrefix != nil && ![_mappingPrefix isEqualToString:CNStringEmpty]);
}

- (BOOL)isSelfClosing {
	return ([_childs count] == 0 && [[self trimmedValue] isEqualToString:CNStringEmpty]);
}

- (NSString *)startTag {
	if (self.isRoot) {
		if ([self hasNameSpace]) _startTag = [NSString stringWithFormat:@"<%@:%@ xmlns:%@=\"%@\"", _mappingPrefix, _elementName, _mappingPrefix, _namespaceURI];
		else _startTag = [NSString stringWithFormat:@"<%@", _elementName];
	}
	else {
		if ([self hasNameSpace]) _startTag = [NSString stringWithFormat:@"<%@:%@%@", _mappingPrefix, _elementName, [self attributesStringRepresentation]];
		else _startTag = [NSString stringWithFormat:@"<%@", _elementName];
	}

	if ([self isSelfClosing]) _startTag = [_startTag stringByAppendingString:@"/>"];
	else _startTag = [_startTag stringByAppendingString:@">"];

	return _startTag;
}

- (NSString *)endTag {
	if (![self isSelfClosing]) {
		if ([self hasNameSpace]) _endTag = [NSString stringWithFormat:@"</%@:%@>", _mappingPrefix, _elementName];
		else _endTag = [NSString stringWithFormat:@"</%@>", _elementName];
	}
	return _endTag;
}

- (NSString *)trimmedValue {
	return [self.value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
