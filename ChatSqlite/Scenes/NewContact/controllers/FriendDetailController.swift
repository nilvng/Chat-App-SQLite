//
//  DetailPersonViewController.swift
//  Phonebook
//
//  Created by Nil Nguyen on 8/27/21.
//

import UIKit

class FriendDetailViewController: UIViewController {
    
    typealias FriendChangeAction = (FriendDomain) -> Void
    
    private var changeAction : FriendChangeAction?
    
    private var friend : FriendDomain?
    private var tempFriend : FriendDomain?
    private var isNew = false
    
    private var dataSource : UITableViewDataSource?
    private var tableView : UITableView = {
       let view = UITableView()
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 60
        view.tableFooterView = UIView()
        return view
    }()
    
    func configure(with friend: FriendDomain,
                   isNew : Bool = false,
                   changeAction: FriendChangeAction? = nil){
        self.friend = friend
        self.isNew = isNew
        self.changeAction = changeAction
        if isViewLoaded {
            setEditing(isNew, animated: false)
        }

    }
    
    init() {
        super.init(nibName: nil, bundle: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        
        tableView.frame = view.layer.bounds
        tableView.delegate = self
        tableView.register(FriendTextEditCell.self, forCellReuseIdentifier: FriendTextEditCell.identifier)
        tableView.register(FriendDetailAvatarCell.self, forCellReuseIdentifier: FriendDetailAvatarCell.identifier)
        tableView.register(FriendAvatarEditCell.self, forCellReuseIdentifier: FriendAvatarEditCell.identifier)
        tableView.register(FriendDeleteCell.self, forCellReuseIdentifier: FriendDeleteCell.identifier)

        setEditing(isNew, animated: false) // if it's new Friend, auto show edit view

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = editButtonItem
        
        // accessibility
        tableView.accessibilityIdentifier = "table-EditView"
    }
    
    @objc func keyboardWasShown (notification: NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 20, right: 0)
         }
        
    }

    @objc func keyboardWillBeHidden (notification: NSNotification)
    {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
 
        
    override func setEditing(_ isEditing: Bool, animated: Bool){
        super.setEditing(isEditing, animated: animated)
        
        guard let selectedFriend = self.friend else {
            fatalError("No friend found in detail view")
        }
        
        if isEditing {
            transitionToEditMode(selectedFriend)
        } else {
            // done editing existing contact?
            if let temp = tempFriend {
                self.friend = temp
                self.tempFriend = nil
                
                print("To Add/edit friend: \(temp) ...")
                self.changeAction?(temp)
            }
            transitionToDetailMode(selectedFriend)
        }
        tableView.dataSource = dataSource
        tableView.reloadData()
    }
    
    fileprivate func transitionToDetailMode(_ friend : FriendDomain){
        //dataSource = FriendDetailDataSource(friend: self.friend!)
        tableView.allowsSelection = false
        navigationItem.title = NSLocalizedString("View Contact", comment: "nav title for detail view")
        navigationItem.leftBarButtonItem = nil
        editButtonItem.isEnabled = true
    }
    
    fileprivate func transitionToEditMode(_ friend: FriendDomain){
        
        navigationItem.title = isNew ? NSLocalizedString("New Contact", comment: "new contact nav title") : NSLocalizedString("Edit Contact", comment: "edit contact nav title")
        
        dataSource = FriendEditDataSource(friend: friend, deleteAction: { [weak self] friend in
            print("tbd delete Friend..")
            self?.navigationController?.popViewController(animated: true)
        }, changeAction: { [weak self] friend in
            self?.tempFriend = friend
        })
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTrigger))
        
        // For UI Test
        navigationItem.leftBarButtonItem?.accessibilityIdentifier = "DetailView.Cancel"
    }
    @objc
    func cancelButtonTrigger() {
        if isNew {
            dismiss(animated: true, completion: nil)
        }
        tempFriend = nil
        setEditing(false, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
    }
}

extension FriendDetailViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        return 65
    }
}


