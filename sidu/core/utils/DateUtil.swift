//
//  DateUtil.swift
//  sidu
//
//  Created by Armstrong Liu on 04/09/2024.
//

import Foundation

class DateUtil {
    static let shared = DateUtil()
    
    private init() {}
    
    func standardDateFormat(_ timeStampSince1970: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeStampSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        return dateFormatter.string(from: date)
    }
    
    func customDateFormat(_ timeStampSince1970: TimeInterval, format: String) -> String {
        let date = Date(timeIntervalSince1970: timeStampSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func decideToShowDateTime(_ timeStampSince1970: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeStampSince1970)
        let calendar = Calendar.current
        
        let dateFormatter = DateFormatter()
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            dateFormatter.dateFormat = "HH:mm"
            return "Yesterday \(dateFormatter.string(from: date))"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            return dateFormatter.string(from: date)
        }
    }
    
    func compareTimeDifference(startTimeStamp: TimeInterval, endTimeStamp: TimeInterval, inUnit: Calendar.Component) -> Int {
        let startDate = Date(timeIntervalSince1970: startTimeStamp)
        let endDate = Date(timeIntervalSince1970: endTimeStamp)
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([inUnit], from: startDate, to: endDate)
        return dateComponents.value(for: inUnit) ?? 0
    }
}
