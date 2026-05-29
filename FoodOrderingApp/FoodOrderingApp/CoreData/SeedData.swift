//
//  SeedData.swift
//  FoodOrderingApp
//

import Foundation
import CoreData

struct SeedData {
    static func populateIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        let count = (try? context.count(for: request)) ?? 0
        if count > 0 { return }
        
        // MARK: - Рестораны Литвины (4 ресторана)
        
        // 1. Литвины - пр-т Победителей
        let litviny1 = Restaurant(context: context)
        litviny1.id = UUID()
        litviny1.name = "Литвины"
        litviny1.address = "Минск, пр-т Победителей, 119"
        litviny1.latitude = 53.915
        litviny1.longitude = 27.530
        litviny1.rating = 4.5
        litviny1.cuisineType = "Белорусская"
        litviny1.imageURL = "litviny"
        litviny1.phone = "+375 44 557-11-11"
        litviny1.workingHours = "11:00 - 23:00"
        
        // 2. Литвины - ТЦ Green City
        let litviny2 = Restaurant(context: context)
        litviny2.id = UUID()
        litviny2.name = "Литвины"
        litviny2.address = "Минск, ул. Притыцкого, 156/1 (ТЦ Green city)"
        litviny2.latitude = 53.904
        litviny2.longitude = 27.437
        litviny2.rating = 4.6
        litviny2.cuisineType = "Белорусская"
        litviny2.imageURL = "litviny"
        litviny2.phone = "+375 44 519-11-11"
        litviny2.workingHours = "11:00 - 23:00"
        
        // 3. Літвіны - ул. Свердлова (центр)
        let litviny3 = Restaurant(context: context)
        litviny3.id = UUID()
        litviny3.name = "Літвіны"
        litviny3.address = "Минск, ул. Свердлова, 2"
        litviny3.latitude = 53.900
        litviny3.longitude = 27.554
        litviny3.rating = 4.7
        litviny3.cuisineType = "Белорусская"
        litviny3.imageURL = "litviny"
        litviny3.phone = "+375 29 119-34-34"
        litviny3.workingHours = "10:00 - 23:00"
        
        // 4. Литвины - ул. Революционная
        let litviny4 = Restaurant(context: context)
        litviny4.id = UUID()
        litviny4.name = "Литвины"
        litviny4.address = "Минск, ул. Революционная, 26"
        litviny4.latitude = 53.906
        litviny4.longitude = 27.547
        litviny4.rating = 4.4
        litviny4.cuisineType = "Белорусская"
        litviny4.imageURL = "litviny"
        litviny4.phone = "+375 29 314-40-40"
        litviny4.workingHours = "10:00 - 23:00"
        
