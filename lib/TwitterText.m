//
//  TwitterText.m
//
//  Copyright 2012 Twitter, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//

#import "TwitterText.h"
#import "RegexKitLite.h"

//
// These regular expressions are ported from twitter-text-rb on Apr 24 2012.
//

#define TWUControlCharacters        @"\\u0009-\\u000D"
#define TWUSpace                    @"\\u0020"
#define TWUControl85                @"\\u0085"
#define TWUNoBreakSpace             @"\\u00A0"
#define TWUOghamBreakSpace          @"\\u1680"
#define TWUMongolianVowelSeparator  @"\\u180E"
#define TWUWhiteSpaces              @"\\u2000-\\u200A"
#define TWULineSeparator            @"\\u2028"
#define TWUParagraphSeparator       @"\\u2029"
#define TWUNarrowNoBreakSpace       @"\\u202F"
#define TWUMediumMathematicalSpace  @"\\u205F"
#define TWUIdeographicSpace         @"\\u3000"

#define TWUUnicodeSpaces \
    TWUControlCharacters \
    TWUSpace \
    TWUControl85 \
    TWUNoBreakSpace \
    TWUOghamBreakSpace \
    TWUMongolianVowelSeparator \
    TWUWhiteSpaces \
    TWULineSeparator \
    TWUParagraphSeparator \
    TWUNarrowNoBreakSpace \
    TWUMediumMathematicalSpace \
    TWUIdeographicSpace

#define TWUInvalidCharacters        @"\\uFFFE\\uFEFF\\uFFFF\\u202A-\\u202E"

#define TWULatinAccents \
    @"\\u00C0-\\u00D6\\u00D8-\\u00F6\\u00F8-\\u00FF\\u0100-\\u024F\\u0253-\\u0254\\u0256-\\u0257\\u0259\\u025b\\u0263\\u0268\\u026F\\u0272\\u0289\\u02BB\\u1E00-\\u1EFF"

//
// Hashtag
//

#define TWUCyrillicHashtagChars                     @"\\u0400-\\u04FF"
#define TWUCyrillicSupplementHashtagChars           @"\\u0500-\\u0527"
#define TWUCyrillicExtendedAHashtagChars            @"\\u2DE0-\\u2DFF"
#define TWUCyrillicExtendedBHashtagChars            @"\\uA640-\\uA69F"
#define TWUHebrewHashtagChars                       @"\\u0591-\\u05BF\\u05C1-\\u05C2\\u05C4-\\u05C5\\u05C7\\u05D0-\\u05EA\\u05F0-\\u05F4"
#define TWUHebrewPresentationFormsHashtagChars      @"\\uFB12-\\uFB28\\uFB2A-\\uFB36\\uFB38-\\uFB3C\\uFB3E\\uFB40-\\uFB41\\uFB43-\\uFB44\\uFB46-\\uFB4F"
#define TWUArabicHashtagChars                       @"\\u0610-\\u061A\\u0620-\\u065F\\u066E-\\u06D3\\u06D5-\\u06DC\\u06DE-\\u06E8\\u06EA-\\u06EF\\u06FA-\\u06FC\\u06FF"
#define TWUArabicSupplementHashtagChars             @"\\u0750-\\u077F"
#define TWUArabicExtendedAHashtagChars              @"\\u08A0\\u08A2-\\u08AC\\u08E4-\\u08FE"
#define TWUArabicPresentationFormsAHashtagChars     @"\\uFB50-\\uFBB1\\uFBD3-\\uFD3D\\uFD50-\\uFD8F\\uFD92-\\uFDC7\\uFDF0-\\uFDFB"
#define TWUArabicPresentationFormsBHashtagChars     @"\\uFE70-\\uFE74\\uFE76-\\uFEFC"
#define TWUZeroWidthNonJoiner                       @"\\u200C"
#define TWUThaiHashtagChars                         @"\\u0E01-\\u0E3A"
#define TWUHangulHashtagChars                       @"\\u0E40-\\u0E4E"
#define TWUHangulJamoHashtagChars                   @"\\u1100-\\u11FF"
#define TWUHangulCompatibilityJamoHashtagChars      @"\\u3130-\\u3185"
#define TWUHangulJamoExtendedAHashtagChars          @"\\uA960-\\uA97F"
#define TWUHangulSyllablesHashtagChars              @"\\uAC00-\\uD7AF"
#define TWUHangulJamoExtendedBHashtagChars          @"\\uD7B0-\\uD7FF"
#define TWUHalfWidthHangulHashtagChars              @"\\uFFA1-\\uFFDC"

