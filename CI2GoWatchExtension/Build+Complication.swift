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
            return successImage(for: complication)
        case .failed:
            return failedImage(for: complication)
        default:
            fatalError("Unsupported status: \(rawValue)")
        }
    }

    private func successImage(for complication: CLKComplication) -> UIImage {
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
    }

    private func failedImage(for complication: CLKComplication) -> UIImage {
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
    }
}

extension Build {
    func template(for complication: CLKComplication) -> CLKComplicationTemplate? {
        let visibleStatuses: [Build.Status] = [.success, .fixed, .failed]
        guard timestamp != nil && visibleStatuses.contains(status) else {
            return nil
        }
        switch complication.family {
        case .circularSmall:
            return circularSmallTemplate(for: complication)
        case .extraLarge:
            return extraLargeTemplate(for: complication)
        case .modularLarge:
            return modularLargeTemplate(for: complication)
        case .modularSmall:
            return modularSmallTemplate(for: complication)
        case .utilitarianLarge:
            return utilitarianLargeTemplate(for: complication)
        case .utilitarianSmallFlat, .utilitarianSmall:
            return utilitarianSmallTemplate(for: complication)
        }
    }

    func circularSmallTemplate(for complication: CLKComplication) -> CLKComplicationTemplateCircularSmallStackImage {
        let tmpl = CLKComplicationTemplateCircularSmallStackImage()
        tmpl.line1ImageProvider = complicationImageProvider(for: complication)
        tmpl.line2TextProvider = complicationBuildNumberProvider
        tmpl.tintColor = status.color
        return tmpl
    }

    func extraLargeTemplate(for complication: CLKComplication) -> CLKComplicationTemplateExtraLargeStackImage {
        let tmpl = CLKComplicationTemplateExtraLargeStackImage()
        tmpl.line1ImageProvider = complicationImageProvider(for: complication)
        tmpl.line2TextProvider = complicationBuildNumberProvider
        tmpl.tintColor = status.color
        return tmpl
    }

    func modularLargeTemplate(for complication: CLKComplication) -> CLKComplicationTemplateModularLargeStandardBody {
        let tmpl = CLKComplicationTemplateModularLargeStandardBody()
        tmpl.headerImageProvider = complicationImageProvider(for: complication)
        tmpl.headerTextProvider = complicationBuildNumberProvider
        tmpl.body1TextProvider = complicationProjectNameProvider
        tmpl.body2TextProvider = complicationBranchNameProvider
        tmpl.tintColor = status.color
        return tmpl
    }

    func modularSmallTemplate(for complication: CLKComplication) -> CLKComplicationTemplateModularSmallStackImage {
        let tmpl = CLKComplicationTemplateModularSmallStackImage()
        tmpl.line1ImageProvider = complicationImageProvider(for: complication)
        tmpl.line2TextProvider = complicationBuildNumberProvider
        tmpl.tintColor = status.color
        tmpl.highlightLine2 = false
        return tmpl
    }

    func utilitarianLargeTemplate(for complication: CLKComplication) -> CLKComplicationTemplateUtilitarianLargeFlat {
        let tmpl = CLKComplicationTemplateUtilitarianLargeFlat()
        tmpl.imageProvider = complicationImageProvider(for: complication)
        tmpl.textProvider = complicationProjectNameProvider
        tmpl.tintColor = status.color
        return tmpl
    }

    func utilitarianSmallTemplate(for complication: CLKComplication) -> CLKComplicationTemplateUtilitarianSmallFlat {
        let tmpl = CLKComplicationTemplateUtilitarianSmallFlat()
        tmpl.imageProvider = complicationImageProvider(for: complication)
        tmpl.textProvider = complicationBuildNumberProvider
        tmpl.tintColor = status.color
        return tmpl
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
