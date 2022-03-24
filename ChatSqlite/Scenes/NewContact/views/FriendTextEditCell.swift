//
//  FriendDetailCell.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/2/21.
//

import UIKit


class FriendTextEditCell: UITableViewCell {
    typealias TitleChangeAction = (String) -> Void
    private var titleChangeAction: TitleChangeAction?

    static let identifier = "TextEditCell"

    private let textfield = UITextField()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textfield)
        textfield.delegate = self
        
    }
    func configure(with text: String,
                   placeholder: String,
                   onlyNumber: Bool = false,
                   changeAction: @escaping TitleChangeAction){
        
        textfield.placeholder = placeholder
        textfield.text = text
        textfield.keyboardType = onlyNumber ? .asciiCapableNumberPad : .alphabet
        self.titleChangeAction = changeAction
        
        // for UI Test
        textfield.accessibilityIdentifier = "edit-\(placeholder)"
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        setupTextfield()
    }
    private func setupTextfield(){
        textfield.layer.cornerRadius = 10
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.backgroundColor = .white
        textfield.isUserInteractionEnabled = true
    
        textfield.anchor(top: topAnchor, leading: leftAnchor, bottom: nil, trailing: nil, padding: .init(top: 7, left: 7, bottom: 3, right: 7), size: .init(width: contentView.frame.width-14, height: contentView.frame.height - 10))

    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension FriendTextEditCell : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let originalText = textField.text {
            let title = (originalText as NSString).replacingCharacters(in: range, with: string)
            
            //  remove leading and trailing whitespace
            let cleanValue = title.trimmingCharacters(in: .whitespacesAndNewlines)
                        
            // only update when it truly changes
            if cleanValue != originalText{
                titleChangeAction?(cleanValue)
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfield.text = textfield.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        textfield.resignFirstResponder()
        return true
    }
}

