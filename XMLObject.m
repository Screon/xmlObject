//
//  XMLObject.m
//
//  Created by Petr Syrov on 15/11/13.
//  Copyright (c) 2013 Petr Syrov. All rights reserved.
//

#import "XMLObject.h"

#define ATTRIBUTES @"__attributes__"
#define CHARACTERS @"__characters__"
#define ELEMENTS @"__elements__"

@implementation NSObject (XMLObject)

- (id)stringByReplacingQuotes {
    if ([self isKindOfClass:[NSString class]]) {
        NSString *value = [NSString stringWithString:(NSString *)self];
        value = [value stringByReplacingOccurrencesOfString:@"\"" withString:@"&quot;"];
        value = [value stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
        value = [value stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
        value = [value stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
        value = [value stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        return value;
    }
    return self;
}

@end

@interface XMLObject ()

@property (strong) NSXMLParser *parser;
@property (strong, nonatomic) NSMutableArray *rootArray;
@property (strong, nonatomic) NSMutableArray *currentDictionary;
@property (strong, nonatomic) NSMutableArray *currentArray;

@end

@implementation XMLObject

- (id)init {
	self = [super init];
	if (self) {
	}
    return self;
}

- (id)initWithData:(NSData *)data {
	self = [self init];
	if (self) {
        self.parser = [[NSXMLParser alloc] initWithData:data];
        [self.parser setDelegate:self];
	}
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self init];
    if (self) {
        self.rootArray = [NSMutableArray arrayWithObject:dictionary];
    }
    return self;
}

- (id)initWithArray:(NSArray *)array {
    self = [self init];
    if (self) {
        self.rootArray = [NSMutableArray arrayWithArray:array];
    }
    return self;
}

- (NSMutableDictionary *)xmlElementDictionaryForKey:(NSString *)key atIndex:(NSInteger)index {
    for (NSInteger i = 0; i < self.rootArray.count; i++) {
        NSMutableDictionary *dictionary = [self.rootArray objectAtIndex:i];
        if ([dictionary objectForKey:key] && (index == NSIntegerMax)?YES:(i == index)) {
            return [dictionary objectForKey:key];
        }
    }
    return nil;
}

- (NSString *)description {
    return self.rootArray.description;
}

+ (id)xmlObjectWithData:(NSData *)data error:(NSError **)error {
    XMLObject *xmlObject = [[XMLObject alloc] initWithData:data];
    [xmlObject.parser parse];
    if (xmlObject.parser.parserError) {
        if (error != NULL) *error = xmlObject.parser.parserError;
        return nil;
    }
    return xmlObject;
}

+ (id)xmlObjectWithXMLObject:(XMLObject *)xmlObject {
    return [XMLObject xmlObjectWithArray:xmlObject.rootArray];
}

+ (id)xmlObjectWithXMLObjects:(NSArray *)xmlObjects value:(NSString *)value  attributes:(NSDictionary *)attributes forKey:(NSString *)key {
    NSMutableArray *xmlObjectsArray = [NSMutableArray arrayWithCapacity:0];
    for (XMLObject *xmlObject in xmlObjects) {
        [xmlObjectsArray addObjectsFromArray:xmlObject.rootArray];
    }
    NSMutableDictionary *xmlElementDictionary = [NSMutableDictionary dictionaryWithDictionary:@{CHARACTERS: value?:@"", ELEMENTS: xmlObjectsArray?:@[], ATTRIBUTES: attributes?:@{}}];
    return [XMLObject xmlObjectWithArray:[NSMutableArray arrayWithArray:@[[NSMutableDictionary dictionaryWithDictionary:@{key: xmlElementDictionary}]]]];
}

+ (id)xmlObjectWithValue:(NSString *)value  attributes:(NSDictionary *)attributes forKey:(NSString *)key {
    return [XMLObject xmlObjectWithXMLObjects:@[] value:value attributes:attributes forKey:key];
}

+ (id)xmlObjectWithAttributes:(NSDictionary *)attributes forKey:(NSString *)key {
    return [XMLObject xmlObjectWithXMLObjects:@[] value:@"" attributes:attributes forKey:key];
}

+ (id)xmlObjectForKey:(NSString *)key {
    return [XMLObject xmlObjectWithXMLObjects:@[] value:@"" attributes:@{} forKey:key];
}

+ (id)xmlObjectWithDictionary:(NSDictionary *)dictionary {
    return [[[self class] alloc] initWithDictionary:dictionary];
}

+ (id)xmlObjectWithArray:(NSArray *)array {
    return [[[self class] alloc] initWithArray:array];
}

- (NSArray *)allTags {
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithCapacity:0];
    for (NSDictionary *dictionary in self.rootArray) {
        [tags setObject:@"tag" forKey:dictionary.allKeys.firstObject];
    }
    return tags.allKeys;
}

- (NSString *)xml {
    return [NSString stringWithFormat:@"<?xml version=\"1.0\"?>%@", self.string];
}

- (NSString *)string {
    NSMutableString *string = [NSMutableString stringWithCapacity:0];
    for (NSDictionary *xmlElement in self.rootArray) {
        NSDictionary *xmlElementObject = [xmlElement objectForKey:xmlElement.allKeys.firstObject];
        [string appendFormat:@"<%@", xmlElement.allKeys.firstObject];
        NSDictionary *attributes = [xmlElementObject objectForKey:ATTRIBUTES];
        if (attributes) {
            for (NSString *attributeKey in [attributes allKeys]) {
                [string appendFormat:@" %@=\"%@\"", attributeKey, [[attributes valueForKey:attributeKey] stringByReplacingQuotes]];
            }
        }
        [string appendString:@">"];
        
        NSString *value =[xmlElementObject objectForKey:CHARACTERS];
        if (value) {
            [string appendString:[value stringByReplacingQuotes]];
        }
        
        NSArray *elements = [xmlElementObject objectForKey:ELEMENTS];
        if (elements) {
            [string appendString:[[XMLObject xmlObjectWithArray:elements] string]];
        }
        
        [string appendFormat:@"</%@>", xmlElement.allKeys.firstObject];
    }
    return string;
}

- (XMLObject *)objectForKey:(NSString *)key {
    return [self objectForKey:key atIndex:NSIntegerMax];
}

- (XMLObject *)objectForKeys:(NSArray *)keys {
    if (keys.count > 1) {
        NSMutableArray *mutableKeys = [NSMutableArray arrayWithArray:keys];
        [mutableKeys removeObjectAtIndex:0];
        XMLObject *xmlObject = [self objectForKey:keys.firstObject];
        return [xmlObject objectForKeys:mutableKeys];
    } else if (keys.count == 1) {
        return [self objectForKey:keys.firstObject];
    } else {
        return nil;
    }
}

- (XMLObject *)objectForKey:(NSString *)key atIndex:(NSInteger)index {
    NSMutableDictionary *xmlElementDictionary = [self xmlElementDictionaryForKey:key atIndex:index];
    if (xmlElementDictionary) {
        return [XMLObject xmlObjectWithArray:[xmlElementDictionary objectForKey:ELEMENTS]];
    }
    return nil;
}

- (XMLObject *)objectAtIndex:(NSInteger)index {
    return [self objectForKey:self.allTags.firstObject atIndex:index];
}

- (NSString *)valueForKey:(NSString *)key {
    return [self valueForKey:key atIndex:NSIntegerMax];
}

- (NSString *)valueForKeys:(NSArray *)keys {
    NSMutableArray *mutableKeys = [NSMutableArray arrayWithArray:keys];
    [mutableKeys removeLastObject];
    XMLObject *xmlObject = [self objectForKeys:mutableKeys];
    if (xmlObject) {
        return [xmlObject valueForKey:keys.lastObject];
    } else {
        return [self valueForKey:keys.lastObject];
    }
}

- (NSString *)valueForKey:(NSString *)key atIndex:(NSInteger)index {
    NSMutableDictionary *xmlElementDictionary = [self xmlElementDictionaryForKey:key atIndex:index];
    if (xmlElementDictionary) {
        return [xmlElementDictionary objectForKey:CHARACTERS];
    }
    return nil;
}

- (NSString *)valueAtIndex:(NSInteger)index {
    return [self valueForKey:self.allTags.firstObject atIndex:index];
}

- (NSDictionary *)attributesForKey:(NSString *)key {
    return [self attributesForKey:key atIndex:NSIntegerMax];
}

- (NSDictionary *)attributesForKeys:(NSArray *)keys {
    NSMutableArray *mutableKeys = [NSMutableArray arrayWithArray:keys];
    [mutableKeys removeLastObject];
    XMLObject *xmlObject = [self objectForKeys:mutableKeys];
    if (xmlObject) {
        return [xmlObject attributesForKey:keys.lastObject];
    } else {
        return [self attributesForKey:keys.lastObject];
    }
}

- (NSDictionary *)attributesForKey:(NSString *)key atIndex:(NSInteger)index {
    NSMutableDictionary *xmlElementDictionary = [self xmlElementDictionaryForKey:key atIndex:index];
    if (xmlElementDictionary) {
        return [xmlElementDictionary objectForKey:ATTRIBUTES];
    }
    return nil;
}

- (NSDictionary *)attributesAtIndex:(NSInteger)index {
    return [self attributesForKey:self.allTags.firstObject atIndex:index];
}

- (NSInteger)countForKey:(NSString *)key {
    NSInteger count = 0;
    for (NSMutableDictionary *dictionary in self.rootArray) {
        if ([dictionary objectForKey:key]) {
            count++;
        }
    }
    return count;
}

- (void)setAttributes:(NSDictionary *)attributes forKey:(NSString *)key atIndex:(NSInteger)index {
    NSMutableDictionary *xmlElementDictionary = [self xmlElementDictionaryForKey:key atIndex:index];
    if (xmlElementDictionary) {
        [xmlElementDictionary setObject:attributes forKey:ATTRIBUTES];
    }
}

- (void)setAttributes:(NSDictionary *)attributes forKey:(NSString *)key {
    [self setAttributes:attributes forKey:key atIndex:NSIntegerMax];
}

- (void)setValue:(NSString *)value forKey:(NSString *)key atIndex:(NSInteger)index {
    NSMutableDictionary *xmlElementDictionary = [self xmlElementDictionaryForKey:key atIndex:index];
    if (xmlElementDictionary) {
        [xmlElementDictionary setObject:value forKey:CHARACTERS];
    }
}

- (void)setValue:(NSString *)value forKey:(NSString *)key {
    [self setValue:value forKey:key atIndex:NSIntegerMax];
}

- (void)setObject:(XMLObject *)xmlObject forKey:(NSString *)key atIndex:(NSInteger)index {
    NSMutableDictionary *xmlElementDictionary = [self xmlElementDictionaryForKey:key atIndex:index];
    if (xmlElementDictionary) {
        [xmlElementDictionary setObject:xmlObject.rootArray forKey:ELEMENTS];
    }
}

- (void)setObject:(XMLObject *)xmlObject forKey:(NSString *)key {
    [self setObject:xmlObject forKey:key atIndex:NSIntegerMax];
}

- (void)addObject:(XMLObject *)xmlObject forKey:(NSString *)key atIndex:(NSInteger)index {
    NSMutableDictionary *xmlElementDictionary = [self xmlElementDictionaryForKey:key atIndex:index];
    if (xmlElementDictionary) {
        [xmlElementDictionary setObject:[self.rootArray arrayByAddingObjectsFromArray:xmlObject.rootArray] forKey:ELEMENTS];
    }
}

- (void)addObject:(XMLObject *)xmlObject forKey:(NSString *)key {
    [self addObject:xmlObject forKey:key atIndex:NSIntegerMax];
}

- (void)removeObjectForKey:(NSString *)key atIndex:(NSInteger)index {
    for (NSInteger i = 0; i < self.rootArray.count; i++) {
        NSMutableDictionary *dictionary = [self.rootArray objectAtIndex:i];
        if ([dictionary objectForKey:key] && (index == NSIntegerMax)?YES:(i == index)) {
            [self.rootArray removeObject:dictionary];
            break;
        }
    }
}

- (void)removeObjectForKey:(NSString *)key {
    [self removeObjectForKey:key atIndex:NSIntegerMax];
}

#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.rootArray = [NSMutableArray arrayWithCapacity:0];
    
    self.currentArray = [NSMutableArray arrayWithCapacity:0];
    [self.currentArray addObject:self.rootArray];
    
    self.currentDictionary = [NSMutableArray arrayWithCapacity:0];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
    NSMutableDictionary *element = [NSMutableDictionary dictionaryWithCapacity:0];
    [element setObject:attributeDict forKey:ATTRIBUTES];
    NSMutableArray *subElements = [NSMutableArray arrayWithCapacity:0];
    [element setObject:subElements forKey:ELEMENTS];
    
    [self.currentDictionary addObject:element];
    
    [self.currentArray.lastObject addObject:@{elementName: element}];
    
    [self.currentArray addObject:subElements];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    /*
     NSString *trim = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
     if (trim.length) {
     */
    NSMutableString *currentString = [self.currentDictionary.lastObject valueForKey:CHARACTERS];
    if (!currentString) {
        currentString = [NSMutableString stringWithString:@""];
    }
    
    [currentString appendString:string];
    //    [currentString appendString:trim];
    [self.currentDictionary.lastObject setObject:currentString forKey:CHARACTERS];
    /*
     }
     */
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    [self.currentDictionary removeLastObject];
    [self.currentArray removeLastObject];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
}

@end
