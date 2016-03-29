//
//  DeviceController.swift
//  again
//
//  Created by user on 14/12/5.
//  Copyright (c) 2014年 yzlpie. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

protocol BeaconProcotol {
    func onBeaconReturn()
}

class DeviceController: UITableViewController, CLLocationManagerDelegate, CBCentralManagerDelegate, UITextViewDelegate {
    
    var alert:UIAlertController?
    var saveButton:UIAlertAction?
    
    let kUUID:String = Constants.UUID
    let kIdentifier:String = Constants.IDENTIFIER
    
    var locationManager:CLLocationManager = CLLocationManager()
    var beaconRegion:CLBeaconRegion = CLBeaconRegion()
    var bluetooth:CBCentralManager?
    
    var nearest = "0_0"
    var candidate = "0_0"
    var count = 0
    var current = ""
    var currentDes = ""
    
    var textView:UITextView?
    var doneButton:UIButton?

    @IBOutlet weak var tv: UITableView!
    @IBOutlet weak var returnBtn: UIBarButtonItem!
    
    @IBOutlet weak var searchBtn: UIBarButtonItem!
    
    var deviceList:NSArray = NSArray()
    
    var delegate:BeaconProcotol?
    
    @IBAction func onClickReturn(sender: UIBarButtonItem) {
        self.delegate?.onBeaconReturn()
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func searchDevice(sender: UIBarButtonItem) {
        alert = UIAlertController(title: "搜索新设备", message: "扫描中...", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelButton = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel) { (action:UIAlertAction!) -> Void in
            self.locationManager.stopRangingBeaconsInRegion(self.beaconRegion)
        }

        saveButton = UIAlertAction(title: "添加", style: UIAlertActionStyle.Default) { (action:UIAlertAction!) -> Void in
            let res = FileUtils.createDir(self.nearest)
            if(res) {
                let res1 = FileUtils.writeFile(self.nearest, fileName: Constants.DESCRIPTION_FILE, content: "从07年法兰克福车展上的首次现身，到08年底特律车展上的量产车首发，再到北京车展的国内亮相，X6无疑是目前宝马产品序列中曝光度最高的车型。")
                if(res1) {
                    self.deviceList = FileUtils.subDirList()
                    self.tv.reloadData()
                }
            }
        }
        
        alert?.addAction(cancelButton)
        alert?.addAction(saveButton!)
        saveButton!.enabled = false
        
        presentViewController(alert!, animated: true) { () -> Void in
            self.initRegion()
        }
        
        
    }
    
    func initRegion(){
        var uuid:NSUUID = NSUUID(UUIDString: kUUID)!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, identifier: kIdentifier)
        beaconRegion.notifyEntryStateOnDisplay = true
        locationManager.delegate = self
        bluetooth = CBCentralManager(delegate:self, queue: nil)
        
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.AuthorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()
        }
        self.locationManager.startMonitoringForRegion(self.beaconRegion)
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
    }
    
    func locationManager(manager: CLLocationManager!, didStartMonitoringForRegion region: CLRegion!) {
        self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        self.locationManager.startRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        self.locationManager.stopRangingBeaconsInRegion(self.beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {

        if beacons.count <= 0 {
            return
        }
        
        var farest = -10000;
        var index = 0
        for(var i = 0; i < beacons.count; i++) {
            if(beacons[i].rssi > farest) {
                farest = beacons[i].rssi
                index = i
            }
        }
        
        let best = "\(beacons[index].major)_\(beacons[index].minor)"
        
        for(var i = 0; i < self.deviceList.count; i++) {
            if(best == (deviceList[i] as? String)) {
                return
            }
        }
        
        if (best == candidate) { //最近的基站变成了疑似基站
            if(count < 1) { //但是还没有连续3次以上都变成某个新基站
                count++
                return
            } else {    //连续3次以上都是新的某个基站，则确认基站变化成新的
                nearest = best
                candidate = "0_0"
                count = 0
                
                self.alert?.message = "找到ID号为 \(nearest) 的设备"
                self.saveButton!.enabled = true
                self.locationManager.stopRangingBeaconsInRegion(self.beaconRegion)
            }
            
        } else {    //发现全新基站，先定为疑似
            candidate = best
            count = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //FileUtils.createDir("30855_290")    //TODO just for test
        //FileUtils.writeFile("30855_290", fileName: "description.txt", content: "暂无描述123") //TODO just for test
        returnBtn.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(24)], forState: UIControlState.Normal)
        
        self.deviceList = FileUtils.subDirList()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FileUtils.subDirList().count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("deviceTableView", forIndexPath: indexPath) as UITableViewCell
        let id = self.deviceList[indexPath.row] as? String
        cell.textLabel?.text = id
        let button = UIButton()
        let rect = UIScreen.mainScreen().bounds
        let width = rect.width
        button.frame = CGRectMake(width-160, 5, 120, 70);
        button.setTitle("编辑简介", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        let font = UIFont(name: "HelveticaNeue", size: 20.0)
        button.titleLabel?.font = font
        button.addTarget(self, action: "addDescription:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.addSubview(button)
        
        if(id == current){
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None;
        }

        return cell
    }
    
    func addDescription(sender:UIButton!) {
        let cell = sender.superview as UITableViewCell
        let id = cell.textLabel?.text
        drawDescriptionView(id!)
    }
    
    func drawDescriptionView(id:String) {
        //TODO 添加文本域
        let mainRect = UIScreen.mainScreen().bounds
        let width = mainRect.width
        let height = mainRect.height
        
        let uirect = CGRectMake(20, 20, width - 40, height - 120)
        var uiview = UIView(frame: uirect)
        
        uiview.backgroundColor = UIColor.clearColor()
        uiview.layer.cornerRadius = 8
        uiview.layer.masksToBounds = true

        
        let titleRect = CGRectMake(0, 0, width - 40, 30)
        let titleLabel = UILabel(frame: titleRect)
        titleLabel.text = id
        titleLabel.textAlignment = .Center
        titleLabel.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.9)
        
        let rect = CGRectMake(0, 30, width - 40, height - 180)
        textView = UITextView(frame: rect)
        textView!.delegate = self;
        textView!.font = UIFont.systemFontOfSize(24)
        textView!.scrollEnabled = true;
        textView!.text = FileUtils.readFile(id, fileName: Constants.DESCRIPTION_FILE)
        textView!.textColor = UIColor.blackColor()
        textView!.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 0.9)
        textView!.layer.borderColor = UIColor.grayColor().CGColor
        textView!.layer.borderWidth = 1
        textView!.editable = true
        
        
        let cancelRect = CGRectMake(0, height - 170, (width - 40)/2, 50)
        var cancelButton = UIButton(frame: cancelRect)
        cancelButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.9)
        cancelButton.setTitle("取消", forState: UIControlState.Normal)
        cancelButton.frame = cancelRect
        cancelButton.addTarget(self, action: "cancelDescription:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let saveRect = CGRectMake((width - 40)/2, height - 170, (width - 40)/2, 50)
        var saveButton = UIButton(frame: saveRect)
        saveButton.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.9)
        saveButton.setTitle("保存", forState: UIControlState.Normal)
        saveButton.frame = saveRect
        saveButton.addTarget(self, action: "saveDescription:", forControlEvents: UIControlEvents.TouchUpInside)
        
        currentDes = id
        
        uiview.addSubview(titleLabel)
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            let doneRect = CGRectMake(width - 100, 0, 60, 30)
            doneButton = UIButton(frame: doneRect)
            doneButton!.backgroundColor = UIColor.clearColor()
            doneButton!.frame = doneRect
            doneButton!.addTarget(self, action: "doneDescription:", forControlEvents: UIControlEvents.TouchUpInside)
            uiview.addSubview(doneButton!)
        }
        uiview.addSubview(textView!)
        uiview.addSubview(cancelButton)
        uiview.addSubview(saveButton)
        
        self.view.addSubview(uiview)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if UIDevice.currentDevice().userInterfaceIdiom != .Pad {
            doneButton!.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.9)
            doneButton!.setTitle("完成", forState: UIControlState.Normal)
            doneButton!.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        }
    }
    
    func doneDescription(sender:UIButton!) {
        self.textView!.resignFirstResponder()
        doneButton!.backgroundColor = UIColor.clearColor()
        doneButton!.setTitle("", forState: UIControlState.Normal)
    }
    
    func cancelDescription(sender:UIButton!) {
        sender.superview?.removeFromSuperview()
    }
    
    func saveDescription(sender:UIButton!) {
        //保存产品描述
        let descript = self.textView?.text
        let id = currentDes
        sender.superview?.removeFromSuperview()
        FileUtils.writeFile(id, fileName: Constants.DESCRIPTION_FILE, content: descript!)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // Delete the row from the data source
            let dirName = self.deviceList[indexPath.row] as String
            let res = FileUtils.deleteFolder(dirName)
            if(res) {
                self.deviceList = FileUtils.subDirList()
                //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                self.tv.reloadData()
            }
            
        } else if (editingStyle == UITableViewCellEditingStyle.Insert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let row = self.tv.indexPathForSelectedRow()?.row
        let id = self.deviceList[row!] as String
        let navC = segue.destinationViewController as UINavigationController
        let albumC = navC.viewControllers[0] as AlbumController
        albumC.title = id
        albumC.albumID = id
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
