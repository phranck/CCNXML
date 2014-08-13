//
//  CCNXMLElement.m
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

#import "CCNXMLElement.h"
#import "NSString+CCNXMLAdditions.h"
#import "NSMutableString+CCNXMLAdditions.h"


NSString *const CCNXMLEmptyString = @"";
static NSString *const CCNXMLStartTagBeginFormatString = @"<%@%@%@";
static NSString *const CCNXMLStartTagEndFormatString = @">";
static NSString *const CCNXMLStartTagEndSelfClosingFormatString = @"/>";
static NSString *const CCNXMLEndTagFormatString = @"</%@>";
static NSString *const CCNXMLMappingPrefixFormatString = @"%@:%@";
static NSString *const CCNXMLNamespacePrefixFormatString = @"xmlns:%@";
static NSString *const CCNXMLAttributePlaceholderFormatString = @" %@=\"%@\"";
static NSString *const CCNXMLVersionAndEncodingHeaderString = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>";



@interface CCNXMLElement () {
   NSMutableDictionary *_attributes;
   NSMutableArray *_children;
   NSMutableDictionary *_namespaces;
}
@property (strong, nonatomic) NSString *mappingPrefix;
@property (strong, nonatomic) NSString *elementName;
@property (strong, nonatomic) NSString *qualifiedName;
@property (strong, nonatomic) NSString *startTag;
@property (strong, nonatomic) NSString *endTag;
@end

@implementation CCNXMLElement
#pragma mark - Inititialization

- (id)init {
   self = [super init];
   if (self) {
      _attributes               = [NSMutableDictionary dictionary];
      _children                 = [NSMutableArray array];
      _namespaces               = nil;

      self.mappingPrefix        = CCNXMLEmptyString;
      self.qualifiedName        = CCNXMLEmptyString;
      self.startTag             = CCNXMLEmptyString;
      self.endTag               = CCNXMLEmptyString;

      self.useFormattedXML      = YES;
      self.root                 = NO;
      self.value                = CCNXMLEmptyString;
      self.level                = 0;
      self.attributesSortedKeys = nil;

      self.indentationType      = CCNXMLContentIndentationTypeTab;
      self.indentationWidth     = 4;
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
      self.elementName = theName;
      self.mappingPrefix = (mappingPrefix ?: CCNXMLEmptyString);
      self.qualifiedName = ([self.mappingPrefix isEqualToString:CNXMLEmptyString] ? theName : [NSString stringWithFormat:CCNXMLMappingPrefixFormatString, self.mappingPrefix, self.elementName]);

      if (attributes) {
         _attributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
      }
   }
   return self;
}

#pragma mark - Managing Namespaces

- (void)addNamespaceWithPrefix:(NSString *)thePrefix namespaceURI:(NSString *)theNamespaceURI {
   NSString *key = [NSString stringWithFormat:CCNXMLNamespacePrefixFormatString, thePrefix];
   if (!_namespaces) {
      _namespaces = [NSMutableDictionary dictionary];
   }
   _namespaces[key] = theNamespaceURI;
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
   return [self _XMLStringFormatted:self.useFormattedXML];
}

- (NSString *)_XMLStringFormatted:(BOOL)useFormattedXML {
   NSMutableString *XMLString = [NSMutableString stringWithString:CNXMLEmptyString];
   NSString *CRLF             = CCNXMLEmptyString;
   NSString *TAB              = CCNXMLEmptyString;
   NSString *XMLStartTag      = self.startTag;
   NSString *XMLEndTag        = self.endTag;

   if (useFormattedXML) {
      CRLF = @"\n";
      switch (self.indentationType) {
         case CCNXMLContentIndentationTypeTab: {
            TAB = [TAB stringByPaddingToLength:self.level withString:@"\t" startingAtIndex:0];
            break;
         }
         case CCNXMLContentIndentationTypeSpace: {
            TAB = [TAB stringByPaddingToLength:(self.level * self.indentationWidth) withString:@" " startingAtIndex:0];
            break;
         }
      }
   }

   if (self.isRoot) {
      [XMLString appendString:CCNXMLVersionAndEncodingHeaderString];
   }

   if ([self hasChildren]) {
      NSString *valueString = CCNXMLEmptyString;

      for (CCNXMLElement *child in self.children) {
         child.indentationType      = self.indentationType;
         child.indentationWidth     = self.indentationWidth;
         child.useFormattedXML      = self.useFormattedXML;

         valueString = [valueString stringByAppendingString:[child XMLString]];
      }

      [XMLString appendObjects:@[ CRLF, TAB, XMLStartTag, valueString, CRLF, TAB, XMLEndTag ]];
   }
   else {
      if ([self isSelfClosing]) {
         [XMLString appendObjects:@[ CRLF, TAB, XMLStartTag ]];
      }
      else {
         [XMLString appendObjects:@[ CRLF, TAB, XMLStartTag, self.value.xmlEscapedString, XMLEndTag ]];
      }
   }

   return XMLString;
}

#pragma mark - Managing XML Element Attributes

- (void)setValue:(id)theValue forAttribute:(NSString *)theAttribute {
   if (theAttribute != nil && ![theAttribute isEqualToString:CNXMLEmptyString]) {
      _attributes[theAttribute] = theValue;
   }
}

- (id)valueForAttribute:(NSString *)theAttribute {
   id attributeValue = nil;
   if (_attributes && [_attributes count] > 0 && ![theAttribute isEqualToString:CNXMLEmptyString]) {
      attributeValue = _attributes[theAttribute];
   }
   return attributeValue;
}

