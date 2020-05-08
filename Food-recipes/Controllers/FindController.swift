//  FindController.swift
//  Food-recipes

import UIKit

/* Используется для компактного хранения массивов в формате строки
   и вставках на форму, манипуляций с базой данных в данном модуле
   не происходит */
import SQLite

class FindRecipeView: UIView{
    
    @IBOutlet weak var tableFound: UITableView!
}

class FindController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    
    var searchController : CustomButtonSearchController? = CustomButtonSearchController(searchResultsController: nil)
    var textFounded : String? = nil
    var subtextFounded : String? = nil
    var imageFounded : SQLite.Blob? = nil
    var linkRow : SQLite.Row? = nil
    var countSections = 0
    var textBar : String? = nil
    var selected : Bool = false
    var selectedCancel : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Поиск"
        self.tabBarItem = UITabBarItem(title: self.title, image:UIImage(named: "search"), tag: 2)
        if searchController == nil{
            searchController = CustomButtonSearchController(searchResultsController: nil)
        }
        self.definesPresentationContext = true
        
        
        if let loadedView = Bundle.main.loadNibNamed("searchView", owner: self, options: nil)?.first as? FindRecipeView{
            // Конфигурация таблицы
            loadedView.tableFound.delegate = self
            loadedView.tableFound.dataSource = self
            
            searchController?.searchResultsUpdater = self
            searchController?.searchBar.delegate = self
            searchController?.searchBar.text = textBar
            searchController?.searchBar.showsCancelButton = false
            searchController?.hidesNavigationBarDuringPresentation = false
            searchController?.obscuresBackgroundDuringPresentation = false
 
            loadedView.tableFound.tableHeaderView = searchController?.searchBar
            
            if selected == false{
                loadedView.tableFound.contentInset = UIEdgeInsets(top: 44,left: 0,bottom: 0,right: 0);
            }else{
                loadedView.tableFound.contentInset = UIEdgeInsets(top: 108,left: 0,bottom: 0,right: 0);
            }
            
            self.view = loadedView
        }
        print("Рисование вызывалось")
    }
    
    
    // Нажатие на ячейку
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Вы нажали на еду: \(textFounded!).")
        tableView.deselectRow(at: indexPath, animated: false)
        self.navigationController?.pushViewController(LogicRecipeViewController(idRecipe: self.linkRow![Database.Recipe().idRecipe], findMode: true), animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("Вызвал обновление данных")
        self.textFounded = searchBar.text
        self.textBar = self.textFounded
        searchBar.showsCancelButton = false
        // Запрос в БД по названию
        let findedFood = DatabaseQuery.findRecipeByName(recipeName: textFounded!)
        
        textFounded = nil
        subtextFounded = nil
        imageFounded = nil
        countSections = 0
        
        if findedFood != nil{
            self.linkRow = findedFood
            countSections = 1
            textFounded = findedFood![Database.Recipe().namefood]
            subtextFounded = findedFood![Database.Recipe().shortDescriptionFood]
            imageFounded = findedFood![Database.Recipe().imageBlob]
        }
        
        selected = true
        viewDidLoad()
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchBar.showsCancelButton = false
        print("Набирается строка для поиска")
    }
    
    class CustomButtonSearchController: UISearchController {
        let customButtonSearchBar = CustomButtonSearchBar()
        override var searchBar: UISearchBar { return customButtonSearchBar }
    }

    class CustomButtonSearchBar: UISearchBar {
        override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) {}
    }
    
    // Для таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Число секций (число блюд)
       func numberOfSections(in tableView: UITableView) -> Int {
           // <Определяется из БД>
           return countSections
       }
       
       // Расстояние между секциями
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
           return 0.0
       }
       
        // Размер ячейки в высоту
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80
        }
    
       // Очистить цвет между секциями
       func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
           if let header = view as? UITableViewHeaderFooterView {
               header.backgroundView?.backgroundColor = .clear
           }
       }
    
    // Вид ячеек
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = Bundle.main.loadNibNamed("tableCountryCell", owner: self, options: nil)?.first as? CountryTableViewCell{
             cell.backgroundColor = .white
             // Задать форму ячейки
             cell.layer.cornerRadius = cell.frame.height / 2
             
            // Из БД
            // Название блюда
            if self.textFounded != nil{
                cell.nameCountry.text = textFounded
            }else{
                cell.nameCountry.text = ""
            }
             
             // Краткое описание блюда
            if self.subtextFounded != nil{
                cell.shortDescription.text = self.subtextFounded
            }else{
                cell.shortDescription.text = ""
            }
             
             // Круглая картинка блюда
            if imageFounded != nil{
                cell.imageCountry.image = UIImage(data: Data.fromDatatypeValue(imageFounded!))
                cell.imageCountry.layer.cornerRadius = cell.imageCountry.frame.height / 2
                cell.imageCountry.layer.borderColor = UIColor.black.cgColor
                cell.imageCountry.layer.borderWidth = 3
            }
             return cell
         }
         return UITableViewCell()
    }
}
