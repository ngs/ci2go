//
//  CI2GoManagedObject.swift
//  CI2Go
//
//  Created by Atsushi Nagase on 11/1/14.
//  Copyright (c) 2014 LittleApps Inc. All rights reserved.
//

import Foundation
import CoreData

public class CI2GoManagedObject :NSManagedObject {


  public class func idFromObjectData(data: AnyObject!) -> String? {
    return nil
  }

  public class func addPrimaryAttributeWithObjectData(data: AnyObject!) -> NSDictionary? {
    if let dict  = data as? NSDictionary {
      if let id = idFromObjectData(data) {
        let key = MR_primaryKeyNameFromString(entityName.componentsSeparatedByString("_")[0])
        let mDict = dict.mutableCopy() as! NSMutableDictionary
        mDict.setValue(id, forKey: key)
        let nullKeys = mDict.allKeysForObject(NSNull())
        mDict.removeObjectsForKeys(nullKeys)
        return mDict.copy() as? NSDictionary
      }
      return dict
    }
    return nil
  }

  public override class func MR_importFromObject(data: AnyObject!, inContext context: NSManagedObjectContext!) -> CI2GoManagedObject! {
    let data2 = addPrimaryAttributeWithObjectData(data)
    return super.MR_importFromObject(data2, inContext: context) as! CI2GoManagedObject
  }
  
  public override func MR_importValuesForKeysWithObject(data: AnyObject!) -> Bool {
    let data2 = self.dynamicType.addPrimaryAttributeWithObjectData(data)
    return super.MR_importValuesForKeysWithObject(data2)
  }
  

  public class func MR_findOrCreateByAttribute(attribute: NSString, withValue searchValue: AnyObject!) -> CI2GoManagedObject! {
    var ret = MR_findFirstByAttribute(attribute as String, withValue: searchValue)
    if nil != ret {
      return ret
    }
    ret = MR_createEntity()
    ret.setValue(searchValue, forKey: attribute as String)
    return ret
  }

  public override func MR_relatedValueForRelationship(relationshipInfo: NSRelationshipDescription!) -> AnyObject! {
    return super.MR_relatedValueForRelationship(relationshipInfo)
  }

  public override func MR_findObjectForRelationship(relationshipInfo: NSRelationshipDescription!, withData singleRelatedObjectData: AnyObject!) -> NSManagedObject! {
    let klazz: AnyClass! = NSClassFromString(relationshipInfo.destinationEntity?.managedObjectClassName)
    let data2 = klazz.addPrimaryAttributeWithObjectData(singleRelatedObjectData)
    return super.MR_findObjectForRelationship(relationshipInfo, withData: data2)
  }

  

}
