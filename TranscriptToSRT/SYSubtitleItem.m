//
//  SYSubtitleItem.m
//  TranscriptToSRT
//
//  Created by rominet on 12/11/14.
//  Copyright (c) 2014 Syan.me. All rights reserved.
//

#import "SYSubtitleItem.h"
#import "NSString+Time.h"
#import "NSString+XMLEntities.h"

@implementation SYSubtitleItem

- (instancetype)initWithXMLDic:(NSDictionary *)xmlDic
{
    self = [super init];
    if (self)
    {
        self.startTime = xmlDic[@"_start"];
        self.duration  = xmlDic[@"_dur"];
        self.text = xmlDic[@"__text"];
        
        self.text = [self.text stringByDecodingXMLEntities];
    }
    return self;
}

- (NSString *)srtStringWithItemNumber:(NSUInteger)itemNumber
{
    NSMutableString *string = [NSMutableString string];
    
    if(itemNumber > 0)
        [string appendFormat:@"%ld\n", itemNumber];
    
    [string appendFormat:@"%@ --> %@\n", [self startTimeString], [self endTimeString]];
    [string appendFormat:@"%@\n\n", self.text];
    
    return [string copy];
}

- (NSString *)startTimeString
{
    return [NSString stringForTimeFormattedForSeconds:[self.startTime doubleValue]];
}

- (NSString *)durationString
{
    return [NSString stringForTimeFormattedForSeconds:[self.duration doubleValue]];
}

- (NSString *)endTimeString
{
    return [NSString stringForTimeFormattedForSeconds:[self.startTime doubleValue] + [self.duration doubleValue]];
}

- (NSString *)description
{
    return [self srtStringWithItemNumber:0];
}

@end
