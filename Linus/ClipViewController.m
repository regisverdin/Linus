//
//  ClipViewController.m
//  Linus
//
//  Created by Regis Verdin on 4/2/16.
//  Copyright © 2016 Regis Verdin. All rights reserved.
//

#import "ClipViewController.h"
#import "TimelineModel.h"
#import "TimelineViewController.h"

@interface ClipViewController()

@property TimelineScene *scene;
@property BOOL assignClipMode;
@property UIButton *midiButton;
@property NSMutableArray *clipButtons;
@property UIPickerView *midiNotePicker;
@property UITextField *pickerTextField;
@property NSMutableArray *midiNoteList;
@property int selectedMidiNote;
@property int selectedClipButton;

@end

@implementation ClipViewController


-(void) viewDidLoad {
    [super viewDidLoad];
    _assignClipMode = NO;
    _clipButtons = [[NSMutableArray alloc]init];
    _midiNoteList = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"----"], nil];
    for(int i = 0; i < 128; i++) {
        [_midiNoteList addObject:[NSString stringWithFormat:@"%i", i]];
    }
    _selectedMidiNote = -1;
}


- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidLoad];
    
    //get Size of view
    CGFloat windowWidth = self.view.frame.size.width;
    CGFloat windowHeight = self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height;
    
    CGFloat clipGridWidth = windowWidth * (4.0/5.0);
    CGFloat clipGridXOffset = windowWidth * (1.0/5.0);

    //Add 16 buttons for loading clips
    for (int i = 0; i < 16; i++){
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIImage *buttonImage = [UIImage imageNamed:@"button.png"];
        [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
        
        CGFloat xPos = ((clipGridWidth/4.0) * (i%4)) + (clipGridWidth / 8) + clipGridXOffset;
        CGFloat yPos = ( windowHeight / 4.0 ) * ceil( (i+1)/4.0 ) - (windowHeight / 8);
//        NSLog(@"%f", yPos);
//        NSLog(@"%f", ceil( (i+1.0)/4.0 ));
        button.frame = CGRectMake(0.f, 0.f, windowWidth/8, windowWidth/8);
        [button setCenter:CGPointMake(xPos, yPos)];
        
        NSString *title = [NSString stringWithFormat: @"%i", (i+1)];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13 weight:5];
        
        [self.view addSubview:button];
        [_clipButtons addObject:button];
    }
    
    //Make MIDI Note Assign button
    _midiButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_midiButton addTarget:self action:@selector(toggleAssignClipMode:) forControlEvents:UIControlEventTouchUpInside];
    _midiButton.frame = CGRectMake(0.f, 0.f, clipGridXOffset, 50);
    [_midiButton setBackgroundColor:[UIColor blackColor]];
    
    _midiButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _midiButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSString *title = [NSString stringWithFormat: @"Assign Midi Note"];
    [_midiButton setTitle:title forState:UIControlStateNormal];
    [self.view addSubview:_midiButton];
    
    //Add Dummy Textfield (for pickerview)
    
    self.pickerTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.pickerTextField];
    
    //Add Pickerview
    
    _midiNotePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _midiNotePicker.showsSelectionIndicator = YES;
    _midiNotePicker.dataSource = self;
    _midiNotePicker.delegate = self;

    self.pickerTextField.inputView = _midiNotePicker;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.barStyle = UIBarStyleBlackOpaque;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneTouched:)];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTouched:)];
    
    [toolBar setItems:[NSArray arrayWithObjects:cancelButton, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    self.pickerTextField.inputAccessoryView = toolBar;

}

-(IBAction)toggleAssignClipMode:(id)sender {
    _midiButton.selected = !_midiButton.selected;
    _assignClipMode = !_assignClipMode;
    
    if(!_assignClipMode) {
        for(UIButton *button in _clipButtons){
            [button setBackgroundColor:[UIColor clearColor]];
        }
    }
}

- (IBAction)selectButton:(UIButton *)sender {
    
    _scene = [TimelineViewController getScene];
    _selectedClipButton = [sender.titleLabel.text integerValue];
    
    if(_assignClipMode) {
        for(UIButton *button in _clipButtons){
            [button setBackgroundColor:[UIColor clearColor]];
        }
        [sender setBackgroundColor:[UIColor blueColor]];
        
        [self.pickerTextField becomeFirstResponder];
        
    } else {
        
        //Set selectedClipNumber classVariable to current button selected (with flags for + and -)
        if ([sender.titleLabel.text  isEqual: @"+"]) {
            [TimelineModel setSelectedClipNumber:-1];
            [_scene setSelectedClipNumber:-1];
            
        } else if ([sender.titleLabel.text  isEqual: @"-"]) {
            [TimelineModel setSelectedClipNumber:-2];
            [_scene setSelectedClipNumber:-2];
        } else {
            int clipNumber = [sender.titleLabel.text intValue];
            [TimelineModel setSelectedClipNumber:clipNumber-1]; //IMPORTANT: internal clip numbers are 1 less than shown in display
            [_scene setSelectedClipNumber:clipNumber-1];
        }
        
    }
}


- (void)cancelTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.pickerTextField resignFirstResponder];
    _selectedMidiNote = -1;
    
}

- (void)doneTouched:(UIBarButtonItem *)sender
{
    // hide the picker view
    [self.pickerTextField resignFirstResponder];
    
    // perform some action
    [_scene.timelineModel.audioController assignMidiNote:_selectedMidiNote toClipButton:_selectedClipButton];
}





- (void) loadClip:(UIButton *)sender {
    //Get clip number from button title
    NSString *s = sender.titleLabel.text;
    NSInteger clipNum = [s integerValue];
    
    //Choose URL from filesystem
//    [[AudioShare sharedInstance] initiateSoundImport];
    //    NSOpenPanel *open =
    
    
    //Pass url and clipnum to audiocontroller
    //    [AudioController assignClip:url toIndex:clipNum];
}






#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_midiNoteList count];
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *item = [_midiNoteList objectAtIndex:row];
    
    return item;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // perform some action
    
    if ([[_midiNoteList objectAtIndex:row] isEqualToString:@"----"]) {
        _selectedMidiNote = -1;
    } else {
        _selectedMidiNote = [[_midiNoteList objectAtIndex:row] integerValue];
    }
}


@end