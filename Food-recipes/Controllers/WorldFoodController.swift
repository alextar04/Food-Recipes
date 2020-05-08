import UIKit

/* Используется для компактного хранения массивов в формате строки
   и вставках на форму, манипуляций с базой данных в данном модуле
   не происходит */
import SQLite

// Ячейка для таблицы со странами
class CountryTableViewCell : UITableViewCell{
    
    @IBOutlet weak var nameCountry: UILabel!
    @IBOutlet weak var shortDescription: UILabel!
    @IBOutlet weak var imageCountry: UIImageView!
    @IBOutlet weak var cellView: UIView!
    
}

class WorldFoodController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // Таблица - для отображения стран
    var countryTableView = UITableView()
    var backgroundView = UIImageView()
    // Идентификатор для ячейки
    let idMainCell : String = "MainCell"
    // Список стран (из БД) - описание в  model
    var countryList = [SQLite.Row]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Рецепты"
        
        let filepath = Bundle.main.path(forResource: "images/cook30x30", ofType: "png")
        if filepath != nil{
            let image = UIImage(contentsOfFile: filepath!)
            self.tabBarItem = UITabBarItem(title: self.title, image: image, tag:0)
            
            // Фоновая картинка
            let background = UIImage(named: "mainMenuWallper")
            backgroundView = UIImageView(image: background)
            backgroundView.contentMode =  UIView.ContentMode.scaleAspectFill
            backgroundView.clipsToBounds = true
            backgroundView.image = background
            backgroundView.center = self.view.center
        }
        
        createTable()
    }
    
    
    // Работа с таблицей
    func createTable(){
        // Создание таблицы
        self.countryTableView = UITableView(frame: self.view.bounds, style: .grouped)
        // Загрузка данных из БД (получение списка стран)
        countryList = DatabaseQuery.getListCountryTable()
        
        // Регистрация в таблице ячейки
        self.countryTableView.register(UITableViewCell.self, forCellReuseIdentifier: idMainCell)
        self.countryTableView.delegate = self
        self.countryTableView.dataSource = self
        
        // Раcтянуть таблицу
        self.countryTableView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        self.countryTableView.backgroundColor = .clear
        self.countryTableView.sectionFooterHeight = 0.0;
        self.countryTableView.backgroundView = self.backgroundView
        self.view.addSubview(countryTableView)
    }
    
    // Для Delegate
    // Размер ячейки в высоту
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Число секций
    func numberOfSections(in tableView: UITableView) -> Int {
        // <Определяется из БД>
        return countryList.count
    }
    
    // Расстояние между секциями
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    // Нажатие на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  <Тут будет переход на страницы кухонь>
        print("You tapped country: \(self.countryList[indexPath.section][Database.Country().name]).")
        tableView.deselectRow(at: indexPath, animated: false)
        self.navigationController?.pushViewController(CountryDetailViewController(country: self.countryList[indexPath.section][Database.Country().name]), animated: true)
    }
    
    // Для DataSource
    // Количество ячеек в секции = 1 (общее число секций определяется в БД)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
            case self.countryTableView:
                return 1
            default:
                return 0
        }
    }
    
    // Создание объекта ячейки (каждая в своей секции)
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = Bundle.main.loadNibNamed("tableCountryCell", owner: self, options: nil)?.first as? CountryTableViewCell{
            cell.backgroundColor = .white
            // Задать форму ячейки
            cell.layer.cornerRadius = cell.frame.height / 2
            
            // Название страны
            cell.nameCountry.text = "\(self.countryList[indexPath.section][Database.Country().name])"
            
            // Краткое описание кухни
            cell.shortDescription.text = "\(self.countryList[indexPath.section][Database.Country().shortDescription]!)"
            
            // Круглая картинка
            let imageFood : SQLite.Blob? = self.countryList[indexPath.section][Database.Country().flag]
            cell.imageCountry.image = UIImage(data: Data.fromDatatypeValue(imageFood!))
            cell.imageCountry.layer.cornerRadius = cell.imageCountry.frame.height / 2
            cell.imageCountry.layer.borderColor = UIColor.black.cgColor
            cell.imageCountry.layer.borderWidth = 3
            return cell
        }
        return UITableViewCell()
        }
}
