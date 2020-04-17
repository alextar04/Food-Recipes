//  InformationController.swift
//  Food-recipes

import UIKit

class InformationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Информация"
        self.tabBarItem = UITabBarItem(title: self.title, image:UIImage(named: "information"), tag: 3)
        let backgroundImage = UIImageView(image: UIImage(named: "mainMenuWallper"))
        self.view = backgroundImage
    }

}
