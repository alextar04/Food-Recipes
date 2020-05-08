//  InformationController.swift
//  Food-recipes

import UIKit

class informationView: UIView {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var cookImage: UIImageView!
    @IBOutlet weak var box: UIView!
}

class InformationController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Информация"
        self.tabBarItem = UITabBarItem(title: self.title, image:UIImage(named: "information"), tag: 3)
        
        let xibname = "information"
        if let loadedView = Bundle.main.loadNibNamed(xibname, owner: self, options: nil)?.first as? informationView{
            loadedView.backgroundColor = UIColor(patternImage: UIImage(named: "mainMenuWallper")!)
            loadedView.backView.backgroundColor = UIColor(red: 242.0/256.0, green: 242.0/256.0, blue: 246.0/256.0, alpha: 1.0)
            loadedView.backView.alpha = 0.7
            
            let pathImage = "cook"
            loadedView.cookImage.image = UIImage(named: pathImage)
            self.view = loadedView
        }
        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
    }

}
