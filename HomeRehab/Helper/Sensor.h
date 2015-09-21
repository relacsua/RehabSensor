//
//  Sensor.h
//  HomeRehab
//
//  Created by Muhammad Muneer on 21/9/15.
//  Copyright (c) 2015 Muhammad Muneer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MadgwickAHRS.h"
#import <GLKit/GLKit.h>

@interface Sensor : NSObject

+ (void)getSensorReading:(NSData *) data
                    accX:(float *)accX
                    accY:(float *)accY
                    accZ:(float *)accZ
                    magX:(float *)magX
                    magY:(float *)magY
                    magZ:(float *)magZ
                   gyroX:(float *)gyroX
                   gyroY:(float *)gyroY
                   gyroZ:(float *)gyroZ
                  atTime:(float *)timestamp;

+ (void)getYawPitchRoll:(float)accX
                    accY:(float)accY
                    accZ:(float)accZ
                    magX:(float)magX
                    magY:(float)magY
                    magZ:(float)magZ
                   gyroX:(float)gyroX
                   gyroY:(float)gyroY
                   gyroZ:(float)gyroZ
                     yaw:(float *)yaw
                   pitch:(float *)pitch
                    roll:(float *)roll;

@end
