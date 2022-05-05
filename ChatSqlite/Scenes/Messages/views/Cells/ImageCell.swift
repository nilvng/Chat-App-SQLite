//
//  ImageCell.swift
//  ChatSqlite
//
//  Created by LAP11353 on 29/03/2022.
//

import UIKit

protocol ImageCellDelegate : AnyObject{
    func didTap(_ cell: ImageCell)
}

class ImageCell : MessageCell {
    static let ID = "PhotoBubbleCell"
    var myImageView : PhotoView = PhotoView()
    var prep : MediaPrep!
    weak var delegate : ImageCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        messageContainerView.addSubview(myImageView)
        setupImageView()
        messageContainerView.clipsToBounds = true
        messageContainerView.layer.cornerRadius = 15
    }
    
    func configure(with im: UIImage){
        myImageView.image = im
    }
    override func configure(with model: MessageDomain, indexPath: IndexPath, isStartMessage isStart: Bool, isEndMessage isEnd: Bool) {
    
        super.configure(with: model, indexPath: indexPath, isStartMessage: isStart, isEndMessage: isEnd)
        
        guard let prep = model.getPrep(index: 0) else {
            print("Cant display image: \(message.content)")
            return
        }
        
        self.prep = prep
        let bgColor = model.getPrepColor(i: 0)
        myImageView.load(filename: prep.imageID, folder: model.cid, type: .thumbnail, backgroundColor: bgColor)
    }
    
    func reloadData(){
        guard let prep = message.getPrep(index: 0) else {
            print("Cant display image: \(message.content)")
            return
        }
        let bgColor = message.getPrepColor(i: 0)
        myImageView.load(filename: prep.imageID, folder: message.cid, type: .thumbnail, backgroundColor: bgColor)
    }
    
    func configure(urlString: String){
        guard let url = URL(string: urlString) else {
            print("\(self) Error: invalid image URL")
            return
        }
        myImageView.af.setImage(withURL: url)
    }
    
    func setupImageView(){
        myImageView.addConstraints(top: messageContainerView.topAnchor,
                                   leading: messageContainerView.leadingAnchor, bottom: messageContainerView.bottomAnchor,
                                   trailing: messageContainerView.trailingAnchor)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        messageContainerView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(sender: UIGestureRecognizer){
        delegate?.didTap(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        myImageView.image = nil
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        self.layoutIfNeeded()
        let width = bubbleWidth
        let height = bubbleWidth * CGFloat(prep.height) / CGFloat(prep.width)
        return CGSize(width: width, height: height)
    }
    
}
