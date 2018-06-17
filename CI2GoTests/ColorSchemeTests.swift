//
//  ColorSchemeTests.swift
//  CI2GoTests
//
//  Created by Atsushi Nagase on 2018/06/17.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import XCTest
@testable import CI2Go

class ColorSchemeTests: XCTestCase {
    
    func testPerformanceExample() {
        self.measure {
            XCTAssertEqual(ColorScheme.names.count, 116)
        }
    }
    
    func testNames() {
        XCTAssertEqual([
            "3024 Day", "3024 Night", "AdventureTime", "Afterglow", "AlienBlood", "Argonaut", "Arthur", "Atom",
            "Belafonte Day", "Belafonte Night", "BirdsOfParadise", "Blazer", "Broadcast", "Brogrammer", "C64",
            "Chalk", "Chalkboard", "Ciapre", "CLRS", "Cobalt2", "CrayonPonyFish", "Dark Pastel", "Darkside",
            "Desert", "DimmedMonokai", "Dracula", "Earthsong", "Elemental", "Espresso", "Espresso Libre", "FishTank",
            "Flat", "FrontEndDelight", "FunForrest", "Github", "Grape", "Grass", "Hardcore", "Harper", "Highway",
            "Hipster Green", "Homebrew", "Hurtado", "Hybrid", "IC_Green_PPL", "IC_Orange_PPL", "idleToes", "IR_Black",
            "Jackie Brown", "Japanesque", "Jellybeans", "Kibble", "Lavandula", "LiquidCarbon", "LiquidCarbonTransparent",
            "LiquidCarbonTransparentInverse", "Man Page", "Mathias", "Medallion", "Misterioso", "Molokai", "MonaLisa",
            "Monokai Soda", "N0tch2k", "Neopolitan", "NightLion v1", "NightLion v2", "Novel", "Obsidian", "Ocean", "Ollie",
            "Parasio Dark", "PaulMillr", "PencilDark", "PencilLight", "Pnevma", "Pro", "Red Alert", "Red Sands",
            "Rippedcasts", "Royal", "Seafoam Pastel", "SeaShells", "Seti", "Shaman", "Smyck", "SoftServer", "Solarized Darcula",
            "Solarized Dark", "Solarized Dark Higher Contrast", "Solarized Light", "Spacedust", "SpaceGray", "Spring",
            "Square", "Sundried", "Symfonic", "Teerb", "Terminal Basic", "Thayer Bright", "Tomorrow", "Tomorrow Night",
            "Tomorrow Night Blue", "Tomorrow Night Bright", "Tomorrow Night Eighties", "ToyChest", "Treehouse", "Twilight",
            "Urple", "Vaughn", "VibrantInk", "WarmNeon", "Wez", "Wombat", "Wryan", "Zenburn"], ColorScheme.names)
    }

    func testInit() {
        ColorScheme.names.forEach { name in
            let color = ColorScheme(name)
            XCTAssertNotNil(color)
            XCTAssertNotNil(color?.configuration)
            XCTAssertNotNil(color?.createANSIEscapeHelper())
            XCTAssertEqual([
                "Ansi 0 Color", "Ansi 1 Color", "Ansi 10 Color", "Ansi 11 Color",
                "Ansi 12 Color", "Ansi 13 Color", "Ansi 14 Color", "Ansi 15 Color",
                "Ansi 2 Color", "Ansi 3 Color", "Ansi 4 Color", "Ansi 5 Color",
                "Ansi 6 Color", "Ansi 7 Color", "Ansi 8 Color", "Ansi 9 Color",
                "Background Color", "Bold Color", "Cursor Color", "Cursor Text Color",
                "Foreground Color", "Selected Text Color", "Selection Color"
                ], Array(color!.configuration.keys).sorted(), name)
        }
    }

    func testInitNil() {
        let color = ColorScheme("Tomorrow Morning")
        XCTAssertNil(color)
    }
    
}
