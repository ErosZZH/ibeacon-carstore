//
//  FileUtils.swift
//  again
//
//  Created by user on 14/12/6.
//  Copyright (c) 2014年 yzlpie. All rights reserved.
//

import Foundation

struct FileUtils {
    
    //获取沙盒根路径
    static func dirHome() -> NSString {
        return NSHomeDirectory()
    }
    
    //获取Documents目录
    static func dirDoc() -> NSString {
        let path:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let documentsDirectory:NSString = path[0] as NSString
        return documentsDirectory
    }
    
    //获取Library目录路径
    static func dirLib() -> NSString {
        let path:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.LibraryDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let libraryDirectory:NSString = path[0] as NSString
        return libraryDirectory
    }
    
    //获取Cached目录路径
    static func dirCache() -> NSString {
        let path:NSArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray
        let cachePath:NSString = path[0] as NSString
        return cachePath
    }
    
    //获取tmp目录路径
    static func dirTmp() -> NSString {
        return NSTemporaryDirectory()
    }
    
    //创建文件夹
    static func createDir(folderName:String) -> Bool{
        let documentPath = FileUtils.dirDoc()
        let fileManager = NSFileManager()
        let targetPath = documentPath.stringByAppendingPathComponent(folderName)
        let photoPath = targetPath.stringByAppendingPathComponent(Constants.PHOTO_DIR)
        let res = fileManager.createDirectoryAtPath(targetPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        if(res) {
            let photores = fileManager.createDirectoryAtPath(photoPath, withIntermediateDirectories: true, attributes: nil, error: nil)
            return res
        } else {
            return false
        }
    }
    
    //查找文件夹
    static func existDir(folderName:String) -> Bool{
        let documentPath = FileUtils.dirDoc()
        let fileManager = NSFileManager()
        let targetPath = documentPath.stringByAppendingPathComponent(folderName)
        let res = fileManager.fileExistsAtPath(targetPath)
        return res
    }
    
    //创建文件
    static func createFile(folderName:String, fileName:String, data:NSData) -> Bool {
        let documentPath = FileUtils.dirDoc()
        let targetPath = documentPath.stringByAppendingPathComponent(folderName).stringByAppendingPathComponent(Constants.PHOTO_DIR)
        let fileManager = NSFileManager()
        let targetFile = targetPath.stringByAppendingPathComponent(fileName)
        let res = fileManager.createFileAtPath(targetFile, contents: data, attributes: nil)
        return res
    }
    
    //写数据到文件
    static func writeFile(folderName:String, fileName:String, content:NSString) -> Bool {
        let documentPath = FileUtils.dirDoc()
        let targetPath = documentPath.stringByAppendingPathComponent(folderName)
        let targetFile = targetPath.stringByAppendingPathComponent(fileName)
        let res = content.writeToFile(targetFile, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
        return res
    }
    
    //读文件数据
    static func readFile(folderName:String, fileName:String) -> NSString {
        let documentPath = FileUtils.dirDoc()
        let targetPath = documentPath.stringByAppendingPathComponent(folderName)
        let targetFile = targetPath.stringByAppendingPathComponent(fileName)
        let content = NSString(contentsOfFile: targetFile, encoding: NSUTF8StringEncoding, error: nil)
        return content!
    }
    
    //读二进制文件数据
    static func readBinFile(folderName:String, fileName:String) -> NSData {
        let documentPath = FileUtils.dirDoc()
        let targetPath = documentPath.stringByAppendingPathComponent(folderName).stringByAppendingPathComponent(Constants.PHOTO_DIR)
        let targetFile = targetPath.stringByAppendingPathComponent(fileName)
        let content = NSData(contentsOfFile: targetFile)
        return content!
    }
    
    //文件属性
    static func fileAttriutes(folderName:String, fileName:String) -> NSDictionary {
        let documentPath = FileUtils.dirDoc()
        let targetPath = documentPath.stringByAppendingPathComponent(folderName)
        let targetFile = targetPath.stringByAppendingPathComponent(fileName)
        let fileManager = NSFileManager()
        let fileAttributes = fileManager.attributesOfItemAtPath(targetFile, error: nil)
        return fileAttributes!
    }
    
    //删除文件
    static func deleteFile(folderName:String, fileName:String) -> Bool {
        let documentPath = FileUtils.dirDoc()
        let targetPath = documentPath.stringByAppendingPathComponent(folderName).stringByAppendingPathComponent(Constants.PHOTO_DIR)
        let targetFile = targetPath.stringByAppendingPathComponent(fileName)
        let fileManager = NSFileManager()
        let res = fileManager.removeItemAtPath(targetFile, error: nil)
        return res
    }
    
    //删除路径
    static func deleteFolder(folderName:String) -> Bool {
        let documentPath = FileUtils.dirDoc()
        let targetPath = documentPath.stringByAppendingPathComponent(folderName)
        let fileManager = NSFileManager()
        let res = fileManager.removeItemAtPath(targetPath, error: nil)
        return res
    }
    
    //获取文件夹列表
    static func subDirList() -> NSArray {
        let documentPath = FileUtils.dirDoc()
        let fileManager = NSFileManager()
        let dirList = fileManager.contentsOfDirectoryAtPath(documentPath, error: nil)
        return dirList!
    }
    
    //获取自文件列表
    static func subDirList(folderName:String) -> NSArray {
        let documentPath = FileUtils.dirDoc()
        let targetPath = documentPath.stringByAppendingPathComponent(folderName).stringByAppendingPathComponent(Constants.PHOTO_DIR)
        let fileManager = NSFileManager()
        let dirList = fileManager.contentsOfDirectoryAtPath(targetPath, error: nil)
        return dirList!
    }
}