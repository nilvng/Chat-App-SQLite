//
//  ChatModule.swift
//  ChatSqlite
//
//  Created by LAP11353 on 10/02/2022.
//

import Foundation
import UIKit

class ChatModule {
    func build(for conv : ConversationDomain) -> ChatViewController{
        let view = ChatViewController()
        let listView = MessageListViewController()
        let barView = ChatbarViewController()
        
        let service = ChatServiceManager.shared.getChatService(for: conv)
        print("show: \(conv.id)")
        let inter = MessagesInteractorImpl(chatService: service)
        
        let router = ChatRouter()
        router.viewController = view
        
        listView.interactor = inter
        listView.configure(conversation: conv)
        listView.parentDelegate = view
        service.observeMessageList(observer: listView)
        
        barView.delegate = view
        
        view.messageListView = listView
        view.chatBarView = barView
        view.interactor = inter
        view.router = router
        view.conversation = conv

        return view
    }
    func build(for friend : FriendDomain) -> ChatViewController{
        let view = ChatViewController()
        
        let listView = MessageListViewController()
        let barView = ChatbarViewController()
        
        let service = ChatServiceManager.shared.getChatService(for: friend)
        service.observeMessageList(observer: listView)

        let inter = MessagesInteractorImpl(chatService: service)
        
        let router = ChatRouter()
        router.viewController = view
        
        listView.interactor = inter
        listView.configure(friend: friend)
        listView.parentDelegate = view
        
        barView.delegate = view
        
        view.messageListView = listView
        view.chatBarView = barView
        view.interactor = inter
        view.router = router
        view.configure(friend: friend)
        
        return view
    }
    
}
