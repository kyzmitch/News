//
//  AppDelegate.swift
//  News
//
//  Created by Andrey Ermoshin on 24/03/2017.
//  Copyright © 2017 kyzmitch. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        let firstScreen = UIStoryboard.newsScreen()
        let tinkoffDataSource = TinkoffNewsNetworkSource()
        let newsService = NewsNetworkService(dataSource: tinkoffDataSource)
        firstScreen.add(newsService: newsService)
        self.window?.rootViewController = firstScreen
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.shared.saveContext()
    }
}

