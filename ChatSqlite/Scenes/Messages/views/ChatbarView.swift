//
//  ChatboxView.swift
//  Chat App
//
//  Created by Nil Nguyen on 9/29/21.
//

import UIKit

protocol ChatbarDelegate {
    func messageSubmitted(message: String)
    func adjustHeight(amount : CGFloat)
}
class ChatbarView: UIView {

    var delegate : ChatbarDelegate?
    
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
        button.setImage(UIImage(systemName: "circle.fill"), for: .normal)
        return button
    }()
    
    var separatorLine : UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return line
    }()

    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        setupEmojiButton()
        setupSubmitButton()
        setupTextView()
        setupSeparatorLine()
        
        submitButton.addTarget(self, action: #selector(submitButtonPressed), for: .touchUpInside)
        emojiButton.addTarget(self, action: #selector(selectEmoji), for: .touchUpInside)
        
        textView.delegate = self
    }
    
    func configure(accent: UIColor){
        submitButton.tintColor = accent
    }
    
    func setupTextView(){
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: emojiButton.trailingAnchor, constant: 5),
            textView.trailingAnchor.constraint(equalTo: submitButton.leadingAnchor, constant:  -5),

        ])
    }
    
    func setupSubmitButton(){
        addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            submitButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            submitButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            submitButton.widthAnchor.constraint(equalToConstant: 50),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    func setupEmojiButton(){
        addSubview(emojiButton)
        emojiButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            emojiButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -5),
            emojiButton.widthAnchor.constraint(equalToConstant: 50),
            emojiButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
    func setupSeparatorLine(){
        addSubview(separatorLine)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            separatorLine.topAnchor.constraint(equalTo: topAnchor, constant: 0),
                separatorLine.leadingAnchor.constraint(equalTo: leadingAnchor),
                separatorLine.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.7)
        ])
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    @objc func submitButtonPressed(){
        sendMessage(textView.text)
    }
    
    @objc func selectEmoji(){
        print("emoji")
    }
    
}

extension ChatbarView : UITextViewDelegate{
    fileprivate func sendMessage(_ text: String) {
        if  text != ""{
            ///  remove leading and trailing whitespace
            let cleanValue = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            delegate?.messageSubmitted(message: cleanValue)
            // clear chat bar
            textView.text = ""

            }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let originalText = textView.text {
            
            // Send message
            if text == "\n" {
                // Usual edit message
                let title = (originalText as NSString).replacingCharacters(in: range, with: text)
                sendMessage(title)
                
                // shrink text view if needed
                textView.isScrollEnabled = false
                return false
            }
        }
        
        // Enter message
        /// check if text window's size is increasing
        if textView.frame.height >= 75{
            textView.textContainer.maximumNumberOfLines = 0
            textView.isScrollEnabled = true
        } else {
            textView.isScrollEnabled = false

        }
        delegate?.adjustHeight(amount: textView.frame.height)
        return true

    }
    func textViewDidBeginEditing(_ textView: UITextView) {
    }

}
