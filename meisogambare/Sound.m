#import "Sound.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation Sound {
    SystemSoundID handle;
}

- (id) initWithPath: (NSString*) path
{
    self = [super init];
    NSString *const resourceDir = [[NSBundle mainBundle] resourcePath];
    NSString *const fullPath = [resourceDir stringByAppendingPathComponent:path];
    NSURL *const url = [NSURL fileURLWithPath:fullPath];
    OSStatus errcode = AudioServicesCreateSystemSoundID((__bridge CFURLRef) url, &handle);
//    NSLog(@"%@",path);
    NSAssert1(errcode == 0, @"Failed to load sound: %@", path);
    return self;
}

- (void) dealloc
{
    AudioServicesDisposeSystemSoundID(handle);
}

- (void) play
{
    AudioServicesPlaySystemSound(handle);
}

@end