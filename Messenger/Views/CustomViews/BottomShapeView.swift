//
//  ButtomShapeView.swift
//  Messenger
//
//  Created by Employee1 on 5/23/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class BottomShapeView: UIView {
    var gradient = CAGradientLayer()
    
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
        drawSecondView()
        drawView()
    }
    
    func drawView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 20))
        path.addQuadCurve(to: CGPoint(x: self.frame.width * 3/4, y: self.frame.height),controlPoint: CGPoint(x: self.frame.width * 0.25, y: self.frame.height - 15))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: 20))
        
        gradient.frame = path.bounds
        let col1 = UIColor.init(red: 129/255, green: 138/255, blue: 197/255, alpha: 1)
        let col2 = UIColor.init(red: 117/255, green: 113/255, blue: 208/255, alpha: 1)
        gradient.colors = [col1,col2]
        
        let gradient1 = CGGradient(colorsSpace: nil, colors: [col1.cgColor, col2.cgColor] as CFArray, locations: nil)!
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setLineWidth(0)
        ctx.fillPath()
        ctx.saveGState()
        ctx.addPath(path.cgPath)
        ctx.clip()
        ctx.drawLinearGradient(gradient1, start: CGPoint(x: 0, y: 0), end: CGPoint(x: frame.width, y: 0), options: [])
        ctx.restoreGState()
    }
    
    func drawSecondView() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addQuadCurve(to: CGPoint(x: self.frame.width / 2.5, y: self.frame.height * 0.8), controlPoint: CGPoint(x: self.frame.width * 1/5, y: self.frame.height * 2/3))
        path.addQuadCurve(to: CGPoint(x: self.frame.width, y: self.frame.height), controlPoint: CGPoint(x: self.frame.width - 20, y: self.frame.height - 10))
        path.addLine(to: CGPoint(x: 0, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        let gradient1 = CGGradient(colorsSpace: nil, colors: [UIColor.init(red: 167/255, green: 182/255, blue: 217/255, alpha: 1).cgColor,UIColor.init(red: 176/255, green: 167/255, blue: 219/255, alpha: 1).cgColor] as CFArray, locations: nil)!
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setLineWidth(0)
        ctx.fillPath()
        ctx.saveGState()
        ctx.addPath(path.cgPath)
        ctx.clip()
        ctx.drawLinearGradient(gradient1, start: CGPoint(x: 0, y: 0), end: CGPoint(x: frame.width, y: 0), options: [])
        ctx.restoreGState()
    }
    
    
}
