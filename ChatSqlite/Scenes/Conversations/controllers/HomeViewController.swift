//
//  ViewController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 16/12/2021.
//

import UIKit
import AlamofireImage
protocol ConversationListInteractor {
    func loadData()
    func loadMoreData(tableOffset: CGFloat)
    func deleteConversation(item: ConversationDomain, indexPath: IndexPath)
    func filterBy(key: String)
    func selectConversation(_ c: ConversationDomain)
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
        let btn = PostButton()
        btn.setImage(UIImage.navigation_button_plus, for: .normal)
        btn.setImage(UIImage.navigation_button_plus_selected, for: .selected)
        btn.setBackgroundImage(UIImage.bg_yellow_gradient, for: .normal)
        return btn
    }()
    
    var postButton : UIButton = {
        let btn = PostButton()
        btn.setImage(UIImage.navigation_search, for: .normal)
        btn.setImage(UIImage.navigation_search_selected, for: .selected)
        btn.setBackgroundImage(UIImage.bg_yellow_gradient, for: .normal)
        return btn
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
        setupBlurEffectView()
        printUID()
        observeNetworkChanges()
        setupTapDismissGesture()
        setupPostButton()
        setupComposeButton()
        postButton.isHidden = true
        addLongPressGesture()
    }
    
    func printUID(){
        print(UserSettings.shared.getUserID() ?? "No ID")
    }
    
    func setup(interactor : ConversationListInteractor) {
        var inter = interactor
        //inter.presenter = conversationListViewController
        conversationListViewController.interactor = inter
    }
    
    // MARK: AutoLayout setups
    private func setupTitle(){
        searchField.delegate = self
        navigationItem.titleView = searchField
    }
    
    func setupNavigationBarColor() {
        
        let appearance = UINavigationBarAppearance()
        //appearance.backgroundColor = .zaloBlue
        appearance.backgroundImage = UIImage(named: "gradient-pink-image")
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
    let blurEffectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        effectView.alpha = 0.3
        return effectView
    }()
    
    func setupBlurEffectView(){
        view.addSubview(blurEffectView)
        blurEffectView.isHidden = true
    }
    
    func setupTapDismissGesture(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissComposeOptions))
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGesture)
    }
    
    func setupComposeButton(){

        view.addSubview(composeButton)

        composeButton.translatesAutoresizingMaskIntoConstraints = false
        let margins = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            composeButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -10),
            composeButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -20),
            composeButton.heightAnchor.constraint(equalToConstant: 60),
            composeButton.widthAnchor.constraint(equalToConstant: 60),
        ])
        composeButton.addTarget(self, action: #selector(composeButtonPressed), for: .touchUpInside)

    }
    
    func setupPostButton(){
        view.addSubview(composeButton)
        view.addSubview(postButton)

        postButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            postButton.centerXAnchor.constraint(equalTo: composeButton.centerXAnchor),
            postButton.centerYAnchor.constraint(equalTo: composeButton.centerYAnchor),
            postButton.heightAnchor.constraint(equalToConstant: 50),
            postButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        postButton.addTarget(self, action: #selector(postButtonPressed), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurEffectView.frame = view.bounds
    }


    // MARK: Actions

    var composeStateOne : Bool = true
    
    @objc func cancelSearchPressed(){
        print("cancel")
        clearSearchField()
    }
    
    // MARK: Blur effect
    fileprivate func toggleBlurEffect() {
        let maxAlpha = 0.3
        let duration = 0.05
        let willShow = !blurEffectView.isHidden
        let beforeAlpha = blurEffectView.isHidden ? 0 : maxAlpha
        let afterAlpha = blurEffectView.isHidden ? maxAlpha : 0
        
        blurEffectView.isHidden = true
        
        blurEffectView.alpha = beforeAlpha
        UIView.animate(withDuration: duration, animations: {
            self.blurEffectView.alpha = afterAlpha
        })
        
        blurEffectView.isHidden = willShow
    }
    
    @objc func dismissComposeOptions(){
        toggleSlideOptions(forceAppeared: false)
//        toggleBlurEffect()
//        postButton.isHidden = true
//        composeButton.flash { [weak self] in
//            self?.composeButton.setImage(UIImage.navigation_button_plus, for: .normal)
//        }
    }
    
    @objc func composeButtonPressed(){
        print("Compose message...")
        composeStateOne = !composeStateOne

        router?.showComposeView()
    }
    
    @objc func postButtonPressed(){
        print("Post new group...")
    }
    
    func addLongPressGesture(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPress.minimumPressDuration = 0.5
        self.composeButton.addGestureRecognizer(longPress)
    }
    func addSinglePressGesture(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPress.minimumPressDuration = 0.75
        self.composeButton.addGestureRecognizer(longPress)
    }
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        if !postButton.isHidden {
            return
        }
        if gesture.state == UIGestureRecognizer.State.began {
            toggleSlideOptions(forceAppeared: true)
        }
    }
    
    func toggleSlideOptions(forceAppeared: Bool? = nil){
        let willShow = forceAppeared ?? false ? forceAppeared! : postButton.isHidden
        if willShow {
            toggleBlurEffect()
            postButton.appearToTop(withDuration: 0.5, offset: 60)
        } else {
            toggleBlurEffect()
            postButton.disappearToBottom(withDuration: 0.5, offset: 60)
        }
    }
    
    func animateRotateCompose(){
        composeButton.rotate(degree: Double.pi / 2, duration: 0.1)
        composeButton.flash { [weak self] in
            self?.composeButton.setImage(UIImage.back_button, for: .normal)
        }
    }
    
    @objc func searchButtonPressed(){
        promptForAnswer()
    }
    
    func promptForAnswer(){
        let ac = UIAlertController(title: "Setting User Name", message: "Enter name your friend can use to contact you", preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        let submitAction = UIAlertAction(title: "Submit", style: .cancel, handler: { [unowned ac] _ in
            guard let answer = ac.textFields![0].text, answer != "" else {
                return
            }
            UserSettings.shared.setUserID(uid: answer)
        })
        let closeAction = UIAlertAction(title: "Close", style: .default, handler: nil)
        ac.addAction(closeAction)
        ac.addAction(submitAction)
        present(ac,animated: true)
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

extension HomeViewController {
    func observeNetworkChanges(){
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.networkChanged),
            name: .networkChanged,
            object: nil)
    }
    
    @objc func networkChanged(noti : NSNotification){
        guard let data = noti.userInfo, let msg = data["msg"] as? String else{
            print("Doesn't received any message when network changed?")
            return
        }
        let ac = UIAlertController(title: "Connection Warning", message: msg, preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        ac.addAction(submitAction)
        present(ac,animated: true)
    }
}
