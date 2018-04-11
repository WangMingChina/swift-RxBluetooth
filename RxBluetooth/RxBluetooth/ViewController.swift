//
//  ViewController.swift
//  RxBluetooth
//
//  Created by HY on 2018/4/9.
//  Copyright © 2018年 XY. All rights reserved.
//

import UIKit
import CoreBluetooth
import RxSwift
import RxCocoa
import RxDataSources
class ViewController: UIViewController {

    let centralManager = CBCentralManager(delegate: nil, queue: nil)
    let disposeBag = DisposeBag()
    let tableView = UITableView()
    let peripherals = Variable<[CBPeripheral]>([])
    var connectPeripherals = [CBPeripheral]()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.frame = view.bounds
        self.title = "蓝牙搜索"
        let item = UIBarButtonItem(title: "搜索", style: UIBarButtonItemStyle.plain, target: self, action: #selector(itemEvent as ()->()))
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Int,CBPeripheral>>(configureCell: {(_,tableView,indexPath,model) in
            var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
                cell?.detailTextLabel?.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 10)
            }
            cell?.textLabel?.text = (model.name ?? "null") + " rssi" + String(model.xyRssi)
            cell?.detailTextLabel?.text = model.identifier.uuidString
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            switch model.state {
            case .connected:
               label.text = "已连接"
            case .connecting:
                label.text = "正在连接"
            case .disconnected:
                label.text = "未连接"
            case .disconnecting:
                label.text = "未连接"
            }
            label.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            label.sizeToFit()
            cell?.accessoryView = label
            return cell!
        })
        peripherals.asDriver().map { (arr) -> [SectionModel<Int,CBPeripheral>] in
            return [SectionModel(model: 0, items: arr)]
        }.drive(tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        tableView.rowHeight = 44
        self.navigationItem.rightBarButtonItem = item
        centralManager.rx.state.subscribe { (event) in
            
            ////监听蓝牙状态
            print("event = \(event)")
        }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected.map{ return dataSource[$0] }.subscribe { [unowned self](event) in
            guard let peripheral = event.element else { return }
            self.centralManager.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnConnectionKey:30])
            self.tableView.reloadData()
            ///超时监测
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 15, execute: {
                if peripheral.state == CBPeripheralState.connecting {
                    self.centralManager.cancelPeripheralConnection(peripheral)
                    self.tableView.reloadData()
                }
            })
        }.disposed(by: disposeBag)
        
        centralManager.rx.didConnect.subscribe(onNext: { [unowned self](peripheral) in
            self.connectPeripherals.append(peripheral)
            self.tableView.reloadData()
            self.centralManager.stopScan()
            self.connect(peripheral: peripheral)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
        
        centralManager.rx.didDisconnect.subscribe { (event) in
            guard let peripheral = event.element else { return }
            if !self.connectPeripherals.contains(peripheral) {
                print("连接超时")
            }
        }.disposed(by: disposeBag)
        
    }
    
    var peripheralDisposeBag = DisposeBag()
    var dataDisposeBag = DisposeBag()
    @objc func itemEvent(){
        self.peripherals.value = []
        dataDisposeBag = DisposeBag()
        centralManager.rx.scan(services: nil).subscribe(onNext: { [unowned self](peripheral) in
            self.peripherals.value.append(peripheral)
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: dataDisposeBag)
    }
    
    func connect(peripheral:CBPeripheral){
        ///销毁上一个连接的监听
        peripheralDisposeBag = DisposeBag()
        peripheral.rx.discoverServices(nil).flatMap{
            ///选取第一个服务
            return $0.rx.discoverCharacteristics(nil, for: $0.services![0])
        }.subscribe({ (event) in
                guard let service = event.element else { return }
                guard let characteristics = service.characteristics else { return }
            ///订阅所有特征
                characteristics.forEach({ (characteristic) in
                    service.peripheral.setNotifyValue(true, for: characteristic)
                })
        }).disposed(by: peripheralDisposeBag)
        ///监听特征值该变
        peripheral.rx.didUpdateValueFor.subscribe { (event) in
             guard let characteristic = event.element else { return }
             print(characteristic.value?.hexString)
        }.disposed(by: peripheralDisposeBag)
        ////监听蓝牙断开
        centralManager.rx.didDisconnect.subscribe { [unowned self](event) in
            guard let peripheral = event.element else { return }
            if self.connectPeripherals.contains(peripheral) {
                print("连接已断开")
            }
        }.disposed(by: peripheralDisposeBag)
        
        
    }

}
extension Data{
    
    var hexString : String {
        
        return withUnsafeBytes {(bytes: UnsafePointer<UInt8>) -> String in
            let buffer = UnsafeBufferPointer(start: bytes, count: count)
            return buffer.map {String(format: "%02hhx", $0)}.reduce("", { $0 + $1 }).uppercased()
        }
    }
}
