//
//  ViewController.swift
//  again
//
//  Created by user on 14/12/2.
//  Copyright (c) 2014年 yzlpie. All rights reserved.
//
//  major 30885, minor 266 boy, 260 现代 girl

import UIKit
import CoreLocation
import CoreBluetooth
import MediaPlayer

class BeaconController: UIViewController, CLLocationManagerDelegate, CBCentralManagerDelegate, UIActionSheetDelegate, iCarouselDataSource, iCarouselDelegate, BeaconProcotol {
    
    @IBAction func onClickShare(sender: UIBarButtonItem) {
        let shareSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消分享", destructiveButtonTitle: "分享到朋友圈", otherButtonTitles: "分享给微信好友")
        shareSheet.showInView(self.view)
    }
    
    func onBeaconReturn() {
        nearest = "0_0"
        photoList = nil
        candidate = "0_0"
        count = 0
        self.trackLocationManager.startRangingBeaconsInRegion(self.beaconRegion)
    }

    
    @IBOutlet weak var carouselView: iCarousel!

    @IBAction func onClickDetail(sender: UIBarButtonItem) {
        toggleSideMenuView()
    }
    
    @IBOutlet weak var moreBtn: UIBarButtonItem!
    @IBOutlet weak var iv: UIImageView!
    
    @IBOutlet weak var detailBtn: UIBarButtonItem!
    
    @IBOutlet weak var setupBtn: UIBarButtonItem!
    
    let kUUID:String = Constants.UUID
    let kIdentifier:String = Constants.IDENTIFIER
    
    var trackLocationManager:CLLocationManager = CLLocationManager()
    var beaconRegion:CLBeaconRegion = CLBeaconRegion()
    var bluetooth:CBCentralManager?
    
    var nearest = "0_0"
    var candidate = "0_0"
    var count = 0
    //var nearest = "30855_290" //TODO just for test
    
    var photoList:NSArray?
    
    var player:MPMoviePlayerController?
    var playerViewController:MPMoviePlayerViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initRegion()
        carouselView.type = .CoverFlow2
        
        //self.photoList = FileUtils.subDirList(nearest) //TODO just for test
        //self.moreBtn.hidden = false //TODO just for test
        
        // Adjust butten size of navigation conroller
        detailBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(24)], forState: UIControlState.Normal)
        
        setupBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(24)], forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "deviceSegue"){
            let navC = segue.destinationViewController as UINavigationController
            let devC = navC.viewControllers[0] as DeviceController
            devC.current = self.nearest
            devC.delegate = self
            self.trackLocationManager.stopRangingBeaconsInRegion(self.beaconRegion)
        } else {
            
        }
        
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        //        if (self.bluetooth?.state != CBCentralManagerState.PoweredOn) {
        //            println("not open");
        //            let alert = UIAlertView()
        //            alert.title = "Tips"
        //            alert.message = "Please power on your bluetooth"
        //            alert.addButtonWithTitle("Ok")
        //            alert.show()
        //       }
    }
    
    func initRegion(){
        var uuid:NSUUID = NSUUID(UUIDString: kUUID)!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: kIdentifier)
        beaconRegion.notifyEntryStateOnDisplay = true
        trackLocationManager.delegate = self
        bluetooth = CBCentralManager(delegate:self, queue: nil)
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            trackLocationManager.requestWhenInUseAuthorization()
        }
        self.trackLocationManager.startMonitoringForRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        self.trackLocationManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        self.trackLocationManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        self.trackLocationManager.stopRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        //println("beacons count" + String(beacons.count))
        if beacons.count <= 0 {
            return
        }
        
        var farest = -10000.0;
        var index = 0
//        for(var i = 0; i < beacons.count; i++) {
//            if(beacons[i].rssi > farest) {
//                farest = beacons[i].rssi
//                index = i
//            }
//        }
        
        for(var i = 0; i < beacons.count; i++) {
            let rssi = abs(beacons[i].rssi)
            let r = Double( rssi - 48)
            let n : Double = 2.0 * 10.0
            let ci : Double = r / n
            let distance = pow(10.0, ci)
            
            println("RSSI: \(beacons[i].rssi) ci: \(ci) distance: \(distance) minor: \(beacons[i].minor)")
            
            if(distance > farest){
                farest = distance
                index = i
            }
        }
        
        let best = "\(beacons[index].major)_\(beacons[index].minor)"
        
        if(best == nearest) {   //最近的基站没变，直接返回
            count = 0
            return
        }
        nearest = best
        
        if(FileUtils.existDir(nearest)) {   //新基站有对应资料
            self.photoList = FileUtils.subDirList(nearest)
            if(photoList?.count > 0) {
                let fileName = self.photoList![0] as String
                let data = FileUtils.readBinFile(nearest, fileName: fileName)
                //                        iv.image = UIImage(data: data)
                //                        if (nearest == "30885_260") {
                //                            iv.image = UIImage(named: "x6")
                //                        } else {
                //                            iv.image = UIImage(named: "b7")
                //                        }
                carouselView.reloadData()
                iv.hidden = true
                //                        moreBtn.enabled = true
            }
            
        } else {    //新基站无对应资料
            iv.hidden = false
            carouselView.reloadData()
            return
        }
