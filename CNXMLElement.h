//
//  CNXMLElement.h
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



extern NSString *CNXMLStringEmpty;

@interface CNXMLElement : NSObject

/** @name  XML Element Creation */
#pragma mark - XML Element Creation

+ (instancetype)elementWithName:(NSString *)elementName mappingPrefix:(NSString *)mappingPrefix attributes:(NSDictionary *)attributes;
- (instancetype)initWithName:(NSString *)theName mappingPrefix:(NSString *)mappingPrefix attributes:(NSDictionary *)attributes;

/** @name Handling Namespaces */
#pragma mark - Handling Namespaces

- (void)addNamespaceWithPrefix:(NSString *)thePrefix namespaceURI:(NSString *)theNamespaceURI;
//- (NSDictionary *)namespaces;
- (NSString *)prefixForNamespaceURI:(NSString *)theNamespaceURI;


/** @name XML Element Properties */
#pragma mark - XML Element Properties

@property (strong, readonly) NSString *mappingPrefix;
@property (strong, readonly) NSString *elementName;
@property (strong, nonatomic, readonly) NSDictionary *attributes;
@property (assign, getter = isRoot) BOOL root;
@property (strong) NSString *value;
@property (assign) NSUInteger level;


/** @name Handling XML Element Attributes */
#pragma mark - Handling XML Element Attributes

- (void)setValue:(id)theValue forAttribute:(NSString *)theAttribute;
- (id)valueForAttribute:(NSString *)theAttribute;
- (void)removeAttribute:(NSString *)theAttribute;
- (NSString *)attributesString;
- (BOOL)hasAttribute:(NSString *)theAttribute;


/** @name Content Representation */
#pragma mark - Content Representation

- (NSString *)XMLString;
- (NSString *)XMLStringMinified;


/** @name Handling Child Elements */
#pragma mark - Handling Child Elements

- (BOOL)hasChildren;
- (NSArray *)children;
- (void)addChild:(CNXMLElement *)theChild;
- (void)removeChild:(CNXMLElement *)theChild;
- (void)removeChildWithName:(NSString *)theChildName;
- (void)removeChildWithAttributes:(NSDictionary *)attibutes;
- (void)removeAllChildren;
- (void)enumerateChildrenUsingBlock:(void (^)(CNXMLElement *child, NSUInteger idx, BOOL *stop))block;
- (void)enumerateChildWithName:(NSString *)elementName usingBlock:(void (^)(CNXMLElement * child, NSUInteger idx, BOOL isLastChild, BOOL *stop))block;
- (CNXMLElement *)childWithName:(NSString *)theChildName;

@end
