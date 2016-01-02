//
//  ColorSchemeSpec.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 1/2/16.
//  Copyright © 2016 LittleApps Inc. All rights reserved.
//

import Foundation
import Quick
import Nimble
import OHHTTPStubs

@testable import CI2Go

class ColorSchemeSpec: QuickSpec {
    override func spec() {
        let names = ["3024 Day", "3024 Night", "AdventureTime", "Afterglow", "AlienBlood", "Argonaut", "Arthur", "Atom",
            "Belafonte Day", "Belafonte Night", "BirdsOfParadise", "Blazer", "Broadcast", "Brogrammer", "C64", "Chalk",
            "Chalkboard", "Ciapre", "CLRS", "Cobalt2", "CrayonPonyFish", "Dark Pastel", "Darkside", "Desert", "DimmedMonokai",
            "Dracula", "Earthsong", "Elemental", "Espresso Libre", "Espresso", "FishTank", "Flat", "FrontEndDelight",
            "FunForrest", "Github", "Grape", "Grass", "Hardcore", "Harper", "Highway", "Hipster Green", "Homebrew",
            "Hurtado", "Hybrid", "IC_Green_PPL", "IC_Orange_PPL", "idleToes", "IR_Black", "Jackie Brown", "Japanesque",
            "Jellybeans", "Kibble", "Lavandula", "LiquidCarbon", "LiquidCarbonTransparent", "LiquidCarbonTransparentInverse",
            "Man Page", "Mathias", "Medallion", "Misterioso", "Molokai", "MonaLisa", "Monokai Soda", "N0tch2k", "Neopolitan",
            "NightLion v1", "NightLion v2", "Novel", "Obsidian", "Ocean", "Ollie", "Parasio Dark", "PaulMillr", "PencilDark",
            "PencilLight", "Pnevma", "Pro", "Red Alert", "Red Sands", "Rippedcasts", "Royal", "Seafoam Pastel", "SeaShells",
            "Seti", "Shaman", "Smyck", "SoftServer", "Solarized Darcula", "Solarized Dark Higher Contrast", "Solarized Dark",
            "Solarized Light", "Spacedust", "SpaceGray", "Spring", "Square", "Sundried", "Symfonic", "Teerb", "Terminal Basic",
            "Thayer Bright", "Tomorrow Night Blue", "Tomorrow Night Bright", "Tomorrow Night Eighties", "Tomorrow Night",
            "Tomorrow", "ToyChest", "Treehouse", "Twilight", "Urple", "Vaughn", "VibrantInk", "WarmNeon", "Wez", "Wombat",
            "Wryan", "Zenburn"]

        describe("::names()") {
            it("loads names from bundled files") {
                expect(ColorScheme.names).to(haveCount(116))
                expect(ColorScheme.names).to(equal(names))
            }
        }
        describe("initializer") {
            it("returns non-nil if name is valid") {
                expect(ColorScheme("Tomorrow Night Bright")).notTo(beNil())
                expect(ColorScheme("Tomorrow Night Bright")?.name).to(equal("Tomorrow Night Bright"))
            }
            it("returns nil if name is invalid") {
                expect(ColorScheme("Foo")).to(beNil())
            }
        }
        describe("dictionary") {
            it("returns dictionary by loading scheme file") {
                for name in ColorScheme.names {
                    expect(ColorScheme(name)?.dictionary).notTo(beNil())
                    expect(ColorScheme(name)!.dictionary.keys.sort()).to(contain(
                        "Ansi 0 Color", "Ansi 1 Color", "Ansi 10 Color", "Ansi 11 Color", "Ansi 12 Color",
                        "Ansi 13 Color", "Ansi 14 Color", "Ansi 15 Color", "Ansi 2 Color", "Ansi 3 Color",
                        "Ansi 4 Color", "Ansi 5 Color", "Ansi 6 Color", "Ansi 7 Color", "Ansi 8 Color",
                        "Ansi 9 Color", "Background Color", "Cursor Color",
                        "Cursor Text Color", "Foreground Color"))
                }
            }
        }
        describe("color") {
            it("returns color from key") {
                expect(ColorScheme("Tomorrow Night Bright")?.color(key: "Selection")).notTo(beNil())
            }
            it("returns color from ansi color code") {
                expect(ColorScheme("Tomorrow Night Bright")?.color(code: 7)).notTo(beNil())
            }
        }
    }
}