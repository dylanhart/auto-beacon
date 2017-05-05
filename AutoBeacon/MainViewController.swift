//
//  MainViewController.swift
//  AutoBeacon
//
//  Created by Dylan Hart on 5/4/17.
//  Copyright © 2017 Dylan Hart. All rights reserved.
//

import Cocoa
import CoreBluetooth

class MainViewController: NSViewController, CBPeripheralManagerDelegate {

    @IBOutlet weak var uuidField: NSTextField!
    @IBOutlet weak var majorField: NSTextField!
    @IBOutlet weak var minorField: NSTextField!
    @IBOutlet weak var broadcastButton: NSButton!
    @IBOutlet weak var statusLabel: NSTextField!

    var manager = CBPeripheralManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBPeripheralManager.init(delegate: self, queue: nil)
    }

    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        updateStatus(peripheral)
    }

    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let err = error {
            statusLabel.stringValue = err.localizedDescription
        } else {
            updateStatus(peripheral)
        }
    }

    func updateStatus(_ peripheral: CBPeripheralManager) {
        var state = ""
        switch peripheral.state {
        case .unknown: state = "Unknown"
        case .resetting: state = "Resetting"
        case .unsupported: state = "Unsupported"
        case .unauthorized: state = "Unauthorized"
        case .poweredOff: state = "Powered Off"
        case .poweredOn: state = "Powered On"
        }

        statusLabel.stringValue = "\(state), broadcasting: \(peripheral.isAdvertising)"
    }

    // https://updatemycode.com/2014/11/29/yosemite-as-an-ibeacon-swift/
    func beaconAdvertisement() -> [String: Any?]? {
        let bufferSize = 21

        var advertisementBytes = [CUnsignedChar](repeating: 0, count: bufferSize)

        if let uuid = NSUUID.init(uuidString: uuidField.stringValue) {
            uuid.getBytes(&advertisementBytes)
        } else {
            return nil
        }

        let major = majorField.integerValue
        let minor = minorField.integerValue
        advertisementBytes[16] = CUnsignedChar(major >> 8)
        advertisementBytes[17] = CUnsignedChar(major & 255)

        advertisementBytes[18] = CUnsignedChar(minor >> 8)
        advertisementBytes[19] = CUnsignedChar(minor & 255)

        // http://stackoverflow.com/a/25667091/3824765
        advertisementBytes[20] = CUnsignedChar(bitPattern: -59)

        // http://stackoverflow.com/questions/24196820/nsdata-from-byte-array-in-swift
        let advertisement = NSData(bytes: advertisementBytes, length: bufferSize)

        return ["kCBAdvDataAppleBeaconKey": advertisement]
    }

    @IBAction func toggleAdvertising(sender: AnyObject?) {
        if !manager.isAdvertising {
            if let data = beaconAdvertisement() {
                manager.startAdvertising(data)
                broadcastButton.title = "Stop"
            } else {
                statusLabel.stringValue = "Invalid Input."
            }
        } else {
            manager.stopAdvertising()
            broadcastButton.title = "Broadcast"
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                self.updateStatus(self.manager)
            })
        }
    }

    @IBAction func performQuit(sender: AnyObject?) {
        NSApplication.shared().terminate(self)
    }
}
