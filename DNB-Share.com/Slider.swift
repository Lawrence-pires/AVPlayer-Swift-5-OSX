//
//  Slider.swift
//  DNB-Share.com
//
//  Created by M1 on 20/03/2021.
//

import Foundation
import Cocoa

class CustomSliderCell: NSSliderCell {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        var rect = aRect
        rect.size.height = CGFloat(5)
        let barRadius = CGFloat(2.5)
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        let finalWidth = CGFloat(value * (self.controlView!.frame.size.width - 8))
        var leftRect = rect
        leftRect.size.width = finalWidth
        let bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        NSColor.gray.setFill()
        bg.fill()
        let active = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
        NSColor.darkGray.setFill()
        active.fill()
    }
    
    /*
     
     
     
     override func drawBar(inside aRect: NSRect, flipped: Bool) {
         var rect = aRect
         rect.size.height = CGFloat(5)
         let barRadius = CGFloat(2.5)
         let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
         let finalWidth = CGFloat(value * (self.controlView!.frame.size.width - 8))
         var leftRect = rect
         leftRect.size.width = finalWidth
         let bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
         NSColor.gray.setFill()
         bg.fill()
         let active = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
         NSColor.darkGray.setFill()
         active.fill()
     }
     */
    
    
    
    
}
class RLSlider: NSSlider {
init() {
    super.init(frame: NSZeroRect)
    addFilter()
}

required init?(coder: NSCoder) {
    super.init(coder: coder)
    addFilter()
}

func addFilter() {
    let colorFilter = CIFilter(name: "CIFalseColor")!
  //  printView(colorFilter)
    colorFilter.setDefaults()
    colorFilter.setValue(CIColor(cgColor: NSColor.white.cgColor), forKey: "inputColor0")
    colorFilter.setValue(CIColor(cgColor: NSColor.lightGray.cgColor), forKey: "inputColor1")
   
//        colorFilter.setValue(CIColor(cgColor: NSColor.yellow.cgColor), forKey: "inputColor0")
//        colorFilter.setValue(CIColor(cgColor: NSColor.yellow.cgColor), forKey: "inputColor1")

    self.contentFilters = [colorFilter]
}
}

