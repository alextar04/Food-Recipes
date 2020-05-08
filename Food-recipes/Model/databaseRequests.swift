//  databaseRequests.swift
//  Рецепты мира

import Foundation
import UIKit
import SQLite

// Расширение для запросов к БД
class DatabaseQuery{
    
    // Получение список стран, кухни которых представлены
    public static func getListCountryTable() -> [SQLite.Row] {
        let database : Connection? = Database.getInstanceDatabase()
        let tableCountry : Database.Country = Database.Country()
        // Возвращаемый список с результатами
        var countryList = [SQLite.Row]()
        
        do{
            for country in try database!.prepare(tableCountry.Country.order(tableCountry.name)){
                countryList.append(country)
            }
        }
        catch {
            print("Неудачный запрос списка кухонь! \(error)")
        }
        return countryList
    }
    
    
    // Список рецептов для определенной кухни
    public static func getListRecipesCountry(countryName : String) -> [SQLite.Row]{
        let database : Connection? = Database.getInstanceDatabase()
        let tableRecipe : Database.Recipe = Database.Recipe()
        
        // Возвращаемый список с результатами
        var RecipeList = [SQLite.Row]()
        
        // ID - необходимой страны
        let tableCountry : Database.Country = Database.Country()
        do{
            let idCountry = try database?.pluck(tableCountry.Country.filter(tableCountry.name == countryName))?[tableCountry.id]
            // Рецепты по необходимому ID
            do{
                for recipe in try database!.prepare(tableRecipe.Recipe.filter(tableRecipe.idCountryForeign == idCountry!)){
                    RecipeList.append(recipe)
                }
            }
            catch{
                print("Неудачный запрос списка рецептов для кухни " + countryName + "!")
            }
        }
        catch{
            print("Не найден ID страны")
        }
        return RecipeList
    }
    
    // Получение флага страны по ID
    public static func getCountryFlagById(idCountry : Int?) -> SQLite.Blob?{
        let database : Connection? = Database.getInstanceDatabase()
        let tableCountry : Database.Country = Database.Country()
        
        if idCountry != nil{
            do{
                let rowCountry = try database?.pluck(tableCountry.Country.filter(tableCountry.id == idCountry!))
                let countryFlag = rowCountry![tableCountry.flag]
                return countryFlag
            }
            catch{
                print("Не найден ID страны")
            }
        }
        return nil
    }
    
    // Получение названия страны по ID
    public static func getCountryById(idCountry : Int?) -> String?{
        let database : Connection? = Database.getInstanceDatabase()
        let tableCountry : Database.Country = Database.Country()
        
        if idCountry != nil{
            do{
                let rowCountry = try database?.pluck(tableCountry.Country.filter(tableCountry.id == idCountry!))
                let countryName = rowCountry![tableCountry.name]
                return countryName
            }
            catch{
                print("Не найден ID страны")
            }
        }
        return nil
    }
    
    // Получение ID страны по ее названию
    public static func getIdByCountry(nameCountry : String?) -> Int?{
        let database : Connection? = Database.getInstanceDatabase()
        let tableCountry : Database.Country = Database.Country()
        
        if nameCountry != nil{
            do{
                let rowCountry = try database?.pluck(tableCountry.Country.filter(tableCountry.name == nameCountry!))
                if rowCountry != nil{
                    let countryId = rowCountry![tableCountry.id]
                    return countryId
                }
            }
            catch{
                print("Не найден ID страны")
            }
        }
        return nil
    }
    
    // Получение информации по рецепту по его id
    public static func getRecipeInformation(idRecipe : Int) -> SQLite.Row? {
        let database : Connection? = Database.getInstanceDatabase()
        let tableRecipe : Database.Recipe = Database.Recipe()
        var recipeRow : SQLite.Row? = nil
        
        do {
            recipeRow = try database?.pluck(tableRecipe.Recipe.filter(tableRecipe.idRecipe == idRecipe))
        }
        catch{
            print("Неудачный запрос содержимого рецепта для кухни!")
        }
        return recipeRow
    }
    
    // Парсинг ингредиентов рецепта
    public static func getIngredientsFromString(ingredientsString : String) -> [Substring]{
        let listIngredients = ingredientsString.split(separator: ";")
        return listIngredients
    }
    
    // Парсинг этапов хода приготовления
    public static func getStepsFromRecipeString(recipeString : String) -> [Substring]{
        let listStepRecipe = recipeString.split(separator: "@")
        return listStepRecipe
    }
    
    // Поиск рецепта по названию блюда
    public static func findRecipeByName(recipeName : String) -> SQLite.Row? {
        let database : Connection? = Database.getInstanceDatabase()
        let tableRecipe : Database.Recipe = Database.Recipe()
        var recipeRow : SQLite.Row? = nil
        
        do {
            recipeRow = try database?.pluck(tableRecipe.Recipe.filter(tableRecipe.namefood == recipeName))
        }
        catch{
            print("Запрос несуществующего рецепта!")
        }
        return recipeRow
    }
    
