//
//  MessengeInteractor.swift
//  ChatSqlite
//
//  Created by LAP11353 on 17/12/2021.
//

import Foundation
import UIKit
import Photos

protocol MessagesPresenter : AnyObject{
    func presentItems(_ items: [MessageDomain]?, offset: Int)
    func presentReceivedItem(_ item : MessageDomain)
    func presentSentItem(_ item: MessageDomain)
    func onFoundConversation(_ c: ConversationDomain)
    func presentMessageStatus(id: String, status: MessageStatus)
    func presentFFMessageStatus()
}

class MessagesInteractorImpl : MessageListInteractor {
            
    var chatService : ChatService
    var mediaWorker : MediaWorker = MediaWorker.shared
        
    var noRecords : Int = 20
    var offSet : CGFloat {
        CGFloat(420)
    }
    var currPage = 0
    var selectedFriend : FriendDomain?
    
    func doneSelectLocalMedia(_ assets: [PHAsset]){
        Task.detached{ [weak self] in
            guard let m  = self?.chatService.createNewMessage(type: .image) else {
                return
            }
            try await m.setPreps(assets: assets)
            self?.chatService.sendMessage(m)
            
            do {
                
                guard let savedMediasMessage = try await self?.savePhotos(of: m, assets: assets) else {
                    return
                }
                NotificationCenter.default.post(name: .onFinishCacheImageOfMessage, object: savedMediasMessage)
                // Notify to reload cells
            } catch let e {
                print(e.localizedDescription)
            }
        }
    }
    
    internal init(chatService: ChatService, noRecords: Int = 20, currPage: Int = 0, selectedFriend: FriendDomain? = nil) {
        self.chatService = chatService
        self.noRecords = noRecords
        self.currPage = currPage
        self.selectedFriend = selectedFriend
    }
    
    
    // TODO: Only save photos, not create list of preps
    func savePhotos(of model: MessageDomain, assets: [PHAsset]) async throws -> MessageDomain{
//        var urlStrings : [String] = []
        
        let results = try await withThrowingTaskGroup(of: (String, UIImage).self,
                                                      returning: [String: UIImage].self,
                                                      body: { taskGroup in
            for i in 0..<assets.count {
                taskGroup.addTask{
                    // Save photo
                    let saveType : ImageFileType = assets[i].mediaType == .video ? .video : .both
                    let (img,id) = try await self.mediaWorker.save(asset: assets[i],
                                                                   folder: model.cid,
                                                                   type: saveType)
                    
                    // Save video if any
                    if assets[i].mediaType == .video {
                        self.mediaWorker.saveVideo(asset: assets[i], folder: model.cid)
                    }
                    return (id,img)
                }
            }
            // Collect results of all child task in a dictionary
            var childTaskResults = [String: UIImage]()
            for try await result in taskGroup {
                // Set operation name as key and operation result as value
                childTaskResults[result.0] = result.1
            }
            
            // All child tasks finish running, thus task group result
            return childTaskResults
            
        })
        return model
        
    }
    
    
    


    func sendSeenStatus(){
        print("currently in Chat View")
        chatService.updatetoSeen()
    }
    
    func setSelectedFriend(friend : FriendDomain){
        // find conversation with friend
        //memoStore?.requestGetAll(noRecords: noRecords, noPages: 0)
        selectedFriend = friend

    }
    
    func loadData(){
        // filter messenges belong to this conversation
        chatService.loadMessages(noRecords: noRecords, noPages: 0)
        }
    
    func loadMore(tableOffset : CGFloat){
        //print(tableOffset)
        
        let pages = Int(tableOffset / offSet)
        guard pages - currPage == 1 else {
            return
        }
        currPage = pages

//        chatService.loadMessages(noRecords: noRecords, noPages: pages)
    }

    func onSendMessage(content: String, conversation: ConversationDomain){
        // display message
        let m = MessageDomain(cid: conversation.id, content: content, type: .text, status: .sent)
        
        // update db
        chatService.sendMessage(m)
        
    }
    
    func onSendMessage(m: MessageDomain){
        chatService.sendMessage(m)
    }
    
    
}
