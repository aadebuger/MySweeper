//
//  ViewController.m
//  MySweeper
//
//  Created by aadebuger on 2018/5/19.
//  Copyright © 2018年 aadebuger. All rights reserved.
//

#import "ViewController.h"

#import "GCDAsyncUdpSocket.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <CoreLocation/CoreLocation.h>
#import "AsyncSocket.h"
@interface ViewController ()<GCDAsyncUdpSocketDelegate,CLLocationManagerDelegate>
{
    UILabel * _directionLabel;
    UILabel * _angleLabel;
    UILabel * _positionLabel;
    UILabel * _latitudlongitudeLabel;
}
@property (strong, nonatomic)GCDAsyncUdpSocket * udpSocket;
@property (nonatomic,strong)NSArray *array;
@property int step;
@property int action ;
//位置信息
@property(nonatomic, strong)  CLLocation *currLocation;

@property(strong,nonatomic)CLLocationManager *locationManager;
@end

#define udpPort 8888
@implementation ViewController {
AsyncSocket *_socket;
NSMutableArray *_connectedSockets;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    CGRect buttonFrame = CGRectMake( 10, 40, 100, 30 );
    UIButton *button = [[UIButton alloc] initWithFrame: buttonFrame];
    [button setTitle:@"LRotate" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:button];
    [button addTarget:self
               action:@selector(handleButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside
     ];
    
    
     buttonFrame = CGRectMake( 250, 40, 100, 30 );
    UIButton *button0 = [[UIButton alloc] initWithFrame: buttonFrame];
    [button0 setTitle:@"Rotate" forState:UIControlStateNormal];
    [button0 setBackgroundColor:[UIColor whiteColor]];
    [button0 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:button0];
    [button0 addTarget:self
               action:@selector(handleRrotateButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside
     ];
    
    
    
    buttonFrame = CGRectMake( 150, 40, 100, 30 );
    UIButton *button5 = [[UIButton alloc] initWithFrame: buttonFrame];
    [button5 setTitle:@"CompassRotate" forState:UIControlStateNormal];
    [button5 setBackgroundColor:[UIColor whiteColor]];
    [button5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:button5];
    [button5 addTarget:self
                action:@selector(handleRrotateButtonClicked:)
      forControlEvents:UIControlEventTouchUpInside
     ];
    
    
    
    
    
    buttonFrame = CGRectMake( 10, 120, 100, 30 );
    UIButton *button1 = [[UIButton alloc] initWithFrame: buttonFrame];
    [button1 setTitle:@"FORWARD" forState:UIControlStateNormal];
    [button1 setBackgroundColor:[UIColor whiteColor]];
    [button1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:button1];
    
    
    [button1 addTarget:self
               action:@selector(handleForwardButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside
     ];
    
    buttonFrame = CGRectMake( 10, 200, 100, 30 );
     UIButton * button2 = [[UIButton alloc] initWithFrame: buttonFrame];
    [button2 setTitle:@"BACKWARD" forState:UIControlStateNormal];
    [button2 setBackgroundColor:[UIColor whiteColor]];
    [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:button2];
    
    
    [button2 addTarget:self
                action:@selector(handleBackwardButtonClicked:)
      forControlEvents:UIControlEventTouchUpInside
     ];
    
    
    buttonFrame = CGRectMake( 10, 290, 100, 30 );
    UIButton * button3 = [[UIButton alloc] initWithFrame: buttonFrame];
    [button3 setTitle:@"STOP" forState:UIControlStateNormal];
    [button3 setBackgroundColor:[UIColor whiteColor]];
    [button3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview:button3];
    
    
    [button3 addTarget:self
                action:@selector(handleStopButtonClicked:)
      forControlEvents:UIControlEventTouchUpInside
     ];
    
    
    _udpSocket = [[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError * error = nil;
    [_udpSocket bindToPort:udpPort error:&error];
    if (error) {
        NSLog(@"error:%@",error);
    }else {
        [_udpSocket beginReceiving:&error];
    }
    
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:0] ;
    
    [mArray addObject:@"FORWARD"];
    
    self.step=0;
    self.array = mArray;
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
    
    
    
    _angleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 100,
                                                            // _scaView.frame.size.height + _scaView.frame.origin.y, 100, 100)];
           350, 100, 100)];
    _angleLabel.font = [UIFont systemFontOfSize:30];
    _angleLabel.textAlignment = NSTextAlignmentCenter;
    _angleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_angleLabel];
    
    _directionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, _angleLabel.frame.origin.y, 50, 50)];
    _directionLabel.font = [UIFont systemFontOfSize:15];
    _directionLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_directionLabel];
    
    _positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, _angleLabel.frame.origin.y + _directionLabel.frame.size.height, self.view.frame.size.width/2, 70)];
    _positionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    _positionLabel.numberOfLines = 3;
    _positionLabel.font = [UIFont systemFontOfSize:15];
    _positionLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_positionLabel];
    
    _latitudlongitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _positionLabel.frame.origin.y + _positionLabel.frame.size.height, self.view.frame.size.width, 30)];
    _latitudlongitudeLabel.font = [UIFont systemFontOfSize:16];
    _latitudlongitudeLabel.textAlignment = NSTextAlignmentCenter;
    _latitudlongitudeLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_latitudlongitudeLabel];
    
    
    
    // init networking
    [self initServer];
        [self createLocationManager];
    
}

