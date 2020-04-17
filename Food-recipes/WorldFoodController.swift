import UIKit

class WorldFoodController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Рецепты"
        let filepath = Bundle.main.path(forResource: "images/cook30x30", ofType: "png")
        if filepath != nil{
            let image = UIImage(contentsOfFile: filepath!)
            self.tabBarItem = UITabBarItem(title: self.title, image: image, tag:0)
            self.view.backgroundColor = UIColor.green
            let backgroundImage = UIImageView(image: UIImage(named: "mainMenuWallper"))
            self.view = backgroundImage
        }
    }
}
