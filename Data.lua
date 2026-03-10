GuildCD_RaidIDs = {
    ["Karazhan"] = "KZ", ["Каражан"] = "KZ",
    ["Gruul's Lair"] = "GL", ["Логово Груула"] = "GL",
    ["Magtheridon's Lair"] = "ML", ["Логово Магтеридона"] = "ML",
    ["Serpentshrine Cavern"] = "SSC", ["Змеиное святилище"] = "SSC",
    ["The Eye"] = "TK", ["Крепость Бурь"] = "TK",
    ["Battle for Mount Hyjal"] = "HYJ", ["Битва за гору Хиджал"] = "HYJ",
    ["Black Temple"] = "BT", ["Черный храм"] = "BT",
    ["Sunwell Plateau"] = "SWP", ["Плато Солнечного Колодца"] = "SWP",
    ["Mogu'shan Vaults"] = "MV", ["Подземелья Могу'шан"] = "MV",
    ["Heart of Fear"] = "HOF", ["Сердце Страха"] = "HOF",
    ["Terrace of Endless Spring"] = "TES", ["Терраса Вечной Весны"] = "TES",
    ["Throne of Thunder"] = "TOT", ["Престол Грез"] = "TOT",
    ["Siege of Orgrimmar"] = "SOO", ["Осада Оргриммара"] = "SOO",
    ["Nerub'ar Palace"] = "NP", ["Неруб'арский дворец"] = "NP",
    ["Liberation of Undermine"] = "LOU", ["Освобождение Нижней Шахты"] = "LOU",
    ["Sunwell's Eclipse"] = "SE", ["Затмение Солнечного Колодца"] = "SE",
    ["Void-Purge of Quel'Thalas"] = "VP", ["Очищение Кель'Таласа от Бездны"] = "VP",
    ["The Ethereal Bastion"] = "EB", ["Эфириальный Бастион"] = "EB",
    ["Molten Core"] = "MC", ["Огненные Недра"] = "MC" -- Добавлено
}

GuildCD_Database = {
    ["KZ"] = { 
        name = "Karazhan", 
        bosses = {
            {en="Attumen", ru="Полночь"}, {en="Moroes", ru="Мороуз"}, {en="Maiden", ru="Благочестивая дева"}, 
            {en="Opera", ru="Оперный театр"}, {en="Curator", ru="Куратор"}, {en="Terestian", ru="Терестиан Больное Копыто"}, 
            {en="Aran", ru="Тень Арана"}, {en="Netherspite", ru="Гнев Пустоты"}, {en="Chess", ru="Шахматы"}, 
            {en="Prince", ru="Принц Малчезар"}, {en="Nightbane", ru="Погибель"}
        } 
    },
    ["BT"] = { 
        name = "Black Temple", 
        bosses = {
            {en="Naj'entus", ru="Наджентус"}, {en="Supremus", ru="Супремус"}, {en="Akama", ru="Акама"}, 
            {en="Gorefiend", ru="Терон Кровожад"}, {en="Bloodboil", ru="Гуртогг Кипящая Кровь"}, 
            {en="Reliquary", ru="Реликвия Душ"}, {en="Shahraz", ru="Матушка Шахраз"}, 
            {en="Council", ru="Совет Иллидари"}, {en="Illidan", ru="Иллидан Ярость Бури"}
        } 
    },
    ["SWP"] = { 
        name = "Sunwell Plateau", 
        bosses = {
            {en="Kalecgos", ru="Калесгос"}, {en="Brutallus", ru="Бруталл"}, {en="Felmyst", ru="Пророк Скверны"}, 
            {en="Twins", ru="Эредарские близнецы"}, {en="M'uru", ru="М'ууру"}, {en="Kil'jaeden", ru="Кил'джеден"}
        } 
    },
    ["MC"] = { -- Добавлен рейд Molten Core
        name = "Molten Core",
        bosses = {
            {en="Lucifron", ru="Люцифрон"}, {en="Magmadar", ru="Магмадар"}, {en="Gehennas", ru="Гееннас"}, 
            {en="Garr", ru="Гарр"}, {en="Baron Geddon", ru="Барон Геддон"}, {en="Shazzrah", ru="Шаззрах"}, 
            {en="Sulfuron Harbinger", ru="Предвестник Сульфурон"}, {en="Golemagg", ru="Големагг Испепелитель"}, 
            {en="Majordomo Executus", ru="Мажордом Экзекутус"}, {en="Ragnaros", ru="Рагнарос"}
        }
    },
    ["SOO"] = { 
        name = "Siege of Orgrimmar", 
        bosses = {
            {en="Immerseus", ru="Глубиний"}, {en="Protectors", ru="Защитники"}, {en="Norushen", ru="Норушен"}, 
            {en="Sha of Pride", ru="Ша Гордыни"}, {en="Galakras", ru="Галакрас"}, {en="Juggernaut", ru="Железный исполин"}, 
            {en="Shamans", ru="Шаманы"}, {en="Nazgrim", ru="Назгрим"}, {en="Malkorok", ru="Малкорок"}, 
            {en="Spoils", ru="Трофеи Пандарии"}, {en="Thok", ru="Ток Кровожадный"}, 
            {en="Siegecrafter", ru="Мастер осады Черноплавс"}, {en="Paragons", ru="Клакси"}, {en="Garrosh", ru="Гаррош Адский Крик"}
        } 
    },
    ["NP"] = { 
        name = "Nerub'ar Palace", 
        bosses = {
            {en="Ulgrax", ru="Ульгракс"}, {en="Horror", ru="Ужас"}, {en="Sikran", ru="Сикран"}, 
            {en="Rasha'nan", ru="Раша'нан"}, {en="Ovi'nax", ru="Ови'накс"}, {en="Ky'veza", ru="Ки'веза"}, 
            {en="Court", ru="Силковый двор"}, {en="Ansurek", ru="Ансурек"}
        } 
    },
    -- ... (Остальные рейды заполняются по аналогии)
}