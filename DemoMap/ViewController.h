//
//  ViewController.h
//  DemoMap
//
//  Created by NVKHANH on 3/13/16.
//  Copyright © 2017 NVK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@interface ViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)selectTypes:(id)sender;
- (IBAction)myLocation:(id)sender;
//Khai bao bien quan ly viec truy xuat vi tri cua nguoi dung
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong)NSString *address;
@end

