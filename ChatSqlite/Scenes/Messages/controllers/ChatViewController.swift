//
//  MessengeController.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import UIKit
import Alamofire
import PhotosUI

protocol MessageListInteractor {
    
    func setSelectedFriend(friend: FriendDomain)
    func loadData()
    func loadMore(tableOffset: CGFloat)
    func onSendMessage(content: String, conversation: ConversationDomain)
    func onSendMessage(m: MessageDomain)
    func sendSeenStatus()
    func doneSelectLocalMedia(_ asset: [PHAsset])
}


enum AccentColorMode {
    case light
    case dark
}
class ChatViewController: UIViewController {
    // MARK: VC properties
    var interactor : MessageListInteractor?
    var router : ChatRouter?
    
    var conversation : ConversationDomain! {
        didSet{
            theme = conversation?.theme ?? .basic
            DispatchQueue.main.async {
                self.chatTitleLabel.text = self.conversation?.title ?? ""
                self.messageListView.setBubbleTheme(theme: self.theme)
                self.view.layoutIfNeeded()
            }
        }
    }
        
    // MARK: UI Properties
    var theme : Theme = .basic
    var mode : AccentColorMode = .light
    lazy var chatTitleLabel : UILabel = {
        let chatTitleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 50))
        chatTitleLabel.textColor  = mode == .light ? UIColor.darkGray : UIColor.white
        chatTitleLabel.font = UIFont.systemFont(ofSize: 19)
        chatTitleLabel.text = "New Friend"
        return chatTitleLabel
    }()
    
    var menuButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.chat_menu, for: .normal)
        return button
    }()
    var messageListView : MessageListViewController!
    
    var tableInset : CGFloat = 35
    
    var backgroundImageView : UIImageView = {
        let bg = UIImageView()
        bg.contentMode = .scaleAspectFill
        return bg
    }()
    var chatBarView : ChatbarViewController!
    
    var chatBarBottomConstraint : NSLayoutConstraint!
    
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
    deinit{
        print("\(self) deinit.")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(friend: FriendDomain) {
        chatTitleLabel.text = friend.name
        conversation = ConversationDomain.fromFriend(friend: friend)
    }
    
    // MARK: Setups
    
    func setupTableView(){
        
        add(messageListView)
        guard let tableView = messageListView.tableView else {
            print("No table view?")
            return
        }

        tableView.translatesAutoresizingMaskIntoConstraints = false
                
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
        tableView.contentInset = UIEdgeInsets(top: tableInset, left: 0, bottom: 0, right: 0)

    }
    // MARK: setup float bb
    var bbFlyConstraint : NSLayoutConstraint!
    var bbSnapConstraint : NSLayoutConstraint!
    var bbStretchConstraint : NSLayoutConstraint!
    
    func setupFloatBb(){
        
        view.addSubview(bbBgView)
        view.addSubview(floatBubble)
        
//        chatBarView.layoutIfNeeded() // layout chat bar so that we can align text field frame with float bb
        
        floatBubble.isHidden = true
        floatBubble.translatesAutoresizingMaskIntoConstraints = false
        bbFlyConstraint = floatBubble.bottomAnchor.constraint(equalTo: chatBarView.view.bottomAnchor,
                                                              constant: -BubbleConstant.vPadding)
        
        self.bbSnapConstraint = floatBubble.widthAnchor.constraint(lessThanOrEqualToConstant: BubbleConstant.maxWidth)
        self.bbStretchConstraint = floatBubble.widthAnchor.constraint(
            equalToConstant: 270)
        
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

        add(chatBarView)
        chatBarView.delegate = self
        
        guard let barView = chatBarView.view else {
            print("No table view?")
            return
        }
        barView.translatesAutoresizingMaskIntoConstraints = false

        let margin = view.safeAreaLayoutGuide
        chatBarBottomConstraint = barView.bottomAnchor.constraint(equalTo: margin.bottomAnchor)

        NSLayoutConstraint.activate([
            barView.leadingAnchor.constraint(equalTo: margin.leadingAnchor),
            barView.trailingAnchor.constraint(equalTo: margin.trailingAnchor),
            chatBarBottomConstraint!,
            barView.heightAnchor.constraint(lessThanOrEqualToConstant: 140),
            barView.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),
            ])
        chatBarView.configure(accent: theme.accentColor)

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
    
    func setupNavigationBar(){
        navigationItem.rightBarButtonItem = nil
        
        navigationItem.titleView = chatTitleLabel
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.chat_menu,
            style: .plain,
            target: self,
            action: #selector(menuButtonPressed))
    }
    
    // MARK: Navigation
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        
        setupTableView()
        
        setupChatbarView()
        setupFloatBb()
        
        edgesForExtendedLayout = []
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarColor()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = theme.accentColor
    }
    
    // MARK: Actions
    @objc func menuButtonPressed(){
        guard let c = conversation else {
            return
        }
        router?.toMenuScreen(conversation: c)
    }
    
    @objc func handleTap(){
        view.endEditing(true)
    }
 
    var newMessAnimation : Bool = false
    
    var outgoingBubbleConfig : BackgroundConfig = {
        let config = BackgroundConfig()
        config.color = .none
        config.corner = [.allCorners]
        config.radius = 13
        return config
    }()

}

