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
        
        let inter = MessagesInteractorImpl()

        let router = ChatRouter()
        router.viewController = view
        
        listView.interactor = inter
        listView.configure(conversation: conv)
        let memoStore = MessageMemoManager.shared.get(conversationID: conv.id)
        listView.viewModel = memoStore
        inter.memoStore = memoStore
        listView.parentDelegate = view

        
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
        
        let inter = MessagesInteractorImpl()
        inter.setSelectedFriend(friend: friend)

        let router = ChatRouter()
        router.viewController = view
        
        let memoStore = MessageMemoManager.shared.get(friendID: friend.id)
        listView.parentDelegate = view
        listView.viewModel = memoStore
        inter.memoStore = memoStore

        listView.interactor = inter
        
        listView.configure(friend: friend)
        
        view.configure(friend: friend)

        
        barView.delegate = view
        
        view.messageListView = listView
        view.chatBarView = barView
        view.interactor = inter
        view.router = router

        return view
    }
    
}
