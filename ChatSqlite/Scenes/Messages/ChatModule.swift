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
        
        let inter = WorkerManager.shared.getMessageWorker(cid: conv.id)
        inter.presenter = listView

        let router = ChatRouter()
        router.viewController = view
        
        
        listView.interactor = inter
        listView.parentDelegate = view
        listView.configure(conversation: conv)
        
        barView.delegate = view
        
        view.messageListView = listView
        view.chatBarView = barView
        view.interactor = inter
        view.router = router
        view.conversation = conv

        return view
    }
    func build(for friend : FriendDomain) -> ChatViewController{
        let view = buildRaw()
       // view.configure(friend: friend)
        
        return view
    }
    
    private func buildRaw() -> ChatViewController {
        let view = ChatViewController()
        let interactor = WorkerManager.shared.getMessageWorker()
        
        view.interactor = interactor
        return view
    }
    
}
