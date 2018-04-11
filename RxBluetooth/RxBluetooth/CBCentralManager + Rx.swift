//
//  CBCentralManager + Rx.swift
//  RxBluetooth
//
//  Created by HY on 2018/4/10.
//  Copyright © 2018年 XY. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreBluetooth
enum RxCentralManagerState:Int {
    case unknown
    
    case resetting
    
    case unsupported
    
    case unauthorized
    
    case poweredOff
    
    case poweredOn
}
extension CBCentralManager: HasDelegate {
    public typealias Delegate = CBCentralManagerDelegate
}
func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}
extension Reactive where Base: CBCentralManager{
    var delegate: DelegateProxy<CBCentralManager, CBCentralManagerDelegate> {
        return RxCentralManagerDelegateProxy.proxy(for: base)
    }
    var state:ControlEvent<RxCentralManagerState>{
        return ControlEvent(events: RxCentralManagerDelegateProxy.proxy(for: base).updateState)
    }
    var didDiscover:ControlEvent<CBPeripheral>{
        let souce:Observable<CBPeripheral> = delegate.methodInvoked(#selector(CBCentralManagerDelegate.centralManager(_:didDiscover:advertisementData:rssi:))).map { a in
            let peripheral = try castOrThrow(CBPeripheral.self, a[1])
            peripheral.xyRssi = try castOrThrow(NSNumber.self, a[3]).doubleValue
            return peripheral
        }
        return ControlEvent(events: souce)
    }
    
    var didConnect:ControlEvent<CBPeripheral>{
        let souce:Observable<CBPeripheral> = delegate.methodInvoked(#selector(CBCentralManagerDelegate.centralManager(_:didConnect:))).map { a in
            let peripheral = try castOrThrow(CBPeripheral.self, a[1])
            return peripheral
        }
        return ControlEvent(events: souce)
    }
    
    var didFailToConnect:ControlEvent<CBPeripheral>{
        let souce:Observable<CBPeripheral> = delegate.methodInvoked(#selector(CBCentralManagerDelegate.centralManager(_:didFailToConnect:error:))).map { a in
            let peripheral = try castOrThrow(CBPeripheral.self, a[1])
            return peripheral
        }
        return ControlEvent(events: souce)
    }
    
    var didDisconnect:ControlEvent<CBPeripheral>{
        let souce:Observable<CBPeripheral> = delegate.methodInvoked(#selector(CBCentralManagerDelegate.centralManager(_:didDisconnectPeripheral:error:))).map { a in
            let peripheral = try castOrThrow(CBPeripheral.self, a[1])
            return peripheral
        }
        return ControlEvent(events: souce)
    }
    ///...
    func scan(services:[CBUUID]?,options:[String : Any]? = nil) -> ControlEvent<CBPeripheral> {
        base.scanForPeripherals(withServices: services, options: options)
        return didDiscover
    }
}
