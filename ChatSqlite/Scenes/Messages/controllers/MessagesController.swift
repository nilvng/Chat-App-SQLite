//
//  MessengeController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import UIKit
import Alamofire

protocol MessageListInteractor {
    var presenter : MessagesPresenter? {get set}
    
    func fetchData(friend: FriendDomain)
    func fetchData(conversation: ConversationDomain)
    func loadMore(tableOffset: CGFloat)
    func onSendMessage(content: String, newConv: Bool)
    
}
enum AccentColorMode {
    case light
    case dark
}
class MessagesController: UIViewController {
    // MARK: VC properties
    var interactor : MessageListInteractor?
    var dataSource = MessageDataSource()
    
    var conversation : ConversationDomain? {
        didSet{
            theme = conversation?.theme ?? .basic
    }
    }
    
    var isNew : Bool = false
    
    // MARK: UI Properties
    var theme : Theme = .basic
    var mode : AccentColorMode = .light
    var chatTitleLabel : UILabel!
    
    var menuButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.chat_menu, for: .normal)
        return button
    }()
    var tableView : UITableView = {
        let table = UITableView()
        table.separatorStyle = .none
        table.allowsSelection = false
        table.alwaysBounceVertical = false
        
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    var tableInset : CGFloat = 30
    
    var backgroundImageView : UIImageView = {
        let bg = UIImageView()
        bg.contentMode = .scaleAspectFill
        return bg
    }()
    var chatBarView : ChatbarView = {
        return ChatbarView()
    }()
    var chatBarBottomConstraint : NSLayoutConstraint!
    
    // Float bubble
    var floatBubble : UILabel = {
        let view = UILabel(frame: CGRect(x: 160, y: 531, width: 100, height: 30))
        view.backgroundColor = .clear
        view.numberOfLines = 0
        view.lineBreakMode = .byWordWrapping
        view.sizeToFit()
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = .white
        return view
    }()
    
    var bbBgView : UIImageView = {
        let v = UIImageView()
        return v
    }()
    
    // MARK: Init
    init(){
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(friend: FriendDomain){
        interactor?.fetchData(friend: friend)
        self.conversation = ConversationDomain.fromFriend(friend: friend)
    }
    
    func configure(conversation : ConversationDomain){
        self.conversation = conversation
        interactor?.fetchData(conversation: conversation)
    }
    
    // MARK: Setups
    func setup(interactor: MessageListInteractor){
        var inter = interactor
        inter.presenter = self
        self.interactor = inter
    }
    
    func configureTable(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.isUserInteractionEnabled = true
        dataSource.bubbleViewDelegate = self
        
        tableView.addGestureRecognizer(tapGesture)

        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    func setupTableView(){
        
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
                
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
        tableView.contentInset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)

    }
    // MARK: setup float bb
    var bbFlyConstraint : NSLayoutConstraint!
    var bbSnapConstraint : NSLayoutConstraint!
    var bbStretchConstraint : NSLayoutConstraint!
    
    func setupFloatBb(){
        
        view.addSubview(bbBgView)
        view.addSubview(floatBubble)
        
        chatBarView.layoutIfNeeded() // layout chat bar so that we can align text field frame with float bb
        
        floatBubble.isHidden = true
        floatBubble.translatesAutoresizingMaskIntoConstraints = false
        bbFlyConstraint = floatBubble.bottomAnchor.constraint(equalTo: chatBarView.bottomAnchor,
                                                              constant: -BubbleConstant.vPadding)
        
        self.bbSnapConstraint = floatBubble.widthAnchor.constraint(lessThanOrEqualToConstant: BubbleConstant.maxWidth)
        self.bbStretchConstraint = floatBubble.widthAnchor.constraint(
            equalToConstant: (chatBarView.textView.frame.size.width + chatBarView.submitButton.frame.width))
        
        let cs : [NSLayoutConstraint] = [
            bbFlyConstraint,
            bbStretchConstraint,
            floatBubble.trailingAnchor.constraint(equalTo: view.trailingAnchor,
                                                  constant: -BubbleConstant.hPadding),
            floatBubble.heightAnchor.constraint(greaterThanOrEqualToConstant: 25)

        ]
        
        bbBgView.translatesAutoresizingMaskIntoConstraints = false

        let constraints : [NSLayoutConstraint] = [
            bbBgView.topAnchor.constraint(equalTo: floatBubble.topAnchor,
                                          constant: -BubbleConstant.vPadding + BubbleConstant.contentVPadding + 2),
            bbBgView.leadingAnchor.constraint(equalTo: floatBubble.leadingAnchor,
                                              constant: -BubbleConstant.hPadding + BubbleConstant.contentHPadding),
            bbBgView.bottomAnchor.constraint(equalTo:  floatBubble.bottomAnchor,
                                             constant: BubbleConstant.vPadding - BubbleConstant.contentVPadding - 2),
            bbBgView.trailingAnchor.constraint(equalTo: floatBubble.trailingAnchor,
                                               constant: BubbleConstant.hPadding - BubbleConstant.contentHPadding),
        ] // WEIRD
        NSLayoutConstraint.activate(cs)
        NSLayoutConstraint.activate(constraints)
        
        bbBgView.isHidden = true
        bbBgView.image =  BackgroundFactory.shared.getBackground(config: outgoingBubbleConfig)

    }
    
    func setupChatbarView(){

        view.addSubview(chatBarView)
        chatBarView.delegate = self
        chatBarView.translatesAutoresizingMaskIntoConstraints = false

        let margin = view.safeAreaLayoutGuide
        chatBarBottomConstraint = chatBarView.bottomAnchor.constraint(equalTo: margin.bottomAnchor)

        NSLayoutConstraint.activate([
            chatBarView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            chatBarView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            chatBarBottomConstraint!,
            chatBarView.heightAnchor.constraint(lessThanOrEqualToConstant: 140),
            chatBarView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),
            ])
        chatBarView.configure(accent: theme.accentColor)

    }
    func setupObserveKeyboard(){
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardMoving), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardMoving), name: UIResponder.keyboardWillHideNotification, object: nil)
    
}
    func setupNavigationBarColor() {
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.darkGray]
        
        navigationItem.backButtonDisplayMode = .minimal
        navigationController?.navigationBar.tintColor = theme.accentColor
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

    }
    
    func setupTitleLabel(){
        chatTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        chatTitleLabel.textColor  = mode == .light ? UIColor.darkGray : UIColor.white
        chatTitleLabel.font = UIFont.systemFont(ofSize: 19)
        chatTitleLabel.text = conversation?.title

    }
    
    func setupNavigationBar(){
        navigationItem.rightBarButtonItem = nil
        
        navigationItem.titleView = chatTitleLabel
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.chat_menu,
            style: .plain,
            target: self,
            action: #selector(menuButtonPressed))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTitleLabel()
        setupNavigationBar()
        
        configureTable()
        setupObserveKeyboard()
        setupTableView()
        
        setupChatbarView()
        setupFloatBb()
        
        edgesForExtendedLayout = []
        
    }
    // MARK: Navigation
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableInset = chatBarView.frame.height + 5
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarColor()
        //guard let c = conversation else {return}
        //mediator?.fetchData(conversation: c)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = theme.accentColor
        
        NSLog("Csc appeared")

        
        guard dataSource.items.count > 0 else {return}
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unobserveKeyboard()
    }

    func unobserveKeyboard(){
        NotificationCenter.default.removeObserver(self)

    }
    
    // MARK: Actions
    @objc func menuButtonPressed(){
        let menuViewController = ChatMenuController()
        menuViewController.configure(conversation!)
        navigationController?.pushViewController(menuViewController, animated: true)
    }
    
    @objc func handleTap(){
        view.endEditing(true)
    }
    
    func scrollToLastMessage(animated: Bool = true){

        guard !dataSource.isEmpty() else {
            return
        }
        DispatchQueue.main.async {
            let lastindex = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: lastindex, at: .bottom, animated: animated)
        }
    }
 
    var lastPage : Int = 0
    var newMessAnimation : Bool = false
    var outgoingBubbleConfig : BackgroundConfig = {
        let config = BackgroundConfig()
        config.color = .none
        config.corner = [.allCorners]
        config.radius = 13
        return config
    }()
    
    // MARK: Handle keyboard
    @objc func handleKeyboardMoving(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue?, keyboardFrame.cgRectValue.height > 0 else {
            return
        }
        let moveUp = notification.name == UIResponder.keyboardWillShowNotification
        let animateDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        //print("\(keyboardFrame.cgRectValue.height) height - \(tableInset)")
        let scalingValue =  moveUp ? keyboardFrame.cgRectValue.height : 0
        self.chatBarBottomConstraint.constant = moveUp ? -keyboardFrame.cgRectValue.height : 0
        let inset = tableInset

        UIView.animate(withDuration: animateDuration, animations: { [weak self] in
            self?.tableView.contentInset.top = moveUp ? scalingValue + inset : inset
            self?.view.layoutIfNeeded()
        }, completion: {  [self]_ in
            if !dataSource.isEmpty() {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                           at: .bottom, animated: true)
            }
        })

        
    }

}