// MARK: Animate Bubble

extension ChatViewController {
    
    func animateBubble(toRect bbRect: CGRect){
        guard newMessAnimation else {return;}
        DispatchQueue.main.async {
            self.animateFloatBb(toRect: bbRect)
        }
        newMessAnimation = false
    }
    
    fileprivate func animateFloatBb(toRect bbRect: CGRect) {
        // show float bubble
        self.bbBgView.isHidden = false
        self.floatBubble.isHidden = false

        self.view.layoutIfNeeded()

        // get gradient color for float bubble
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
        })//
    }
    
    
}

// MARK: Chatbar Delegate
extension ChatViewController : ChatbarDelegate {
    func photoIconSelected() {
        router?.toPhotoGallery()
//        configurePHPicker()
    }
    
    func configurePHPicker(){
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        config.filter = .images
        let view = PHPickerViewController(configuration: config)
        view.delegate = self
        present(view, animated: true)
    }
    
    func moveUp(constant: Double, duration: Double) {
        chatBarBottomConstraint.constant = constant
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.messageListView.tableView.contentInset.top = -constant + self!.tableInset
            self?.view.layoutIfNeeded()
        }, completion: {  [weak self]_ in
            self?.messageListView.scrollToLastMessage()
        })
    }
    
    func adjustHeight(amount: CGFloat) {
    }
    
    func messageSubmitted(message: String) {

        interactor?.onSendMessage(content: message, conversation: conversation)
        }
}

// MARK: PHPicker
extension ChatViewController : PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        var providers = [NSItemProvider]()
        providers = results.map(\.itemProvider)
        let m = MessageDomain(cid: conversation.id, content: "New photos", type: .image, status: .sent)
//            getPhoto(from: providers, completion: { ims in
//                m.images = ims
//                self.interactor?.onSendMessage(m: m)
//            })
        getPhotoURLs(from: providers, completion: { urls in
            m.encodeImageUrls(urls)
            self.interactor?.onSendMessage(m: m)
        })
        dismiss(animated: true, completion: nil)
    }

    private func getPhoto(from itemProviders: [NSItemProvider], completion: @escaping ([UIImage]) -> Void) {
        var locals : [UIImage] = []
        itemProviders.forEach { itemProvider in
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
         
                    if let image = object as? UIImage {
                        locals.append(image)
                        if locals.count == itemProviders.count {
                            completion(locals)
                        }
                    }
                }
            }
        }
    
        }
    
    private func getPhotoURLs(from itemProviders: [NSItemProvider], completion: @escaping ([String]) -> Void) {
        var locals : [String] = []
        itemProviders.forEach { itemProvider in
            guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
                  let utType = UTType(typeIdentifier)
            else { return }
            itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                guard let url = url else { return }
                
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent) else { return }
                
                do {
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        try FileManager.default.removeItem(at: targetURL)
                    }
                    
                    try FileManager.default.copyItem(at: url, to: targetURL)
                    locals.append(targetURL.lastPathComponent)
                    if locals.count == itemProviders.count {
                        completion(locals)
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }

}

// MARK: MessageListDelegate
extension ChatViewController : MessageListViewDelegate {
    func onConversationChanged(conversation: ConversationDomain) {
        self.conversation = conversation
        //chatTitleLabel.text = conversation.title
    }
    
    func messageWillDisplay(tableView: UITableView) {

    }
    
    func textMessageIsSent(content: String, inTable tableView: UITableView) {
        configureFloatBubble(content: content)
        let bbRect = tableView.convert(tableView.rectForRow(at: IndexPath(row: 0, section: 0)), to: self.view)
        animateBubble(toRect: bbRect)
    }
    
    fileprivate func configureFloatBubble(content: String){
        newMessAnimation = true
        floatBubble.text = content
    }
    
}
