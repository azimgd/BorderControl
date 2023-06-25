//
//  EndpointSecurityProvider.h
//  BorderControl
//
//  Created by azimgd on 25.06.2023.
//

#ifndef EndpointSecurityProvider_h
#define EndpointSecurityProvider_h

#import <Foundation/Foundation.h>
#import <EndpointSecurity/EndpointSecurity.h>

@interface EndpointSecurityProvider : NSObject

@property (nonatomic, assign) es_client_t *client;

- (void)start;
- (void)subscribe;

@end

#endif /* EndpointSecurityProvider_h */
