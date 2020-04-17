//  AppDelegate.swift
//  Food-recipes

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // Экземпляр окна приложения
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Окно на полные границы экрана
        self.window = UIWindow(frame: UIScreen.main.bounds)
        // Контроллеры для окон
        let worldFoodController = WorldFoodController()
        let findController = FindController()
        let userController = UserController()
        let informationController = InformationController()
        // Отобразить подписи окон на нижней панели
        findController.loadViewIfNeeded()
        userController.loadViewIfNeeded()
        informationController.loadViewIfNeeded()
        
        // Верхняя панель окон для навигации (черный стиль для автоматически белого текста)
        let worldFoodNavigationController = UINavigationController(rootViewController: worldFoodController)
        worldFoodNavigationController.navigationBar.barTintColor = UIColor(red: 26/255, green: 100/255, blue: 23/255, alpha: 1.0)
        worldFoodNavigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        worldFoodNavigationController.navigationBar.barStyle = .black
        let findNavigationController = UINavigationController(rootViewController: findController)
        let userNavigationController = UINavigationController(rootViewController: userController)
        let informationNavigationController = UINavigationController(rootViewController: informationController)
        
        // Контроллер для нижней панели управления окнами
        let tabBarController = UITabBarController()
        tabBarController.setViewControllers([worldFoodNavigationController,
                                             userNavigationController,
                                             findNavigationController,
                                             informationNavigationController], animated: true)
        // Цвет заднего фона таббара
        tabBarController.tabBar.barTintColor = UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1.0)
        // Цвет элементов на таббаре
        tabBarController.tabBar.tintColor = .black
        
        
        // Стартовый контроллер включает в себя табБар
        self.window?.rootViewController = tabBarController
        // Полное отображения окна над всеми окнами
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Food_recipes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

