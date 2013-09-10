//
//  GameResult.m
//  Matchismo
//
//  Created by Hugo Ferreira on 2013/09/10.
//  Copyright (c) 2013 Mindclick. All rights reserved.
//

#import "GameResult.h"

@interface GameResult()

@property (readwrite, nonatomic) NSDate *start;
@property (readwrite, nonatomic) NSDate *end;

@end

@implementation GameResult
{}
#define KEY_ALL_RESULTS @"GameResult.AllResults"
#define KEY_START   @"StartDate"
#define KEY_END     @"EndDate"
#define KEY_SCORE   @"Score"

#pragma mark - Class

+ (NSArray *)allGameResults
{
    NSMutableArray *allGameResults = [[NSMutableArray alloc] init];
    
    for (id plist in [[[NSUserDefaults standardUserDefaults] dictionaryForKey:KEY_ALL_RESULTS] allValues]) {
        GameResult *result = [[GameResult alloc] initFromPropertyList:plist];
        [allGameResults addObject:result];
    }
    
    return allGameResults;
}

#pragma mark - Initializers

/** Designated initializer */
- (id)init
{
    self = [super init];
    if (self) {
        _start = [NSDate date];
        _end = _start;
    }
    return self;
}

- (id)initFromPropertyList:(id)plist
{
    self = [self init];
    if (self) {
        if ([plist isKindOfClass:[NSDictionary class]]) {
            _start = plist[KEY_START];
            _end = plist[KEY_END];
            _score = [plist[KEY_SCORE] intValue];
            if (!_start || !_end) self = nil;
        } 
    }
    return self;
}

#pragma mark - Properties

- (NSTimeInterval)duration
{
    return [self.end timeIntervalSinceDate:self.start];
}

- (void)setScore:(int)score
{
    _score = score;
    self.end = [NSDate date];
    [self synchronize];
}

#pragma mark - Methods

- (NSDictionary *)asPropertyList
{
    return @{ KEY_START : self.start, KEY_END : self.end, KEY_SCORE : @(self.score) };
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ (%0g) = %d points", self.start, round(self.duration), self.score];
}

- (void)synchronize
{
    // Fetch
    NSMutableDictionary *allGameResults = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:KEY_ALL_RESULTS ] mutableCopy];
    if (!allGameResults) allGameResults = [[NSMutableDictionary alloc] init];
    // Change
    allGameResults[[self.start description]] = [self asPropertyList];
    // Store
    [[NSUserDefaults standardUserDefaults] setObject:allGameResults forKey:KEY_ALL_RESULTS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
