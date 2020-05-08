//  UserController.swift
//  Food-recipes

import UIKit

/* Используется для компактного хранения массивов в формате строки
   и вставках на форму, манипуляций с базой данных в данном модуле
   не происходит */
import SQLite

class ViewUserRoom: UIView{
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var updateInformationButton: UIButton!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userRecipesTable: UITableView!
    @IBAction func updateUserInformation(_ sender: Any) {
        print("Решили обновить пользователя")
        // Посылка сообщения контроллеру, дальнейшие действия выполняет он
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateUserInformation"), object: nil)
    }
}


class UserController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var background : UIImage? = nil
    var headerView : UIView? = nil
    // Информация из модели
    var listFood = [SQLite.Row]()
    var userRow : SQLite.Row? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Мой кабинет"
        // Значок пользователя в нижней части
        self.tabBarItem = UITabBarItem(title: self.title, image:UIImage(named: "user"), tag: 1)
        
        // Кнопка "Добавить" в правой части
        let barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addKeyTapped))
        barButton.tintColor = .white
        self.navigationItem.rightBarButtonItem = barButton
        
        // Фоновая картинка
        background = UIImage(named: "mainMenuWallper")
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadEditUser), name: NSNotification.Name(rawValue: "updateUserInformation"), object: nil)
        // Вызов функции добавления компонентов из XIB-файла
        addItemsFromXib(xibname: "userRoom")
    }
    
    @objc func loadEditUser(){
        self.navigationController?.pushViewController(UserEditViewController(), animated: true)
    }
    
    // Добавление элементов из XIB-файла
    func addItemsFromXib(xibname: String){
        listFood = DatabaseQuery.findRecipesByUser()
        userRow = DatabaseQuery.getUserInformation()
        if let loadedView = Bundle.main.loadNibNamed(xibname, owner: self, options: nil)?.first as? ViewUserRoom{
            // Фоновое изображение
            loadedView.backgroundColor = UIColor(patternImage: background!)
            
            // Добавим информацию о пользователе
            loadedView.usernameLabel.text = userRow![Database.User().username]
            loadedView.statusLabel.text = userRow![Database.User().status]
        
            // Круглая картинка
            let image : SQLite.Blob? = self.userRow?[Database.User().image]
            loadedView.userPhoto.image = UIImage(data: Data.fromDatatypeValue(image!))
            loadedView.userPhoto.layer.cornerRadius = loadedView.userPhoto.frame.height/2
            loadedView.userPhoto.layer.borderColor = UIColor.black.cgColor
            loadedView.userPhoto.layer.borderWidth = 3
            
            // Cоздание ячеек для таблицы
            loadedView.userRecipesTable.delegate = self
            loadedView.userRecipesTable.dataSource = self
            // Для таблицы отчистить цвет фона
            loadedView.userRecipesTable.backgroundColor = .clear
            // Особый заголовок для 1 секции
            headerView = loadedView.headerView
            headerView?.backgroundColor = .clear
            
            
            self.view = loadedView
        }
    }
    
    // Реакция на кнопку добавления
    @objc func addKeyTapped()->Void{
        print("Хочу добавить новое блюдо!")
        self.navigationController?.pushViewController(EditRecipeViewController(idRecipe: nil, target : "addFromUser", nameCountry: nil), animated: true)
    }
    
    // Размер ячейки в высоту
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Число секций (число блюд пользователя)
    func numberOfSections(in tableView: UITableView) -> Int {
        // <Определяется из БД>
        return listFood.count
    }
    
    // Расстояние между секциями
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 110.0
        }
        return 10.0
    }
    
    // Очистить цвет между секциями
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = .clear
        }
    }
    
    // Заголовок 0 - секции
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
         return headerView
        }
        return nil
    }
    
    // Нажатие на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  Переход на определенное блюдо
        print("You tapped food: \(listFood[indexPath.section][Database.Recipe().namefood]).")
        tableView.deselectRow(at: indexPath, animated: false)
        self.navigationController?.pushViewController(LogicRecipeViewController(idRecipe: listFood[indexPath.section][Database.Recipe().idRecipe], findMode: false), animated: true)
    }
    
    
    // Количесвто элементов в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Создание объекта ячейки
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = Bundle.main.loadNibNamed("tableCountryCell", owner: self, options: nil)?.first as? CountryTableViewCell{
            cell.backgroundColor = .white
            // Задать форму ячейки
            cell.layer.cornerRadius = cell.frame.height / 2
            
            // Название блюда
            cell.nameCountry.text = "\(self.listFood[indexPath.section][Database.Recipe().namefood])"
            
            // Краткое описание блюда
            cell.shortDescription.text = "\(self.listFood[indexPath.section][Database.Recipe().shortDescriptionFood])"
            
            // Круглая картинка блюда
            let imageFood : SQLite.Blob? = self.listFood[indexPath.section][Database.Recipe().imageBlob]
            cell.imageCountry.image = UIImage(data: Data.fromDatatypeValue(imageFood!))
            cell.imageCountry.layer.cornerRadius = cell.imageCountry.frame.height / 2
            cell.imageCountry.layer.borderColor = UIColor.black.cgColor
            cell.imageCountry.layer.borderWidth = 3
            return cell
        }
        return UITableViewCell()
    }
}
