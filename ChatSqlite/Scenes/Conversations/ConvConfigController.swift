//
//  ConversationConfigViewController.swift
//  Chat App
//
//  Created by Nil Nguyen on 10/17/21.
//

import UIKit

class ConvConfigController : UIViewController {
    
    typealias  ConfigAction = () -> Void
    var deleteAction : ConfigAction?
    var muteAction : ConfigAction?
    
    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.isScrollEnabled = false
        table.rowHeight = 65
        return table
    }()
    
    enum ConfigDetail: Int, CaseIterable {
        case delete
        case mute
        
        func getIconImage() -> UIImage?{
            switch self {
            case .delete:
                return UIImage(systemName: "trash.fill")
            case .mute:
                return UIImage(systemName: "bell.slash")
                
                }
        }
        func getTitleText() -> String? {
            switch self {
            case .delete:
                return "Delete"
            case .mute:
                return "Mute notifications"
            }
        }
    }

    override func viewDidLoad() {
        setupTableView()
    }
    
    func configure(deleteAction: @escaping () -> Void){
        self.deleteAction = deleteAction
    }
    
    func setupTableView(){
        
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: margin.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    func takeAction(config : ConfigDetail) {
        switch config {
        case .delete:
            deleteAction?()
        case .mute:
            muteAction?()
        }
    }

}

extension ConvConfigController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ConfigDetail.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let config = ConfigDetail.init(rawValue: indexPath.row) else {
            fatalError()
        }
        cell.imageView?.image =  config.getIconImage()
        cell.textLabel?.text = config.getTitleText()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let config = ConfigDetail.init(rawValue: indexPath.row) else {
            fatalError()
        }
        takeAction(config: config)
        self.dismiss(animated: true, completion: nil)
    }
}
