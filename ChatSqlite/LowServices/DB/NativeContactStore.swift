//
//  NativeContactService.swift
//  ChatSqlite
//
//  Created by LAP11353 on 05/01/2022.
//

import Foundation
import Contacts


struct FriendContact{
    
    var uid : String
    var firstName: String
    var lastName: String
    var phoneNumbers: [String]
    var avatarData: Data?

    var source: CNContact? {
        didSet{
            // uid and avatar have to comply native source
            guard let s = source else { return }
            self.uid = s.identifier
            if let photoData = s.imageData {
                self.avatarData = photoData
            }
        }
    }

    init() {
        uid = UUID().uuidString
        firstName = ""
        lastName = ""
        phoneNumbers = []
    }
    
    init(firstName: String, lastName: String, phoneNumbers: [String]){
        self.uid = UUID().uuidString
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumbers = phoneNumbers

    }
    
    func getPhoneNumber(index: Int) -> String{
        guard index > -1 else {
            print("Warning: access phone number out of range.")
            return ""
        }
        guard  phoneNumbers.count > index else {
            return ""
        }
        return phoneNumbers[index]
    }
    
    mutating func setPhoneNumber(_ value :String ,at index: Int) {
        if phoneNumbers.count <= index {
            phoneNumbers.append(value)
        } else {
            phoneNumbers[index] = value
        }
    }
}

extension FriendContact{
        
    init(contact: CNContact) {
        self.init()
        self.uid            = contact.identifier
        self.firstName      = contact.givenName
        self.lastName       = contact.familyName
        self.source         = contact
        self.avatarData     = contact.imageData
        self.phoneNumbers   = contact.phoneNumbers.compactMap { $0.value.stringValue}
    }

    
    func toCNContact() -> CNContact {
        if let storedContact = source{
            return storedContact
        }
        // in case when there a contact is not in native App
        return toMutableContact() as CNContact
    }
    
    func toMutableContact() -> CNMutableContact {
        let contactObj : CNMutableContact
        if let source = source {
            contactObj = source.mutableCopy() as! CNMutableContact
        } else{
            contactObj = CNMutableContact()
        }

        contactObj.givenName = firstName
        contactObj.familyName = lastName

        contactObj.phoneNumbers = phoneNumbers.map {
            return CNLabeledValue(label: CNLabelPhoneNumberMain, value: CNPhoneNumber(stringValue: $0))}
        return contactObj

    }
}

extension FriendContact : Equatable {
    static func == (lhs: FriendContact, rhs: FriendContact) -> Bool {
        return lhs.uid == rhs.uid &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.phoneNumbers == rhs.phoneNumbers &&
            lhs.source == rhs.source
    }
    
    static func != (lhs: FriendContact, rhs: CNContact) -> Bool {
        return !(lhs.uid == rhs.identifier &&
            lhs.firstName == rhs.givenName &&
            lhs.lastName == rhs.familyName &&
            lhs.phoneNumbers == rhs.phoneNumbers.compactMap { $0.value.stringValue})
    }
}

extension FriendContact : CustomStringConvertible {
    var description: String{
        "\(uid); \(firstName) \(lastName); \(phoneNumbers)"
    }
}


class NativeContactStore{
    private let nativeStore = CNContactStore()
    private var isAuthorized = {
        CNContactStore.authorizationStatus(for: .contacts) == .authorized
    }()

    func getAllContactsFromNative()-> [FriendContact]{
        // fetching all contacts from the Contacts.app
        var contacts: [CNContact] = []
        let keysToFetch : [CNKeyDescriptor] = [CNContactIdentifierKey,CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey, CNContactImageDataKey] as [CNKeyDescriptor]
        //keysToFetch += [CNContactViewController.descriptorForRequiredKeys()]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
        do {
            try self.nativeStore.enumerateContacts(with: fetchRequest, usingBlock: {(contact, stopPointer) in
                contacts.append(contact)
            })
        } catch let err {
            print("Failed to fetch contacts: ",err)
        }
        let res = contacts.map { FriendContact(contact: $0) }
        //print("CNStore: \(res)")
        return res
    }
    
    func saveContactToNative(_ contact: FriendContact, completition: @escaping (Bool) -> Void) {
        guard isAuthorized else {
            completition(false)
            return
        }
        do{
            let request = CNSaveRequest()
            request.add(contact.toMutableContact(), toContainerWithIdentifier: nil)
            try self.nativeStore.execute(request)
            completition(true)
        }catch let err{
            print("Failed to save contact in Contacts native app: ",err)
            completition(false)
        }
    }
    
    func removeNativeContact(_ contact: FriendContact, completition: @escaping (Bool) -> Void) {
        guard isAuthorized else {
            completition(false)
            return
        }
        let mutableContact = contact.toMutableContact()
            do{
                let request = CNSaveRequest()
                request.delete(mutableContact)
                try self.nativeStore.execute(request)
                completition(true)
            }catch let err{
                print("Failed to delete contact in Contacts native app: ",err)
                completition(false)
            }
    }
    
    func updateNativeContact(_ contact: FriendContact, completition: @escaping (Bool) -> Void) {
        guard isAuthorized else {
            completition(false)
            return
        }
        do{
            let request = CNSaveRequest()
            request.update(contact.toMutableContact())
            try self.nativeStore.execute(request)
            completition(true)
        }catch let err{
            print("Failed to update contact in Contacts native app: ",err)
            completition(false)
        }
    }
    
    func getContactWithId(_ id: String) -> FriendContact?{
        guard isAuthorized else {
            return nil
        }
        let predicate = CNContact.predicateForContacts(withIdentifiers: [id])
        let toFetch : [CNKeyDescriptor] = [CNContactIdentifierKey,CNContactGivenNameKey,CNContactFamilyNameKey,CNContactPhoneNumbersKey, CNContactImageDataKey] as [CNKeyDescriptor]

        do {
        let contacts = try nativeStore.unifiedContacts(matching: predicate,keysToFetch: toFetch)
            guard contacts.count > 0 else {
                return nil
            }
            
            return FriendContact(contact: contacts.first!)
            
        } catch let e {
            print(e.localizedDescription)
        }
        return nil
    }
}

enum FetchError: Error {
    case unauthorized
    case failed
}


