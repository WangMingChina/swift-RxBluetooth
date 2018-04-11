//
//  CBPeripheral + Rx.swift
//  RxBluetooth
//
//  Created by HY on 2018/4/10.
//  Copyright © 2018年 XY. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreBluetooth
extension CBPeripheral: HasDelegate {
    public typealias Delegate = CBPeripheralDelegate
}
extension Reactive where Base: CBPeripheral{
    var delegate: DelegateProxy<CBPeripheral, CBPeripheralDelegate> {
        return RxPeripheralDelegateProxy.proxy(for: base)
    }
    func discoverServices(_ serviceUUIDs:[CBUUID]?)->ControlEvent<CBPeripheral>{
        base.discoverServices(serviceUUIDs)
        return didDiscoverServices
    }
   
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService)->ControlEvent<CBService>{
        base.discoverCharacteristics(characteristicUUIDs, for: service)
        return didDiscoverCharacteristicsFor
    }
    var updateName:ControlEvent<CBPeripheral>{
        let source = delegate.methodInvoked(#selector(CBPeripheralDelegate.peripheralDidUpdateName(_:))).map{ a in
            return try castOrThrow(CBPeripheral.self, a[0])
        }
        return ControlEvent(events: source)
    }
    
    var didDiscoverServices:ControlEvent<CBPeripheral>{
        
        let source:Observable<CBPeripheral> = delegate.methodInvoked(#selector(CBPeripheralDelegate.peripheral(_:didDiscoverServices:))).map{ a in
            return try castOrThrow(CBPeripheral.self, a[0])
        }
        return ControlEvent(events: source)
    }
    
    var didDiscoverCharacteristicsFor:ControlEvent<CBService>{
        let source:Observable<CBService> = delegate.methodInvoked(#selector(CBPeripheralDelegate.peripheral(_:didDiscoverCharacteristicsFor:error:))).map{ a in
            print("didDiscoverCharacteristicsFor")
            return try castOrThrow(CBService.self, a[1])
        }
        return ControlEvent(events: source)
    }
    var didUpdateValueFor:ControlEvent<CBCharacteristic>{
       // #selector(CBPeripheralDelegate.peripheral(_:didUpdateValueFor:error:)) //Ambiguous use of
        return ControlEvent(events: RxPeripheralDelegateProxy.proxy(for:base).didUpdateValueFor)
    }
    
    ///...
}