        // MARK: - Расширенное меню для Литвинов
        let litvinyDishes: [(name: String, price: Double, category: String, description: String, isAvailable: Bool, imageURL: String?)] = [
            // 🥗 ЗАКУСКИ
            ("Кныш с сыром", 7.50, "Закуски", "Пирожок с сырной начинкой", true, "knysh"),
            ("Сало по-белорусски", 8.90, "Закуски", "Домашнее сало с чесноком и черным хлебом", true, "salo"),
            ("Грибная полянка", 9.50, "Закуски", "Маринованные лесные грибы с луком и маслом", true, "griby"),
            ("Селедка с картошечкой", 7.90, "Закуски", "Слабосоленая селедка с отварным картофелем", true, "seledka"),
            
            // 🥣 СУПЫ
            ("Борщ литвинский", 9.50, "Супы", "Наваристый борщ со свеклой и мясом", true, "borsh"),
            ("Суп грибной", 8.50, "Супы", "Ароматный суп из лесных грибов", true, "gribnoy_sup"),
            ("Солянка мясная", 10.90, "Супы", "Сборная солянка с тремя видами мяса", true, "solyanka"),
            ("Окрошка на квасе", 8.90, "Супы", "Освежающая окрошка с домашним квасом", false, "okroshka"),
            
            // 🍖 ГОРЯЧИЕ БЛЮДА
            ("Драники по-литвински", 12.50, "Горячие блюда", "Традиционные драники с золотистой корочкой", true, "draniki"),
            ("Колдуны с мясом", 13.90, "Горячие блюда", "Картофельные колдуны с мясной начинкой", true, "kolduny"),
            ("Верещака", 15.90, "Горячие блюда", "Традиционная белорусская похлебка с ребрышками", true, "vereshchaka"),
            ("Котлета по-белорусски", 14.50, "Горячие блюда", "Котлета из двух видов мяса с грибами", true, "kotleta"),
            ("Мясо по-магнатски", 22.90, "Горячие блюда", "Свинина с черносливом в сметанном соусе", true, "myaso"),
            ("Мачанка", 16.90, "Горячие блюда", "Традиционное блюдо с колбасками и беконом", true, "machanka"),
            ("Зразы картофельные", 11.90, "Горячие блюда", "Картофельные зразы с грибной начинкой", true, "zrazy"),
            
            // 🥗 САЛАТЫ
            ("Салат Беловежский", 10.50, "Салаты", "Копченая курица, грибы, сыр, сухарики", true, "salat1"),
            ("Винегрет", 7.50, "Салаты", "Классический винегрет с квашеной капустой", true, "vinegret"),
            ("Салат с печенью", 9.50, "Салаты", "Теплый салат с куриной печенью", true, "salat_pechen"),
            
            // 🥞 БЛИНЫ И ДРАНИКИ
            ("Блинчики с творогом", 9.50, "Блины", "Тонкие блинчики с творожной начинкой", true, "bliny_tvorog"),
            ("Блинчики с мясом", 11.90, "Блины", "Блинчики с мясным фаршем", true, "bliny_myaso"),
            ("Драники с грибами", 14.50, "Блины", "Драники с грибной подливой", true, "draniki_gribi"),
            ("Драники с мясом", 15.50, "Блины", "Драники с мясной начинкой", true, "draniki_myaso"),
            
            // 🍰 ДЕСЕРТЫ
            ("Сырники со сметаной", 8.20, "Десерты", "Нежные сырники с домашней сметаной", true, "syrniki"),
            ("Медовик", 7.50, "Десерты", "Классический медовый торт", true, "medovik"),
            ("Наполеон", 8.50, "Десерты", "Воздушный торт Наполеон", true, "napoleon"),
            ("Яблочный штрудель", 7.90, "Десерты", "Хрустящий штрудель с яблоком", true, "shtrudel"),
            ("Оладьи с вареньем", 7.50, "Десерты", "Пышные оладьи с домашним вареньем", true, "oladi"),
            
            // 🥤 НАПИТКИ
            ("Медуха", 8.00, "Напитки", "Традиционный белорусский медовый напиток", true, "meduha"),
            ("Крамбамбуля", 9.00, "Напитки", "Алкогольный напиток на меду и пряностях", true, "krambambulya"),
            ("Квас домашний", 5.00, "Напитки", "Натуральный квас собственного производства", true, "kvas"),
            ("Морс клюквенный", 6.00, "Напитки", "Освежающий клюквенный морс", true, "mors"),
            ("Сбитень", 7.00, "Напитки", "Старинный русский напиток на меду", true, "sbiten"),
            ("Компот из сухофруктов", 4.50, "Напитки", "Домашний компот из сухофруктов", true, "kompot"),
            ("Чай травяной", 4.00, "Напитки", "Сбор лесных трав", true, "tea"),
            ("Кофе по-восточному", 5.00, "Напитки", "Крепкий кофе с кардамоном", true, "coffee"),
        ]
        
        // Добавляем блюда для всех ресторанов Литвины
        for restaurant in [litviny1, litviny2, litviny3, litviny4] {
            for dishData in litvinyDishes {
                let dish = Dish(context: context)
                dish.id = UUID()
                dish.name = dishData.name
                dish.price = dishData.price
                dish.category = dishData.category
                dish.dishDescription = dishData.description
                dish.isAvailable = dishData.isAvailable
                dish.imageURL = dishData.imageURL
                dish.restaurant = restaurant
            }
        }
        
        // MARK: - Рестораны Васильки (8 ресторанов)
        
        let vasilkiAddresses: [(String, Double, Double, String, String)] = [
            ("Минск, ул. Комсомольская, 32", 53.905, 27.556, "+375 17 123-45-67", "10:00 - 23:00"),
            ("Минск, пр-т Независимости, 16", 53.898, 27.566, "+375 17 123-45-68", "10:00 - 23:00"),
            ("Минск, пр-т Независимости, 89", 53.921, 27.595, "+375 17 123-45-69", "10:00 - 23:00"),
            ("Минск, пр-т Независимости, 58", 53.915, 27.580, "+375 17 123-45-70", "10:00 - 23:00"),
            ("Минск, ул. Бобруйская, 6 (ТРЦ Galileo)", 53.900, 27.544, "+375 17 123-45-71", "11:00 - 23:00"),
            ("Минск, пр-т Победителей, 9 (ТРЦ Galleria Minsk)", 53.911, 27.535, "+375 17 123-45-72", "11:00 - 23:00"),
            ("Минск, ул. Якуба Коласа, 37", 53.917, 27.602, "+375 17 123-45-73", "10:00 - 23:00"),
            ("Минск, ул. Петра Мстиславца, 11 (ТРЦ Dana Mall)", 53.925, 27.627, "+375 17 123-45-74", "11:00 - 23:00")
        ]
        
        var vasilkiRestaurants: [Restaurant] = []
        