#define TWUNonLatinHashtagChars \
    TWUCyrillicHashtagChars \
    TWUCyrillicSupplementHashtagChars \
    TWUCyrillicExtendedAHashtagChars \
    TWUCyrillicExtendedBHashtagChars \
    TWUHebrewHashtagChars \
    TWUHebrewPresentationFormsHashtagChars \
    TWUArabicHashtagChars \
    TWUArabicSupplementHashtagChars \
    TWUArabicExtendedAHashtagChars \
    TWUArabicPresentationFormsAHashtagChars \
    TWUArabicPresentationFormsBHashtagChars \
    TWUZeroWidthNonJoiner \
    TWUThaiHashtagChars \
    TWUHangulHashtagChars \
    TWUHangulJamoHashtagChars \
    TWUHangulCompatibilityJamoHashtagChars \
    TWUHangulJamoExtendedAHashtagChars \
    TWUHangulSyllablesHashtagChars \
    TWUHangulJamoExtendedBHashtagChars \
    TWUHalfWidthHangulHashtagChars

#define TWUKatakanaHashtagChars                 @"\\u30A1-\\u30FA\\u30FC-\\u30FE"
#define TWUKatakanaHalfWidthHashtagChars        @"\\uFF66-\\uFF9F"
#define TWULatinFullWidthHashtagChars           @"\\uFF10-\\uFF19\\uFF21-\\uFF3A\\uFF41-\\uFF5A"
#define TWUHiraganaHashtagChars                 @"\\u3041-\\u3096\\u3099-\\u309E"
#define TWUCJKExtensionAHashtagChars            @"\\u3400-\\u4DBF"
#define TWUCJKUnifiedHashtagChars               @"\\u4E00-\\u9FFF"
#define TWUCJKExtensionBHashtagChars            @"\\U00020000-\\U0002A6DF"
#define TWUCJKExtensionCHashtagChars            @"\\U0002A700-\\U0002B73F"
#define TWUCJKExtensionDHashtagChars            @"\\U0002B740-\\U0002B81F"
#define TWUCJKSupplementHashtagChars            @"\\U0002F800-\\U0002FA1F\\u3003\\u3005\\u303B"

#define TWUCJKHashtagCharacters \
    TWUKatakanaHashtagChars \
    TWUKatakanaHalfWidthHashtagChars \
    TWULatinFullWidthHashtagChars \
    TWUHiraganaHashtagChars \
    TWUCJKExtensionAHashtagChars \
    TWUCJKUnifiedHashtagChars \
    TWUCJKExtensionBHashtagChars \
    TWUCJKExtensionCHashtagChars \
    TWUCJKExtensionDHashtagChars \
    TWUCJKSupplementHashtagChars

#define TWUPunctuationChars                             @"\\-_!\"#$%&'()*+,./:;<=>?@\\[\\]^`{|}~"
#define TWUPunctuationCharsWithoutHyphen                @"_!\"#$%&'()*+,./:;<=>?@\\[\\]^`{|}~"
#define TWUPunctuationCharsWithoutHyphenAndUnderscore   @"!\"#$%&'()*+,./:;<=>?@\\[\\]^`{|}~"
#define TWUCtrlChars                                    @"\\x00-\\x1F\\x7F"

#define TWHashtagAlpha \
@"[a-z_" \
    TWULatinAccents \
    TWUNonLatinHashtagChars \
    TWUCJKHashtagCharacters \
@"]"

#define TWUHashtagAlphanumeric \
@"[a-z0-9_" \
    TWULatinAccents \
    TWUNonLatinHashtagChars \
    TWUCJKHashtagCharacters \
