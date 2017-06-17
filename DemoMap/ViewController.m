//
//  ViewController.m
//  DemoMap
//
//  Created by NVKHANH on 3/13/16.
//  Copyright © 2017 NVK. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Set up location manager va mapkit de lay vi tri hien tai
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //Xin quyen truy cap
    if ([self.locationManager performSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    //Thiet lap delegate cho map view
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = true;
    
    //Them gesture vao cho mapview
    [self addGestureToMapView];
}
//1. Lay location cua nguoi dung va zoom toi
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    //Tao region quanh vi tri cua nguoi dung tren mapview
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 2000, 2000);
    //Thiet lap region cho mapView
    [self.mapView setRegion:region];
    
    //Them Annotation cho vi tri hien tai
    //[self addAnnotationWithLocation:userLocation.coordinate];
    [self getDataFromGoogleMapWSWithLocation:userLocation.coordinate];
}
//Them Annotation len userLocation
-(void)addAnnotationWithLocation:(CLLocationCoordinate2D)coordinate{
    //Khoi tao Annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    //Thiet lap coordinate cho annotation
    point.coordinate = coordinate;
    //Thiet lap cac thuoc tinh khac
    //point.title = [NSString stringWithFormat:@"%f",coordinate.latitude];
    point.title = self.address;
    point.subtitle = [NSString stringWithFormat:@"%f",coordinate.longitude];
    
    //Them annotaion vao mapview
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotation:point];
    });
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//2. thiet lap map type cho mapview
- (IBAction)selectTypes:(id)sender {
    //Tao alert controler dang ActionSheet
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"Choose type" preferredStyle:UIAlertControllerStyleActionSheet];
    
    //Them alert action
    UIAlertAction *standardAction = [UIAlertAction actionWithTitle:@"Standard" style:UIAlertActionStyleDefault handler:^(UIAlertAction *standartAction){
        self.mapView.mapType = MKMapTypeStandard;
    }];
    UIAlertAction *satellitedAction = [UIAlertAction actionWithTitle:@"Satellite" style:UIAlertActionStyleDefault handler:^(UIAlertAction *satellitedAction){
        self.mapView.mapType = MKMapTypeSatellite;
    }];
    
    UIAlertAction *hybridAction = [UIAlertAction actionWithTitle:@"Hybrid" style:UIAlertActionStyleDefault handler:^(UIAlertAction *hybridAction){
        self.mapView.mapType = MKMapTypeHybrid;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *cancelAction){
    
    }];
    //Them alert action vao alert controller
    [alert addAction:standardAction];
    [alert addAction:satellitedAction];
    [alert addAction:hybridAction];
    [alert addAction:cancelAction];
    
    //Hien thi alert
    [self presentViewController:alert animated:true completion:nil];
}
//3. Lay vi tri hien tai
- (IBAction)myLocation:(id)sender {
    [self.locationManager startUpdatingLocation];
}

//3.1 Ham delegate cua CLLocationManager
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    [self setLocation: newLocation];
    [manager stopUpdatingLocation];
}

//Ham tu dinh nghia, cap nhat lai vi tri ban dau
-(void)setLocation:(CLLocation *)location{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000);
    [self.mapView setRegion:region];
}

//4. Them gesture vao map view
-(void)addGestureToMapView{
    //Tao gesture dang Long press
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] init];
    gesture.minimumPressDuration = 1;
    
    //Xu ly su kien cua gesture
    [gesture addTarget:self action:@selector(addPinToMap:)];

    //Them gesture vao mapview
    [self.mapView addGestureRecognizer:gesture];
}

//4.1 Them annotation khi gap su kien long press
-(void)addPinToMap:(UIGestureRecognizer *)gesture{
    //Xoa cac annotation hien co tren mapview
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //Lay vi tri cham tren man hinh
    CGPoint touchPoint = [gesture locationInView:self.mapView];
    //Convert vi tri tren man hinh thanh location tren mapview
    CLLocationCoordinate2D pointOnMap = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    //Them annotation cho vi tri nay
    //[self addAnnotationWithLocation:pointOnMap];
    [self getDataFromGoogleMapWSWithLocation:pointOnMap];
}

//Truy van du lieu google theo location tim duoc
-(void)getDataFromGoogleMapWSWithLocation:(CLLocationCoordinate2D)coordinate{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=AIzaSyAPFlJ2xOpj6IH280mf653W0KCkEJjJ6-c",coordinate.latitude,coordinate.longitude];
    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionTask *task = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        
        if (!error) {
            NSDictionary *myDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSArray *result = [myDict objectForKey:@"results"];
            NSDictionary *dictResult = result[0];
            self.address = [dictResult objectForKey:@"formatted_address"];
            //NSLog(@"%@",self.address);
            [self addAnnotationWithLocation:coordinate];
        }
        else{
            NSLog(@"%@",[error localizedDescription]);
        }
    }];
    [task resume];
}
@end