- (void)timerFired:(NSObject *)obj {
    NSLog(@"time fire");
    NSLog(@"array=%@",self.array);
    if ( self.step < [self.array count])
    {
        NSLog(@"step=%@",[self.array objectAtIndex:self.step]);
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) handleButtonClicked:(id)sender {
    NSLog(@"button have been clicked.");
    NSString *ipAddress=@"192.168.31.74";
    NSString *command=@"LSPEED,-100";
    NSString *string = [command  stringByAppendingString:@"\n"];
    NSData * sendData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [_udpSocket sendData:sendData toHost:ipAddress port:udpPort withTimeout:-1 tag:0];
    
    command=@"RSPEED,100";
 string = [command  stringByAppendingString:@"\n"];
    sendData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [_udpSocket sendData:sendData toHost:ipAddress port:udpPort withTimeout:-1 tag:0];
}

- (void) handleRrotateButtonClicked:(id)sender {
    NSLog(@"button have been clicked.");
    NSString *ipAddress=@"192.168.31.74";
    NSString *command=@"LSPEED,100";
    NSString *string = [command  stringByAppendingString:@"\n"];
    NSData * sendData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [_udpSocket sendData:sendData toHost:ipAddress port:udpPort withTimeout:-1 tag:0];
    
    command=@"RSPEED,-100";
    string = [command  stringByAppendingString:@"\n"];
    sendData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [_udpSocket sendData:sendData toHost:ipAddress port:udpPort withTimeout:-1 tag:0];
}


- (void) handleForwardButtonClicked:(id)sender {
    NSLog(@"button have been clicked.");
    NSString *ipAddress=@"192.168.31.74";
    NSString *command=@"FORWARD,100";
    NSString *string = [command  stringByAppendingString:@"\n"];
    NSData * sendData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [_udpSocket sendData:sendData toHost:ipAddress port:udpPort withTimeout:-1 tag:0];
    
    
}

- (void) handleStopButtonClicked:(id)sender {
    NSLog(@"button have been clicked.");
    NSString *ipAddress=@"192.168.31.74";
    NSString *command=@"STOP,100";
    NSString *string = [command  stringByAppendingString:@"\n"];
    NSData * sendData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [_udpSocket sendData:sendData toHost:ipAddress port:udpPort withTimeout:-1 tag:0];
    
    
}

- (void) handleBackwardButtonClicked:(id)sender {
    NSLog(@"button have been clicked.");
    NSString *ipAddress=@"192.168.31.74";
    NSString *command=@"BACKWARD,100";
    NSString *string = [command  stringByAppendingString:@"\n"];
    NSData * sendData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    [_udpSocket sendData:sendData toHost:ipAddress port:udpPort withTimeout:-1 tag:0];
    
    
}


#pragma mark - GCDAsyncUdpSocket delegate
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    NSLog(@"发送信息成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
    NSLog(@"发送信息失败");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext
{
    
    NSLog(@"接收到%@的消息",address);
    NSString * sendMessage = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
  //  [self sendMessage:sendMessage andType:@1];
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    NSLog(@"udpSocket关闭");
}

//创建初始化定位装置
- (void)createLocationManager{
    
    //attention 注意开启手机的定位服务，隐私那里的
    
    self.locationManager = [[CLLocationManager alloc]init];
    
    self.locationManager.delegate=self;
    //  定位频率,每隔多少米定位一次
    // 距离过滤器，移动了几米之后，才会触发定位的代理函数
    self.locationManager.distanceFilter = 0;
    
    // 定位的精度，越精确，耗电量越高
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//导航
    
    //请求允许在前台获取用户位置的授权
    [self.locationManager requestWhenInUseAuthorization];
    
    //允许后台定位更新,进入后台后有蓝条闪动
  //  self.locationManager.allowsBackgroundLocationUpdates = YES;
    
    //判断定位设备是否能用和能否获得导航数据
    if ([CLLocationManager locationServicesEnabled]&&[CLLocationManager headingAvailable]){
        
        [self.locationManager startUpdatingLocation];//开启定位服务
        [self.locationManager startUpdatingHeading];//开始获得航向数据
        
    }
    else{
        NSLog(@"不能获得航向数据");
    }
    
}

// 定位成功之后的回调方法，只要位置改变，就会调用这个方法
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    
    self.currLocation = [locations lastObject];
    
    //维纬度
    NSString * latitudeStr = [NSString stringWithFormat:@"%3.2f",
                              _currLocation.coordinate.latitude];
    //经度
    NSString * longitudeStr  = [NSString stringWithFormat:@"%3.2f",
                                _currLocation.coordinate.longitude];
    //高度
    NSString * altitudeStr  = [NSString stringWithFormat:@"%3.2f",
                               _currLocation.altitude];
    
    NSLog(@"纬度 %@  经度 %@  高度 %@", latitudeStr, longitudeStr, altitudeStr);
    /*
    _latitudlongitudeLabel.text = [NSString stringWithFormat:@"纬度：%@  经度：%@  海拔：%@", latitudeStr, longitudeStr, altitudeStr];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:self.currLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if ([placemarks count] > 0) {
                           
                           CLPlacemark *placemark = placemarks[0];
                           
                           NSDictionary *addressDictionary =  placemark.addressDictionary;
                           
                           NSString *street = [addressDictionary
                                               objectForKey:(NSString *)kABPersonAddressStreetKey];
                           street = street == nil ? @"": street;
                           
                           NSString *country = placemark.country;
                           
                           NSString * subLocality = placemark.subLocality;
                           
                           NSString *city = [addressDictionary
                                             objectForKey:(NSString *)kABPersonAddressCityKey];
                           city = city == nil ? @"": city;
                           
                           NSLog(@"%@",[NSString stringWithFormat:@"%@ \n%@ \n%@  %@ ",country, city,subLocality ,street]);
                           
                           _positionLabel.text = [NSString stringWithFormat:@" %@\n %@ %@%@ " ,country, city,subLocality ,street];
                           
                       }
                       
                   }];
     
     */
}

//获得地理和地磁航向数据，从而转动地理刻度表
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    
    //获得当前设备
    UIDevice *device =[UIDevice currentDevice];
    
    //    判断磁力计是否有效,负数时为无效，越小越精确
    if (newHeading.headingAccuracy>0)
    {
        //地磁航向数据-》magneticHeading
        float magneticHeading =[self heading:newHeading.magneticHeading fromOrirntation:device.orientation];
        
        //地理航向数据-》trueHeading
        float trueHeading =[self heading:newHeading.trueHeading fromOrirntation:device.orientation];
        
        //地磁北方向
        float heading = -1.0f *M_PI *newHeading.magneticHeading /180.0f;
        
        self.newangleLabel.text = [NSString stringWithFormat:@"%3.1f°",magneticHeading];
        
        /*
        _angleLabel.text = [NSString stringWithFormat:@"%3.1f°",magneticHeading];
        
        //旋转变换
        [_scaView resetDirection:heading];
    */
        [self updateHeading:newHeading];
        
    }
    
    
}