@"]"

#define TWUHashtagBoundary \
@"\\A|\\z|[^&a-z0-9_" \
    TWULatinAccents \
    TWUNonLatinHashtagChars \
    TWUCJKHashtagCharacters \
@"]"

#define TWUValidHashtag \
    @"(?:" TWUHashtagBoundary @")([#＃]" TWUHashtagAlphanumeric @"*" TWHashtagAlpha TWUHashtagAlphanumeric @"*)"

#define TWUEndHashTagMatch      @"\\A(?:[#＃]|://)"

//
// Mention and list name
//

#define TWUValidMentionPrecedingChars   @"(?:[^a-zA-Z0-9_!#$%&*@＠]|^|RT:?)"
#define TWUAtSigns                      @"[@＠]"
#define TWUValidUsername                @"\\A" TWUAtSigns @"[a-zA-Z0-9_]{1,20}\\z"
#define TWUValidList                    @"\\A" TWUAtSigns @"[a-zA-Z0-9_]{1,20}/[a-zA-Z][a-zA-Z0-9_\\-]{0,24}\\z"

#define TWUValidMentionOrList \
    @"(" TWUValidMentionPrecedingChars @")" \
    @"(" TWUAtSigns @")" \
    @"([a-zA-Z0-9_]{1,20})" \
    @"(/[a-zA-Z][a-zA-Z0-9_\\-]{0,24})?"

#define TWUValidReply                   @"\\A(?:[" TWUUnicodeSpaces @"])*" TWUAtSigns @"([a-zA-Z0-9_]{1,20})"
#define TWUEndMentionMatch              @"\\A(?:" TWUAtSigns @"|[" TWULatinAccents @"]|://)"

//
// URL
//

#define TWUValidURLPrecedingChars       @"(?:[^a-zA-Z0-9@＠$#＃" TWUInvalidCharacters @"]|^)"

#define TWUDomainValidStartEndChars \
@"[^" \
    TWUPunctuationChars \
    TWUCtrlChars \
    TWUInvalidCharacters \
    TWUUnicodeSpaces \
@"]"

#define TWUSubdomainValidMiddleChars \
@"[^" \
    TWUPunctuationCharsWithoutHyphenAndUnderscore \
    TWUCtrlChars \
    TWUInvalidCharacters \
    TWUUnicodeSpaces \
@"]"

#define TWUDomainValidMiddleChars \
@"[^" \
    TWUPunctuationCharsWithoutHyphen \
    TWUCtrlChars \
    TWUInvalidCharacters \
    TWUUnicodeSpaces \
@"]"

#define TWUValidSubdomain \
@"(?:" \
    @"(?:" TWUDomainValidStartEndChars TWUSubdomainValidMiddleChars @"*)?" TWUDomainValidStartEndChars @"\\." \
@")"

#define TWUValidDomainName \
@"(?:" \
    @"(?:" TWUDomainValidStartEndChars TWUDomainValidMiddleChars @"*)?" TWUDomainValidStartEndChars @"\\." \
@")"

#define TWUValidGTLD    @"(?:(?:aero|asia|biz|cat|com|coop|edu|gov|info|int|jobs|mil|mobi|museum|name|net|org|pro|tel|travel|xxx)(?=[^0-9a-z]|$))"
#define TWUValidCCTLD \
@"(?:" \
    @"(?:" \
        @"ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|" \
        @"bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|" \
        @"cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|eu|fi|fj|fk|fm|" \
        @"fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|" \
        @"ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|" \
        @"ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|" \
        @"mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|" \
        @"pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|" \
        @"si|sj|sk|sl|sm|sn|so|sr|ss|st|su|sv|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|" \
        @"tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|za|zm|" \
        @"zw" \
    @")" \
    @"(?=[^0-9a-z]|$)" \
@")"

#define TWUValidPunycode                @"(?:xn--[0-9a-z]+)"

#define TWUValidDomain \
@"(?:" \
    TWUValidSubdomain @"*" TWUValidDomainName \
    @"(?:" TWUValidGTLD @"|" TWUValidCCTLD @"|" TWUValidPunycode @")" \