    // Получение информации о пользователе
    public static func getUserInformation() -> SQLite.Row?{
        let database : Connection? = Database.getInstanceDatabase()
        let tableUser : Database.User = Database.User()
        var userRow : SQLite.Row? = nil
        
        do {
            userRow = try database?.pluck(tableUser.User.filter(tableUser.idUser == 0))
        }
        catch{
            print("Пользователя нет в системе!\(error)")
        }
        return userRow
    }
    
    // Получение рецептов пользователя
    public static func findRecipesByUser() -> [SQLite.Row] {
        let database : Connection? = Database.getInstanceDatabase()
        let tableRecipe : Database.Recipe = Database.Recipe()
        var RecipeList = [SQLite.Row]()
        
        do {
            for recipe in try database!.prepare(tableRecipe.Recipe.filter(tableRecipe.idUserForeign == 0)){
                RecipeList.append(recipe)
            }
        }
        catch{
            print("Рецепты пользователя не найдены!")
        }
        return RecipeList
    }
    
    // Сохранить(обновить) новую запись в БД
    public static func saveNewRecordInDatabase(nameInStartRecipe : String,
                                               nameFood : String,
                                               nameCountry : String?,
                                               portionsCount : String,
                                               timePreparation : String,
                                               complexity : Int,
                                               ingredients : String,
                                               recipeSteps : String,
                                               photo : UIImage,
                                               shortDescription : String
                                               ) -> Void{
        let database : Connection? = Database.getInstanceDatabase()
        let tableRecipe : Database.Recipe = Database.Recipe()

        // По названию страны - опредлим ее Id
        // Для блюда пользователя - id-страны = null
        let idCountry = getIdByCountry(nameCountry: nameCountry)
        var userForeign : Int? = nil
        if idCountry == nil{
            userForeign = 0
        }
        
        // Преобразование фото из UIImage в бинарный формат
        let imageBlob : SQLite.Blob = photo.jpegData(compressionQuality: 1.0)!.datatypeValue
        
        do{
            // Если изначальная строка была пустой, тогда создать новую запись, иначе обновить старую
            if nameInStartRecipe == ""{
                let result = try database?.run(tableRecipe.Recipe.insert(tableRecipe.namefood <- nameFood,
                                                        tableRecipe.idCountryForeign <- idCountry,
                                                        tableRecipe.imageBlob <- imageBlob,
                                                        tableRecipe.portionsCount <- Int(portionsCount)!,
                                                        tableRecipe.time <- timePreparation,
                                                        tableRecipe.complexity <- complexity,
                                                        tableRecipe.ingredients <- ingredients,
                                                        tableRecipe.recipe <- recipeSteps,
                                                        tableRecipe.shortDescriptionFood <- shortDescription,
                                                        tableRecipe.idUserForeign <- userForeign))
                print("Результат добавления записи в таблицу: \(result)")
            } else {
                // Найти старый рецепт, обновить его
                let row = tableRecipe.Recipe.filter(tableRecipe.namefood == nameInStartRecipe)
                let result = try database?.run(row.update(tableRecipe.idRecipe <- row[Database.Recipe().idRecipe],
                                                            tableRecipe.namefood <- nameFood,
                                                            tableRecipe.idCountryForeign <- idCountry,
                                                            tableRecipe.imageBlob <- imageBlob,
                                                            tableRecipe.portionsCount <- Int(portionsCount)!,
                                                            tableRecipe.time <- timePreparation,
                                                            tableRecipe.complexity <- complexity,
                                                            tableRecipe.ingredients <- ingredients,
                                                            tableRecipe.recipe <- recipeSteps,
                                                            tableRecipe.shortDescriptionFood <- shortDescription,
                                                            tableRecipe.idUserForeign <- userForeign))
                print("Результат обновления записи в таблице: \(String(describing: result))")
            }
        }catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
        return
    }
    
    // Удалить рецепт из БД по названию
    public static func deleteRecipe(nameRecipe : String){
        let database : Connection? = Database.getInstanceDatabase()
        let tableRecipe : Database.Recipe = Database.Recipe()
        
        do {
            let recipe = tableRecipe.Recipe.filter(tableRecipe.namefood == nameRecipe)
            let result = try database?.run(recipe.delete())
            print("Результат удаления записи из таблицы: \(result)")
        } catch{
            print("Неудачная попытка удаления записи")
        }
        return
    }
    
    // Сохранение информации о пользователе в БД
    public static func saveUserInDatabase(username:String, status:String, photo:UIImage) -> Void{
        let database : Connection? = Database.getInstanceDatabase()
        let tableUser : Database.User = Database.User()
        let row = tableUser.User.filter(tableUser.idUser == 0)
        
        // Преобразование фото из UIImage в бинарный формат
        let imageBlob : SQLite.Blob = photo.jpegData(compressionQuality: 1.0)!.datatypeValue
        
        do{
            let result = try database?.run(row.update(tableUser.idUser <- 0,
                                                      tableUser.username <- username,
                                                      tableUser.status <- status,
                                                      tableUser.image <- imageBlob))
            print("Результат обновления пользователя в таблице: \(result)")
        }catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
        return
    }
}
