//
//  RxCentralManagerDelegateProxy.swift
//  RxBluetooth
//
//  Created by HY on 2018/4/9.
//  Copyright © 2018年 XY. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreBluetooth




class RxCentralManagerDelegateProxy:DelegateProxy<CBCentralManager, CBCentralManagerDelegate>,DelegateProxyType,CBCentralManagerDelegate {
    weak private(set) var centralManager: CBCentralManager?
    init(manager:ParentObject){
        super.init(parentObject: manager, delegateProxy: RxCentralManagerDelegateProxy.self)
    }
    static func registerKnownImplementations() {
        self.register{ RxCentralManagerDelegateProxy(manager: $0) }
    }
    var updateState = PublishSubject<RxCentralManagerState>()
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            updateState.onNext(RxCentralManagerState.unknown)
        case .resetting:
            updateState.onNext(RxCentralManagerState.resetting)
        case .unsupported:
            updateState.onNext(RxCentralManagerState.unsupported)
        case .unauthorized:
            updateState.onNext(RxCentralManagerState.unauthorized)
        case .poweredOff:
            updateState.onNext(RxCentralManagerState.poweredOff)
        case .poweredOn:
            updateState.onNext(RxCentralManagerState.poweredOn)
        }
    }
}
