//
//  BLEManager.m
//
//  Created by zwwuchn on 7/19/19.
//  Copyright © 2019 fhit. All rights reserved.
//

#import "BLEManager.h"

@interface BLEManager()<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    CBPeripheral *connectPeripheral;
    NSString *serviceUUIDString;
    NSString *write;
    NSString *notify;
}
@end
@implementation BLEManager
static BLEManager *Manager = nil;
+ (BLEManager *)shareInstance{
    static dispatch_once_t dispatch;
    dispatch_once(&dispatch, ^{
        Manager = [[BLEManager alloc] init];
        [Manager instanse];
    });
    return Manager;
}

- (void)instanse{
    self.cbCM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    serviceUUIDString = @"FF00";
    write = @"FF01";
    notify = @"FF02";
}
#pragma mark- 开始搜索
- (void)beginScan{
    [self.cbCM scanForPeripheralsWithServices:nil options:nil];
}
#pragma mark- 停止搜索
- (void)stopScan{
    [self.cbCM stopScan];
}
#pragma mark- 设置服务属性
- (void)setServiceUUIDString:(NSString *)serviceUUIDString writeCharacteristic:(NSString *)writeCharacteristic notify:(NSString *)notify{
    self->serviceUUIDString = serviceUUIDString;
    self->write = writeCharacteristic;
    self->notify = notify;
}
#pragma mark- 连接设备
- (void)connect:(CBPeripheral *)peripheral{
    [self.cbCM stopScan];
    [self.cbCM connectPeripheral:peripheral options:nil];
}
#pragma mark- 断开连接
- (void)disconnect:(CBPeripheral *)peripheral{
    [self.cbCM cancelPeripheralConnection:peripheral];
}
#pragma mark- 发送数据
- (void)write:(NSData *)data withResponse:(BOOL)withResponse{
    if(!_writeCharacteristic){
        NSLog(@"writeCharacteristic is nil!");
        return;
    }
    [connectPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:withResponse ? CBCharacteristicWriteWithResponse : CBCharacteristicWriteWithoutResponse];
}
#pragma mark- CBPeripheralDelegate
#pragma mark- 发现设备
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    if ([self.delegate respondsToSelector:@selector(didPeripheralFound:advertisementData:RSSI:)]) {
        [self.delegate didPeripheralFound:peripheral advertisementData:advertisementData RSSI:RSSI];
    }
}
#pragma mark- 连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    connectPeripheral = peripheral;
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    if ([self.delegate respondsToSelector:@selector(didConnectPeripheral:)]) {
        [self.delegate didConnectPeripheral:peripheral];
    }
}
#pragma mark- 连接失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(didFailToConnectPeripheral:error:)]) {
        [self.delegate didFailToConnectPeripheral:peripheral error:error];
    }
}
#pragma mark- 断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    if ([self.delegate respondsToSelector:@selector(didDisconnectPeripheral:error:)]) {
        [self.delegate didDisconnectPeripheral:peripheral error:error];
    }
}
#pragma mark- 蓝牙状态的改变
- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:
            //未知状态
            break;
        case CBManagerStateResetting:
            //蓝牙重置中
            break;
        case CBManagerStateUnsupported:
            //蓝牙不支持
            break;
        case CBManagerStateUnauthorized:
            //没有权限
            break;
        case CBManagerStatePoweredOff:
            //蓝牙为开启
            break;
        case CBManagerStatePoweredOn:
            //蓝牙已开启
            break;
        default:
            break;
    }
}
#pragma mark- 蓝牙数据接收
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:self->serviceUUIDString]]) {
        NSData *data = characteristic.value;
        if (data) {
            if ([self.delegate respondsToSelector:@selector(bleGattServiceDataReceived:)]) {
                [self.delegate bleGattServiceDataReceived:data];
            }
        }
    }
}

#pragma mark- CBCentralManagerDelegate
//发现服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    for (CBService *s in peripheral.services) {
        if ([s.UUID.UUIDString isEqualToString:self->serviceUUIDString]) {
            //这里可以通过service的UUID属性来辨识你要的服务
            [peripheral discoverCharacteristics:nil forService:s];
        }
    }
}
//设置特征属性值
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:self->notify]]){
            // 订阅, 实时接收
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:self->write]]){
            self.writeCharacteristic = characteristic;
        }
    }
}
@end
