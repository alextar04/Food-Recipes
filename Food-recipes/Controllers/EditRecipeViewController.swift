//  EditRecipeViewController.swift
//  Рецепты мира

import UIKit

/* Используется для компактного хранения рецепта в формате строки
   и вставках на форму, манипуляций с базой данных в данном модуле
   не происходит */
import SQLite


class EditRecipeView: UIView, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var nameFood: UITextField!
    
    @IBOutlet weak var Complexity: UISegmentedControl!
    @IBOutlet weak var timePreparetion: UITextField!
    @IBOutlet weak var shortDescription: UITextField!
    
    @IBOutlet weak var portionsCount: UITextField!
    @IBOutlet weak var countryName: UITextField!
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    // -----------------------------------------
    @IBOutlet weak var ingredientsField: UITextView!
    @IBOutlet weak var RecipeField: UITextView!
    // -------------------
    var nameRecipeInStart : String = ""
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Поставим слушатель на момент считывания текущего названия продукта
        NotificationCenter.default.addObserver(self, selector: #selector(getNameRecipeInStart), name: NSNotification.Name(rawValue: "signalToView"), object: nil)
    }
    
    // Получить начальное название рецепта
    @objc func getNameRecipeInStart(_ notification: NSNotification){
        if let nameRecipe = notification.userInfo?["nameRecipeInStart"] as? String {
            nameRecipeInStart = nameRecipe
        }
    }
    
    
    // Обработка нажатий
    @IBAction func choosePhotoEntered(_ sender: Any) {
        print("Загрузка картинки")
        // Посылка сообщения контроллеру, дальнейшие действия выполняет он
        NotificationCenter.default.post(name: Notification.Name(rawValue: "choosePhotoEntered"), object: nil)
    }
    
    @IBAction func OkEntered(_ sender: Any) {
        // Запрос к модулю, работающим с БД (загужаем или обновляем рецепт)
        DatabaseQuery.saveNewRecordInDatabase(nameInStartRecipe: nameRecipeInStart, nameFood: nameFood.text!, nameCountry: countryName.text, portionsCount: portionsCount.text!, timePreparation: timePreparetion.text!, complexity: Complexity.selectedSegmentIndex, ingredients: ingredientsField.text, recipeSteps: RecipeField.text, photo: photoView.image!, shortDescription: shortDescription.text!)
        // Посылка сообщения контроллеру, дальнейшие действия выполняет он
        print("Загрузили рецепт")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "OkEntered"), object: nil)
    }
    
    @IBAction func DeleteEntered(_ sender: Any) {
        // Запрос к модулю, работающим с БД
        DatabaseQuery.deleteRecipe(nameRecipe: nameFood.text!)
        print("Удалили рецепт")
        // Посылка сообщения контроллеру, дальнейшие действия выполняет он
        NotificationCenter.default.post(name: Notification.Name(rawValue: "DeleteEntered"), object: nil)
    }
}

class EditRecipeViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate{
    var background : UIImage? = nil
    var picker : UIImagePickerController? = UIImagePickerController()
    var globalLinkForPhoto : UIImageView?
    var globalLinkForScroller : UIScrollView? = nil
    var keyboardOpen = false
    
    /* Отображаемая информация при редактировании */
    var idRecipe : Int? = nil
    var recipeInformation : SQLite.Row? = nil
    var target : String = ""
    var nameCountry : String? = nil
    var nameRecipeInStart : String = ""
    
