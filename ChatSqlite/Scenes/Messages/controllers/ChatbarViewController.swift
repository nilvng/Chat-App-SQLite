//
//  ChatboxView.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/29/21.
//

import UIKit

protocol ChatbarDelegate : AnyObject{
    func photoIconSelected()
    func messageSubmitted(message: String)
    func adjustHeight(amount : CGFloat)
    func moveUp(constant: Double, duration: Double)
}
class ChatbarViewController: UIViewController {

    weak var delegate : ChatbarDelegate?
    
    var textView : UITextView = {
        let tview = UITextView()
        tview.isScrollEnabled = true
        tview.contentInsetAdjustmentBehavior = .never
        tview.backgroundColor = .white
        tview.font = UIFont(name: "Arial", size: 16)
        return tview
    }()
    
    var submitButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage.btn_send_forboy, for: .normal)
        button.setImage(.btn_send_forboy_disabled, for: .disabled)

        return button
    }()
    private var emojiButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        return button
    }()
    
    var separatorLine : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return line
    }()

    deinit{
        print("\(self) deinit.")
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupEmojiButton()
        setupSubmitButton()
        setupTextView()
        setupSeparatorLine()
        
        setupObserveKeyboard()
        
        submitButton.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        emojiButton.addTarget(self, action: #selector(selectEmoji), for: .touchUpInside)
        
        textView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unobserveKeyboard()
    }
    
    func configure(accent: UIColor){
        submitButton.tintColor = accent
    }
    
    func unobserveKeyboard(){
        NotificationCenter.default.removeObserver(self)

    }
    
    var padding : CGFloat = 3
    
    func setupTextView(){
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            textView.leadingAnchor.constraint(equalTo: emojiButton.trailingAnchor, constant: padding),
            textView.trailingAnchor.constraint(equalTo: submitButton.leadingAnchor, constant:  -padding),

        ])
    }
    
    func setupSubmitButton(){
        view.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: view.topAnchor),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            submitButton.widthAnchor.constraint(equalToConstant: 50),
            submitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    func setupEmojiButton(){
        view.addSubview(emojiButton)
        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiButton.topAnchor.constraint(equalTo: view.topAnchor),
            emojiButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -padding),
            emojiButton.widthAnchor.constraint(equalToConstant: 50),
            emojiButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    func setupSeparatorLine(){
        view.addSubview(separatorLine)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separatorLine.topAnchor.constraint(equalTo: view.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.7)
        ])
    }


    @objc func submitButtonPressed(){
        sendMessage(textView.text)
        textView.text = ""
    }
    
    @objc func selectEmoji(){
        print("emoji")
        delegate?.photoIconSelected()
    }
    
    func setupObserveKeyboard(){
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardMoving), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardMoving), name: UIResponder.keyboardWillHideNotification, object: nil)
    
    }
    @objc func handleKeyboardMoving(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue?, keyboardFrame.cgRectValue.height > 0 else {
            return
        }
        let moveUp = notification.name == UIResponder.keyboardWillShowNotification
        let animateDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let constant = moveUp ? -keyboardFrame.cgRectValue.height : 0
        
        delegate?.moveUp(constant: constant, duration: animateDuration)
    }
}

extension ChatbarViewController : UITextViewDelegate{
    fileprivate func sendMessage(_ text: String) {
        if  text != ""{
            delegate?.messageSubmitted(message: text)
            }
    }
    
    fileprivate func typeEnter(_ originalText: String, _ range: NSRange, _ text: String, _ textView: UITextView) -> Bool {
        // Usual edit message
        let title = (originalText as NSString)
            .replacingCharacters(in: range, with: text)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        sendMessage(title)
        
        // shrink text view after sending message
        textView.isScrollEnabled = false
        textView.text = ""
        return false
    }
    
    fileprivate func adjustTextFieldScrollabilty(_ textView: UITextView) {
        // Enter message
        /// check if text window's size is increasing
        if textView.frame.height >= 75{
            textView.textContainer.maximumNumberOfLines = 0
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false
            
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let originalText = textView.text else {
            return true
        }
        // Send message
        if text == "\n" {
            return typeEnter(originalText, range, text, textView)
        }
        
        // Continue to type message
        adjustTextFieldScrollabilty(textView)
        delegate?.adjustHeight(amount: textView.frame.height)
        return true

    }

}
