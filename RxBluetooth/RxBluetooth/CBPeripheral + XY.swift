//
//  CBPeripheral + XY.swift
//  XY
//
//  Created by HY on 2018/3/19.
//  Copyright © 2018年 mac. All rights reserved.
//

import Foundation
import CoreBluetooth
private var xyRssiKey = "xyRssiKey"
extension CBPeripheral {
    var xyRssi:Double{
        get{
            return (objc_getAssociatedObject(self, &xyRssiKey) as? Double) ?? 0
        }
        set{
            objc_setAssociatedObject(self, &xyRssiKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
