//
//  DGK_WeatherViewController.m
//  Weather
//
//  Created by Derek Knight on 5/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define LOW_LEVEL_DEBUG FALSE

#import "DGK_WeatherViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DGK_WeatherViewController ()

@end

@implementation DGK_WeatherViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mode = MODE_TEMPERATURE;
    when = [NSDate date];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"wood-grain"]];
    
    UIImage *needleImage = [UIImage imageNamed:@"gauge-needle.png"];
    arrowImageView = [[UIImageView alloc] initWithImage:needleImage];
    [arrowImageView setFrame:CGRectMake(148, 92, 20, 120)];
    [self.view addSubview:arrowImageView];
    
    arrowImageView.layer.anchorPoint = CGPointMake(0.5, 0.13);
    arrowImageView.opaque = YES;
    
    graph = [[CPTXYGraph alloc] initWithFrame: _graphView.bounds];
    
    _graphView.backgroundColor = [UIColor colorWithRed:(16.0/255.0) green:(16.0/255.0) blue:(54.0/255.0) alpha:1.0],
    _graphView.hostedGraph = graph;
    graph.plotAreaFrame.masksToBorder = NO;
    graph.paddingLeft = 35.0;
    graph.paddingTop = 10.0;
    graph.paddingRight = 10.0;
    graph.paddingBottom = 45.0;

    CPTMutableLineStyle *axisLine = [CPTMutableLineStyle lineStyle];
    axisLine.lineColor = [CPTColor whiteColor];
    axisLine.lineWidth = 2.0f;
    CPTMutableLineStyle *gridLine = [CPTMutableLineStyle lineStyle];
    gridLine.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.4];
    gridLine.lineWidth = 1.0f;
    CPTMutableLineStyle *plotLine = [CPTMutableLineStyle lineStyle];
    plotLine.lineWidth = 2.0f;
    plotLine.lineColor = [CPTColor whiteColor];
    
    CPTMutableTextStyle *axisText = [CPTTextStyle textStyle];
    axisText.color = [CPTColor whiteColor];
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    
    axisSet.xAxis.majorIntervalLength = [[NSNumber numberWithInt:4*3] decimalValue];
    axisSet.xAxis.minorTicksPerInterval = 4*3;
    axisSet.xAxis.majorTickLineStyle = axisLine;
    axisSet.xAxis.minorTickLineStyle = axisLine;
    axisSet.xAxis.axisLineStyle = axisLine;
    axisSet.xAxis.minorTickLength = 5.0f;
    axisSet.xAxis.majorTickLength = 7.0f;
    axisSet.xAxis.labelOffset = 3.0f;
    axisSet.xAxis.majorGridLineStyle = gridLine;
    axisSet.xAxis.labelTextStyle = axisText;
    axisSet.xAxis.labelExclusionRanges = [[NSArray alloc]initWithObjects:[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-40) 
                                                                                                      length:CPTDecimalFromFloat(40)], nil];
    axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    axisSet.xAxis.majorTickLocations = [[NSSet alloc]initWithObjects:
                                        [NSNumber numberWithInt:8*3],
//                                        [NSNumber numberWithInt:16*3],
                                        [NSNumber numberWithInt:24*3],
//                                        [NSNumber numberWithInt:32*3],
                                        [NSNumber numberWithInt:40*3],
//                                        [NSNumber numberWithInt:48*3],
                                        [NSNumber numberWithInt:56*3],
//                                        [NSNumber numberWithInt:64*3],
                                        [NSNumber numberWithInt:72*3],
//                                        [NSNumber numberWithInt:80*3],
                                        [NSNumber numberWithInt:88*3],
//                                        [NSNumber numberWithInt:96*3],
                                        nil];
    NSArray *xAxisLabels = [NSArray arrayWithObjects:
                            @"2am",
//                            @"4am",
                            @"6am",
//                            @"8am",
                            @"10am",
//                            @"12pm",
                            @"2pm",
//                            @"4pm",
                            @"6pm",
//                            @"8pm",
                            @"10pm",
//                            @"12am",
                            nil];
    NSUInteger labelLocation = 0;
    NSMutableSet *customLabels = [NSMutableSet setWithCapacity:[xAxisLabels count]];
    for (NSNumber *tickLocation in axisSet.xAxis.majorTickLocations) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[xAxisLabels objectAtIndex:labelLocation++]
                                                          textStyle:axisSet.xAxis.labelTextStyle];
        newLabel.tickLocation = [[NSNumber numberWithInt:(labelLocation*2-1)*8*3] decimalValue];
        newLabel.offset = axisSet.xAxis.labelOffset + axisSet.xAxis.majorTickLength;
        newLabel.rotation = M_PI_2;
        [customLabels addObject:newLabel];
    }
    axisSet.xAxis.axisLabels = customLabels;

    axisSet.yAxis.majorIntervalLength = [[NSNumber numberWithInt:10] decimalValue];
    axisSet.yAxis.minorTicksPerInterval = 10;
    axisSet.yAxis.majorTickLineStyle = axisLine;
    axisSet.yAxis.minorTickLineStyle = axisLine;
    axisSet.yAxis.majorGridLineStyle = gridLine;
    axisSet.yAxis.axisLineStyle = axisLine;
    axisSet.yAxis.minorTickLength = 5.0f;
    axisSet.yAxis.majorTickLength = 7.0f;
    axisSet.yAxis.labelOffset = 3.0f;
    axisSet.yAxis.labelTextStyle = axisText;
    axisSet.yAxis.alternatingBandFills = [NSArray arrayWithObjects:
                                          [CPTColor colorWithComponentRed:(16.0/255.0) green:(16.0/255.0) blue:(54.0/255.0) alpha:1.0],
                                          [CPTColor colorWithComponentRed:(16.0/255.0) green:(16.0/255.0) blue:(108.0/255.0) alpha:1.0], nil];

    CPTScatterPlot *tempPlot = [[CPTScatterPlot alloc] initWithFrame:graph.defaultPlotSpace.accessibilityFrame];
    tempPlot.interpolation = CPTScatterPlotInterpolationCurved;
    tempPlot.identifier = @"Temperature Plot";
    tempPlot.dataLineStyle = plotLine;
    tempPlot.dataSource = self;
    [graph addPlot:tempPlot];
    
