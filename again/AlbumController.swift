//
//  AlbumController.swift
//  again
//
//  Created by user on 14/12/6.
//  Copyright (c) 2014年 yzlpie. All rights reserved.
//

import UIKit
import AssetsLibrary

class AlbumController: UICollectionViewController, UICollectionViewDataSource,UICollectionViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, YYImagePickerDelegate {
    
    var albumID:String!
    
    var photoList:NSArray?
    

    @IBOutlet weak var cv: UICollectionView!
    
    @IBOutlet weak var returnBtn: UIBarButtonItem!
    
    @IBAction func onClickReturn(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickTakePhoto(sender: UIBarButtonItem) {
        let photoSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: "拍照", otherButtonTitles: "从手机相册选择")
        photoSheet.showInView(self.view)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        returnBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(24)], forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        photoList = FileUtils.subDirList(albumID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //println("\(photoList!.count)")
        return photoList!.count
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell:PhotoCell = self.cv.dequeueReusableCellWithReuseIdentifier("photoList", forIndexPath: indexPath) as PhotoCell
        let fileName = photoList![indexPath.row] as String
        let data = FileUtils.readBinFile(albumID, fileName: fileName)
        cell.iv.image = UIImage(data: data)
        cell.label.text = fileName
        cell.label.hidden = true
        
        return cell
    }
    
//    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
//        let title = actionSheet.buttonTitleAtIndex(buttonIndex)
//        if(title == "从手机相册选择") {
//            if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
//                localPhotoIpad()
//            } else {
//                localPhotoIphone()
//            }
//        } else if (title == "拍照") {
//            takePhoto()
//        }
//    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        let title = actionSheet.buttonTitleAtIndex(buttonIndex)
        if(title == "从手机相册选择") {
//            localPhotoSingle()
            localPhotoMultiple()

        } else if (title == "拍照") {
            takePhoto()
        }
    }
    

    func localPhotoSingle() {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        self.presentViewController(picker, animated: true, nil)
    }
    
    func localPhotoMultiple() {
        show()
    }
    
    func takePhoto() {
        //拍照
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            let picker = UIImagePickerController()
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            picker.allowsEditing = true
            self.presentViewController(picker, animated: true, nil)
        } else {
            let alert = UIAlertView()
            alert.title = "抱歉"
            alert.message = "该设备没有摄像头"
            alert.addButtonWithTitle("知道了")
            alert.show()
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as UIImage
        var imageData:NSData?;
        var ext:String?

        imageData = UIImageJPEGRepresentation(image, 0.5)
        if (imageData != nil) {
            ext = ".jpg"
        }else {
            imageData = UIImagePNGRepresentation(image);
            ext = ".png"
        }
        dismissViewControllerAnimated(true, nil)
        let filename = "\(albumID)_\(arc4random())\(ext)"
        //println("New file name: \(filename)")
        FileUtils.createFile(albumID, fileName: filename, data: imageData!)
        
        cv.reloadData()
        
    }

    
    func show(){
        let imagePickerVC = YYImagePickerController()
        imagePickerVC.view.backgroundColor = UIColor.whiteColor()
        self.presentViewController(imagePickerVC, animated: true, completion: nil)
        imagePickerVC.delegate = self
        imagePickerVC.numberOfRow = 4
        imagePickerVC.limitMaxSelectNum = 30
    }
    
    func imagePickerDidSelectImages(array:NSArray!){
        if (array != nil){
            for(var i = 0; i < array.count; i++) {
                let asset:ALAsset = array[i] as ALAsset
                let image = UIImage(CGImage: asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
                var imageData:NSData?;
                var ext:String?
                
                imageData = UIImageJPEGRepresentation(image, 0.5)
                if (imageData != nil) {
                    ext = ".jpg"
                }else {
                    imageData = UIImagePNGRepresentation(image);
                    ext = ".png"
                }
                let filename = "\(albumID)_\(arc4random())\(ext)"
                FileUtils.createFile(albumID, fileName: filename, data: imageData!)
            }
            cv.reloadData()
        }
    }
}