    convenience init(idRecipe : Int?, target : String, nameCountry : String?){
        self.init()
        self.idRecipe = idRecipe
        self.target = target
        self.nameCountry = nameCountry
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Заголовок окна
        self.title = "Мастерская"
        // Фоновая картинка
        background = UIImage(named: "mainMenuWallper")
        // Получение информации о рецепте
        if idRecipe != nil{
            recipeInformation = DatabaseQuery.getRecipeInformation(idRecipe: idRecipe!)
        }
        
        // Цвет кнопки назад
        self.navigationController?.navigationBar.tintColor = .white
        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Добавить слушателя для входа в галерею фотографий
        NotificationCenter.default.addObserver(self, selector: #selector(wantOpenImageLibrary), name: NSNotification.Name(rawValue: "choosePhotoEntered"), object: nil)
        // Слушатель для кнопок
        NotificationCenter.default.addObserver(self, selector: #selector(wantSaveChanged), name: NSNotification.Name(rawValue: "OkEntered"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(wantDeleteFood), name: NSNotification.Name(rawValue: "DeleteEntered"), object: nil)
        
        
        createDataOnScreen(xibname: "modificationRecipeRoom")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        signalToView()
    }
    
    // Функции для перемещения экрана при наборе текста
    func keyboardWillShow() {
        if !keyboardOpen{
            self.view.frame.origin.y -= 150
            keyboardOpen = true
        }
    }
    
    func keyboardWillHide() {
        if keyboardOpen{
            self.view.frame.origin.y += 150
            keyboardOpen = false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        keyboardWillShow()
    }
    
    // Для text-field
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            keyboardWillHide()
            return false
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    // Функция для скрытия клавиатуры при тапе вне textedit
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Функция получает сообщения на открытие галереии фотографий
    @objc func wantOpenImageLibrary(){
        print("Получил сообщение")
        picker?.allowsEditing = false
        picker?.sourceType = .photoLibrary
        self.present(picker!, animated: true, completion: nil)
    }
    
    @objc func wantSaveChanged(){
        print("Получил сообщение")
        self.navigationController?.popViewController(animated: true)
        
        // Возвращение к пользователю
        let userVC = self.navigationController?.viewControllers.last as? UserController
        if userVC != nil{
            userVC?.addItemsFromXib(xibname: "userRoom")
            return
        }
        
        // Возвращение к рецепту после редактирования
        let RecipeFromRecipeEditVC = self.navigationController?.viewControllers.last as? LogicRecipeViewController
        if RecipeFromRecipeEditVC != nil{
            RecipeFromRecipeEditVC?.updateLastScreens()
            return
        }
        
        
        // Возвращение к стране
        let countryVC = self.navigationController?.viewControllers.last as? CountryDetailViewController
        if countryVC != nil{
            countryVC?.reloadListCountry()
            return
        }
    }
    
    @objc func wantDeleteFood(){
        print("Получил сообщение")
        
        // Возвращение к пользователю
        let userVC = self.navigationController?.viewControllers[0] as? UserController
        if userVC != nil{
            userVC?.addItemsFromXib(xibname: "userRoom")
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        
        // Возвращение к стране
        let countryVC = self.navigationController?.viewControllers[1] as? CountryDetailViewController
        if countryVC != nil{
            countryVC?.reloadListCountry()
            let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
            self.navigationController?.popToViewController(viewControllers[1], animated: true)
            return
        }
        
    }
    
    // Установка скролящейся площади
    override func viewWillLayoutSubviews(){
        super.viewWillLayoutSubviews()
        globalLinkForScroller?.contentSize = CGSize(width: 375, height: 1100)
    }
    
    // Что то выбрал (новенькую пикчу)
    func imagePickerController(_  picker:  UIImagePickerController,  didFinishPickingMediaWithInfo info:  [ UIImagePickerController.InfoKey :  Any] ) {
        if let pickedImage =  info[ UIImagePickerController.InfoKey.originalImage]  as? UIImage {
            globalLinkForPhoto?.contentMode = .scaleAspectFill
            globalLinkForPhoto?.image = pickedImage
            print("Новое изображение установлено!")
        }
        dismiss(animated:  true,  completion:  nil)
    }
    
    // Функция отмена ввода новой пикчи
    func imagePickerControllerDidCancel(_  picker:  UIImagePickerController) {
        dismiss(animated:  true,  completion:  nil)
    }
    
    // Установка данных на экране
    func createDataOnScreen(xibname : String){
        if let loadedView = Bundle.main.loadNibNamed(xibname, owner: self, options: nil)?.first as? EditRecipeView{
            loadedView.backgroundColor = UIColor(patternImage: background!)
            // Получение делегата для открытия меню фотографий
            picker?.delegate = self
            
            // Получение делегатов для форм для наполнения их текстом
            loadedView.nameFood.delegate = self
            loadedView.timePreparetion.delegate = self
            loadedView.portionsCount.delegate = self
            loadedView.countryName.delegate = self
            loadedView.ingredientsField.delegate = self
            loadedView.RecipeField.delegate = self
            loadedView.shortDescription.delegate = self
            globalLinkForScroller = loadedView.scroller
            
            // Название
            if idRecipe != nil{
                loadedView.nameFood.text = self.recipeInformation?[Database.Recipe().namefood]
                nameRecipeInStart = loadedView.nameFood.text!
            }
            
            // Краткое описание
            if idRecipe != nil{
                loadedView.shortDescription.text = self.recipeInformation?[Database.Recipe().shortDescriptionFood]
            }
        
            // Картинка
            globalLinkForPhoto = loadedView.photoView
            if idRecipe != nil{
                // По стандарту загружается картинка из БД или пустая в случае загрузки нового рецепта
                let imageFood : SQLite.Blob? = self.recipeInformation?[Database.Recipe().imageBlob]
                loadedView.photoView.image = UIImage(data: Data.fromDatatypeValue(imageFood!))
            }
            loadedView.photoView.backgroundColor = .white
            
            
            // Страна
            if idRecipe != nil{
                let country = DatabaseQuery.getCountryById(idCountry: self.recipeInformation?[Database.Recipe().idCountryForeign])
                if country != nil{
                    loadedView.countryName.text = country!
                } else{
                    loadedView.countryName.isEnabled = false
                }
            }
            
            // Число порций
            if idRecipe != nil{
                loadedView.portionsCount.text = String(self.recipeInformation![Database.Recipe().portionsCount])
            }
            
            // Время
            if idRecipe != nil{
                loadedView.timePreparetion.text = self.recipeInformation![Database.Recipe().time]
            }
            
            // Сложность
            if idRecipe != nil{
                let complexity : Int = Int(self.recipeInformation![Database.Recipe().complexity])
                loadedView.Complexity.selectedSegmentIndex = complexity
            }
            
            // Инградиенты
            if idRecipe != nil{
                loadedView.ingredientsField.text = self.recipeInformation![Database.Recipe().ingredients]
            } else {
                loadedView.ingredientsField.text = ""
            }
            
            // Рецепт
            if idRecipe != nil{
                loadedView.RecipeField.text = self.recipeInformation![Database.Recipe().recipe]
            }else{
                loadedView.RecipeField.text = ""
            }
            
            // Установка параметров в зависимости от вызвавших view окон
            if self.target == "addFromUser"{
                loadedView.deleteButton.isEnabled = false
                loadedView.countryName.isEnabled = false
                loadedView.deleteButton.alpha = 0.5
                loadedView.countryName.alpha = 0.5
            }
            
            if self.target == "addFromCountry"{
                loadedView.countryName.isEnabled = false
                loadedView.countryName.text = nameCountry!
                loadedView.deleteButton.isEnabled = false
                loadedView.deleteButton.alpha = 0.5
                loadedView.countryName.alpha = 0.5
            }
            
            if self.target == "edition"{
                loadedView.countryName.isEnabled = false
                loadedView.deleteButton.isEnabled = true
                loadedView.deleteButton.alpha = 1.0
                loadedView.countryName.alpha = 0.5
            }
            
            
            self.view = loadedView
        }
    }
    
    // Сигнал View, для считывание начального название рецепта при редактировании
    func signalToView(){
        let nameRecipe : [String: String] = ["nameRecipeInStart": nameRecipeInStart]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "signalToView"), object: nil, userInfo: nameRecipe)
    }
}
