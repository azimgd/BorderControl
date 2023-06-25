//
//  SecurityExtension.h
//  BorderControl
//
//  Created by azimgd on 25.06.2023.
//

#ifndef SecurityExtension_h
#define SecurityExtension_h

#import <SystemExtensions/SystemExtensions.h>

@interface SecurityExtension : NSObject<OSSystemExtensionRequestDelegate>
  @property (class, nonatomic, readonly) SecurityExtension *shared;

  - (void)install;
@end

#endif /* SecurityExtension_h */
