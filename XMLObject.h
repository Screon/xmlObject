//
//  XMLObject.h
//
//  Created by Petr Syrov on 15/11/13.
//  Copyright (c) 2013 Petr Syrov. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 @description
 XMLObject class synchronously creates a structure, that can be used in dictionary-like and array-like styles.
 */
@interface XMLObject : NSObject <NSXMLParserDelegate>

@property (readonly, weak, nonatomic) NSArray *allTags;
@property (readonly, weak, nonatomic) NSString *xml;
@property (readonly, weak, nonatomic) NSString *string;

- (NSString *)description;

+ (id)xmlObjectWithData:(NSData *)data error:(NSError **)error;
+ (id)xmlObjectWithXMLObject:(XMLObject *)xmlObject;
+ (id)xmlObjectWithXMLObjects:(NSArray *)xmlObjects value:(NSString *)value  attributes:(NSDictionary *)attributes forKey:(NSString *)key;
+ (id)xmlObjectWithValue:(NSString *)value  attributes:(NSDictionary *)attributes forKey:(NSString *)key;
+ (id)xmlObjectWithAttributes:(NSDictionary *)attributes forKey:(NSString *)key;
+ (id)xmlObjectForKey:(NSString *)key;

- (XMLObject *)objectForKey:(NSString *)key;
- (XMLObject *)objectForKeys:(NSArray *)keys;
- (XMLObject *)objectForKey:(NSString *)key atIndex:(NSInteger)index;
- (XMLObject *)objectAtIndex:(NSInteger)index;

- (NSString *)valueForKey:(NSString *)key;
- (NSString *)valueForKeys:(NSArray *)keys;
- (NSString *)valueForKey:(NSString *)key atIndex:(NSInteger)index;
- (NSString *)valueAtIndex:(NSInteger)index;

- (NSDictionary *)attributesForKey:(NSString *)key;
- (NSDictionary *)attributesForKeys:(NSArray *)keys;
- (NSDictionary *)attributesForKey:(NSString *)key atIndex:(NSInteger)index;
- (NSDictionary *)attributesAtIndex:(NSInteger)index;

- (NSInteger)countForKey:(NSString *)key;

- (void)setAttributes:(NSDictionary *)attributes forKey:(NSString *)key atIndex:(NSInteger)index;
- (void)setAttributes:(NSDictionary *)attributes forKey:(NSString *)key;

- (void)setValue:(NSString *)value forKey:(NSString *)key atIndex:(NSInteger)index;
- (void)setValue:(NSString *)value forKey:(NSString *)key;

- (void)setObject:(XMLObject *)xmlObject forKey:(NSString *)key atIndex:(NSInteger)index;
- (void)setObject:(XMLObject *)xmlObject forKey:(NSString *)key;
- (void)addObject:(XMLObject *)xmlObject forKey:(NSString *)key atIndex:(NSInteger)index;
- (void)addObject:(XMLObject *)xmlObject forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key atIndex:(NSInteger)index;
- (void)removeObjectForKey:(NSString *)key;

@end
