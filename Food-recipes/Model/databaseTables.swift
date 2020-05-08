//  databaseTables.swift
//  Рецепты мира

import Foundation
import SQLite

// Расширение для получения таблиц БД
extension Database{

    class Country{
        let Country = Table("Country")
        let id = Expression<Int?>("id")
        let name = Expression<String>("name")
        let flag = Expression<SQLite.Blob>("flag")
        let shortDescription = Expression<String?>("shortDescription")
    }
    
    class Recipe{
        let Recipe = Table("Recipe")
        let idRecipe = Expression<Int>("id")
        let idCountryForeign = Expression<Int?>("idCountry")
        let idUserForeign = Expression<Int?>("idUser")
        let namefood = Expression<String>("nameFood")
        let imageBlob = Expression<SQLite.Blob>("imageBinary")
        let shortDescriptionFood = Expression<String>("shortDescription")
        let portionsCount = Expression<Int>("portionsCount")
        let time = Expression<String>("time")
        let complexity = Expression<Int>("complexity")
        let ingredients = Expression<String>("ingredients")
        let recipe = Expression<String>("recipe")
    }
    
    class User{
        let User = Table("User")
        let idUser = Expression<Int>("id")
        let username = Expression<String?>("username")
        let status = Expression<String>("status")
        let image = Expression<SQLite.Blob>("image")
    }
}