// MARK: UITableViewDelegate
extension MessagesController : UITableViewDelegate {
    
    // MARK: Scroll events
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        interactor?.loadMore(tableOffset: tableView.contentOffset.y)
        
        // change bubble gradient as scrolling
        let ideaRatio = UIScreen.main.bounds.size.height / 17
        let lag : CGFloat = scrollView.isTracking ? 18 : ideaRatio
        let currentPage = (Int) (scrollView.contentOffset.y / lag)
        
        if (currentPage != lastPage){
            lastPage = currentPage
            self.updatesBubble()
        }
    }
    
    func updatesBubble(givenIndices: [IndexPath]? = nil){
       var indices = givenIndices
        DispatchQueue.main.async {
            if indices == nil {
                indices = self.tableView.indexPathsForVisibleRows
                guard indices != nil else {
                    print("no cell!")
                    return
                }

            }
            
            for i in indices!{
                guard let cell = self.tableView.cellForRow(at: i) as? MessageCell else{
                    //print("no cell for that index")
                    continue
                }
                
                let pos = self.tableView.rectForRow(at: i)
                let relativePos = self.tableView.convert(pos, to: self.tableView.superview)
                
                cell.updateGradient(currentFrame: relativePos, theme: self.theme)
            }
        }
    }
    
    // MARK: Animate Bubble
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // update gradient color of visible bubbles
        updatesBubble(givenIndices: [indexPath])
        
        // sent message? -> animate bubble
        guard newMessAnimation else {return;}
        DispatchQueue.main.async {
            self.animateFloatBb()
        }
        newMessAnimation = false
    }
    
    fileprivate func animateFloatBb() {
        // show float bubble
        self.bbBgView.isHidden = false
        self.floatBubble.isHidden = false

        self.view.layoutIfNeeded()

        // animate float bubble
        
        let bbRect = tableView.convert(tableView.rectForRow(at: IndexPath(row: 0, section: 0)), to: self.view)
        // get gradient color
        self.bbBgView.tintColor = theme.gradientImage.getPixelColor(pos: CGPoint(x:100 , y: bbRect.maxY))
                                                      
        UIView.animate(withDuration: 0.26, delay: 0.02, options: .curveEaseOut, animations: { [weak self] in
            // move to cell
            self?.bbFlyConstraint.constant = bbRect.maxY - (self?.floatBubble.frame.maxY ?? 0) - 13
            // shrink
            self?.bbStretchConstraint.isActive = false
            self?.bbSnapConstraint.isActive = true
            self?.view.layoutIfNeeded()
        }, completion: { c in
            print("done animation")

            self.floatBubble.isHidden = true
            self.bbBgView.isHidden = true
            self.bbSnapConstraint.isActive = false
            self.bbStretchConstraint.isActive = true

            self.bbFlyConstraint.constant = -BubbleConstant.contentVPadding
        })
    }
    
    
}

