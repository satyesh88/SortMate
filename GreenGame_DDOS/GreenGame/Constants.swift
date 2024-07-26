//
//  Constants.swift
//  GreenGame
//
//  Created by Satyesh Shivam on 14/06/24.
//

import Foundation

let RESTMULL_CLASSES = [
    "Cold Ashes", "Ballpoint pen refills", "Bones", "Carbon paper",
    "Cat litter", "Cigarette butts", "Condoms", "Diapers", "Discs, cassettes",
    "Disk records", "Disposable lighters", "Leather", "Light bulbs", "Meat and cheese wrappings",
    "Medicaments", "Paper napkins (dyed)", "Paper tissues", "Photos", "film negatives", "slides",
    "Rags", "Rubber", "Sanitary products", "Sweepings", "Tooth brushes",
    "Vacuum cleaner bags", "Waste fabric", "Wax", "Writing utensils"
]

let BIO_BIN_CLASSES = [
    "Absorbent paper", "Balcony plants", "Coffee filters",
    "Egg cartons", "Eggshells", "Fallen fruits", "Food remains",
    "Grass", "Hair", "Feathers", "Hedge trimmings", "Leaves", "Orange peels",
    "Plant remains", "Shrub trimmings", "Small animal litter", "Soil",
    "Spoiled or mouldy food", "Wood wool"
]

let YELLOW_MULL = [
    "Aluminium foil and cans Bottle", "Bottles (plastic)","Coffee packaging","Juice cartons","Milk cartons","Paint buckets (empty)","Plastic bags Polystyrene","Tetra packs","Tubes","Yoghurt cups"
]

let BLUE_PAPER_MULL = ["Books","Boxes made of paper Brochures", "Cardboard containers Catalogues", "Detergent boxes","Dyed paper","Envelopes", "Flour and sugar paper bags", "Newspapers", "magazines", "Waste paper","Writing paper"]

let ALL_CLASSES = RESTMULL_CLASSES + BIO_BIN_CLASSES + YELLOW_MULL + BLUE_PAPER_MULL
let apiKey = "YOUR OPENAI API KEY"
let apiBase = "https://api.openai.com/v1/chat/completions"

