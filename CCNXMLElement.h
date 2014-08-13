//
//  CCNXMLElement.h
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



FOUNDATION_EXPORT NSString *const CCNXMLEmptyString;

/**
 Constant that describes the way of indentation if the XML document will be formatted.
 */
typedef NS_ENUM(NSUInteger, CCNXMLContentIndentationType) {
    /** Indention by the tab character */
    CCNXMLContentIndentationTypeTab = 0,
    /** Indention by the space character (this is the default) */
    CCNXMLContentIndentationTypeSpace
};

@class CCNXMLElement;

typedef void (^CCNXMLEnumerateChildrenBlock)(CCNXMLElement *child, NSUInteger idx, BOOL *stop);
typedef void (^CCNXMLEnumerateChildWithNameBlock)(CCNXMLElement * child, NSUInteger idx, BOOL isLastChild, BOOL *stop);




@interface CCNXMLElement : NSObject

/** @name  XML Element Creation */
#pragma mark - XML Element Creation

/**
 Creates and returns an CCNXMLElement object with the given name, namespace prefix and a set of attributes.

 @param elementName   The element name.
 @param mappingPrefix A namespace prefix
 @param attributes    A dictionary of element attributes.

 @return An instance of CCNXMLElement.
 */
+ (instancetype)elementWithName:(NSString *)elementName mappingPrefix:(NSString *)mappingPrefix attributes:(NSDictionary *)attributes;

/**
 Creates and returns an CCNXMLElement object with the given name, namespace prefix and a set of attributes.

 @param elementName   The element name.
 @param mappingPrefix A namespace prefix
 @param attributes    A dictionary of element attributes.

 @return An instance of CCNXMLElement.
 */
- (instancetype)initWithName:(NSString *)theName mappingPrefix:(NSString *)mappingPrefix attributes:(NSDictionary *)attributes;


/** @name Managing Namespaces */
#pragma mark - Managing Namespaces

- (void)addNamespaceWithPrefix:(NSString *)thePrefix namespaceURI:(NSString *)theNamespaceURI;

/**
 Returns the prefix for the given namespace URI.

 @param theNamespaceURI A namespace URI string.

 @return The prefix for the given namespace URI.
 */
- (NSString *)prefixForNamespaceURI:(NSString *)theNamespaceURI;


/** @name XML Element Properties */
#pragma mark - XML Element Properties

@property (strong, readonly) NSString *mappingPrefix;

/** The name of this element. */
@property (strong, readonly) NSString *elementName;
/** A dictionary of the receivers attributes */
@property (strong, readonly) NSDictionary *attributes;
/** An array of ordered attribute names. If you want your attributes in a special order, use this array. */
@property (strong) NSArray *attributesSortedKeys;
/** Property that determines if the receiver is the root element (of an XML tree). */
@property (assign, getter = isRoot) BOOL root;                       // default: NO
@property (strong) NSString *value;
@property (assign) NSUInteger level;                                 // default: 0


/** @name Managing XML Element Attributes */
#pragma mark - Managing XML Element Attributes

- (void)setValue:(id)theValue forAttribute:(NSString *)theAttribute;
- (id)valueForAttribute:(NSString *)theAttribute;
- (void)removeAttribute:(NSString *)theAttribute;
- (NSString *)attributesString;
- (BOOL)hasAttribute:(NSString *)theAttribute;


/** @name Content Representation */
#pragma mark - Content Representation

@property (assign) CCNXMLContentIndentationType indentationType;
@property (assign) NSUInteger indentationWidth;                      // default 4 (only effective if indentationType is set to CNXMLContentIndentationTypeSpace)
@property (assign, nonatomic) BOOL useFormattedXML;                  // default: YES
- (NSString *)XMLString;


/** @name Managing Child Elements */
#pragma mark - Managing Child Elements

- (NSArray *)children;
- (void)setChildren:(NSArray *)children;
@property (assign, nonatomic, readonly) BOOL hasChildren;
- (void)addChild:(CCNXMLElement *)theChild;
- (void)insertChild:(CCNXMLElement *)child atIndex:(NSInteger)index;
- (void)removeChild:(CCNXMLElement *)theChild;
- (void)removeChildWithName:(NSString *)theChildName __attribute__((deprecated));
- (void)removeChildWithAttributes:(NSDictionary *)attibutes __attribute__((deprecated));
- (void)removeAllChildren;
- (CCNXMLElement *)childWithName:(NSString *)theChildName;
- (void)enumerateChildrenUsingBlock:(CCNXMLEnumerateChildrenBlock)block;
- (void)enumerateChildWithName:(NSString *)elementName usingBlock:(CCNXMLEnumerateChildWithNameBlock)block;
- (CCNXMLElement *)childWithName:(NSString *)theChildName;

@end