@")"

#define TWUValidASCIIDomain \
    @"(?:[a-zA-Z0-9\\-_" TWULatinAccents @"]+\\.)+" \
    @"(?:" TWUValidGTLD @"|" TWUValidCCTLD @"|" TWUValidPunycode @")" \

#define TWUValidTCOURL                  @"https?://t\\.co/[a-zA-Z0-9]+"
#define TWUInvalidShortDomain           @"\\A" TWUValidDomainName TWUValidCCTLD @"\\z"

#define TWUValidPortNumber              @"[0-9]+"
#define TWUValidGeneralURLPathChars     @"[a-zA-Z0-9!\\*';:=+,.$/%#\\[\\]\\-_~&|" TWULatinAccents @"]"

#define TWUValidURLBalancedParens       @"\\(" TWUValidGeneralURLPathChars @"+\\)"
#define TWUValidURLPathEndingChars      @"[a-zA-Z0-9=_#/+\\-" TWULatinAccents @"]|(?:" TWUValidURLBalancedParens @")"

#define TWUValidURLPath \
@"(?:" \
    @"(?:" \
        TWUValidGeneralURLPathChars @"*" \
        @"(?:" TWUValidURLBalancedParens TWUValidGeneralURLPathChars @"*)*" TWUValidURLPathEndingChars \
    @")" \
    @"|" \
    @"(?:" TWUValidGeneralURLPathChars @"+/)" \
@")"

#define TWUValidURLQueryChars           @"[a-zA-Z0-9!?*'\\(\\);:&=+$/%#\\[\\]\\-_\\.,~|]"
#define TWUValidURLQueryEndingChars     @"[a-zA-Z0-9_&=#/]"

#define TWUValidURL \
@"(" \
    @"(" TWUValidURLPrecedingChars @")" \
    @"(" \
        @"(https?://)?" \
        @"(" TWUValidDomain @")" \
        @"(?::(" TWUValidPortNumber @"))?" \
        @"(/" TWUValidURLPath @"*)?" \
        @"(\\?" TWUValidURLQueryChars @"*" TWUValidURLQueryEndingChars @")?" \
    @")" \
@")"

static const int MaxTweetLength = 140;
static const int HTTPShortURLLength = 14;
static const int HTTPSShortURLLength = 15;

static NSCharacterSet *invalidURLWithoutProtocolPrecedingCharSet;

@interface TwitterText ()
+ (NSArray*)hashtagsInText:(NSString*)text withURLEntities:(NSArray*)urlEntities;
@end

@implementation TwitterText

+ (NSArray*)entitiesInText:(NSString*)text
{
    if (!text.length) {
        return [NSArray array];
    }

    NSMutableArray *results = [NSMutableArray array];
    
    NSArray *urls = [self URLsInText:text];
    NSArray *hashtags = [self hashtagsInText:text withURLEntities:urls];
    [results addObjectsFromArray:urls];
    [results addObjectsFromArray:hashtags];
    
    NSArray *mentionsAndLists = [self mentionsOrListsInText:text];
    NSMutableArray *addingItems = [NSMutableArray array];
    
    for (TwitterTextEntity *entity in mentionsAndLists) {
        NSRange entityRange = entity.range;
        BOOL found = NO;
        for (TwitterTextEntity *existingEntity in results) {
            if (NSIntersectionRange(existingEntity.range, entityRange).length > 0) {
                found = YES;
                break;
            }
        }
        if (!found) {
            [addingItems addObject:entity];
        }
    }
    
    [results addObjectsFromArray:addingItems];
    [results sortUsingSelector:@selector(compare:)];
    
    return results;
}

