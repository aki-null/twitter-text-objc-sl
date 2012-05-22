// CocoaRegex is copyrighted free software by Satoshi Nakagawa <psychs AT limechat DOT net>.
// You can redistribute it and/or modify it under the new BSD license.

#import <Foundation/Foundation.h>

typedef enum { 
    CocoaRegexCaseInsensitive                       = 1 << 1,
    CocoaRegexAllowCommentsAndWhitespace            = 1 << 2,
    CocoaRegexAnchorsMatchLines                     = 1 << 3,
    CocoaRegexDotMatchesLineSeparators              = 1 << 5,
    CocoaRegexUseUnicodeWordBoundaries              = 1 << 8,
} CocoaRegexOptions;

typedef enum {
    CocoaRegexMatchingAnchored                      = 1 << 1,
    CocoaRegexMatchingWithTransparentBounds         = 1 << 2,
    CocoaRegexMatchingWithoutAnchoringBounds        = 1 << 3,
} CocoaRegexMatchingOptions;

@interface CocoaRegex : NSObject <NSCopying>

+ (CocoaRegex*)regexWithPattern:(NSString*)pattern options:(CocoaRegexOptions)options;

- (id)initWithPattern:(NSString*)pattern options:(CocoaRegexOptions)options;

- (BOOL)matchesInString:(NSString*)string;
- (BOOL)matchesInString:(NSString*)string range:(NSRange)range;
- (BOOL)matchesInString:(NSString*)string range:(NSRange)range options:(CocoaRegexMatchingOptions)options;

- (NSRange)rangeOfFirstMatchInString:(NSString*)string;
- (NSRange)rangeOfFirstMatchInString:(NSString*)string range:(NSRange)range;
- (NSRange)rangeOfFirstMatchInString:(NSString*)string range:(NSRange)range options:(CocoaRegexMatchingOptions)options;

- (NSUInteger)numberOfMatchingRanges;
- (NSRange)matchingRangeAt:(NSUInteger)index;

- (void)reset;

@end
