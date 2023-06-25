//
//  main.m
//  Security
//
//  Created by azimgd on 25.06.2023.
//

#import <Foundation/Foundation.h>
#import <EndpointSecurity/EndpointSecurity.h>

int main(int argc, char *argv[])
{
    // Create the client
    es_client_t *client = NULL;
    es_new_client_result_t newClientResult = es_new_client(&client, ^(es_client_t *c, const es_message_t *message) {
        // Do processing on the message received
    });

    if (newClientResult != ES_NEW_CLIENT_RESULT_SUCCESS) {
        return 1;
    }

    dispatch_main();
}
