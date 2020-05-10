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
        return builds.filter { $0.template(for: complation) != nil }.sorted()
    }

    func getSupportedTimeTravelDirections(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }

    func getTimelineStartDate(
        for complication: CLKComplication,
        withHandler handler: @escaping (Date?) -> Void) {
        let date = self.builds(for: complication).first?.timestamp
        handler(date)
    }

    func getTimelineEndDate(
        for complication: CLKComplication,
        withHandler handler: @escaping (Date?) -> Void) {
        let date = self.builds(for: complication).last?.timestamp
        handler(date)
    }

    func getPrivacyBehavior(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population

    func getCurrentTimelineEntry(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
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

    func getTimelineEntries(
        for complication: CLKComplication, before date: Date, limit: Int,
        withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let entries: [CLKComplicationTimelineEntry] = self.builds(for: complication)
            .filter { build in
                if let timestamp = build.timestamp, timestamp < date {
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

    func getTimelineEntries(
        for complication: CLKComplication, after date: Date, limit: Int,
        withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        let entries: [CLKComplicationTimelineEntry] = self.builds(for: complication)
            .filter { build in
                if let timestamp = build.timestamp, timestamp > date {
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

    func getTimelineAnimationBehavior(
        for complication: CLKComplication,
        withHandler handler: @escaping (CLKComplicationTimelineAnimationBehavior) -> Void) {
        handler(.grouped)
    }

    // MARK: - Placeholder Templates

    func getLocalizableSampleTemplate(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        handler(nil)
    }

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func template(for complication: CLKComplication) -> CLKComplicationTemplate {
        let appNameTextProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: "CI2Go")
        let emptyTextProvider = CLKTextProvider.localizableTextProvider(withStringsFileTextKey: "")
        switch complication.family {
        case .circularSmall:
            let tmpl = CLKComplicationTemplateCircularSmallSimpleImage()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-circularSmall"))
            return tmpl
        case .extraLarge:
            let tmpl = CLKComplicationTemplateExtraLargeSimpleImage()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-extraLarge"))
            return tmpl
        case .modularLarge:
            let tmpl = CLKComplicationTemplateModularLargeStandardBody()
            tmpl.headerImageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-modularLarge-header"))
            tmpl.headerTextProvider = emptyTextProvider
            tmpl.body1TextProvider = appNameTextProvider
            tmpl.body2TextProvider = emptyTextProvider
            return tmpl
        case .modularSmall:
            let tmpl = CLKComplicationTemplateModularSmallSimpleImage()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-modularSmall"))
            return tmpl
        case .utilitarianLarge:
            let tmpl = CLKComplicationTemplateUtilitarianLargeFlat()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-utilitarian"))
            tmpl.textProvider = appNameTextProvider
            return tmpl
        case .utilitarianSmallFlat, .utilitarianSmall:
            let tmpl = CLKComplicationTemplateUtilitarianSmallFlat()
            tmpl.imageProvider = CLKImageProvider(onePieceImage: #imageLiteral(resourceName: "appicon-utilitarian"))
            tmpl.textProvider = appNameTextProvider
            return tmpl
        case .graphicCorner:
            if #available(watchOSApplicationExtension 5.0, *) {
                let tmpl = CLKComplicationTemplateGraphicCornerTextImage()
                tmpl.imageProvider = CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "appicon-utilitarian"))
                tmpl.textProvider = appNameTextProvider
                return tmpl
            } else {
                fatalError()
            }
        case .graphicBezel:
            if #available(watchOSApplicationExtension 5.0, *) {
                let tmpl = CLKComplicationTemplateGraphicBezelCircularText()
                tmpl.textProvider = appNameTextProvider
                return tmpl
            } else {
                fatalError()
            }
        case .graphicCircular:
            if #available(watchOSApplicationExtension 5.0, *) {
                let tmpl = CLKComplicationTemplateGraphicCircularOpenGaugeImage()
                tmpl.bottomImageProvider = CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "appicon-utilitarian"))
                return tmpl
            } else {
                fatalError()
            }
        case .graphicRectangular:
            if #available(watchOSApplicationExtension 5.0, *) {
                let tmpl = CLKComplicationTemplateGraphicRectangularLargeImage()
                tmpl.imageProvider = CLKFullColorImageProvider(fullColorImage: #imageLiteral(resourceName: "appicon-utilitarian"))
                tmpl.textProvider = appNameTextProvider
                return tmpl
            } else {
                fatalError()
            }
        @unknown default:
            fatalError()
        }
    }
}
