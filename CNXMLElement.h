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


#import <Foundation/Foundation.h>


extern NSString *CNStringEmpty;

@interface CNXMLElement : NSObject

/** @name  XML Element Creation */
#pragma mark - XML Element Creation

+ (instancetype)elementWithName:(NSString *)elementName mappingPrefix:(NSString *)mappingPrefix namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes;
- (instancetype)initWithName:(NSString *)elementName mappingPrefix:(NSString *)mappingPrefix namespaceURI:(NSString *)namespaceURI attributes:(NSDictionary *)attributes;


/** @name XML Element Properties */
#pragma mark - XML Element Properties

@property (strong, nonatomic, readonly) NSString *mappingPrefix;
@property (strong, nonatomic, readonly) NSString *namespaceURI;
@property (strong, nonatomic, readonly) NSString *elementName;
@property (strong, nonatomic, readonly) NSDictionary *attributes;
@property (assign, getter = isRoot) BOOL root;
@property (strong) NSString *value;


/** @name Handling XML Element Attributes */
#pragma mark - Handling XML Element Attributes

- (void)setValue:(id)attributeValue forAttribute:(NSString *)attributeName;
- (id)valueForAttribute:(NSString *)attributeName;
- (void)removeAttribute:(NSString *)attributeName;
- (NSString *)attributesStringRepresentation;


/** @name Content Representation */
#pragma mark - Content Representation

@property (strong, nonatomic, readonly) NSString *xmlStringRepresentation;


/** @name Handling Child Elements */
#pragma mark - Handling Child Elements

- (void)addChild:(CNXMLElement *)childElement;
- (void)removeChild:(CNXMLElement *)childElement;
- (void)removeChildWithName:(NSString *)elementName;
- (void)removeChildWithAttributes:(NSDictionary *)attibutes;
- (void)removeAllChilds;
- (void)enumerateChildsUsingBlock:(void(^) (CNXMLElement * child, BOOL * stop))block;
- (void)enumerateChildWithName:(NSString *)elementName usingBlock:(void(^) (CNXMLElement * child, NSUInteger idx, BOOL isLastChild, BOOL * stop))block;
- (CNXMLElement *)childWithName:(NSString *)elementName;

@end
