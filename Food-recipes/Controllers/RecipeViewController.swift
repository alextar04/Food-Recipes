//  RecipeViewController.swift
//  Рецепты мира

import UIKit

/* Используется для компактного хранения рецепта в формате строки
   и вставках на форму, манипуляций с базой данных в данном модуле
   не происходит */
import SQLite

// Ячейка для таблицы с инградиентом/шагом рецепта
class FoodTableViewCell : UITableViewCell{
    @IBOutlet weak var labelDescription: UILabel!
}


class RecipeView: UIView{
    @IBOutlet weak var imageFood: UIImageView!
    @IBOutlet weak var nameFoodLabel: UILabel!
    
    @IBOutlet weak var countryImage: UIImageView!
    @IBOutlet weak var numberServingsLabel: UILabel!
    @IBOutlet weak var timePreparationLabel: UILabel!
    @IBOutlet weak var complexetyPreparationLabel: UILabel!
    
    @IBOutlet weak var scroller: UIScrollView!
    
    @IBOutlet weak var tabSwitching: UISegmentedControl!
    @IBOutlet weak var tableInformation: UITableView!
    
    // Обработка смены экрана
    var recipeFlag = false;
    @IBAction func SegmentedControlWasSelected(_ sender: Any) {
        // Из БД
        NotificationCenter.default.post(name: Notification.Name(rawValue: "SegmentedControlWasSelected"), object: nil)
        switch tabSwitching.selectedSegmentIndex {
            case 0: setIngradientsDataView();
            case 1: setRecipeDataView();
            default: break;
        }
    }
    
    func setIngradientsDataView()->Void{
        print("На инградиентах")
    }
    
    func setRecipeDataView()->Void{
        print("На рецепте")
    }
}

