//  UserEditViewController.swift
//  Рецепты мира

import UIKit

/* Используется для компактного хранения массивов в формате строки
   и вставках на форму, манипуляций с базой данных в данном модуле
   не происходит */
import SQLite

class UserEditView : UIView {
    
    @IBOutlet weak var setupedImage: UIImageView!
    @IBOutlet weak var statusUser: UITextField!
    @IBOutlet weak var userName: UITextField!
    
    @IBAction func chooseFromGallery(_ sender: Any) {
        print("Загрузка картинки")
        // Посылка сообщения контроллеру, дальнейшие действия выполняет он
        NotificationCenter.default.post(name: Notification.Name(rawValue: "chooseFromGallery"), object: nil)
    }
    
    @IBAction func OkPressed(_ sender: Any) {
        print("Загрузили иноформацию о пользователе")
        DatabaseQuery.saveUserInDatabase(username: userName.text!, status: statusUser.text!, photo: setupedImage.image!)
        // Посылка сообщения контроллеру, дальнейшие действия выполняет он
        NotificationCenter.default.post(name: Notification.Name(rawValue: "OkPressed"), object: nil)
    }
}

class UserEditViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    var background : UIImage? = nil
    var picker : UIImagePickerController? = UIImagePickerController()
    var globalPhotoLink : UIImageView?
    var userRow : SQLite.Row? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Фоновая картинка
        background = UIImage(named: "mainMenuWallper")
        // Цвет кнопки назад
        self.navigationController?.navigationBar.tintColor = .white
        userRow = DatabaseQuery.getUserInformation()
        
        self.edgesForExtendedLayout = UIRectEdge()
        self.extendedLayoutIncludesOpaqueBars = false
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Вызов функции добавления компонентов из XIB-файла
        addItemsFromXib(xibname: "editUserView")
    }
    
    // Функция заполнения компонентов на экране
    func addItemsFromXib(xibname : String)->Void{
        if let loadedView = Bundle.main.loadNibNamed(xibname, owner: self, options: nil)?.first as? UserEditView{
            loadedView.backgroundColor = UIColor(patternImage: background!)
            // Из БД заполняются данные о пользователе
            loadedView.userName.text = userRow![Database.User().username]
            loadedView.statusUser.text = userRow![Database.User().status]
            
            
            // По стандарту загружается картинка из БД или новая в случае загрузки новой картинки
            let imageFood : SQLite.Blob? = self.userRow?[Database.User().image]
            loadedView.setupedImage.image = UIImage(data: Data.fromDatatypeValue(imageFood!))
            loadedView.setupedImage.backgroundColor = .white
            
            
            // Пропишем всем делегаты
            loadedView.userName.delegate = self
            loadedView.statusUser.delegate = self
            picker?.delegate = self
            
            
            
            globalPhotoLink = loadedView.setupedImage
            // Добавить слушателя для входа в галерею фотографий
            NotificationCenter.default.addObserver(self, selector: #selector(openImageLibrary),name:NSNotification.Name(rawValue: "chooseFromGallery"), object: nil)
            // Слушатель для кнопок
            NotificationCenter.default.addObserver(self, selector: #selector(saveChanged), name: NSNotification.Name(rawValue: "OkPressed"), object: nil)
            
            self.view = loadedView
        }
    }
    
    @objc func saveChanged(){
        print("Получил сообщение")
        self.navigationController?.popViewController(animated: true)
        let previousVC = self.navigationController?.viewControllers.last as? UserController
        previousVC?.addItemsFromXib(xibname: "userRoom")
    }
    
    // Функция получает сообщения на открытие галереии фотографий
    @objc func openImageLibrary(){
        print("Получил сообщение")
        picker?.allowsEditing = false
        picker?.sourceType = .photoLibrary
        self.present(picker!, animated: true, completion: nil)
    }
    
    // Что то выбрал (новенькую пикчу)
    func imagePickerController(_  picker:  UIImagePickerController,  didFinishPickingMediaWithInfo info:  [ UIImagePickerController.InfoKey :  Any] ) {
        if let pickedImage =  info[ UIImagePickerController.InfoKey.originalImage]  as? UIImage {
            globalPhotoLink?.contentMode = .scaleAspectFill
            globalPhotoLink?.image = pickedImage
            print("Новое изображение установлено!")
        }
        dismiss(animated:  true,  completion:  nil)
    }
    
    // Функция отмена ввода новой пикчи
    func imagePickerControllerDidCancel(_  picker:  UIImagePickerController) {
        dismiss(animated:  true,  completion:  nil)
    }
    
    // Для скрытия text-field
       func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
           if (text == "\n") {
               textView.resignFirstResponder()
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
            

}
