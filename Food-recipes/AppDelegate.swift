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
        worldFoodController.loadViewIfNeeded()
        findController.loadViewIfNeeded()
        userController.loadViewIfNeeded()
        informationController.loadViewIfNeeded()
        
        // Верхняя панель окон для навигации
        let worldFoodNavigationController = createNavigationControllers(viewController: worldFoodController)
        let findNavigationController = createNavigationControllers(viewController: findController)
        let userNavigationController = createNavigationControllers(viewController: userController)
        let informationNavigationController = createNavigationControllers(viewController: informationController)
        
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
    
    // Функция создания и модификации параметров навигационного бара
    func createNavigationControllers(viewController : UIViewController) -> UINavigationController{
        // Верхняя панель окон для навигации (черный стиль для автоматически белого текста)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.barTintColor = UIColor(red: 26/255, green: 100/255, blue: 23/255, alpha: 1.0)
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController.navigationBar.barStyle = .black
        
        return navigationController
    }
    

    // Системная часть
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Food_recipes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
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
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

