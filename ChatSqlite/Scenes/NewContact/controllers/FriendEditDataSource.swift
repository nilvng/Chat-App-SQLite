//
//  FriendEditDataSource.swift
//  Phonebook
//
//  Created by Nil Nguyen on 9/8/21.
//

import UIKit

class FriendEditDataSource : NSObject {
    typealias FriendChangeAction = (FriendDomain) -> Void
    private var changeAction : FriendChangeAction?
    private var deleteAction : FriendChangeAction?

    private var friend : FriendDomain
    
    public enum ContactDetail: Int, CaseIterable{
        case avatar
        case firstname
        case lastname
        case phonenumber
        
        func getCellId() -> String {
            switch self {
            case .avatar:
                return FriendAvatarEditCell.identifier
            case .firstname:
                return FriendTextEditCell.identifier
            case .lastname:
                return FriendTextEditCell.identifier
            case .phonenumber:
                return FriendTextEditCell.identifier
            }
        }
        
    }

    init( friend: FriendDomain, deleteAction: @escaping FriendChangeAction, changeAction: @escaping FriendChangeAction) {
        self.friend = friend
        self.changeAction = changeAction
        self.deleteAction = deleteAction
        super.init()
    }

}
extension FriendEditDataSource : UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // all detail + delete button
        return ContactDetail.allCases.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // for delete button row
        if indexPath.row == ContactDetail.allCases.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: FriendDeleteCell.identifier, for: indexPath) as! FriendDeleteCell
            cell.configure { self.deleteAction?(self.friend) }
            return cell
        }
        
        // for other details
        guard let detail = ContactDetail.init(rawValue: indexPath.row) else {
            fatalError("friend detail is out of range.")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: detail.getCellId(), for: indexPath)
        
        switch detail {
        case .avatar:
            // first cell is contact avatar
            if let avatarCell = cell as? FriendAvatarEditCell{
                
                avatarCell.configure(avatar: friend.avatar, fullname: friend.name)
            }
        case .firstname:
            if let fnameCell = cell as? FriendTextEditCell{
                let firstName = friend.firstName != nil ? friend.firstName! : ""
                fnameCell.configure(with: firstName, placeholder: "First name"){ value in
                    self.friend.firstName = value
                    self.changeAction?(self.friend)
                }
            }
        case .lastname:
            if let lnameCell = cell as? FriendTextEditCell{
                let lastName = friend.lastName != nil ? friend.lastName! : ""
                lnameCell.configure(with: lastName, placeholder: "Last name"){ lastname in
                    self.friend.lastName = lastname
                    self.changeAction?(self.friend)
                }
            }
        case .phonenumber:
            if let phoneNumberCell = cell as? FriendTextEditCell{
                phoneNumberCell.configure(with: self.friend.phoneNumber, placeholder:
                "enter numbers"){ value in
                    self.friend.phoneNumber = value
                    self.changeAction?(self.friend)

                }
            }
        }
        return cell
    }
    
    
}
