//
//  main.m
//  TranscriptToSRT
//
//  Created by rominet on 12/11/14.
//  Copyright (c) 2014 Syan.me. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XMLDictionary.h"
#import "SYSubtitleItem.h"

int main(int argc, const char * argv[])
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:YES];
    [openDlg setCanChooseDirectories:NO];
    [openDlg setPrompt:@"Select"];
    [openDlg setTitle:@"Select transcript file"];
    
    if ([openDlg runModal] != NSOKButton)
        return 0;
    
    NSArray* files = [openDlg URLs];
    if([files count] == 0)
        return 0;
    
    XMLDictionaryParser *parser = [[XMLDictionaryParser alloc] init];
    
    NSString  *inputPath = [(NSURL *)[files objectAtIndex:0] path];
    NSString *outputPath = [inputPath stringByAppendingPathExtension:@"srt"];
    
    NSDictionary  *input = [parser dictionaryWithFile:inputPath];
    NSFileHandle *output = [NSFileHandle fileHandleForWritingAtPath:outputPath];
    if(output == nil) {
        [[NSFileManager defaultManager] createFileAtPath:outputPath contents:nil attributes:nil];
        output = [NSFileHandle fileHandleForWritingAtPath:outputPath];
    }
    
    NSArray *subDics = input[@"text"];
    
    if([subDics count] == 0) {
        NSLog(@"Empty or invalid file");
        return 0;
    }
    
    if(!output) {
        NSLog(@"Couldn't create output file: %@", outputPath);
        return 0;
    }
    
    NSMutableArray *subItems = [NSMutableArray arrayWithCapacity:[subDics count]];
    for(NSDictionary *subDic in subDics)
        [subItems addObject:[[SYSubtitleItem alloc] initWithXMLDic:subDic]];
    
    [subItems sortUsingComparator:^NSComparisonResult(SYSubtitleItem *obj1, SYSubtitleItem *obj2) {
        double start1 = [obj1.startTime doubleValue];
        double start2 = [obj2.startTime doubleValue];
        if(start1 == start2)
            return NSOrderedSame;
        return start1 < start2 ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    for(NSUInteger i = 0; i < [subItems count]; ++i)
    {
        SYSubtitleItem *subItem = subItems[i];
        NSString *subString = [subItem srtStringWithItemNumber:i];
        [output writeData:[subString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [output synchronizeFile];
    [output closeFile];
    
    NSLog(@"Written %d items to %@\nApprox. from %@ to %@",
          (int)[subDics count], outputPath,
          [[subItems firstObject] startTimeString], [[subItems lastObject] endTimeString]);
    
    return 0;
}