        for (index, addressData) in vasilkiAddresses.enumerated() {
            let vasilki = Restaurant(context: context)
            vasilki.id = UUID()
            vasilki.name = "Васильки"
            vasilki.address = addressData.0
            vasilki.latitude = addressData.1
            vasilki.longitude = addressData.2
            vasilki.rating = 4.6 + Double(index) * 0.02
            vasilki.cuisineType = "Белорусская"
            vasilki.imageURL = "vasilki"
            vasilki.phone = addressData.3
            vasilki.workingHours = addressData.4
            vasilkiRestaurants.append(vasilki)
        }
        
        // MARK: - Расширенное меню для Васильков
        let vasilkiDishes: [(name: String, price: Double, category: String, description: String, isAvailable: Bool, imageURL: String?)] = [
            // 🥗 ЗАКУСКИ
            ("Салат Васильковый", 9.50, "Закуски", "Микс салата с курицей и апельсином", true, "salat_vasilkoviy"),
            ("Грибной жульен", 10.90, "Закуски", "Жульен из лесных грибов в сливочном соусе", true, "julien"),
            ("Брускетта с бужениной", 8.90, "Закуски", "Хрустящий брускетта с домашней бужениной", true, "brusketta"),
            
            // 🥣 СУПЫ
            ("Суп-пюре грибной", 9.50, "Супы", "Нежный суп-пюре из белых грибов", true, "sup_pure"),
            ("Солянка сборная", 10.90, "Супы", "Солянка с мясными деликатесами", true, "solyanka"),
            ("Бульон с курицей", 7.50, "Супы", "Прозрачный куриный бульон", true, "bulion"),
            
            // 🍖 ГОРЯЧИЕ БЛЮДА
            ("Котлета по-киевски", 14.50, "Горячие блюда", "Нежная куриная котлета с маслом", true, "kiev"),
            ("Свинина по-домашнему", 16.90, "Горячие блюда", "Запеченная свинина с картофелем", true, "svinina"),
            ("Утиная грудка", 21.90, "Горячие блюда", "Утиная грудка с клюквенным соусом", true, "utka"),
            ("Стейк из семги", 24.90, "Горячие блюда", "Стейк семги с овощами", true, "semga"),
            
            // 🥗 САЛАТЫ
            ("Цезарь с курицей", 11.90, "Салаты", "Классический Цезарь с курицей", true, "cezar"),
            ("Греческий салат", 10.50, "Салаты", "Салат с фетой и оливками", true, "grecheskiy"),
            ("Салат с тунцом", 13.90, "Салаты", "Салат с консервированным тунцом", true, "tunets"),
            
            // 🥞 БЛИНЫ
            ("Блинчики с семгой", 13.90, "Блины", "Блинчики со слабосоленой семгой", true, "bliny_semga"),
            ("Блинчики с ветчиной", 11.50, "Блины", "Блинчики с ветчиной и сыром", true, "bliny_vetchina"),
            ("Драники с семгой", 15.50, "Блины", "Драники с семгой и сливочным сыром", true, "draniki_semga"),
            
            // 🍰 ДЕСЕРТЫ
            ("Торт Ленинградский", 8.90, "Десерты", "Классический советский торт", true, "tort1"),
            ("Птичье молоко", 9.50, "Десерты", "Нежный суфлейный торт", true, "ptichye_moloko"),
            ("Чизкейк", 8.50, "Десерты", "Нью-Йорк чизкейк", true, "cheesecake"),
            ("Панкейки", 9.00, "Десерты", "Американские панкейки с кленовым сиропом", true, "pancake"),
            
            // 🥤 НАПИТКИ
            ("Морс брусничный", 6.00, "Напитки", "Освежающий морс из брусники", true, "mors_brusnika"),
            ("Лимонад домашний", 7.00, "Напитки", "Домашний лимонад с мятой", true, "limonad"),
            ("Смузи ягодный", 8.00, "Напитки", "Смузи из свежих ягод", true, "smuzi"),
            ("Глинтвейн", 9.00, "Напитки", "Горячий глинтвейн с пряностями", false, "glintwein"),
            ("Хреновуха", 7.00, "Напитки", "Традиционная настойка на хрене", true, "hrenovuha"),
        ]
        
        for vasilki in vasilkiRestaurants {
            for dishData in vasilkiDishes {
                let dish = Dish(context: context)
                dish.id = UUID()
                dish.name = dishData.name
                dish.price = dishData.price
                dish.category = dishData.category
                dish.dishDescription = dishData.description
                dish.isAvailable = dishData.isAvailable
                dish.imageURL = dishData.imageURL
                dish.restaurant = vasilki
            }
        }
        
        try? context.save()
        
        let totalDishes = litvinyDishes.count * 4 + vasilkiDishes.count * vasilkiRestaurants.count
        print("✅ Seed data saved successfully!")
        print("   - Рестораны Литвины: 4 шт.")
        print("   - Рестораны Васильки: \(vasilkiRestaurants.count) шт.")
        print("   - Всего блюд: \(totalDishes)")
        print("   - Категории: Закуски, Супы, Горячие блюда, Салаты, Блины, Десерты, Напитки")
    }
}
