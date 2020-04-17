//  UserController.swift
//  Food-recipes

import UIKit

class UserController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Мой кабинет"
        self.tabBarItem = UITabBarItem(title: self.title, image:UIImage(named: "user"), tag: 1)
        let backgroundImage = UIImageView(image: UIImage(named: "mainMenuWallper"))
        self.view = backgroundImage
    }
}
