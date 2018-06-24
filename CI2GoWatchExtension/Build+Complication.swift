//
//  Build+Complication.swift
//  CI2GoWatchExtension
//
//  Created by Atsushi Nagase on 2018/06/24.
//  Copyright © 2018 LittleApps Inc. All rights reserved.
//

import Foundation
import ClockKit

extension Build.Status {
    func complicationImage(for complication: CLKComplication) -> UIImage {
        switch self {
        case .success, .fixed:
            switch complication.family {
            case .circularSmall:
                return #imageLiteral(resourceName: "success-circularSmall")
            case .extraLarge:
                return #imageLiteral(resourceName: "success-circle-extraLarge")
            case .modularLarge:
                return #imageLiteral(resourceName: "success-circle-modularLarge-header")
            case .modularSmall:
                return #imageLiteral(resourceName: "success-modularSmall")
            case .utilitarianLarge, .utilitarianSmallFlat, .utilitarianSmall:
                return #imageLiteral(resourceName: "success-utilitarian")
            }
        case .failed:
            switch complication.family {
            case .circularSmall:
                return #imageLiteral(resourceName: "failed-circularSmall")
            case .extraLarge:
                return #imageLiteral(resourceName: "failed-circle-extraLarge")
            case .modularLarge:
                return #imageLiteral(resourceName: "failed-circle-modularLarge-header")
            case .modularSmall:
                return #imageLiteral(resourceName: "failed-modularSmall")
            case .utilitarianLarge, .utilitarianSmallFlat, .utilitarianSmall:
                return #imageLiteral(resourceName: "failed-utilitarian")
            }
        default:
            fatalError("Unsupported status: \(rawValue)")
        }
    }
}

extension Build {
    func template(for complication: CLKComplication) -> CLKComplicationTemplate? {
        let visibleStatuses: [Build.Status] = [.success, .fixed, .failed]
        guard let _ = timestamp, visibleStatuses.contains(status) else {
            return nil
        }
        let tintColor = status.color
        switch complication.family {
        case .circularSmall:
            let t = CLKComplicationTemplateCircularSmallStackImage()
            t.line1ImageProvider = complicationImageProvider(for: complication)
            t.line2TextProvider = complicationBuildNumberProvider
            t.tintColor = tintColor
            return t
        case .extraLarge:
            let t = CLKComplicationTemplateExtraLargeStackImage()
            t.line1ImageProvider = complicationImageProvider(for: complication)
            t.line2TextProvider = complicationBuildNumberProvider
            t.tintColor = tintColor
            return t
        case .modularLarge:
            let t = CLKComplicationTemplateModularLargeStandardBody()
            t.headerImageProvider = complicationImageProvider(for: complication)
            t.headerTextProvider = complicationBuildNumberProvider
            t.body1TextProvider = complicationProjectNameProvider
            t.body2TextProvider = complicationBranchNameProvider
            t.tintColor = tintColor
            return t
        case .modularSmall:
            let t = CLKComplicationTemplateModularSmallStackImage()
            t.line1ImageProvider = complicationImageProvider(for: complication)
            t.line2TextProvider = complicationBuildNumberProvider
            t.tintColor = tintColor
            t.highlightLine2 = false
            return t
        case .utilitarianLarge:
            let t = CLKComplicationTemplateUtilitarianLargeFlat()
            t.imageProvider = complicationImageProvider(for: complication)
            t.textProvider = complicationProjectNameProvider
            t.tintColor = tintColor
            return t
        case .utilitarianSmallFlat, .utilitarianSmall:
            let t = CLKComplicationTemplateUtilitarianSmallFlat()
            t.imageProvider = complicationImageProvider(for: complication)
            t.textProvider = complicationBuildNumberProvider
            t.tintColor = tintColor
            return t
        }
    }

    func complicationImageProvider(for complication: CLKComplication) -> CLKImageProvider {
        return CLKImageProvider(onePieceImage: status.complicationImage(for: complication))
    }

    var complicationBuildNumberProvider: CLKTextProvider {
        return CLKTextProvider.localizableTextProvider(withStringsFileTextKey: "\(number)")
    }

    var complicationProjectNameProvider: CLKTextProvider {
        return CLKTextProvider.localizableTextProvider(withStringsFileTextKey: project.path, shortTextKey: project.name)
    }

    var complicationBranchNameProvider: CLKTextProvider {
        return CLKTextProvider.localizableTextProvider(withStringsFileTextKey: branch?.name ?? "")
    }

    var complicationBodyTextProvider: CLKTextProvider {
        return CLKTextProvider.localizableTextProvider(withStringsFileTextKey: body)
    }

    var complicationUsernameProvider: CLKTextProvider {
        return CLKTextProvider.localizableTextProvider(withStringsFileTextKey: user?.name ?? "")
    }

    var complicationStatusTextProvider: CLKTextProvider {
        return CLKTextProvider.localizableTextProvider(withStringsFileTextKey: status.humanize)
    }
}
