//  databaseConfiguration.swift
//  Рецепты мира

import Foundation
import SQLite

// Класс для работы с БД
// Синглтон для единственности точки доступа к БД
/* Прим. Таблицы БД - описаны в расширении для класса в файле "databaseTables.swift"
         Функции запросов к БД - описаны в cоответствующем классе в файле "databaseRequest.swift" */
class Database{
    // Объект БД
    private static var clientDatabase : Database?
    // Объект для поддержки соединения
    private var connection : Connection?
    
    // Невозможность явного вызова конструктора извне класса
    private init(){}
    
    // Получение функционирующего манипулятора БД
    public static func getInstanceDatabase() -> Connection?{
        // Проверка на существование экземпляра БД
        if self.clientDatabase == nil{
            do {
                // Создадим экземпляр БД, если он еще не был создан
                self.clientDatabase = Database()
                
                // Для загрузки первоначальной БД, используется для восстановления состояния
                // clearAllFile()
                
                // Перенос БД в директорию Documents
                copyFileToDocumentsFolder(nameForFile: "food-recipes-db", extForFile: "sqlite")
                let filepath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true).first!
                
                self.clientDatabase?.connection = try Connection("\(filepath)/food-recipes-db.sqlite")
                return self.clientDatabase?.connection
            } catch {
                print("Ошибка пути!")
                return nil
            }
        }
        return self.clientDatabase?.connection
    }
}
