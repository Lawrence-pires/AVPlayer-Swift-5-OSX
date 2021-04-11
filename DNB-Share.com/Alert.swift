//
//  Alert.swift
//  DNB-Share.com
//
//  Created by M1 on 20/03/2021.
//

import Foundation
import Cocoa

class Alert: NSObject {
    
    func showAlert(displayError: String) {
    DispatchQueue.main.async {
            
            let alert = NSAlert()
            alert.messageText =  "Error!"
            alert.informativeText = displayError
            //alert.icon = NSImage(named: "High_Score-128.png")
            alert.runModal()
            }
    
        
    }
}