// Класс, управляющий логикой отображения данных рецепта
class LogicRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var globalLinkView : RecipeView? = nil
    var background : UIImage? = nil
    
    /* Для выбора ингредиентов - 0
                  шагов рецепта - 1 */
    var pageChoose : Int = 0
    
    /* Поля для отображения информации */
    var idRecipe : Int = 0
    var recipeInformation : SQLite.Row? = nil
    var IngredientsList : [Substring]? = nil
    var RecipesStepsList : [Substring]? = nil
    var countryFlag : SQLite.Blob? = nil
    var findMode : Bool = false
    
    // При конструкторе окна вызывается считывается id рецепта для отображения
    convenience init(idRecipe : Int, findMode : Bool){
        self.init()
        self.idRecipe = idRecipe
        self.findMode = findMode
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Блюдо"
        // Фоновая картинка
        background = UIImage(named: "mainMenuWallper")
        
        // Цвет кнопки назад
        self.navigationController?.navigationBar.tintColor = .white
        
        // Кнопка "Изменить" в правой части
        let barButton = UIBarButtonItem(image: UIImage(named: "editButton"), style: .plain, target: self, action: #selector(editKeyTapped))
        barButton.tintColor = .white
        if self.findMode == false{
            self.navigationItem.rightBarButtonItem = barButton
        }
        
        // Добавить слушателя для изменения выводимой вкладки
        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: NSNotification.Name(rawValue: "SegmentedControlWasSelected"), object: nil)
        
        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        createDataOnScreen(xibname: "recipeRoom")
    }
    
    // Реакция на кнопку изменение
    @objc func editKeyTapped()->Void{
        print("Хочу изменить блюдо!")
        self.navigationController?.pushViewController(EditRecipeViewController(idRecipe: self.idRecipe, target : "edition", nameCountry: nil), animated: true)
    }
    
    // Установка скролящейся площади
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        globalLinkView?.scroller.contentSize = CGSize(width: 375, height: 690)
    }
    
    // Функция заполнения компонентов на экране
    func createDataOnScreen(xibname : String)->Void{
        if let loadedView = Bundle.main.loadNibNamed(xibname, owner: self, options: nil)?.first as? RecipeView{
            loadedView.backgroundColor = UIColor(patternImage: background!)
            // Получение информации о рецепте
            recipeInformation = DatabaseQuery.getRecipeInformation(idRecipe: idRecipe)
            
            IngredientsList = DatabaseQuery.getIngredientsFromString(ingredientsString: (self.recipeInformation?[Database.Recipe().ingredients])!)
            
            RecipesStepsList = DatabaseQuery.getStepsFromRecipeString(recipeString: (self.recipeInformation?[Database.Recipe().recipe])!)
            
            countryFlag = DatabaseQuery.getCountryFlagById(idCountry: self.recipeInformation?[Database.Recipe().idCountryForeign])
            
            // Изображение блюда
            let imageFood : SQLite.Blob? = self.recipeInformation![Database.Recipe().imageBlob]
            loadedView.imageFood.image = UIImage(data: Data.fromDatatypeValue(imageFood!))
            
            // Название блюда
            loadedView.nameFoodLabel.text = self.recipeInformation?[Database.Recipe().namefood]
            
            // Изображение иконки страны
            if countryFlag != nil{
                loadedView.countryImage.image = UIImage(data: Data.fromDatatypeValue(countryFlag!))
            }
            loadedView.countryImage.layer.cornerRadius = loadedView.countryImage.frame.height / 2
            loadedView.countryImage.layer.borderColor = UIColor.black.cgColor
            loadedView.countryImage.layer.borderWidth = 1
            
            // Число порций
            loadedView.numberServingsLabel.text = String((self.recipeInformation?[Database.Recipe().portionsCount])!)
            
            // Время приготовления
            loadedView.timePreparationLabel.text = String((self.recipeInformation?[Database.Recipe().time])!)
            
            // Сложность приготовления
            //let complexity = "Средняя"
            let complexity : Int = (self.recipeInformation![Database.Recipe().complexity])
            var complexityString = ""
            switch complexity {
                case 0:
                    complexityString = "Низкая"
                case 1:
                    complexityString = "Средняя"
                case 2:
                    complexityString = "Высокая"
                default:
                    print("Ошибка преобразования числового значения сложности в строку")
            }
            loadedView.complexetyPreparationLabel.text = complexityString
            
            // Конфигурация таблицы
            loadedView.tableInformation.delegate = self
            loadedView.tableInformation.dataSource = self
            loadedView.tableInformation.backgroundColor = .clear
            
            // Индекс нажатой кнопки
            loadedView.tabSwitching.selectedSegmentIndex = pageChoose
            
            globalLinkView = loadedView
            self.view = loadedView
        }
    }
    
    // Размер ячейки в высоту
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Число секций (инградиентов или наименований в рецепте)
    func numberOfSections(in tableView: UITableView) -> Int {
        // <Определяется из БД>
        if self.pageChoose == 1{
            return RecipesStepsList!.count
        }
        else{
            return IngredientsList!.count
        }
    }
    
    // Колчичество ячеек в секции
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Реакция на изменение индекса
    @objc func notificationAction(){
        print("Индекс изменился\n")
        pageChoose = (pageChoose + 1) % 2
        createDataOnScreen(xibname: "recipeRoom")
    }
    
    // Отображение ячеек в таблице
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = Bundle.main.loadNibNamed("recipeCell", owner: self, options: nil)?.first as? FoodTableViewCell{
            if globalLinkView?.tabSwitching.selectedSegmentIndex == 0{
                cell.labelDescription?.text = String(self.IngredientsList![indexPath.section])
                cell.backgroundColor = UIColor(red: 242.0/256.0, green: 242.0/256.0, blue: 246.0/256.0, alpha: 1.0)
                // Запрет нажатия на ячейку
                cell.selectionStyle = .none
            }
            if globalLinkView?.tabSwitching.selectedSegmentIndex == 1{
                cell.labelDescription?.text = String(self.RecipesStepsList![indexPath.section])
                cell.labelDescription.numberOfLines = 0
                cell.labelDescription.adjustsFontSizeToFitWidth = true
                cell.labelDescription.minimumScaleFactor = 0.5
                cell.backgroundColor = UIColor(red: 242.0/256.0, green: 242.0/256.0, blue: 246.0/256.0, alpha: 1.0)
                // Запрет нажатия на ячейку
                cell.selectionStyle = .none
            }
            return cell
        }
        return UITableViewCell()
    }
    
    // Функция обновления всех предыдущих в иерархии окон
    func updateLastScreens(){
        createDataOnScreen(xibname: "recipeRoom")

        let userVC = self.navigationController?.viewControllers[0] as? UserController
               if userVC != nil{
                   userVC?.addItemsFromXib(xibname: "userRoom")
                   return
               }
        
        let countryVC = self.navigationController?.viewControllers[1] as? CountryDetailViewController
        if countryVC != nil{
            countryVC?.reloadListCountry()
            return
        }
    }
}
