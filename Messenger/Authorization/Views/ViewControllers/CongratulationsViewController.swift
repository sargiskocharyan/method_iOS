//
//  CongratulationsViewController.swift
//  Messenger
//
//  Created by Employee1 on 5/23/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import Lottie

class CongratulationsViewController: UIViewController {
    
    //MARK: @IBOutlet
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var congratulationsLabel: UILabel!
    
    //MARK: Properties
    var headerShapeView = HeaderShapeView()
    let gradientColor = CAGradientLayer()
    var topWidth = CGFloat()
    var topHeight = CGFloat()
    let bottomView = BottomShapeView()
    var bottomWidth = CGFloat()
    var bottomHeight = CGFloat()
    var count = false
    
    //MARK: @IBAction
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = HomePageViewController.instantiate(fromAppStoryboard: .main) 
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
           
        }
    }
    //MARK: Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        let minRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let maxRectBottom = CGRect(x: 0, y: view.frame.height - bottomHeight, width: bottomWidth, height: bottomHeight)
        let maxRect = CGRect(x: self.view.frame.size.width - topWidth, y: 0, width: topWidth, height: topHeight)
        if (self.view.frame.height < self.view.frame.width) {
            headerShapeView.frame = minRect
            bottomView.frame = minRect
        } else {
            headerShapeView.frame = maxRect
            bottomView.frame = maxRectBottom
        }
        self.gradientColor.removeFromSuperlayer()
        doneButton.setGradientBackground(view: self.view, gradientColor)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimation()
        congratulationsLabel.text = "congratulations".localized()
        doneButton.setTitle("done".localized(), for: .normal)
    }
    
    //MARK: Helper methods
    func configureView() {
        bottomWidth = view.frame.width * 0.6
        bottomHeight = view.frame.height * 0.08
        bottomView.frame = CGRect(x: 0, y: view.frame.height - bottomHeight, width: bottomWidth, height: bottomHeight)
        self.view.addSubview(bottomView)
        topWidth = view.frame.width * 0.83
        topHeight =  view.frame.height * 0.3
        self.view.addSubview(headerShapeView)
    }
    
    func showAnimation() {
        let checkMarkAnimation =  AnimationView(name:  "congr")
        animationView.contentMode = .scaleAspectFit
        checkMarkAnimation.animationSpeed = 1
        checkMarkAnimation.frame = self.animationView.bounds
        checkMarkAnimation.loopMode = .loop
        checkMarkAnimation.play()
        self.animationView.addSubview(checkMarkAnimation)
    }
    
}
