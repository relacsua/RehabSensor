//
//  BluetoothViewController.m
//  HomeRehab
//
//  Created by Muhammad Muneer on 20/9/15.
//  Copyright (c) 2015 Muhammad Muneer. All rights reserved.
//

#import "BluetoothViewController.h"

@interface BluetoothViewController ()

// Labels holding accelerometer data
@property (weak, nonatomic) IBOutlet UILabel *accX;
@property (weak, nonatomic) IBOutlet UILabel *accY;
@property (weak, nonatomic) IBOutlet UILabel *accZ;

// Labels holding magnetometer data
@property (weak, nonatomic) IBOutlet UILabel *magX;
@property (weak, nonatomic) IBOutlet UILabel *magY;
@property (weak, nonatomic) IBOutlet UILabel *magZ;

// Labels holding gyroscope data
@property (weak, nonatomic) IBOutlet UILabel *gyroX;
@property (weak, nonatomic) IBOutlet UILabel *gyroY;
@property (weak, nonatomic) IBOutlet UILabel *gyroZ;

// Labels to show bluetooth status
@property (weak, nonatomic) IBOutlet UILabel *bluetoothStatus;

// Labels to hold the output of the AHRS algo
@property (weak, nonatomic) IBOutlet UILabel *yawLabel;
@property (weak, nonatomic) IBOutlet UILabel *pitchLabel;
@property (weak, nonatomic) IBOutlet UILabel *rollLabel;

// View to add the graphics
@property (nonatomic, retain) IBOutlet OpenGLView *glView;

// Objects required for bluetooth protocol
@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic) BOOL peripheralFound;
@end

@implementation BluetoothViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Scan for home rehab sensor
    CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.centralManager = centralManager;
    self.peripheralFound = NO;
    
    // Add OpenGLView
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height - 510;
    self.glView = [[OpenGLView alloc] initWithFrame:CGRectMake(0, 510, screenWidth, screenHeight)]; 
    [self.view addSubview:_glView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Bluetooth Button Listener

- (IBAction)bluetoothConnect:(id)sender {
    if(self.peripheralFound) {
        [self.centralManager connectPeripheral:self.peripheral options:nil];
    }
}

#pragma mark - CBCentralManagerDelegate

// restart scan by initialising peripheral ivar and scan for peripherals again
- (void)restartScan {
    self.peripheral = nil;
    self.peripheralFound = NO;
    self.bluetoothStatus.text = [[NSString alloc] initWithFormat:@"Bluetooth Status: Peripheral disconnected"];
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
}

// method called when the sensor disconnects
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self restartScan];
}

// method called when central manager fails to connect to peripheral
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral                  error:(NSError *)error {
    [self restartScan];
}

// method called whenever you have successfully connected to the BLE peripheral
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral setDelegate:self];
    [peripheral discoverServices:nil];
    NSString *connected = [NSString stringWithFormat:@"Bluetooth Status: Connected Success: %@", peripheral.state == CBPeripheralStateConnected ? @"YES" : @"NO"];
    self.bluetoothStatus.text = connected;
    NSLog(@"%@", connected);
}

// CBCentralManagerDelegate - This is called with the CBPeripheral class as its main input parameter. This contains most of the information there is to know about a BLE peripheral.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *peripheralName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    if([peripheralName isEqualToString:SENSOR_NAME]) {
        self.bluetoothStatus.text = [[NSString alloc] initWithFormat: @"Bluetooth Status: %@ found.", peripheralName];
        [self.centralManager stopScan];
        self.peripheral = peripheral;
        self.peripheralFound = YES;
        peripheral.delegate = self;
    }
}

