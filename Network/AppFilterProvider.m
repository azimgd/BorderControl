//
//  AppFilterProvider.m
//  Network
//
//  Created by azimgd on 13.06.2023.
//

#import "AppFilterProvider.h"
#import "NetworkCommunication.h"

@implementation AppFilterProvider

static NetworkCommunication *networkCommunication;

- (void)startFilterWithCompletionHandler:(void (^)(NSError * _Nullable))completionHandler
{
  networkCommunication = [NetworkCommunication new];
  [networkCommunication connect];
  
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
}

- (void)stopFilterWithReason:(NEProviderStopReason)reason completionHandler:(void (^)(void))completionHandler
{
  [networkCommunication disconnect];
  completionHandler();
}

- (NEFilterNewFlowVerdict *)handleNewFlow:(NEFilterFlow *)flow {
  NEFilterSocketFlow *socketFlow = (NEFilterSocketFlow*)flow;
  NWHostEndpoint *remoteEndpoint = (NWHostEndpoint*)socketFlow.remoteEndpoint;

  NSDictionary *payload = @{
    @"hostname": remoteEndpoint.hostname,
    @"port": remoteEndpoint.port,
  };
  [networkCommunication dispatch:payload];
  
  return [NEFilterNewFlowVerdict allowVerdict];
}

@end
