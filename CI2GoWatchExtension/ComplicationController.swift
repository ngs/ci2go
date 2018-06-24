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
        // This method will be called once per supported complication, and the results will be cached
        handler(nil)
    }
    
}
