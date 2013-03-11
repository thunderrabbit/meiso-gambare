/*
 - Trivial wrapper around system sound as provided by Audio Services.
 - Don’t forget to link against the Audio Toolbox framework.
 - Assumes ARC support.
 */

@interface Sound : NSObject

// Path is relative to the resources dir.
- (id) initWithPath: (NSString*) path;
- (void) play;

@end