//
//  RxPeripheralDelegateProxy.swift
//  RxBluetooth
//
//  Created by HY on 2018/4/10.
//  Copyright © 2018年 XY. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreBluetooth


class RxPeripheralDelegateProxy:DelegateProxy<CBPeripheral, CBPeripheralDelegate>,DelegateProxyType,CBPeripheralDelegate{
    weak private(set) var peripheral: CBPeripheral?
    init(peripheral:ParentObject) {
        super.init(parentObject: peripheral, delegateProxy: RxPeripheralDelegateProxy.self)
    }
    static func registerKnownImplementations() {
        self.register{ RxPeripheralDelegateProxy(peripheral: $0) }
    }
    var didUpdateValueFor = PublishSubject<CBCharacteristic>()
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        didUpdateValueFor.onNext(characteristic)
    }
}
