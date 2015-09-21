//
//  Sensor.m
//  HomeRehab
//
//  Created by Muhammad Muneer on 21/9/15.
//  Copyright (c) 2015 Muhammad Muneer. All rights reserved.
//

#import "Sensor.h"

@implementation Sensor

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
                  atTime:(float *)timestamp
{
    int8_t lsb = 0x00;
    int8_t msb = 0x00;
    int16_t temp = 0x0000;
    int32_t time = 0x00000000;

//    NSLog(@"%@", data);
    
    /*  Start of extraction of accelerometer values */
    [data getBytes:&temp range:NSMakeRange(2, 2)];
    temp >>= 4;
    *accX = temp;
    [data getBytes:&temp range:NSMakeRange(4, 2)];
    temp >>= 4;
    *accY = temp;
    [data getBytes:&temp range:NSMakeRange(6, 2)];
    temp >>= 4;
    *accZ = temp;
    /*  End of extraction of accelerometer values */
    
    /*  Start of extraction of magnetometer values */
    [data getBytes:&lsb range:NSMakeRange(9, 1)];
    [data getBytes:&msb range:NSMakeRange(8, 1)];
    msb &= 0x0F;
    if (msb & 0x08) msb |= 0xF0;
    temp = ((msb << 8) | (0x00FF & lsb));
    *magX = temp;
    
    [data getBytes:&lsb range:NSMakeRange(11, 1)];
    [data getBytes:&msb range:NSMakeRange(10, 1)];
    msb &= 0x0F;
    if (msb & 0x08) msb |= 0xF0;
    temp = ((msb << 8) | (0x00FF & lsb));
    *magY = temp;
    
    [data getBytes:&lsb range:NSMakeRange(13, 1)];
    [data getBytes:&msb range:NSMakeRange(12, 1)];
    msb &= 0x0F;
    if (msb & 0x08) msb |= 0xF0;
    temp = ((msb << 8) | (0x00FF & lsb));
    *magZ = temp;
    /*  End of extraction of magnetometer values */
    
    /*  Start of extraction of gyroscope values */
    [data getBytes:&lsb range:NSMakeRange(15, 1)];
    [data getBytes:&msb range:NSMakeRange(14, 1)];
    temp = (msb << 8) | (0X00FF & lsb);
    *gyroX = temp;
    
    [data getBytes:&lsb range:NSMakeRange(17, 1)];
    [data getBytes:&msb range:NSMakeRange(16, 1)];
    temp = (msb << 8) | (0X00FF & lsb);
    *gyroY = temp;
    
    [data getBytes:&lsb range:NSMakeRange(19, 1)];
    [data getBytes:&msb range:NSMakeRange(18, 1)];
    temp = (msb << 8) | (0X00FF & lsb);
    *gyroZ = temp;
    /*  End of extraction of gyroscope values */
    
    /*  Start of extraction of timestamp */
    [data getBytes:&lsb range:NSMakeRange(12, 1)];
    time = (0xF0 & lsb) >> 4;
    [data getBytes:&lsb range:NSMakeRange(10, 1)];
    time = (time << 4) | ((0xF0 & lsb) >> 4);
    [data getBytes:&lsb range:NSMakeRange(8, 1)];
    time = (time << 4) | ((0xF0 & lsb) >> 4);
    [data getBytes:&lsb range:NSMakeRange(6, 1)];
    time = (time << 4) | (0x0F & lsb);
    [data getBytes:&lsb range:NSMakeRange(4, 1)];
    time = (time << 4) | (0x0F & lsb);
    [data getBytes:&lsb range:NSMakeRange(2, 1)];
    time = (time << 4) | (0x0F & lsb);
    *timestamp = time;
    /*  End of extraction of timestamp */
}


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
                    roll:(float *)roll
{
    gyroX = GLKMathDegreesToRadians(gyroX/14.375);
    gyroY = GLKMathDegreesToRadians(gyroY/14.375);
    gyroZ = GLKMathDegreesToRadians(gyroZ/14.375);
    
    MadgwickAHRSupdate(gyroX, gyroY, gyroZ, accX, accY, accZ, magX, magY, magZ);
    
    *yaw = atan2(2*q2*q0-2*q1*q3 , 1 - 2*q2*q2 - 2*q3*q3);
    *pitch = asin(2*q1*q2 + 2*q3*q0);
    *roll = atan2(2*q1*q0-2*q2*q3 , 1 - 2*q1*q1 - 2*q3*q3);
    
}

@end
