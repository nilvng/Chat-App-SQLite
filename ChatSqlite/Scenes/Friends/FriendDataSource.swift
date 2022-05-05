//
//  FriendDataSource.swift
//  ChatSqlite
//
//  Created by LAP11353 on 31/12/2021.
//

import Foundation
import UIKit

enum SectionType{
    case contacts
    case options
}

protocol Searchable {
    func getKeyword() -> String
}

enum OtherOptionsTitle : String {
    case newContact = "New Contact"
    case newFriend = "New Friend (enter ID)"
}

struct OtherOptions : Searchable {
    func getKeyword() -> String{
        return title.rawValue
    }
    
    var title : OtherOptionsTitle
    var image : UIImage?
}

struct Section {
    let letter : String?
    let items : [Searchable]
    var type : SectionType = .contacts
}

class FriendDataSource : NSObject {
    private var filteredItems : [FriendDomain] = []
    
    var items: [FriendDomain] = [] {
        didSet {
            filteredItems = items
        }
    }
    var sections = [Section]()

    // MARK: Indexed data source
    
    private func setupOtherOption(){
        // options like New contact, Create group chat etc
        var options = [OtherOptions]()
        options.append(OtherOptions(title: .newContact, image: UIImage.new_contact))
        options.append(OtherOptions(title: .newFriend, image: UIImage.new_group_chat))
        sections.append(Section(letter: nil, items: options, type: .options))
    }
    
    func sortByAlphabet(){
        sections = []
        setupOtherOption()
        
        let groupedDictionary = Dictionary(grouping: filteredItems, by: {String($0.name.prefix(1))})
        // get the keys and sort them
        let keys = groupedDictionary.keys.sorted()
        // map the sorted keys to a struct
        sections += keys.map{ Section(letter: $0, items: groupedDictionary[$0]!) }
        }
    
}

// MARK: basic crud
extension FriendDataSource {
    
    func appendItems(_ items: [FriendDomain]){
        self.items = items
        sortByAlphabet() // resort data
    }
    func updateItem(){
        
    }
    
    func getItem(ip index : IndexPath) -> Searchable{
        return sections[index.section].items[index.row]

    }
}


// MARK: for searching
extension FriendDataSource {
    func filterItemBy(key: String){
        guard key != "" else {
            self.clearSearch()
            return
        }
        self.filteredItems = self.items.filter { item in
            return item.name.lowercased().contains(key.lowercased())
        }
        
        // update data source
        sortByAlphabet()
    }
    
    func clearSearch(){
        //print(filteredItems)
        filteredItems = items
        sortByAlphabet()
    }
}

// MARK: TableDataSource
extension FriendDataSource : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {

        let indexedList = sections.filter{$0.letter != nil}

        return indexedList.map{ $0.letter! }
    }
//
//
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return self.sections[section].letter
//    }
//
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return sections.firstIndex(where: {$0.letter == title } )!
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // first row when user have not searched for any friend : add new contact
        let item = sections[indexPath.section].items[indexPath.row]
        
        // usual contact list sorted by alphabet
        if sections[indexPath.section].type == .contacts{
            // usual contact list sorted by alphabet
            let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell
            cell.avatarView.backgroundColor = UIColor.clear
            cell.configure(friend: item as! FriendDomain)
            return cell
            
        }
        
        // special options for creating new contact, or group chat etc
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchContactCell.identifier, for: indexPath) as! SearchContactCell
        
        if let option = item as? OtherOptions {
            cell.configure(option: option)
        }
        return cell
    }
    
}

