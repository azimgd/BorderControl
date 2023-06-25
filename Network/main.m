//
//  main.m
//  Network
//
//  Created by azimgd on 13.06.2023.
//

#import <Foundation/Foundation.h>
#import <NetworkExtension/NetworkExtension.h>
#import "ExtensionBundle.h"

int main(int argc, char *argv[])
{
  @autoreleasepool {
    [NEProvider startSystemExtensionMode];
  }

  dispatch_main();
}
