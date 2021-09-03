//
//  Scale.swift
//  XCap
//
//  Created by scchn on 2021/5/31.
//

import Foundation

import SwiftyUserDefaults
import DifferenceKit

class Scale: NSObject, Codable {
    
    fileprivate(set)
    var identifier: String
    
    fileprivate(set)
    var fov: CGFloat
    
    fileprivate(set)
    var unit: Unit
    
    fileprivate(set)
    var name: String?
    
    init(fov: CGFloat, unit: Unit, name: String?) {
        self.identifier = UUID().uuidString
        self.name = name
        self.fov = fov
        self.unit = unit
    }
    
}

extension Scale: DefaultsSerializable {
    
    static func ==(lhs: Scale, rhs: Scale) -> Bool {
        lhs.identifier == rhs.identifier
            && lhs.name == rhs.name
            && lhs.fov == rhs.fov
            && lhs.unit == rhs.unit
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let scale = object as? Scale else { return false }
        return self == scale
    }
    
}

extension DefaultsAdapter where KeyStore == DefaultsKeys {
    
    static let didRenameScaleNotification = Notification.Name("com.scchn.XCap.DefaultsAdapter.didRenameScaleNotification")
    
    /// 更名後會發出 `DefaultsAdapter.didRenameScaleNotification`，`object` 的值為比例尺的 ID。
    func renameScale(scale: Scale, name: String) {
        guard scale.name != name else { return }
        guard let index = self.scales.firstIndex(of: scale) else { return }
        scale.name = name
        self.scales.remove(at: index)
        self.scales.insert(scale, at: index)
        
        NotificationCenter.default
            .post(name: Self.didRenameScaleNotification, object: scale.identifier)
    }
    
    /// 未重複並新增成功，回傳 `true`，反之則回傳 `false`。
    @discardableResult
    func addScale(_ scale: Scale, renameTo name: String, unit: Unit? = nil) -> Bool {
        guard !self.scales.contains(scale) else { return false }
        let unit = unit ?? scale.unit
        let fov = scale.unit.convert(value: scale.fov, to: unit)
        scale.name = name
        scale.fov = fov
        scale.unit = unit
        self.scales.append(scale)
        return true
    }
    
}
