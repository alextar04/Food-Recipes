//  CountryDetailViewController.swift
//  Рецепты мира

import UIKit

/* Используется для компактного хранения массивов в формате строки
   и вставках на форму, манипуляций с базой данных в данном модуле
   не происходит */
import SQLite

class CountryDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

   // Таблица - для отображения еды стран
        var countryFoodTableView = UITableView()
        var backgroundView = UIImageView()
        // Идентификатор для ячейки
        let idMainCell : String = "MainCell"
        // Список блюд (из БД) - это model
        var listFood = [SQLite.Row]()
        var myCountry : String = ""
    

    convenience init(country : String){
        self.init()
        self.myCountry = country
    }
    
    override func viewDidLoad() {
            super.viewDidLoad()
            self.title = myCountry
            // Цвет кнопки назад
            self.navigationController?.navigationBar.tintColor = .white
            
        
            // Кнопка "Добавить" в правой части
            let barButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addKeyTapped))
            barButton.tintColor = .white
            self.navigationItem.rightBarButtonItem = barButton
        
        
            // Фоновая картинка
            let background = UIImage(named: "mainMenuWallper")
            backgroundView = UIImageView(image: background)
            backgroundView.contentMode =  UIView.ContentMode.scaleAspectFill
            backgroundView.clipsToBounds = true
            backgroundView.image = background
            backgroundView.center = self.view.center

            createTable()
        }
        
        // Реакция на кнопку добавления
        @objc func addKeyTapped()->Void{
            print("Хочу добавить новое блюдо!")
            self.navigationController?.pushViewController(EditRecipeViewController(idRecipe: nil, target: "addFromCountry", nameCountry: myCountry), animated: true)
        }
    
        // Работа с таблицей
        func createTable(){
            // Создание таблицы
            self.countryFoodTableView = UITableView(frame: self.view.bounds, style: .grouped)
            // Загрузка данных из БД (получение списка блюд для страны)
            listFood = DatabaseQuery.getListRecipesCountry(countryName: self.myCountry)
            
            // Регистрация в таблице ячейки
            self.countryFoodTableView.register(UITableViewCell.self, forCellReuseIdentifier: idMainCell)
            self.countryFoodTableView.delegate = self
            self.countryFoodTableView.dataSource = self
            
            // Раcтянуть таблицу
            self.countryFoodTableView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            self.countryFoodTableView.backgroundColor = .clear
            self.countryFoodTableView.sectionFooterHeight = 0.0;
            self.countryFoodTableView.backgroundView = self.backgroundView
            self.view.addSubview(countryFoodTableView)
        }
        
        func reloadListCountry(){
            listFood = DatabaseQuery.getListRecipesCountry(countryName: self.myCountry)
            self.countryFoodTableView.reloadData()
        }
    
        // Для Delegate
        // Размер ячейки в высоту
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80
        }
        
        // Число секций
        func numberOfSections(in tableView: UITableView) -> Int {
            // <Определяется из БД>
            return listFood.count
        }
        
        // Расстояние между секциями
        func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            return 10.0
        }
        
        // Нажатие на ячейку
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            //  Переход на определенное блюдо
            print("You tapped food: \(listFood[indexPath.section][Database.Recipe().namefood]).")
            tableView.deselectRow(at: indexPath, animated: false)
            self.navigationController?.pushViewController(LogicRecipeViewController(idRecipe: listFood[indexPath.section][Database.Recipe().idRecipe], findMode: false), animated: true)
        }
        
        // Для DataSource
        // Количество ячеек в секции = 1 (общее число секций определяется в БД)
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            switch tableView {
                case self.countryFoodTableView:
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
                
                // Название блюда
                cell.nameCountry.text = "\(self.listFood[indexPath.section][Database.Recipe().namefood])"
                
                // Краткое описание блюда
                cell.shortDescription.text = "\(self.listFood[indexPath.section][Database.Recipe().shortDescriptionFood])"
                
                // Круглая картинка
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