+ (NSArray*)URLsInText:(NSString*)text
{
    if (!text.length) {
        return [NSArray array];
    }
    
    if (!invalidURLWithoutProtocolPrecedingCharSet) {
        invalidURLWithoutProtocolPrecedingCharSet = [NSCharacterSet characterSetWithCharactersInString:@"-_./"];
#if !__has_feature(objc_arc)
        [invalidURLWithoutProtocolPrecedingCharSet retain];
#endif
    }

    NSMutableArray *results = [NSMutableArray array];
    NSInteger len = text.length;
    NSInteger position = 0;
    NSRange allRange = NSMakeRange(0, 0);

    while (1) {
        position = NSMaxRange(allRange);
        
        NSRange searchRange = NSMakeRange(position, len - position);
        allRange = [text rangeOfRegex:TWUValidURL options:RKLCaseless inRange:searchRange capture:0L error:NULL];
        
        if (allRange.location == NSNotFound) {
            break;
        }
        
        NSRange precedingRange = [text rangeOfRegex:TWUValidURL options:RKLCaseless inRange:searchRange capture:2L error:NULL];
        NSRange urlRange = [text rangeOfRegex:TWUValidURL options:RKLCaseless inRange:searchRange capture:3L error:NULL];
        NSRange protocolRange = [text rangeOfRegex:TWUValidURL options:RKLCaseless inRange:searchRange capture:4L error:NULL];
        NSRange domainRange = [text rangeOfRegex:TWUValidURL options:RKLCaseless inRange:searchRange capture:5L error:NULL];
        NSRange pathRange = [text rangeOfRegex:TWUValidURL options:RKLCaseless inRange:searchRange capture:7L error:NULL];
        
        // If protocol is missing and domain contains non-ASCII characters,
        // extract ASCII-only domains.
        if (protocolRange.location == NSNotFound) {
            if (precedingRange.location != NSNotFound && precedingRange.length > 0) {
                NSString *preceding = [text substringWithRange:precedingRange];
                NSRange suffixRange = [preceding rangeOfCharacterFromSet:invalidURLWithoutProtocolPrecedingCharSet options:NSBackwardsSearch | NSAnchoredSearch];
                if (suffixRange.location != NSNotFound) {
                    continue;
                }
            }
            
            NSInteger domainStart = domainRange.location;
            NSInteger domainEnd = NSMaxRange(domainRange);
            TwitterTextEntity *lastEntity = nil;
            BOOL lastInvalidShortResult = NO;
            
            while (domainStart < domainEnd) {
                NSRange asciiResult = [text rangeOfRegex:TWUValidASCIIDomain
                                                 options:RKLCaseless
                                                 inRange:NSMakeRange(domainStart, domainEnd - domainStart)
                                                 capture:0
                                                   error:NULL];
                if (asciiResult.location == NSNotFound) {
                    break;
                }
                
                urlRange = asciiResult;
                lastEntity = [TwitterTextEntity entityWithType:TwitterTextEntityURL range:urlRange];

                NSRange invalidShortResult = [text rangeOfRegex:TWUInvalidShortDomain
                                                        options:RKLCaseless
                                                        inRange:urlRange
                                                        capture:0
                                                          error:NULL];
                lastInvalidShortResult = (invalidShortResult.location != NSNotFound);
                if (!lastInvalidShortResult) {
                    [results addObject:lastEntity];
                }
                
                domainStart = NSMaxRange(urlRange);
            }
            
            if (!lastEntity) {
                continue;
            }
            
            if (pathRange.location != NSNotFound && NSMaxRange(lastEntity.range) == pathRange.location) {
                if (lastInvalidShortResult) {
                    [results addObject:lastEntity];
                }
                NSRange entityRange = lastEntity.range;
                entityRange.length += pathRange.length;
                lastEntity.range = entityRange;
            }
            
        } else {
            // In the case of t.co URLs, don't allow additional path characters
            NSRange tcoRange = [text rangeOfRegex:TWUValidTCOURL
                                          options:RKLCaseless
                                          inRange:urlRange
                                          capture:0
                                            error:NULL];
            if (tcoRange.location != NSNotFound) {
                urlRange.length = tcoRange.length;
            }
            
            TwitterTextEntity *entity = [TwitterTextEntity entityWithType:TwitterTextEntityURL range:urlRange];
            [results addObject:entity];
        }
    }
    
    return results;
}

