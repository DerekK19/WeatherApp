//
//  DGK_WeatherViewController.h
//  Weather
//
//  Created by Derek Knight on 5/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CorePlot-CocoaTouch.h>
#import <AFJSONRequestOperation.h>

#define MODE_CALIBRATE 0
#define MODE_TEMPERATURE 1
#define MODE_HUMIDITY 2
#define MODE_WIND 3
#define MODE_RAIN 4

@interface DGK_WeatherViewController : UIViewController <CPTPlotDataSource>

{
    UIImageView *arrowImageView;
    CPTXYGraph *graph;
    NSMutableArray *graphData1;
    NSMutableArray *graphData2;
    int mode;
    NSDate *when;
    float lastAngle;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *SegmentsVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ImageVerticalSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ImageHorizontalSpaceConstraint;

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *viewChanger;
@property (nonatomic, retain) IBOutlet UIView *gaugeView;
@property (nonatomic, retain) IBOutlet CPTGraphHostingView *graphView;
@property (nonatomic, retain) IBOutlet UIImageView *gauge;
@property (nonatomic, retain) IBOutlet UILabel *reading;
@property (nonatomic, retain) IBOutlet UILabel *label;

- (IBAction)willRefresh:(id)sender;
- (IBAction)willToggle:(id)sender;
- (IBAction)willChangeView:(id)sender;

@end
