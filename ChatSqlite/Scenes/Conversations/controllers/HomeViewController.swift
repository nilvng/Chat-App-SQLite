//
//  ViewController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import UIKit

protocol ConversationListInteractor {
    var presenter : ConversationPresenter? {get set}
    func loadData()
    func loadMoreData(tableOffset: CGFloat)
    func deleteConversation(item: ConversationDomain, indexPath: IndexPath)
    func filterBy(key: String)
}

class HomeViewController: UIViewController {
    
    // MARK: properties
    var router : HomeRouter?
    
    // MARK: UI Properties
    var currentSearchText : String = ""
    
    
    var conversationListViewController : ConversationListViewController! {
        didSet {
            conversationListViewController.delegate = self
        }
    }
    
    var composeButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.navigation_button_plus, for: .normal)
        button.setImage(UIImage.navigation_button_plus_selected, for: .selected)
        button.sizeToFit()

        button.backgroundColor = UIColor.complementZaloBlue
        return button
    }()
    
    var searchField : UITextField = {
        let textfield = UITextField(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        textfield.placeholder = "search..."
        textfield.textColor = .white

        return textfield
    }()
    
    var xbutton : UIBarButtonItem?
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupTitle()
        setupNavigationBar()
        setupNavigationBarColor()
        setupTableView()
        setupComposeButton()
    }
    
    func setup(interactor : ConversationListInteractor) {
        var inter = interactor
        inter.presenter = conversationListViewController
        conversationListViewController.interactor = inter
    }
    
    // MARK: AutoLayout setups
    private func setupTitle(){
        searchField.delegate = self
        navigationItem.titleView = searchField
    }
    
    func setupNavigationBarColor() {
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .zaloBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

    }
    
    func setupNavigationBar(){
        // two navigation icon: search, user preference menu
        let button = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                                       style: .plain, target: self, action: #selector(searchButtonPressed))
        let xbtn = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: (#selector(cancelSearchPressed)))
        navigationItem.leftBarButtonItem = button
        xbutton = xbtn

    }
    // MARK: Setup Data source
    func setupTableView(){
        
    
        add(conversationListViewController)
        
        guard let tableView = conversationListViewController.tableView else {
            print("No table view?")
            return
        }
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let margin = view.safeAreaLayoutGuide
        
        tableView.leftAnchor.constraint(equalTo: margin.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: margin.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    
    }
    
    func setupComposeButton(){

        view.addSubview(composeButton)

        composeButton.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            composeButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10),
            composeButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20),
            composeButton.heightAnchor.constraint(equalToConstant: 66),
            composeButton.widthAnchor.constraint(equalToConstant: 66),
        ])
        composeButton.layer.cornerRadius = 33
        composeButton.addTarget(self, action: #selector(composeButtonPressed), for: .touchUpInside)

    }
        
    @objc func composeButtonPressed(){
        print("Compose message...")
        router?.showComposeView()
    }

    // MARK: Actions

    
    @objc func cancelSearchPressed(){
        print("cancel")
        clearSearchField()
    }
    @objc func searchButtonPressed(){
//        let searchvc = SearchViewController()
//        navigationController?.pushViewController(searchvc, animated: true)
    }

    // MARK: Navigation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarColor() // reset color, if it accidentally changed for other views
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        }
    
}

// MARK: ConversationListViewDelegate
extension HomeViewController : ConversationListViewDelegate {
    func viewBeginDragging(scrollView: UIScrollView) {
        animateComposeButton(btn: composeButton, scrollView: scrollView)
    }
    
    fileprivate func animateComposeButton(btn composeButton: UIButton, scrollView: UIScrollView){
        var goingUp: Bool
                let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
                /// `Velocity` is 0 when user is not dragging.
                if (velocity == 0){
                    goingUp = scrollView.panGestureRecognizer.translation(in: scrollView).y < 0
                } else {
                    goingUp = velocity < 0
                }
                
                if goingUp && composeButton.alpha > 0 {
                    composeButton.fadeOut(duration: 0.2, delay: 0)
                } else {
                    composeButton.fadeIn(duration: 0.2, delay: 0)
                }
    }
    
}
// MARK: Searching
extension HomeViewController : UITextFieldDelegate {
    fileprivate func clearSearchField() {
        
        searchField.text = ""
        
        conversationListViewController.clearFilter()
                
        navigationItem.rightBarButtonItem = nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let originalText = textField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: string)
            
            //  remove leading and trailing whitespace
            let cleanText = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // only update when it truly changes
            if cleanText != currentSearchText{
                filterItemForSearchKey(cleanText)
            }
        }
        return true
    }
    
    func filterItemForSearchKey(_ key: String){
        self.currentSearchText = key
        if key == ""{
            clearSearchField()
        } else{
            navigationItem.rightBarButtonItem = xbutton
            conversationListViewController.filterBy(key: key)
        }
  }
}

