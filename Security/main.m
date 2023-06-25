//
//  main.m
//  Security
//
//  Created by azimgd on 25.06.2023.
//

#import <Foundation/Foundation.h>
#import "EndpointSecurityProvider.h"

int main(int argc, const char *argv[])
{
  @autoreleasepool {
    EndpointSecurityProvider *endpointSecurityProvider = [EndpointSecurityProvider new];
    [endpointSecurityProvider start];
    [endpointSecurityProvider subscribe];
  }

  dispatch_main();
}