//返回当前手机（摄像头)朝向方向
- (void)updateHeading:(CLHeading *)newHeading{
    
    CLLocationDirection  theHeading = ((newHeading.magneticHeading > 0) ?
                                       newHeading.magneticHeading : newHeading.trueHeading);
    
    int angle = (int)theHeading;
    
    NSLog(@"angle = %d",angle);
    
    switch (angle) {
        case 0:
            _directionLabel.text = @"北";
            break;
        case 90:
            _directionLabel.text = @"东";
            break;
        case 180:
            _directionLabel.text = @"南";
            break;
        case 270:
            _directionLabel.text = @"西";
            break;
            
        default:
            break;
    }
    if (angle > 0 && angle < 5) {
        _directionLabel.text = @"东北";
        
        self.headingLabel.text = @"0-5 find ";
        
        NSLog(@"0-5 find");
        
    }
    if (angle > 30 && angle < 45) {
        _directionLabel.text = @"东北";
        
        self.headingLabel.text = @"20-25 find ";
        
        NSLog(@"20-25 find");
        
    }
    if (angle > 0 && angle < 90) {
        _directionLabel.text = @"东北";
    }else if (angle > 90 && angle < 180){
        _directionLabel.text = @"东南";
    }else if (angle > 180 && angle < 270){
        _directionLabel.text = @"西南";
    }else if (angle > 270 ){
        _directionLabel.text = @"西北";
    }
    
}