//    CPTPlotSymbol *dataPointSymbol = [CPTPlotSymbol ellipsePlotSymbol];
//    dataPointSymbol.fill = [CPTFill fillWithColor:[CPTColor blackColor]];
//    dataPointSymbol.size = CGSizeMake(2.0, 2.0);
//    tempPlot.plotSymbol = dataPointSymbol;  
    
    [self willRefresh:nil];
    
    [self willChangeView:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown ||
            interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma core plot data source

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return [graphData count];//95; // every 15 minutes for 24 hours
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot
                     field:(NSUInteger)fieldEnum
               recordIndex:(NSUInteger)index
{
    if(fieldEnum == CPTScatterPlotFieldX)
    {
        return [NSNumber numberWithInt:index];
    }
    else
    { 
        NSDictionary *record = [graphData objectAtIndex:index];
        if (record != nil)
        {
            switch (mode)
            {
                case MODE_TEMPERATURE:
                    return [record objectForKey:@"t"];
                    break;
                case MODE_HUMIDITY:
                    return [record objectForKey:@"h"];
                    break;
            }
        }
        return [NSNumber numberWithFloat:0.0];
    }
}

#pragma mark - Swipe gesture recognisers

- (IBAction)handleGraphSwipeLeft:(UISwipeGestureRecognizer *)sender
{
    DEBUGLog(@"");
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    when = [gregorian dateByAddingComponents:comps toDate:when options:0];
    if ([when timeIntervalSinceNow] > 0) when = [NSDate date];
    [self willRefresh:sender];
}

- (IBAction)handleGraphSwipeRight:(UISwipeGestureRecognizer *)sender
{
    DEBUGLog(@"");
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    when = [gregorian dateByAddingComponents:comps toDate:when options:0];
    [self willRefresh:sender];
}

- (IBAction)handleGraphTap:(UISwipeGestureRecognizer *)sender
{
    DEBUGLog(@"");
    [self willRefresh:sender];
}

#pragma mark - view actions

- (IBAction)willRefresh:(id)sender
{
    AFJSONRequestOperation *operation;
    NSURL *url;
    NSURLRequest *request;
    if ([_viewChanger selectedSegmentIndex] == 0)
    {
        url = [NSURL URLWithString:@"http://xyzzy.gordonknight.co.uk:8080"];
        request = [NSURLRequest requestWithURL:url];
        
        operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                     {
                         DEBUGLog(@"%@", JSON);
                         NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                         [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                         NSNumber *value = nil;
                         float angle;
                         NSString *display;
                         switch(mode)
                         {
                             case MODE_TEMPERATURE:
                                 value = [formatter numberFromString:[JSON valueForKey: @"Temperature"]];
                                 angle = ([value floatValue]-10) / 20 * M_PI * 1.74; // Range is 10-30 degrees Centigrade
                                 display = [NSString stringWithFormat:@"%2.1f \u00B0C", [value floatValue]];
                                 break;
                             case MODE_CALIBRATE:
                                 value = [NSNumber numberWithInt:30];
                                 angle = ([value floatValue]-10) / 20 * M_PI * 1.74;
                                 display = [NSString stringWithFormat:@"%2.1f \u00B0C", [value floatValue]];
                                 break;
                             case MODE_HUMIDITY:
                                 value = [formatter numberFromString:[JSON valueForKey: @"Humidity"]];
                                 angle = ([value floatValue]-30) / 40 * M_PI * 1.74; // Range is 30-70 % Humidity
                                 display = [NSString stringWithFormat:@"%2.1f %% RH", [value floatValue]];
                                 break;
                         }
                         if (value == nil) return;
                         
                         if (angle < 0) angle = 0;
                         if (angle > M_PI * 1.74) angle = M_PI * 1.74;
                         
                         if (abs (angle-lastAngle) < M_PI)
                         {
                             [UIView animateWithDuration:1.0
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseInOut
                                              animations:^() {
                                                  arrowImageView.transform = CGAffineTransformMakeRotation(angle);
                                              }
                                              completion:^(BOOL finished) {}];
                         }
                         else // > 180 degreees, so go in two jumps or the needle will move anticlockwise
                         {
                             [UIView animateWithDuration:1.5
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^() {
                                                  arrowImageView.transform = CGAffineTransformMakeRotation((angle+lastAngle)/2);
                                              }
                                              completion:^(BOOL finished) {
                                                  [UIView animateWithDuration:1.5
                                                                        delay:0
                                                                      options:UIViewAnimationOptionCurveEaseOut
                                                                   animations:^() {
                                                                       arrowImageView.transform = CGAffineTransformMakeRotation(angle);
                                                                   }
                                                                   completion:^(BOOL finished) {}];
                                              }];
                         }
                         lastAngle=angle;
                         _reading.text = display;
                     }
                                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                     {
                         DEBUGLog(@"%@", error);
                     }];
        [operation start];
    }
    else
    {        
        NSString *URL = @"http://xyzzy.gordonknight.co.uk/weather/service/data/list?when=%@&source=%@";
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *date =[formatter stringFromDate:when];

        url = [NSURL URLWithString:[NSString stringWithFormat:URL,date,mode == MODE_TEMPERATURE ? @"temperature" : @"humidity"]];
        request = [NSURLRequest requestWithURL:url];
        operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
                     {
                         DEBUGLog(@"%@", JSON);
                         graphData = JSON;
                         Float32 loY = 1000.0;
                         Float32 hiY = 0.0;
                         Float32 overlap = 0;
                         int yInterval = 1;
                         switch(mode)
                         {
                             case MODE_TEMPERATURE:
                                 // X Axis == time, Y Axis = temp
                                 for (NSDictionary *record in graphData) {
                                     Float32 val = [((NSNumber *)[record objectForKey:@"t"])floatValue];
                                     if (val < loY) loY = val; if (val > hiY) hiY = val;
                                 }
                                 overlap = 3;
                                 yInterval = 5;
                                 break;
                             case MODE_HUMIDITY:
                                 // X Axis == time, Y Axis = humidity
                                 for (NSDictionary *record in graphData) {
                                     Float32 val = [((NSNumber *)[record objectForKey:@"h"])floatValue];
                                     if (val < loY) loY = val; if (val > hiY) hiY = val;
                                 }
                                 overlap = 2;
                                 yInterval = 10;
                                 break;
                         }
                         loY -= 10;
                         hiY += 10;
                         CPTXYAxisSet *axisSet = (CPTXYAxisSet *)(graph.axisSet);
                         NSMutableSet *majorTicks = [[NSMutableSet alloc]init];
                         NSMutableSet *majorLabels = [[NSMutableSet alloc]init];
                         NSMutableSet *minorTicks = [[NSMutableSet alloc]init];
                         for (int i = loY; i <= hiY; i++)
                         {
                             if (i % yInterval == 0)
                             {
                                 [majorTicks addObject:[NSNumber numberWithInt:i]];
                                 CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d", i]
                                                                                   textStyle:axisSet.yAxis.labelTextStyle];
                                 newLabel.tickLocation = [[NSNumber numberWithInt:i] decimalValue];
                                 newLabel.offset = axisSet.yAxis.labelOffset + axisSet.yAxis.majorTickLength;
                                 [majorLabels addObject:newLabel];
                             }
                             [minorTicks addObject:[NSNumber numberWithInt:i]];
                         }
                         CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
                         plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0-overlap)
                                                                         length:CPTDecimalFromFloat(96*3+overlap)];
                         plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(loY-overlap)
                                                                         length:CPTDecimalFromFloat(hiY-loY+overlap)];
                         axisSet.yAxis.majorTickLocations = majorTicks;
                         axisSet.yAxis.minorTickLocations = minorTicks;
                         axisSet.yAxis.axisLabels =  majorLabels;
                         axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
                         axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(loY);
                         axisSet.xAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(loY)
                                                                                     length:CPTDecimalFromFloat(hiY)];
                         [graph reloadData];
                     }
                                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON)
                     {
                         DEBUGLog(@"%@", error);
                     }];
        [operation start];
    }
}

- (IBAction)willToggle:(id)sender
{
    mode = mode == MODE_TEMPERATURE ? MODE_HUMIDITY : MODE_TEMPERATURE;
    switch(mode)
    {
        case MODE_TEMPERATURE:
            _gauge.image = [UIImage imageNamed:@"gauge-background-1"];
            _label.text = @"Temperature";
            break;
        case MODE_CALIBRATE:
            _gauge.image = [UIImage imageNamed:@"gauge-background-1"];
            _label.text = @"Temperature";
            break;
        case MODE_HUMIDITY:
            _gauge.image = [UIImage imageNamed:@"gauge-background-2"];
            _label.text = @"Humidity";
            break;
    }
    [self willRefresh:nil];
}

- (IBAction)willChangeView:(id)sender
{
    if ([_viewChanger selectedSegmentIndex] == 0)
    {
        // Show gauge
        [_gaugeView setHidden:FALSE];
        [arrowImageView setHidden:FALSE];
        [_graphView setHidden:TRUE];
    }
    else
    {
        // Show graph
        [_gaugeView setHidden:TRUE];
        [arrowImageView setHidden:TRUE];
        [_graphView setHidden:FALSE];
    }
    [self willRefresh:nil];
}

@end
