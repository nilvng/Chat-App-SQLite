//
//  ImageCell.swift
//  ChatSqlite
//
//  Created by LAP11353 on 29/03/2022.
//

import UIKit

class ImageCell : UITableViewCell {
    static let ID = "PhotoBubbleCell"
    var myImageView = UIImageView()


    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupImageView()

    }
    
    func configure(with im: UIImage){
        myImageView.image = im
    }
    func configure(with message: MessageDomain){
        guard let u = message.getImageURL(index: 0) else {
            print("Cant display image: \(message.content)")
            return
        }
        DispatchQueue.global().async {
            
            if let data = try? Data(contentsOf: u) {
                DispatchQueue.main.async {
                    
                    self.myImageView.image = UIImage(data: data)
                }
                
            } else {
                print("Failed find image data.")
            }
        }
    }
    
    func configure(urlString: String){
        guard let url = URL(string: urlString) else {
            print("\(self) Error: invalid image URL")
            return
        }
        myImageView.af.setImage(withURL: url)
    }
    
    func setupImageView(){
        contentView.addSubview(myImageView)
        myImageView.contentMode = .scaleToFill
//        myImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 160).isActive = true
        myImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        myImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 130).isActive = true

        myImageView.addConstraints(top: contentView.topAnchor,
                                   bottom: contentView.bottomAnchor,
                                   trailing: contentView.trailingAnchor,
                                   topConstant: 5  , rightConstant: 20)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        myImageView.image = nil
    }
    
}
