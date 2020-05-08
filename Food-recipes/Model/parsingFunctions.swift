//  parsingFunctions.swift
//  Рецепты мира

import Foundation

// Расширение для строк (удаление пробелов)
extension String {
    var stringByRemovingWhitespaces: String {
        return components(separatedBy: .whitespaces).joined()
    }
}

// Для копирования БД в Documetns - директорию для поддержки записи
func copyFileToDocumentsFolder(nameForFile: String, extForFile: String) {

    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let destURL = documentsURL!.appendingPathComponent(nameForFile).appendingPathExtension(extForFile)
    guard let sourceURL = Bundle.main.url(forResource: nameForFile, withExtension: extForFile)
        else {
            print("Source File not found.")
            return
    }
        let fileManager = FileManager.default
        do {
            try fileManager.copyItem(at: sourceURL, to: destURL)
        } catch {
            print("Unable to copy file")
        }
}

// Отчистка домашней директории от лишних файлов
func clearAllFile() {
    let fileManager = FileManager.default
    let myDocuments = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    do {
        try fileManager.removeItem(at: myDocuments)
    } catch {
        return
    }
}
