//
//  NativeContactAdapter.swift
//  ChatSqlite
//
//  Created by LAP11353 on 05/01/2022.
//

import Foundation

//protocol FriendService{
//    func fetchAllItems(completionHandler: @escaping ([FriendDomain]?, StoreError?) -> Void)
//    func fetchItemWithId(_ id: String, completionHandler : @escaping (FriendDomain?, StoreError?) -> Void)
//    func createItem(_ item: FriendDomain,completionHandler : @escaping (StoreError?) -> Void)
//    func updateItem(_ item: FriendDomain,completionHandler : @escaping (StoreError?) -> Void)
//    func deleteItem(id: String ,completionHandler : @escaping (StoreError?) -> Void)
//}

class NativeContactStoreAdapter : FriendService{
    
    var adaptee : NativeContactStore = NativeContactStore()
    let friendsQueue = DispatchQueue(
        label: "zalo.phonebook.friendList",
        qos: .utility,
        autoreleaseFrequency: .workItem,
        target: nil)
    
    func fetchAllItems(completionHandler: @escaping ([FriendDomain]?, StoreError?) -> Void) {
        friendsQueue.async {
            let friendContacts = self.adaptee.getAllContactsFromNative()
            
            if friendContacts.count > 0 {
                let res : [FriendDomain]  = friendContacts.map { self.toDomain(native: $0)}
                completionHandler(res, nil)
            
            } else {
                completionHandler(nil, .cantFetch("Cant Fetch contact."))
            }
        }
    }
    
    func fetchItemWithId(_ id: String, completionHandler: @escaping (FriendDomain?, StoreError?) -> Void) {

    }
    
    func createItem(_ item: FriendDomain, completionHandler: @escaping (StoreError?) -> Void) {
        friendsQueue.async {
            let contact = self.toNative(domain: item)
            self.adaptee.saveContactToNative(contact, completition: { res in
                if res {
                    completionHandler(nil)
                } else {
                    completionHandler(.cantFetch("Cant fetch native contact."))
                }
            })
            
        }

    }
    
    func updateItem(_ item: FriendDomain, completionHandler: @escaping (StoreError?) -> Void) {
        friendsQueue.async {
            let contact = self.toNative(domain: item)
            self.adaptee.updateNativeContact(contact, completition: { res in
                if res {
                    completionHandler(nil)
                } else {
                    completionHandler(.cantFetch("Cant fetch native contact."))
                }
            })
            
        }

    }
    
    func deleteItem(id: String, completionHandler: @escaping (StoreError?) -> Void) {
        friendsQueue.async {
            guard let contact = self.adaptee.getContactWithId(id) else {
                completionHandler(.cantDelete("Cant find Contact(\(id) to delete."))
                return
            }
            self.adaptee.removeNativeContact(contact, completition: { res in
                if res {
                    completionHandler(nil)
                } else {
                    completionHandler(.cantFetch("Cant fetch native contact."))
                }

            })
            
        }

    }
    
    func toDomain(native : FriendContact) -> FriendDomain{
        var domain = FriendDomain()
        domain.id = native.uid
        domain.name = "\(native.firstName) \(native.lastName)"
        domain.phoneNumber = native.getPhoneNumber(index: 0)
        
        return domain
    }
    
    func toNative(domain: FriendDomain) -> FriendContact{
        var native = FriendContact()
        native.uid = domain.id
        
        let arr  = domain.name.components(separatedBy: .whitespacesAndNewlines)
        if arr.count > 1 {
        native.firstName = arr[0]
        }
        if arr.count > 2 {
        native.firstName = arr[1]
        }

        native.phoneNumbers = [domain.phoneNumber]
        
        return native
    }
    
    
}
