//
//  XXTLocationPicker.m
//  XXTLocationPicker
//
//  Created by Zheng on 15/04/2017.
//  Copyright © 2017 Zheng. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "XXTLocationPicker.h"
#import "XXTPickerHelper.h"
#import "XXTPickerDefine.h"

static NSString * const kXXTCoordinateRegionLatitudeKey = @"kXXTCoordinateRegionLatitudeKey";
static NSString * const kXXTCoordinateRegionLongitudeKey = @"kXXTCoordinateRegionLongitudeKey";
static NSString * const kXXTMapViewAnnotationIdentifier = @"kXXTMapViewAnnotationIdentifier";
static NSString * const kXXTMapViewAnnotationFormat = @"Latitude: %f, Longitude: %f";

@interface XXTLocationPicker () <MKMapViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) MKPointAnnotation *pointAnnotation;

@end

@implementation XXTLocationPicker {
    XXTPickerTask *_pickerTask;
    NSString *_pickerSubtitle;
}

@synthesize pickerTask = _pickerTask;

#pragma mark - XXTBasePicker

+ (NSString *)pickerKeyword {
    return @"@loc@";
}

- (NSString *)pickerResult {
    return [NSString stringWithFormat:@"%f, %f",
            self.pointAnnotation.coordinate.latitude,
            self.pointAnnotation.coordinate.longitude];
}

#pragma mark - Default Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (NSString *)title {
    return NSLocalizedStringFromTableInBundle(@"Location", nil, [XXTPickerHelper bundle], nil);
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    mapView.delegate = self;
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    mapView.zoomEnabled = YES; mapView.scrollEnabled = YES; mapView.rotateEnabled = YES;
    mapView.showsUserLocation = YES; mapView.showsBuildings = NO; mapView.showsPointsOfInterest = NO;
    START_IGNORE_PARTIAL
    if (XXTP_SYSTEM_9) {
        mapView.showsCompass = YES; mapView.showsScale = YES; mapView.showsTraffic = NO;
    }
    END_IGNORE_PARTIAL
    self.mapView = mapView;
    
    CLLocationCoordinate2D defaultCoordinate;
    defaultCoordinate.latitude = 39.92f;
    defaultCoordinate.longitude = 116.46f;
    MKCoordinateSpan defaultSpan = {1.f, 1.f};
    MKCoordinateRegion region = {defaultCoordinate, defaultSpan};
    id latitudeObj = [[NSUserDefaults standardUserDefaults] objectForKey:kXXTCoordinateRegionLatitudeKey];
    id longitudeObj = [[NSUserDefaults standardUserDefaults] objectForKey:kXXTCoordinateRegionLongitudeKey];
    if (
        latitudeObj && longitudeObj
        ) {
        defaultCoordinate.latitude = [(NSNumber *)latitudeObj floatValue];
        defaultCoordinate.longitude = [(NSNumber *)longitudeObj floatValue];
    }
    [mapView setRegion:region animated:YES];
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    pointAnnotation.title = NSLocalizedStringFromTableInBundle(@"Drag & Drop 📌", nil, [XXTPickerHelper bundle], nil);
    pointAnnotation.subtitle = [NSString stringWithFormat:NSLocalizedString(kXXTMapViewAnnotationFormat, nil), defaultCoordinate.latitude, defaultCoordinate.longitude];
    pointAnnotation.coordinate = defaultCoordinate;
    [mapView addAnnotation:pointAnnotation];
    [mapView selectAnnotation:pointAnnotation animated:YES];
    self.pointAnnotation = pointAnnotation;
    
    [self.view addSubview:mapView];
    
    [self.pickerTask nextStep];
    UIBarButtonItem *rightItem = NULL;
    if ([self.pickerTask taskFinished]) {
        rightItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(taskFinished:)];
    } else {
        rightItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedStringFromTableInBundle(@"Next", nil, [XXTPickerHelper bundle], nil) style:UIBarButtonItemStylePlain target:self action:@selector(taskNextStep:)];
    }
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSubtitle:NSLocalizedStringFromTableInBundle(@"Select a location by dragging 📌", nil, [XXTPickerHelper bundle], nil)];
}

#pragma mark - Task Operations

- (void)taskFinished:(UIBarButtonItem *)sender {
    [[XXTPickerHelper sharedInstance] performFinished:self];
}

- (void)taskNextStep:(UIBarButtonItem *)sender {
    [[XXTPickerHelper sharedInstance] performNextStep:self];
}

- (void)updateSubtitle:(NSString *)subtitle {
    _pickerSubtitle = subtitle;
    [[XXTPickerHelper sharedInstance] performUpdateStep:self];
}

- (NSString *)pickerSubtitle {
    return _pickerSubtitle;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    MKPinAnnotationView *customPinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kXXTMapViewAnnotationIdentifier];
    if (!customPinView) {
        customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kXXTMapViewAnnotationIdentifier];
        START_IGNORE_PARTIAL
        if (XXTP_SYSTEM_9) {
            customPinView.pinTintColor = [[XXTPickerHelper sharedInstance] frontColor];
        } else {
            customPinView.pinColor = MKPinAnnotationColorRed;
        }
        END_IGNORE_PARTIAL
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        customPinView.draggable = YES;
    } else {
        customPinView.annotation = annotation;
    }
    return customPinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    MKPointAnnotation *anno = ((MKPointAnnotation *)view.annotation);
    NSString *dragTips = [NSString stringWithFormat:NSLocalizedString(kXXTMapViewAnnotationFormat, nil), anno.coordinate.latitude, anno.coordinate.longitude];
    switch (newState) {
        case MKAnnotationViewDragStateStarting:
            break;
        case MKAnnotationViewDragStateDragging:
            break;
        case MKAnnotationViewDragStateEnding:
            anno.subtitle = dragTips;
            [[NSUserDefaults standardUserDefaults] setObject:@((float) anno.coordinate.latitude) forKey:kXXTCoordinateRegionLatitudeKey];
            [[NSUserDefaults standardUserDefaults] setObject:@((float) anno.coordinate.longitude) forKey:kXXTCoordinateRegionLongitudeKey];
            break;
        default:
            break;
    }
    [self updateSubtitle:dragTips];
}

#pragma mark - Memory

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"[XXTLocationPicker dealloc]");
#endif
}

@end
