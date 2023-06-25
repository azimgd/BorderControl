//
//  AppFilterProvider.m
//  Network
//
//  Created by azimgd on 13.06.2023.
//

#import "AppFilterProvider.h"

@implementation AppFilterProvider

- (instancetype)init
{
  if (self = [super init])
  {
  }
  return self;
}

- (void)startFilterWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler
{
  NENetworkRule* networkRule = [
    [NENetworkRule alloc]
    initWithRemoteNetwork:nil
    remotePrefix:0
    localNetwork:nil
    localPrefix:0
    protocol:NENetworkRuleProtocolAny
    direction:NETrafficDirectionOutbound
  ];
  NEFilterRule* filterRule = [
    [NEFilterRule alloc]
    initWithNetworkRule:networkRule
    action:NEFilterActionFilterData
  ];
  NEFilterSettings* filterSettings = [
    [NEFilterSettings alloc]
    initWithRules:@[filterRule]
    defaultAction:NEFilterActionAllow
  ];

  [self applySettings:filterSettings completionHandler:^(NSError * _Nullable error) {
    completionHandler(error);
  }];
  
  completionHandler(nil);
}

- (void)stopFilterWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
  completionHandler();
}

-(NEFilterNewFlowVerdict *)handleNewFlow:(NEFilterFlow *)flow {
  NEFilterSocketFlow *socketFlow = (NEFilterSocketFlow*)flow;
  NWHostEndpoint *remoteEndpoint = (NWHostEndpoint*)socketFlow.remoteEndpoint;

  return [NEFilterNewFlowVerdict allowVerdict];
}

@end
