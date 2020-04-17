//  FindController.swift
//  Food-recipes

import UIKit

class FindController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Поиск"
        self.tabBarItem = UITabBarItem(title: self.title, image:UIImage(named: "search"), tag: 2)
        let backgroundImage = UIImageView(image: UIImage(named: "mainMenuWallper"))
        self.view = backgroundImage
    }

}
