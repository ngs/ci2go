//
//  ComplicationController.swift
//  CI2GoWatch Extension
//
//  Created by Atsushi Nagase on 2018/06/23.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration

    lazy var builds: [Build] = {
        return [Build].fromCache() ?? []
    }()

    func builds(for complation: CLKComplication) -> [Build] {
        return builds.filter{ $0.template(for: complation) != nil }.sorted()
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let date = self.builds(for: complication).first?.timestamp
        handler(date)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let date = self.builds(for: complication).last?.timestamp
        handler(date)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Call the handler with the current timeline entry
        guard
            let build = self.builds(for: complication).last,
            let date = build.timestamp,
            let template = build.template(for: complication)
            else {
                handler(nil)
                return }
        let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let entries: [CLKComplicationTimelineEntry] = self.builds(for: complication)
            .filter { build in
                if let ts = build.timestamp, ts < date {
                    return true
                }
                return false
            }
            .prefix(limit)
            .map { build in
                return CLKComplicationTimelineEntry(
                    date: build.timestamp!,
                    complicationTemplate: build.template(for: complication)!
                )
        }
        handler(entries)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let entries: [CLKComplicationTimelineEntry] = self.builds(for: complication)
            .filter { build in
                if let ts = build.timestamp, ts > date {
                    return true
                }
                return false
            }
            .prefix(limit)
            .map { build in
                return CLKComplicationTimelineEntry(
                    date: build.timestamp!,
                    complicationTemplate: build.template(for: complication)!
                )
        }
        handler(entries)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(nil)
    }

    func template(for complication: CLKComplication) -> CLKComplicationTemplate {
        let appNameTextProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: "CI2Go")
        let emptyTextProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: "")
        switch complication.family {
        case .circularSmall:
            let t = CLKComplicationTemplateCircularSmallSimpleImage()
            t.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-circularSmall"))
            return t
        case .extraLarge:
            let t = CLKComplicationTemplateExtraLargeSimpleImage()
            t.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-extraLarge"))
            return t
        case .modularLarge:
            let t = CLKComplicationTemplateModularLargeStandardBody()
            t.headerImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-modularLarge-header"))
            t.headerTextProvider = emptyTextProvider
            t.body1TextProvider = appNameTextProvider
            t.body2TextProvider = emptyTextProvider
            return t
        case .modularSmall:
            let t = CLKComplicationTemplateModularSmallSimpleImage()
            t.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-modularSmall"))
            return t
        case .utilitarianLarge:
            let t = CLKComplicationTemplateUtilitarianLargeFlat()
            t.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-utilitarian"))
            t.textProvider = appNameTextProvider
            return t
        case .utilitarianSmallFlat, .utilitarianSmall:
            let t = CLKComplicationTemplateUtilitarianSmallFlat()
            t.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-utilitarian"))
            t.textProvider = appNameTextProvider
            return t
        }
    }
}
