//
//  BLEManager.h
//
//  Created by zwwuchn on 7/19/19.
//  Copyright © 2019 fhit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
NS_ASSUME_NONNULL_BEGIN
@protocol BLEManagerDelegate <NSObject>
@optional
#pragma mark- 发现设备
- (void)didPeripheralFound:(nonnull CBPeripheral *)peripheral advertisementData:(nonnull NSDictionary *)advertisementData RSSI:(nullable NSNumber *)RSSI;

#pragma mark 连接成功
- (void)didConnectPeripheral:(nonnull CBPeripheral *)peripheral;

#pragma mark 连接失败
- (void)didFailToConnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error;

#pragma mark 连接断开
- (void)didDisconnectPeripheral:(nonnull CBPeripheral *)peripheral error:(nullable NSError *)error;

#pragma mark- 接收数据
- (void)bleGattServiceDataReceived:(nonnull NSData *)revData;
@end
@interface BLEManager : NSObject
+ (BLEManager *)shareInstance;

@property(nonatomic,strong) CBCentralManager *cbCM;

@property (nonatomic,weak) id <BLEManagerDelegate> _Nullable delegate;

@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;

#pragma mark- 开始搜索
- (void)beginScan;
#pragma mark- 停止搜索
- (void)stopScan;

/**
 如需设置服务及读写特征
 需在调用连接之前调用

 @param serviceUUIDString 服务ID
 @param writeCharacteristic 写特征
 @param notify 读特征
 */
- (void)setServiceUUIDString:(NSString * _Nonnull)serviceUUIDString writeCharacteristic:(NSString *)writeCharacteristic notify:(NSString *)notify;
#pragma mark- 连接设备
- (void)connect:(nonnull CBPeripheral*)peripheral;
#pragma mark- 断开连接
- (void)disconnect:(nonnull CBPeripheral*)peripheral;
#pragma mark- 发送数据
- (void)write:(nonnull NSData *)data withResponse:(BOOL)withResponse;
@end

NS_ASSUME_NONNULL_END