- (void)removeAttribute:(NSString *)theAttribute {
   if (theAttribute != nil && ![theAttribute isEqualToString:CNXMLEmptyString] && _attributes[theAttribute]) {
      [_attributes removeObjectForKey:theAttribute];
   }
}

- (NSString *)attributesString {
   __block NSString *attributesString = CCNXMLEmptyString;

   // handling namespaces
   if (self.isRoot && _namespaces != nil) {
      [_namespaces enumerateKeysAndObjectsUsingBlock:^(NSString *prefix, NSString *namespaceURI, BOOL *stop) {
         attributesString = [attributesString stringByAppendingFormat:CCNXMLAttributePlaceholderFormatString, prefix, namespaceURI];
      }];
   }

   // handling attributes
   if ([_attributes count] > 0) {
      if (self.attributesSortedKeys == nil) {
         [_attributes enumerateKeysAndObjectsUsingBlock: ^(id attributeName, id attributeValue, BOOL *stop) {
            attributesString = [attributesString stringByAppendingFormat:CCNXMLAttributePlaceholderFormatString, attributeName, attributeValue];
         }];
      }
      else {
         [self.attributesSortedKeys enumerateObjectsUsingBlock:^(NSString *attributeName, NSUInteger idx, BOOL *stop) {
            if (_attributes[attributeName] != nil) {
               attributesString = [attributesString stringByAppendingFormat:CCNXMLAttributePlaceholderFormatString, attributeName, _attributes[attributeName]];
            }
         }];
      }
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

#pragma mark - Managing Child Elements

- (void)addChild:(CCNXMLElement *)theChild {
   if (theChild != nil) {
      theChild.level = self.level + 1;
      [_children addObject:theChild];
   }
}

- (void)insertChild:(CCNXMLElement *)child atIndex:(NSInteger)index {
   if (child != nil) {
      child.level = self.level + 1;
      if (index > [_children count]) {
         index = [_children count];
      }
      [_children insertObject:child atIndex:index];
   }
}

- (void)removeChild:(CCNXMLElement *)theChild {
   if ([self.children count] > 0) {
      [_children removeObject:theChild];
   }
}

- (void)removeChildWithName:(NSString *)theChildName {
   __block CCNXMLElement *childToRemove = nil;
   [self.children enumerateObjectsUsingBlock: ^(CCNXMLElement *currentChild, NSUInteger idx, BOOL *stop) {
      if ([currentChild.elementName isEqualToString:theChildName]) {
         childToRemove = currentChild;
         *stop = YES;
      }
   }];

   if (childToRemove) {
      [_children removeObject:childToRemove];
   }
}

- (void)removeChildWithAttributes:(NSDictionary *)attibutes {
   __block CCNXMLElement *childToRemove = nil;
   [self.children enumerateObjectsUsingBlock: ^(CCNXMLElement *child, NSUInteger idx, BOOL *stop) {
      if ([child.attributes isEqualToDictionary:attibutes]) {
         childToRemove = child;
         *stop = YES;
      }
   }];

   if (childToRemove) {
      [_children removeObject:childToRemove];
   }
}

- (void)removeAllChildren {
   [_children removeAllObjects];
}

- (CCNXMLElement *)childWithName:(NSString *)theChildName {
   __block CCNXMLElement *searchedChild = nil;
   [self.children enumerateObjectsUsingBlock:^(CCNXMLElement *aChild, NSUInteger idx, BOOL *stop) {
      if ([aChild.elementName isEqualToString:theChildName]) {
         searchedChild = aChild;
         *stop = YES;
      }
   }];
   return searchedChild;
}

- (void)enumerateChildrenUsingBlock:(CCNXMLEnumerateChildrenBlock)block {
   [self.children enumerateObjectsUsingBlock: ^(CCNXMLElement *currentChild, NSUInteger idx, BOOL *stop) {
      block(currentChild, idx, stop);
   }];
}

- (void)enumerateChildWithName:(NSString *)elementName usingBlock:(CCNXMLEnumerateChildWithNameBlock)block {
   CCNXMLElement *enumElement = [self childWithName:elementName];
   NSInteger lastChildIndex = 0;

   if ([[enumElement children] count] > 0) {
      lastChildIndex = [[enumElement children] count] - 1;
   }

   [enumElement enumerateChildrenUsingBlock:^(CCNXMLElement *child, NSUInteger idx, BOOL *stop) {
      block(child, idx, (lastChildIndex == idx), stop);
   }];
}

#pragma mark - Public Custom Accessors

- (NSArray *)children {
   return _children;
}

- (void)setChildren:(NSArray *)children {
   [self removeAllChildren];
   _children = nil;
   _children = [NSMutableArray arrayWithArray:children];
}

- (BOOL)hasChildren {
   return (self.children && [self.children count] > 0);
}

#pragma mark - Private Custom Accessors

- (NSString *)startTag {
   _startTag = [NSString stringWithFormat:CCNXMLStartTagBeginFormatString, _qualifiedName, [self attributesString], ([self isSelfClosing] ? CCNXMLStartTagEndSelfClosingFormatString : CCNXMLStartTagEndFormatString)];
   return _startTag;
}

- (NSString *)endTag {
   if (![self isSelfClosing]) {
      _endTag = [NSString stringWithFormat:CCNXMLEndTagFormatString, _qualifiedName];
   }
   return _endTag;
}

#pragma mark - Private Helper

- (BOOL)isSelfClosing {
   return (![self hasChildren] && ([[self whitespaceAndNewlineTrimmedValue] isEqualToString:CCNXMLEmptyString] || self.value == nil));
}

- (NSString *)whitespaceAndNewlineTrimmedValue {
   return [self.value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