+ (NSArray*)hashtagsInText:(NSString*)text checkingURLOverlap:(BOOL)checkingURLOverlap
{
    if (!text.length) {
        return [NSArray array];
    }

    NSArray *urls = nil;
    if (checkingURLOverlap) {
        urls = [self URLsInText:text];
    }
    return [self hashtagsInText:text withURLEntities:urls];
}

+ (NSArray*)hashtagsInText:(NSString*)text withURLEntities:(NSArray*)urlEntities
{
    if (!text.length) {
        return [NSArray array];
    }
    
    NSMutableArray *results = [NSMutableArray array];
    NSInteger len = text.length;
    NSInteger position = 0;
    
    while (1) {
        NSRange searchRange = NSMakeRange(position, len - position);
        NSRange allRange = [text rangeOfRegex:TWUValidHashtag options:RKLCaseless inRange:searchRange capture:0L error:NULL];
        
        if (allRange.location == NSNotFound) {
            break;
        }
        
        NSRange hashtagRange = [text rangeOfRegex:TWUValidHashtag options:RKLCaseless inRange:searchRange capture:1L error:NULL];
        
        BOOL matchOk = YES;
        
        // Check URL overlap
        for (TwitterTextEntity *urlEntity in urlEntities) {
            if (NSIntersectionRange(urlEntity.range, hashtagRange).length > 0) {
                matchOk = NO;
                break;
            }
        }

        if (matchOk) {
            NSInteger afterStart = NSMaxRange(hashtagRange);
            if (afterStart < len) {
                NSRange endMatchRange = [text rangeOfRegex:TWUEndHashTagMatch
                                                   options:RKLCaseless
                                                   inRange:NSMakeRange(afterStart, len - afterStart)
                                                   capture:0
                                                     error:NULL];
                if (endMatchRange.location != NSNotFound) {
                    matchOk = NO;
                }
            }
            
            if (matchOk) {
                TwitterTextEntity *entity = [TwitterTextEntity entityWithType:TwitterTextEntityHashtag range:hashtagRange];
                [results addObject:entity];
            }
        }
        
        position = NSMaxRange(allRange);
    }
    
    return results;
}

+ (NSArray*)mentionedScreenNamesInText:(NSString*)text
{
    if (!text.length) {
        return [NSArray array];
    }

    NSArray *mentionsOrLists = [self mentionsOrListsInText:text];
    NSMutableArray *results = [NSMutableArray array];
    
    for (TwitterTextEntity *entity in mentionsOrLists) {
        if (entity.type == TwitterTextEntityScreenName) {
            [results addObject:entity];
        }
    }
    
    return results;
}

+ (NSArray*)mentionsOrListsInText:(NSString*)text
{
    if (!text.length) {
        return [NSArray array];
    }
    
    NSMutableArray *results = [NSMutableArray array];
    NSInteger len = text.length;
    NSInteger position = 0;

    while (1) {
        NSRange searchRange = NSMakeRange(position, len - position);
        NSRange allRange = [text rangeOfRegex:TWUValidMentionOrList options:RKLCaseless inRange:searchRange capture:0L error:NULL];
        
        if (allRange.location == NSNotFound) {
            break;
        }
        
        NSRange atSignRange = [text rangeOfRegex:TWUValidMentionOrList options:RKLCaseless inRange:searchRange capture:2L error:NULL];
        NSRange screenNameRange = [text rangeOfRegex:TWUValidMentionOrList options:RKLCaseless inRange:searchRange capture:3L error:NULL];
        NSRange listNameRange = [text rangeOfRegex:TWUValidMentionOrList options:RKLCaseless inRange:searchRange capture:4L error:NULL];
        
        NSInteger end = NSMaxRange(allRange);
        
        NSRange endMentionRange = [text rangeOfRegex:TWUEndMentionMatch
                                             options:RKLCaseless
                                             inRange:NSMakeRange(end, len - end)
                                             capture:0
                                               error:NULL];
        if (endMentionRange.location == NSNotFound) {
            if (listNameRange.location == NSNotFound) {
                TwitterTextEntity *entity = [TwitterTextEntity entityWithType:TwitterTextEntityScreenName range:NSMakeRange(atSignRange.location, NSMaxRange(screenNameRange) - atSignRange.location)];
                [results addObject:entity];
            } else {
                TwitterTextEntity *entity = [TwitterTextEntity entityWithType:TwitterTextEntityListName range:NSMakeRange(atSignRange.location, NSMaxRange(listNameRange) - atSignRange.location)];
                [results addObject:entity];
            }
        } else {
            // Avoid matching the second username in @username@username
            end++;
        }
        
        position = end;
    }
    
    return results;
}

