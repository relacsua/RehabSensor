//
//  BluetoothViewController.h
//  HomeRehab
//
//  Created by Muhammad Muneer on 20/9/15.
//  Copyright (c) 2015 Muhammad Muneer. All rights reserved.
//

// Constants defined here
#define HOME_REHAB_SENSOR_SERVICE_UUID @"FFF0"
#define HOME_REHAB_SENSOR_CHARACTERISTIC_UUID @"FFF1"
#define SENSOR_NAME @"HomeRehabSensorLimb"

#import <UIKit/UIKit.h>
#import "Sensor.h"
#import "OpenGLView.h"
@import CoreBluetooth;

@interface BluetoothViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@end
