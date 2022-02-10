//
//  HomeModule.swift
//  ChatSqlite
//
//  Created by LAP11353 on 10/02/2022.
//

import Foundation
import UIKit

class HomeModule {
    func build() -> UIViewController {
        let view = HomeViewController()
        let childView = buildChildListView()
        let router = HomeRouter(viewController: view)
        
        childView.delegate = view
                
        childView.router = router
        view.router = router
        
        view.conversationListViewController = childView
        
        return view
    }
    
    private func buildChildListView() -> ConversationListViewController {
        
        let childListView = ConversationListViewController()
        
        let inter = WorkerManager.shared.getConversationWorker()
        let presenter : ConversationPresenter = childListView
        
        inter.presenter = presenter
        childListView.interactor = inter
        
        return childListView
    }
}