-(float)heading:(float)heading fromOrirntation:(UIDeviceOrientation)orientation{
    
    float realHeading =heading;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            realHeading=heading-180.0f;
            break;
        case UIDeviceOrientationLandscapeLeft:
            realHeading=heading+90.0f;
            break;
        case UIDeviceOrientationLandscapeRight:
            realHeading=heading-90.0f;
            break;
        default:
            break;
    }
    if (realHeading>360.0f)
    {
        realHeading-=360.0f;
    }
    else if (realHeading<0.0f)
    {
        realHeading+=360.0f;
    }
    return  realHeading;
}

//判断设备是否需要校验，受到外来磁场干扰时
-(BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return NO;
    
}


- (void)dealloc{
    
    [self.locationManager stopUpdatingHeading];//停止获得航向数据，省电
    
    self.locationManager.delegate=nil;
}

/*
- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
    [self.locationManager stopUpdatingHeading];//停止获得航向数据，省电
    
    self.locationManager.delegate=nil;
    
}
 */

- (void)initServer
{
    if (!_socket) {
        _socket = [[AsyncSocket alloc] init];
        [_socket setDelegate:self];
        _connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    int port = 10001;
    
    NSError *error = nil;
    if(![_socket acceptOnPort:port error:&error]) {
        NSLog(@"Error starting server: %@", error);
        return;
    }
    self.statusLabel.text = [NSString stringWithFormat:@"Listening on port %d ...", port];
}

- (void)onSocket:(AsyncSocket *)socket didAcceptNewSocket:(AsyncSocket *)newSocket
{
    [_connectedSockets addObject:newSocket];
}

- (void)onSocket:(AsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port
{
     self.statusLabel.text = [NSString stringWithFormat:@"%@ connected on port %d", host, port];
    
    NSString *message = @"Welcome :)";
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [socket writeData:data withTimeout:-1 tag:0];
}
@end
