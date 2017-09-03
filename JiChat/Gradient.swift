//
//  Gradient.swift
//  JiChat
//
//  Created by Ji Hwan Seung on 21/08/2017.
//  Copyright © 2017 Ji Hwan Seung. All rights reserved.
//

import UIKit

class Gradient {
    
    var colorSets = [String: [CGColor]]()
    
    
    init() {
        self.colorSets["green"] = [changeToCGColor(hexcode: "9DFFA4"), changeToCGColor(hexcode: "83E8A8")]
    }
    
    
    func changeToCGColor(hexcode: String) -> CGColor {
        
        let hex = hexcode.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        return UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255).cgColor
    }
    
}

