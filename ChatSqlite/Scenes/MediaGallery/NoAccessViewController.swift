//
//  NoAccessViewController.swift
//  PinterestView
//
//  Created by LAP11353 on 07/04/2022.
//

import UIKit

class NoAccessViewController: UIViewController {
    typealias OpenSettingHandler = () -> Void
    
    let label : UILabel = {
        let l = UILabel()
        l.text = "Please give the app access to your photos"
        return l
    }()
    
    var callback : OpenSettingHandler?
    
    let btn : UIButton = {
       let b = UIButton()
        b.setTitle("Go to Settings", for: .normal)
        b.setTitleColor(.systemBlue, for: .normal)
        b.tintColor = .systemBlue
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLabel()
        setupBtn()
        // Do any additional setup after loading the view.
    }
    
    init(callback: OpenSettingHandler?=nil){
        super.init(nibName: nil, bundle: nil)
        self.callback = callback
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel(){
        view.addSubview(label)
        label.addConstraints(top:view.topAnchor,centerX: view.centerXAnchor, topConstant: 100)
        
    }
    func setupBtn(){
        view.addSubview(btn)
        btn.addTarget(self,action: #selector(askForRedirect), for: .touchUpInside)
        btn.addConstraints(top:label.topAnchor,centerX: view.centerXAnchor, topConstant: 10)
        
    }
    @objc func askForRedirect(_ sender: Any) {
        
        let alert = UIAlertController(title: "Allow access to your photos",
                                      message: "This lets you share from your camera roll and enables other features for photos and videos. Go to your settings and tap \"Photos\".",
                                      preferredStyle: .alert)
        
        let notNowAction = UIAlertAction(title: "Not Now",
                                         style: .cancel,
                                         handler: nil)
        alert.addAction(notNowAction)
        
        let openSettingsAction = UIAlertAction(title: "Open Settings",
                                               style: .default) { [unowned self] (_) in
            // Open app privacy settings
            gotoAppPrivacySettings()
        }
        alert.addAction(openSettingsAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: { [weak self] _ in
            self?.callback?()
        })
    }


}
