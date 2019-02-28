//
//  MainGuideContainer.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 31..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit


class MainGuideContainer: UIViewController {
    
    @IBOutlet weak var diseaseNameLabel: UILabel!
    @IBOutlet weak var diseaseIntroduceLabel: UILabel!
    @IBOutlet weak var diseaseCheckLabel: UILabel!
    @IBOutlet weak var LabelView: UIView!
    @IBOutlet weak var processView: UIView!
    @IBOutlet weak var defineView: UIView!
    @IBOutlet weak var treatView: UIView!
    @IBOutlet weak var exceptView: UIView!
    @IBOutlet weak var testView: UIView!
    
    var containerDelegate: ContainerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TEST
        testView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTest(sender:))))
        
        diseaseNameLabel.text = SingleData.instance.disease.title
        diseaseIntroduceLabel.text = SingleData.instance.disease.introduce
        diseaseCheckLabel.text = SingleData.instance.disease.title + "check".localized
        LabelView.backgroundColor = UIColor.colors[SingleData.instance.disease.colorIndex]
        
        processView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onRemoteService(sender:))))
        defineView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDefine(sender:))))
        treatView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTreat(sender:))))
        exceptView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onExcept(sender:))))
    }

    // TEST
    @objc func onTest(sender: UIGestureRecognizer) {
        let callVC = AppStoryboard.treat.instance.instantiateViewController(withIdentifier: VC.callVC.rawValue) as! CallViewController
        self.navigationController?.pushViewController(callVC, animated: true)
//        let mikeVC = AppStoryboard.treat.instance.instantiateViewController(withIdentifier: VC.mikeTestVC.rawValue) as! MikeTestViewController
//        self.navigationController?.pushViewController(mikeVC, animated: true)
    }
    
    @objc func onRemoteService(sender: UIGestureRecognizer) {
        containerDelegate?.alterContainer(Container.processGuide.rawValue)
    }
    
    @objc func onDefine(sender: UIGestureRecognizer) {
        containerDelegate?.alterContainer(Container.define.rawValue)
    }
    
    @objc func onTreat(sender: UIGestureRecognizer) {
        containerDelegate?.alterContainer(Container.treat.rawValue)
    }
    
    @objc func onExcept(sender: UIGestureRecognizer) {
        containerDelegate?.alterContainer(Container.except.rawValue)
    }
}