//        else if (best == candidate) { //最近的基站变成了疑似基站
//            if(count < 2) { //但是还没有连续3次以上都变成某个新基站
//                count++
//                return
//            } else {    //连续3次以上都是新的某个基站，则确认基站变化成新的
//                nearest = best
//                candidate = "0_0"
//                count = 0
//                if(FileUtils.existDir(nearest)) {   //新基站有对应资料
//                    self.photoList = FileUtils.subDirList(nearest)
//                    if(photoList?.count > 0) {
//                        let fileName = self.photoList![0] as String
//                        let data = FileUtils.readBinFile(nearest, fileName: fileName)
////                        iv.image = UIImage(data: data)
////                        if (nearest == "30885_260") {
////                            iv.image = UIImage(named: "x6")
////                        } else {
////                            iv.image = UIImage(named: "b7")
////                        }
//                        carouselView.reloadData()
//                        iv.hidden = true
////                        moreBtn.enabled = true
//                    }
//                    
//                } else {    //新基站无对应资料
//                    iv.hidden = false
//                    carouselView.reloadData()
//                    return
//                }
//            }
//            
//        } else {    //发现全新基站，先定为疑似
//            candidate = best
//            count = 0
//        }
    }
    
    
    //Carousel
    
    func numberOfItemsInCarousel(carousel: iCarousel!) -> Int
    {
        //return items.count
        
        if (self.photoList != nil) {
            return self.photoList!.count
        }
        return 0
    }

    func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, var reusingView view: UIView!) -> UIView!
    {
        var label: UILabel! = nil
        
        //create new view if no view is available for recycling
        if (view == nil && photoList != nil)
        {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            view = UIImageView(frame:CGRectMake(0, 0, 400, 400))
            let fileName = photoList![index] as String
            let data = FileUtils.readBinFile(self.nearest, fileName: fileName)
            
            (view as UIImageView!).image = ImageUtils.imageScale(UIImage(data: data)!)
            view.contentMode = .Center
            
            //label = UILabel(frame:view.bounds)
            //label.backgroundColor = UIColor.clearColor()
            //label.textAlignment = .Center
            //label.font = label.font.fontWithSize(50)
            //label.tag = 1
            //view.addSubview(label)
        }
        else
        {
            //get a reference to the label in the recycled view
            //label = view.viewWithTag(1) as UILabel!
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        //label.text = "\(items[index])"
        
        return view
    }
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex index:NSInteger) {
        let item: NSNumber = index as NSNumber;
        //NSLog("Tapped view number: \(item)");
//        self.dismissViewControllerAnimated(true, completion: nil);
      
        var videoName = "bmwx6"
        //todo
        if (nearest == Constants.Z4_a || nearest == Constants.Z4_b) {
            videoName = "bmwz4"
        }
        
        let url:NSString = NSBundle.mainBundle().pathForResource(videoName, ofType: "mp4")!
        playerViewController = MPMoviePlayerViewController(contentURL: NSURL(fileURLWithPath: url))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "movieFinishedCallback:", name: MPMoviePlayerPlaybackDidFinishNotification, object: playerViewController!.moviePlayer)
        self.view.addSubview(playerViewController!.view)
        player = playerViewController!.moviePlayer
        player?.play()
        
    }
    
    func movieFinishedCallback(aNotification:NSNotification) {
        player = aNotification.object as? MPMoviePlayerController
        NSNotificationCenter.defaultCenter().removeObserver(self, name: MPMoviePlayerPlaybackDidFinishNotification, object: player)
        player?.stop()
        playerViewController!.view.removeFromSuperview()
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        //NSLog("Index: \(self.carousel.currentItemIndex)");
    }
    
    func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if(option == .Wrap) {
            return 1
        }
        if (option == .Spacing)
        {
            return value * 1.1
        }
        return value
    }
    
    
}