// MARK: Presenter
extension MessagesController : MessagesPresenter {
    func showInitialItems(_ items: [MessageDomain]?) {
        if items == nil {
            isNew = true
            return
        }
        
        dataSource.setItems(items!)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    func presentMoreItems(_ items: [MessageDomain]?) {
        if items == nil {
            isNew = true
            return
        }
        
        dataSource.appendItems(items!)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func presentNewItem(_ item: MessageDomain) {
        
        dataSource.appendNewItem(item)
        
        newMessAnimation = true

        isNew = false
        
        floatBubble.text = item.content
        
        DispatchQueue.main.async {
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        }
    }
    
    func loadConversation(_ c: ConversationDomain, isNew : Bool){
        
        self.isNew = isNew
        self.conversation = c
        
    }
    
    
}
// MARK: Chatbar Delegate
extension MessagesController : ChatbarDelegate {
    func adjustHeight(amount: CGFloat) {
        if (-tableInset != tableView.contentOffset.y){
            print("scroll table as user typing text")
            DispatchQueue.main.async {
                self.tableView.setContentOffset(CGPoint(x: 0, y: -self.tableInset), animated: true)
            }
        }
    }
    
    func messageSubmitted(message: String) {
        //print("msg submit")
        interactor?.onSendMessage(content: message, newConv: isNew)
        }
}

extension MessagesController : BubbleListViewDelegate {
    func bubbleList(downloadItemOfCell: MessageCell) {
        print(downloadItemOfCell.message)
    }
    
    
}
