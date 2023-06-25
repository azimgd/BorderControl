//
//  ExtensionBundle.h
//  BorderControl
//
//  Created by azimgd on 14.06.2023.
//

#ifndef ExtensionBundle_h
#define ExtensionBundle_h

@interface ExtensionBundle : NSObject

@property (class, nonatomic, readonly) ExtensionBundle *shared;

- (NSBundle *)extensionBundle:(NSBundle *)bundle;;
- (NSString *)extensionBundleMachService:(NSBundle *)bundle;

@end

#endif /* ExtensionBundle_h */