// method called whenever the device state changes.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString *status = [[NSString alloc] init];
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            status = @"CoreBluetooth BLE hardware is powered off";
            break;
        case CBCentralManagerStatePoweredOn:
            status = @"CoreBluetooth BLE hardware is powered on";
            [self.centralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBCentralManagerStateResetting:
            status = @"CoreBluetooth BLE hardware is resetting";
            break;
        case CBCentralManagerStateUnauthorized:
            status = @"CoreBluetooth BLE state is unauthorized";
            break;
        case CBCentralManagerStateUnknown:
            status = @"CoreBluetooth BLE state is unknown";
            break;
        case CBCentralManagerStateUnsupported:
            status = @"CoreBluetooth BLE hardware is unsupported on this platform";
            break;
        default:
            break;
    }
    self.bluetoothStatus.text = [[NSString alloc] initWithFormat: @"Bluetooth Status: %@", status];
    NSLog(status, nil);
}

#pragma mark - CBPeripheralDelegate

// CBPeripheralDelegate - Invoked when you discover the peripheral's available services.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

// Invoked when you discover the characteristics of a specified service.
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if ([service.UUID isEqual:[CBUUID UUIDWithString:HOME_REHAB_SENSOR_SERVICE_UUID]]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HOME_REHAB_SENSOR_CHARACTERISTIC_UUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }
}

// Invoked when you retrieve a specified characteristic's value, or when the peripheral device notifies your app that the characteristic's value has changed.
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:HOME_REHAB_SENSOR_CHARACTERISTIC_UUID]]) {
        // Get the Heart Rate Monitor BPM
        [self extractData:characteristic error:error];
    }
}

#pragma mark - Data Extraction

- (void) extractData:(CBCharacteristic *)characteristic error:(NSError *)error {
    if(error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    [self calculateQuaternion:[characteristic value]];
}

- (void) calculateQuaternion:(NSData *) data {
    float acc_x, acc_y, acc_z, mag_x, mag_y, mag_z, gyro_x, gyro_y, gyro_z, timestamp, yaw, pitch, roll;
    
    [Sensor getSensorReading:data accX:&acc_x accY:&acc_y accZ:&acc_z magX:&mag_x magY:&mag_y magZ:&mag_z gyroX:&gyro_x gyroY:&gyro_y gyroZ:&gyro_z atTime:&timestamp];
    
    [Sensor getYawPitchRoll:acc_x accY:acc_y accZ:acc_z magX:mag_x magY:mag_y magZ:mag_z gyroX:gyro_x gyroY:gyro_y gyroZ:gyro_z yaw:&yaw pitch:&pitch roll:&roll];
    
    yaw = GLKMathRadiansToDegrees(yaw);
    pitch = GLKMathRadiansToDegrees(pitch);
    roll = GLKMathRadiansToDegrees(roll);
    
    self.accX.text = [[NSString alloc] initWithFormat:@"Ax: %.2f", acc_x];
    self.accY.text = [[NSString alloc] initWithFormat:@"Ay: %.2f", acc_y];
    self.accZ.text = [[NSString alloc] initWithFormat:@"Az: %.2f", acc_z];
    
    self.magX.text = [[NSString alloc] initWithFormat:@"Mx: %.2f", mag_x];
    self.magY.text = [[NSString alloc] initWithFormat:@"My: %.2f", mag_y];
    self.magZ.text = [[NSString alloc] initWithFormat:@"Mz: %.2f", mag_z];
    
    self.gyroX.text = [[NSString alloc] initWithFormat:@"Gx: %.4f", gyro_x];
    self.gyroY.text = [[NSString alloc] initWithFormat:@"Gy: %.4f", gyro_y];
    self.gyroZ.text = [[NSString alloc] initWithFormat:@"Gz: %.4f", gyro_z];
    
    self.yawLabel.text = [[NSString alloc] initWithFormat:@"Yaw: %.2f", yaw];
    self.pitchLabel.text = [[NSString alloc] initWithFormat:@"Pitch: %.2f", pitch];
    self.rollLabel.text = [[NSString alloc] initWithFormat:@"Roll: %.2f", roll];
    
    [self.glView setYawPitchRoll:yaw pitch:pitch roll:roll];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
