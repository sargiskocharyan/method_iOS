//
//  DemoView.swift
//  Messenger
//
//  Created by Employee1 on 5/21/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class HeaderShapeView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        DispatchQueue.main.async {
            self.backgroundColor = UIColor.clear
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        createRectangle()
        self.createTriangle()
    }
    
    func createTriangle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addQuadCurve(to: CGPoint(x: self.frame.width / 2 - 55, y: 45), controlPoint: CGPoint(x: 0, y: 45))
        path.addLine(to: CGPoint(x: self.frame.width / 2 - 55, y: 0))
        
        path.move(to: CGPoint(x: self.frame.width / 2 - 55, y: 45))
        path.addQuadCurve(to: CGPoint(x: self.frame.width / 2 + 90, y: self.frame.height / 2 + 20), controlPoint: CGPoint(x: self.frame.width / 2 + 50, y: 50))
        path.addLine(to: CGPoint(x: self.frame.width / 2 + 40, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width / 2 - 55, y: 0))
        
        path.move(to: CGPoint(x: self.frame.width / 2 + 90, y: self.frame.height / 2 + 20))
        path.addQuadCurve(to: CGPoint(x: self.frame.width , y: self.frame.height - 10), controlPoint: CGPoint(x: self.frame.width * 0.88, y: self.frame.height * 0.94))
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width / 2 + 40, y: 0))
        let gradient1 = CGGradient(colorsSpace: nil, colors: [UIColor.init(red: 130/255, green: 113/255, blue: 196/255, alpha: 1).cgColor,UIColor.init(red: 86/255, green: 161/255, blue: 208/255, alpha: 1).cgColor] as CFArray, locations: nil)!
        
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setLineWidth(0)
        ctx.fillPath()
        ctx.saveGState()
        ctx.addPath(path.cgPath)
        ctx.clip()
        ctx.drawLinearGradient(gradient1, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: frame.height), options: [])
        ctx.restoreGState()
    }
    
    
    func createRectangle() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 00))
        path.addQuadCurve(to: CGPoint(x: self.frame.width / 2 - 55, y: 60), controlPoint: CGPoint(x: 0, y: 60))
        path.addLine(to: CGPoint(x: self.frame.width / 2 - 55, y: 0))
        path.move(to: CGPoint(x: self.frame.width / 2 - 55, y: 60))
        path.addQuadCurve(to: CGPoint(x: self.frame.width / 2 + 85, y: self.frame.height / 2 + 20), controlPoint: CGPoint(x: self.frame.width / 2 + 50 , y: 60))
        path.addLine(to: CGPoint(x: self.frame.width / 2 + 40, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width / 2 - 55, y: 0))
        
        path.move(to:  CGPoint(x: self.frame.width / 2 + 85, y: self.frame.height / 2 + 20))
        path.addQuadCurve(to: CGPoint(x: self.frame.width, y: self.frame.height ), controlPoint: CGPoint(x: self.frame.width * 0.88, y: self.frame.height - 5))
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width / 2 + 40, y: 0))
        let gradient1 = CGGradient(colorsSpace: nil, colors: [UIColor.init(red: 174/255, green: 167/255, blue: 203/255, alpha: 1).cgColor,UIColor.init(red: 149/255, green: 196/255, blue: 225/255, alpha: 1).cgColor] as CFArray, locations: nil)!
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setLineWidth(0)
        ctx.fillPath()
        ctx.saveGState()
        ctx.addPath(path.cgPath)
        ctx.clip()
        ctx.drawLinearGradient(gradient1, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: frame.height), options: [])
        ctx.restoreGState()
    }
}
