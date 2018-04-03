//
//  ViewController.swift
//  SingleTask斷點續傳
//
//  Created by EthanLin on 2018/4/2.
//  Copyright © 2018年 EthanLin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //用來存放斷點續傳的資料
    var resumeData:Data?
    //建立用來存放存resumeData的路徑
    var resumeDataPath:String?
    
    //用來存放progress的進度
    var progressValue:Float?
    
    var downloadTask:URLSessionDownloadTask?
    var backgroundSession:URLSession?
    
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    //暫停工作
    @IBAction func pauseAction(_ sender: UIButton) {
        self.downloadTask?.cancel(byProducingResumeData: { (data) in
            if let data = data{
              //儲存資料
              self.resumeData = data
              
              //儲存臨時資料
              let filePath = NSTemporaryDirectory() + "/" + "resumeData.data"
                do {
                    try self.resumeData?.write(to: URL(fileURLWithPath: filePath))
                    self.resumeDataPath = filePath
                    print(NSTemporaryDirectory())
                    print("儲存臨時資料成功")
                } catch  {
                    print("無法順利存臨時資料")
                }
            }
        })
        //把progressValue存下來
        UserDefaults.standard.set(progressValue, forKey: "progressValue")
    }
    
    @IBAction func startAction(_ sender: UIButton) {
        let url = URL(string: "http://video.cvr720.com/a74ecf04f6fa442abb4a1f33f5a38298/a02b13e35de142e6bceff59dcfd1cbba-5456d705cfd07e668f702e78be66cb6f.mp4")
        //按下start後初始化downloadTask
        if let url = url{
            downloadTask = backgroundSession?.downloadTask(with: url)
            downloadTask?.resume()
        }
    }
    
    @IBAction func resumeAction(_ sender: UIButton) {
        if let resumeData = resumeData{
           downloadTask = backgroundSession?.downloadTask(withResumeData: resumeData)
           downloadTask?.resume()
        }
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //設定backgroundConfiguration
        let backgroundConfig = URLSessionConfiguration.background(withIdentifier: "background")
        backgroundSession = URLSession(configuration: backgroundConfig, delegate: self, delegateQueue: OperationQueue())
        
        //讀取資料
        if resumeData != nil{
          self.resumeData = NSData(contentsOfFile: self.resumeDataPath!) as! Data
          //呈現在bar上
          self.progressValue = UserDefaults.standard.float(forKey: "progressValue")
          self.progressView.setProgress(progressValue!, animated: false)
        }else{
          self.progressView.setProgress(0, animated: false)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
extension ViewController:URLSessionDownloadDelegate{
    
    //下載完後要做的事
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let data = try? Data(contentsOf: location)
        //把資料存到temp資料夾
        
        //建立存檔路徑
        let filePath = NSTemporaryDirectory() + "/" + "video.mp4"
        do {
            try data?.write(to: URL(fileURLWithPath: filePath))
        } catch  {
            print("無法順利存檔")
        }
        
        //印出temporary資料夾的位置
        print(NSTemporaryDirectory())
        
        //下載完成後使session失效
        backgroundSession?.invalidateAndCancel()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            //把進度存到progressValue
            self.progressValue = progress
            self.progressView.setProgress(self.progressValue!, animated: true)
        }
    }
    
}
