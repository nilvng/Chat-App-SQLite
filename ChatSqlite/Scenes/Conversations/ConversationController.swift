//
//  ViewController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import UIKit

protocol ConversationsDisplayLogic {
    func fetchData()
    func addItem(_ conversation : ConversationDomain)
    func onScroll(tableOffset: CGFloat)
}

class ConversationController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: UI Properties
    var currentSearchText : String = ""
    
    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.rowHeight = 86
        return table
    }()
    
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
    
    lazy var blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    // MARK: VC properties
    var interactor : ConversationsDisplayLogic?
    var dataSource  = ConversationDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setup()
        setupTitle()
        setupNavigationBar()
        setupTableView()
        setupComposeButton()
        setupLongPressGesture()
    }
    
    func setup() {
        let service = ConversationStoreProxy.shared
        let inter = ConversationInteractor(store: service)
        inter.presenter = self
        interactor = inter
        }
    // MARK: AutoLayout setups
    private func setupTitle(){
        searchField.delegate = self
        navigationItem.titleView = searchField
        
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
        
        view.addSubview(tableView)
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.identifier)
        
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
        let cmc = FriendsController()
        self.present(cmc, animated: true, completion: nil)
    }

    // MARK: Actions
    fileprivate func clearSearchField() {
        searchField.text = ""
        dataSource.clearSearch()
        tableView.reloadData()
        navigationItem.rightBarButtonItem = nil
    }
    
    @objc func cancelSearchPressed(){
        print("cancel")
        clearSearchField()
    }
    @objc func searchButtonPressed(){
//        let searchvc = SearchViewController()
//        navigationController?.pushViewController(searchvc, animated: true)
    }
    
    func setupLongPressGesture(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 1.0 // 1 second press
        longPress.delegate = self
        tableView.addGestureRecognizer(longPress)

    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .began {
//            let touchPoint = gestureRecognizer.location(in: self.tableView)
//            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
//                print("Long press row: \(indexPath.row)")
//                let configView = ConvConfigController()
//                configView.configure {
//                    let itemToDelete = self.dataSource.items[indexPath.row]
//                    ChatManager.shared.deleteChat(itemToDelete)
//                }
//                configView.modalPresentationStyle = UIModalPresentationStyle.custom
//                configView.transitioningDelegate = self
//                self.present(configView, animated: true, completion: nil)
//            }
        }
    }
    

    // MARK: Navigation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor?.fetchData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         
        navigationController?.navigationBar.barStyle = .black
        }
    
}

// MARK: tableDelegate
extension ConversationController : UITableViewDelegate {

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = MessagesController()
        let c = dataSource.getItem(ip: indexPath)
        controller.configure(conversation: c)
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        interactor?.onScroll(tableOffset: tableView.contentOffset.y)
    }
    
    // MARK: Animate Compose btn
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
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

// MARK: Presenter
extension ConversationController : ConversationPresenter{
    func presentNewItems(_ item: ConversationDomain) {
        
        print("present new conv tbd")
        //self.dataSource.appendItems([item])
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        
        }
    }
    
    func presentAllItems(_ items: [ConversationDomain]?) {
        
        if items == nil {
            return
        }
        
        self.dataSource.loadItems(items!)
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
        
        }
    }
    
}
// MARK: Searching
extension ConversationController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let originalText = textField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: string)
            
            //  remove leading and trailing whitespace
            let cleanText = title.trimmingCharacters(in: .whitespacesAndNewlines)
            
            print("search \(cleanText)")
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
            dataSource.filterItemBy(key: key)
            navigationItem.rightBarButtonItem = xbutton
        }
        tableView.reloadData()
  }
}