+ (TwitterTextEntity*)repliedScreenNameInText:(NSString*)text
{
    if (!text.length) {
        return nil;
    }

    NSInteger len = text.length;
    
    NSRange replyRange = [text rangeOfRegex:TWUValidReply options:RKLCaseless inRange:NSMakeRange(0, len) capture:1L error:NULL];
    if (replyRange.location == NSNotFound) {
        return nil;
    }

    NSInteger replyEnd = NSMaxRange(replyRange);
    
    NSRange endMentionRange = [text rangeOfRegex:TWUEndMentionMatch
                                         options:RKLCaseless
                                         inRange:NSMakeRange(replyEnd, len - replyEnd)
                                         capture:0
                                           error:NULL];
    if (endMentionRange.location != NSNotFound) {
        return nil;
    }
    
    return [TwitterTextEntity entityWithType:TwitterTextEntityScreenName range:replyRange];
}

+ (int)tweetLength:(NSString*)text
{
    text = [text precomposedStringWithCanonicalMapping];
    
    int len = text.length;
    if (!len) {
        return 0;
    }
    
    // Adjust count for non-BMP characters
    UniChar buffer[len];
    [text getCharacters:buffer];
    int charCount = len;
    
    for (int i=0; i<len; i++) {
        UniChar c = buffer[i];
        if (CFStringIsSurrogateHighCharacter(c)) {
            if (i+1 < len) {
                UniChar d = buffer[i+1];
                if (CFStringIsSurrogateLowCharacter(d)) {
                    charCount--;
                    i++;
                }
            }
        }
    }

    return charCount;
}

+ (int)remainingCharacterCount:(NSString*)text
{
    return [self remainingCharacterCount:text httpURLLength:HTTPShortURLLength httpsURLLength:HTTPSShortURLLength];
}

+ (int)remainingCharacterCount:(NSString*)text httpURLLength:(int)httpURLLength httpsURLLength:(int)httpsURLLength
{
    text = [text precomposedStringWithCanonicalMapping];
    
    if (!text.length) {
        return MaxTweetLength;
    }
    
    // Remove URLs from text and add t.co length
    NSMutableString *string = [text mutableCopy];
#if !__has_feature(objc_arc)
    [string autorelease];
#endif
    
    int urlLengthOffset = 0;
    NSArray *urlEntities = [self URLsInText:text];
    for (int i=urlEntities.count-1; i>=0; i--) {
        TwitterTextEntity *entity = [urlEntities objectAtIndex:i];
        NSRange urlRange = entity.range;
        NSString *url = [string substringWithRange:urlRange];
        if ([url rangeOfString:@"https" options:NSCaseInsensitiveSearch | NSAnchoredSearch].location == 0) {
            urlLengthOffset += httpsURLLength;
        } else {
            urlLengthOffset += httpURLLength;
        }
        [string deleteCharactersInRange:urlRange];
    }
    
    int len = string.length;
    int charCount = len + urlLengthOffset;
    
    if (len > 0) {
        // Adjust count for non-BMP characters
        UniChar buffer[len];
        [string getCharacters:buffer];
        
        for (int i=0; i<len; i++) {
            UniChar c = buffer[i];
            if (CFStringIsSurrogateHighCharacter(c)) {
                if (i+1 < len) {
                    UniChar d = buffer[i+1];
                    if (CFStringIsSurrogateLowCharacter(d)) {
                        charCount--;
                        i++;
                    }
                }
            }
        }
    }

    return MaxTweetLength - charCount;
}

@end
