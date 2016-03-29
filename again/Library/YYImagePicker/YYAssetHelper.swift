

import UIKit
import AssetsLibrary

var _sharedInstance:YYAssetHelper!

class YYAssetHelper: NSObject {
    
    var assetsLibrary:ALAssetsLibrary!
    var assetGroups:NSMutableArray!
    var assetPhotos:NSMutableArray!
    var bReverse:Bool!
    
    class func sharedAssetHelper()->YYAssetHelper{
        if !(_sharedInstance != nil){
            _sharedInstance = YYAssetHelper()
            _sharedInstance.initAsset()
        }
        return _sharedInstance
    }
    
    func initAsset(){
        if !(self.assetsLibrary != nil){
            self.assetsLibrary = ALAssetsLibrary()
            
            var strVersion = UIDevice()
            self.assetsLibrary.writeImageToSavedPhotosAlbum(nil, metadata: nil, completionBlock: {(assetURL:NSURL!, error:NSError!) -> Void in})
        }
    }
    
    func getGroupList(result:(NSArray)->()){
        self.initAsset()
      
        var assetGroupEnumerator = {(group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool> ) -> Void in
            
            if !(group != nil){
                result(self.assetGroups)
            }else{
                self.assetGroups.addObject(group)
            }
        }
        
        var assetGroupEnumberatorFailure = {(error:NSError!)->Void in
        }
        
        self.assetGroups = NSMutableArray()
        self.assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupType(ALAssetsGroupSavedPhotos), usingBlock: assetGroupEnumerator, failureBlock:assetGroupEnumberatorFailure)
    }
    
    func getPhotoListOfGroup(alGroup:ALAssetsGroup,result:(NSArray)->Void){
        self.initAsset()
        
        self.assetPhotos = NSMutableArray()
        //alGroup.setAssetsFilter(ALAssetsFilter.allPhotos())
        
        alGroup.enumerateAssetsUsingBlock({(alPhoto:ALAsset!, index:Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if alPhoto == nil {     //Question
                result(self.assetPhotos)
                return
            }else{
                self.assetPhotos.addObject(alPhoto)
            }
            })
    }
    
}
