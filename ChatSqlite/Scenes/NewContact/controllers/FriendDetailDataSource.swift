////
////  FriendDetailDataSource.swift
////  Phonebook
////
////  Created by Nil Nguyen on 9/8/21.
////
//
//import UIKit
//class FriendDetailDataSource : NSObject, UITableViewDataSource {
//    static let identifier = "ContactDetailCell"
//
//    private var friend : Friend?
//
//    public enum FriendDetail: Int, CaseIterable{
//        case avatar
//        case phonenumber
//
//        func displayText(for friend: Friend?) -> String? {
//            switch self {
//            case .phonenumber:
//                return friend?.getPhoneNumber(index: 0)
//            case .avatar:
//                return nil
//            }
//        }
//        var cellIcon: UIImage?{
//            switch self {
//            case .phonenumber:
//                return UIImage(systemName: "phone")
//            case .avatar:
//                return nil
//                }
//            }
//        }
//
//    init(friend: Friend) {
//        self.friend = friend
//        super.init()
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return FriendDetail.allCases.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            // first cell is contact avatar
//            let cell = tableView.dequeueReusableCell(withIdentifier: FriendDetailAvatarCell.identifier, for: indexPath) as! FriendDetailAvatarCell
//
//            if let contact = friend{
//                cell.configure(avatar: contact.avatarData,
//                               fullname: "\(contact.firstName) \(contact.lastName)")
//                return cell
//            } else {
//                return UITableViewCell()
//            }
//        }
//        // other cell is a default cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: FriendDetailDataSource.identifier, for: indexPath)
//        let detail = FriendDetail(rawValue: indexPath.row)
//        cell.textLabel?.text = detail?.displayText(for: self.friend)
//        cell.imageView?.image = detail?.cellIcon
//        return cell
//    }
//}
