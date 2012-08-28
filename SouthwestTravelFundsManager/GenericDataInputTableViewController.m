//
//  GenericFlightTableViewController.m
//  SouthwestTravelManager
//
//  Created by Colin Regan on 8/20/12.
//  Copyright (c) 2012 Red Cup. All rights reserved.
//

#import "GenericDataInputTableViewController.h"
#import "Flight+Create.h"
#import "Fund+Create.h"

@interface GenericDataInputTableViewController ()

- (void)setCustomInputViews;
- (void)setDataInFields;
- (void)datePickerDidEndEditing:(UIDatePicker *)sender;
- (void)switchDidEndEditing:(UISwitch *)sender;
- (void)selectAnimated:(NSSet *)incompleteFields fromRequiredFields:(NSDictionary *)requiredFields;
- (NSSet *)validateFields:(NSMutableSet *)enteredData;

@end

@implementation GenericDataInputTableViewController

@synthesize flightTextField = _flightTextField;
@synthesize confirmTextField = _confirmTextField;
@synthesize costTextField = _costTextField;
@synthesize expirationTextField = _expirationTextField;
@synthesize roundtripSwitch = _roundtripSwitch;
@synthesize outboundTextField = _outboundTextField;
@synthesize returnTextField = _returnTextField;
@synthesize checkInReminderSwitch = _checkInReminderSwitch;
@synthesize notesTextField = _notesTextField;
@synthesize fieldData = _fieldData;
@synthesize airportPickerVC = _airportPickerVC;
@synthesize expirationDatePicker = _expirationDatePicker;
@synthesize outboundDatePicker = _outboundDatePicker;
@synthesize returnDatePicker = _returnDatePicker;
@synthesize formatter = _formatter;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.flightTextField.delegate = self;
    self.confirmTextField.delegate = self;
    self.costTextField.delegate = self;
    self.expirationTextField.delegate = self;
    self.outboundTextField.delegate = self;
    self.returnTextField.delegate = self;
    self.notesTextField.delegate = self;
    [self setCustomInputViews];
    [self setDataInFields];
}

- (NSMutableDictionary *)fieldData {
    if (!_fieldData) _fieldData = [[NSMutableDictionary alloc] initWithCapacity:10];
    return _fieldData;
}

- (void)setDataInFields {
    NSDictionary *aOrigin = [self.fieldData objectForKey:ORIGIN];
    NSDictionary *aDestination = [self.fieldData objectForKey:DESTINATION];
    if (aOrigin && aDestination) [self.airportPickerVC setSelectedOrigin:aOrigin andDestination:aDestination];
    NSString *aConfirmationCode = [self.fieldData objectForKey:CONFIRMATION_CODE];
    if (aConfirmationCode) self.confirmTextField.text = aConfirmationCode;
    NSNumber *aCost = [self.fieldData objectForKey:COST];
    if (aCost) self.costTextField.text = [self.formatter stringForCost:aCost];
    NSDate *aExpirationDate = [self.fieldData objectForKey:EXPIRATION_DATE];
    if (aExpirationDate) {
        self.expirationDatePicker.date = aExpirationDate;
        [self datePickerDidEndEditing:self.expirationDatePicker];
    }
    NSNumber *aRoundtrip = [self.fieldData objectForKey:ROUNDTRIP];
    if (aRoundtrip) self.roundtripSwitch.on = [aRoundtrip boolValue];
    NSDate *aOutboundDepartureDate = [self.fieldData objectForKey:OUTBOUND_DEPARTURE_DATE];
    if (aOutboundDepartureDate) {
        self.outboundDatePicker.date = aOutboundDepartureDate;
        [self datePickerDidEndEditing:self.outboundDatePicker];
    }
    NSDate *aReturnDepartureDate = [self.fieldData objectForKey:RETURN_DEPARTURE_DATE];
    if (aReturnDepartureDate) {
        self.returnDatePicker.date = aReturnDepartureDate;
        [self datePickerDidEndEditing:self.returnDatePicker];
    }
    NSNumber *aCheckInReminder = [self.fieldData objectForKey:CHECK_IN_REMINDER];
    if (aCheckInReminder) self.checkInReminderSwitch.on = [aCheckInReminder boolValue];
    NSString *aNotes = [self.fieldData objectForKey:NOTES];
    if (aNotes) self.notesTextField.text = aNotes;
}

- (AirportPickerViewController *)airportPickerVC {
    if (!_airportPickerVC) {
        _airportPickerVC = [[AirportPickerViewController alloc] init];
        _airportPickerVC.delegate = self;
    }
    return _airportPickerVC;
}

- (UIDatePicker *)expirationDatePicker {
    if (!_expirationDatePicker) {
        _expirationDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 244, 320, 270)];
        _expirationDatePicker.datePickerMode = UIDatePickerModeDate;
        _expirationDatePicker.timeZone = [NSTimeZone localTimeZone];
        [_expirationDatePicker addTarget:self action:@selector(datePickerDidEndEditing:) forControlEvents:UIControlEventValueChanged];
    }
    return _expirationDatePicker;
}

- (UIDatePicker *)outboundDatePicker {
    if (!_outboundDatePicker) {
        _outboundDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 244, 320, 270)];
        _outboundDatePicker.minuteInterval = 5;
        _outboundDatePicker.timeZone = [NSTimeZone timeZoneWithName:[[self.fieldData objectForKey:ORIGIN] objectForKey:TIME_ZONE]];
        [_outboundDatePicker addTarget:self action:@selector(datePickerDidEndEditing:) forControlEvents:UIControlEventValueChanged];
    }
    return _outboundDatePicker;
}

- (UIDatePicker *)returnDatePicker {
    if (!_returnDatePicker) {
        _returnDatePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 244, 320, 270)];
        _returnDatePicker.minuteInterval = 5;
        _returnDatePicker.timeZone = [NSTimeZone timeZoneWithName:[[self.fieldData objectForKey:DESTINATION] objectForKey:TIME_ZONE]];
        [_returnDatePicker addTarget:self action:@selector(datePickerDidEndEditing:) forControlEvents:UIControlEventValueChanged];
    }
    return _returnDatePicker;
}

- (DateAndCurrencyFormatter *)formatter {
    if (!_formatter) _formatter = [[DateAndCurrencyFormatter alloc] init];
    return  _formatter;
}

- (void)setCustomInputViews {
    self.flightTextField.inputView = self.airportPickerVC.airportPicker;
    self.costTextField.keyboardType = UIKeyboardTypeDecimalPad;
    self.expirationTextField.inputView = self.expirationDatePicker;
    [self.roundtripSwitch addTarget:self action:@selector(switchDidEndEditing:) forControlEvents:UIControlEventValueChanged];
    self.outboundTextField.inputView = self.outboundDatePicker;
    self.returnTextField.inputView = self.returnDatePicker;
    [self.checkInReminderSwitch addTarget:self action:@selector(switchDidEndEditing:) forControlEvents:UIControlEventValueChanged];
}

- (void)updatePlaceholderText {
    self.expirationTextField.placeholder = [self.formatter stringForDate:[NSDate dateWithTimeIntervalSinceNow:(60*60*24*365)] withFormat:DATE_FORMAT inTimeZone:[NSTimeZone localTimeZone]];
    self.outboundTextField.placeholder = [self.formatter stringForDate:[NSDate dateWithTimeIntervalSinceNow:(60*60*24*31)] withFormat:DATE_TIME_FORMAT inTimeZone:[NSTimeZone localTimeZone]];
    self.returnTextField.placeholder = [self.formatter stringForDate:[NSDate dateWithTimeIntervalSinceNow:(60*60*24*36)] withFormat:DATE_TIME_FORMAT inTimeZone:[NSTimeZone localTimeZone]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return TRUE;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([textField isEqual:self.confirmTextField]) {
        // move first responder after 6 characters in confirmation code
        if (newString.length == 6) {
            self.confirmTextField.text = newString;
            [self.costTextField becomeFirstResponder];
            return FALSE;
        }
    } else if ([textField isEqual:self.costTextField]) {
        // disallow deletion of "$" character
        if (range.location == 0) return FALSE;
        // disallow multiple decimal points
        if ([string isEqualToString:@"."] && [textField.text rangeOfString:@"."].length) return FALSE;
        // disallow more than two digits after decimal point
        if ([newString rangeOfString:@"."].length && [newString rangeOfString:@"."].location < newString.length - 3) return FALSE;
        // move first responder with two digits after decimal point
        if (newString.length >= 3 && [newString characterAtIndex:newString.length - 3] == '.') {
            self.costTextField.text = newString;
            [self.expirationTextField becomeFirstResponder];
            return FALSE;
        }
    }
    return TRUE;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.costTextField]) {
        // add currency symbol when empty
        if (!self.costTextField.text.length) self.costTextField.text = @"$";
    } else if ([textField isEqual:self.expirationTextField]) {
        if (!self.expirationTextField.text.length) {
            [self.expirationDatePicker setDate:[NSDate dateWithTimeIntervalSinceNow:(60*60*24*365)] animated:TRUE];
            [self datePickerDidEndEditing:self.expirationDatePicker];
        }
    } else if ([textField isEqual:self.returnTextField]) {
        // update date to departure date
        if (!self.returnTextField.text.length) [self.returnDatePicker setDate:self.outboundDatePicker.date animated:TRUE];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // update corresponding property
    if ([textField isEqual:self.confirmTextField]) {
        [self.fieldData setObject:self.confirmTextField.text forKey:CONFIRMATION_CODE];
    } else if ([textField isEqual:self.costTextField]) {
        NSString *numberValue;
        if ([self.costTextField.text hasPrefix:@"$"]) numberValue = [self.costTextField.text substringFromIndex:1];
        if (![numberValue doubleValue] && ![self.costTextField isFirstResponder]) {
            self.costTextField.text = @"";
        } else {
            self.costTextField.text = [self.formatter stringForCost:[NSNumber numberWithDouble:[numberValue doubleValue]]];
        }
        [self.fieldData setObject:[NSNumber numberWithDouble:[numberValue doubleValue]] forKey:@"cost"];
    } else if ([textField isEqual:self.notesTextField]) {
        [self.fieldData setObject:self.notesTextField.text forKey:NOTES];
    }
}

- (void)datePickerDidEndEditing:(UIDatePicker *)sender {
    // update corresponding property and update text field
    if ([sender isEqual:self.expirationDatePicker]) {
        [self.fieldData setObject:self.expirationDatePicker.date forKey:EXPIRATION_DATE];
        self.expirationTextField.text = [self.formatter stringForDate:self.expirationDatePicker.date withFormat:DATE_FORMAT inTimeZone:self.expirationDatePicker.timeZone];
    } else if ([sender isEqual:self.outboundDatePicker]) {
        [self.fieldData setObject:self.outboundDatePicker.date forKey:OUTBOUND_DEPARTURE_DATE];
        self.outboundTextField.text = [self.formatter stringForDate:self.outboundDatePicker.date withFormat:DATE_TIME_FORMAT inTimeZone:self.outboundDatePicker.timeZone];
    } else if ([sender isEqual:self.returnDatePicker]) {
        [self.fieldData setObject:self.returnDatePicker.date forKey:RETURN_DEPARTURE_DATE];
        self.returnTextField.text = [self.formatter stringForDate:self.returnDatePicker.date withFormat:DATE_TIME_FORMAT inTimeZone:self.returnDatePicker.timeZone];
    }
}

- (void)switchDidEndEditing:(UISwitch *)sender {
    // update corresponding property
    if ([sender isEqual:self.roundtripSwitch]) {
        [self.fieldData setObject:[NSNumber numberWithBool:self.roundtripSwitch.on] forKey:ROUNDTRIP];
    } else if ([sender isEqual:self.checkInReminderSwitch]) {
        [self.fieldData setObject:[NSNumber numberWithBool:self.checkInReminderSwitch.on] forKey:CHECK_IN_REMINDER];
    }
}

- (void)airportPickerViewController:(AirportPickerViewController *)airportPickerVC selectedOrigin:(NSDictionary *)origin andDestination:(NSDictionary *)destination {
    self.flightTextField.text = [NSString stringWithFormat:@"%@ - %@", [origin objectForKey:AIRPORT_CODE], [destination objectForKey:AIRPORT_CODE]];
    [self.fieldData setObject:origin forKey:ORIGIN];
    [self.fieldData setObject:destination forKey:DESTINATION];
    self.outboundDatePicker.timeZone = [NSTimeZone timeZoneWithName:[origin objectForKey:TIME_ZONE]];
    if (self.outboundTextField.text.length) self.outboundTextField.text = [self.formatter stringForDate:self.outboundDatePicker.date withFormat:DATE_TIME_FORMAT inTimeZone:self.outboundDatePicker.timeZone];
    self.returnDatePicker.timeZone = [NSTimeZone timeZoneWithName:[destination objectForKey:TIME_ZONE]];
    if (self.returnTextField.text.length) self.returnTextField.text = [self.formatter stringForDate:self.returnDatePicker.date withFormat:DATE_TIME_FORMAT inTimeZone:self.returnDatePicker.timeZone];
}

- (BOOL)tableHasIncompleteRequiredFields:(NSDictionary *)requiredFields {
    NSSet *completedFields = [self validateFields:[NSMutableSet setWithArray:[self.fieldData allKeys]]];
    NSMutableSet *incompleteRequiredFields = [NSMutableSet setWithArray:[requiredFields allKeys]];
    [incompleteRequiredFields minusSet:completedFields];
    [self selectAnimated:incompleteRequiredFields fromRequiredFields:requiredFields];
    return incompleteRequiredFields.count;
}

- (NSSet *)validateFields:(NSMutableSet *)enteredData {
    NSMutableSet *invalid = [[NSMutableSet alloc] initWithCapacity:8];
    for (NSString *field in enteredData) {
        if ([field isEqualToString:DESTINATION]) {
            if ([[self.fieldData objectForKey:field] isEqualToDictionary:[self.fieldData objectForKey:ORIGIN]]) [invalid addObject:field];
        } else if ([field isEqualToString:CONFIRMATION_CODE]) {
            if ([(NSString *)[self.fieldData objectForKey:field] length] != 6) [invalid addObject:field];
        } else if ([field isEqualToString:COST]) {
            if ([(NSNumber *)[self.fieldData objectForKey:field] doubleValue] == 0) [invalid addObject:field];
        } else if ([field isEqualToString:RETURN_DEPARTURE_DATE]) {
            if ([(NSDate *)[self.fieldData objectForKey:field] compare:[self.fieldData objectForKey:OUTBOUND_DEPARTURE_DATE]] == NSOrderedAscending) [invalid addObject:field];
        }
    }
    [enteredData minusSet:invalid];
    return enteredData;
}

- (void)selectAnimated:(NSSet *)incompleteFields fromRequiredFields:(NSDictionary *)requiredFields {
    NSIndexPath *topIndex = [NSIndexPath indexPathForRow:0 inSection:3];
    for (NSString *field in incompleteFields) {
        NSIndexPath *indexPath = [requiredFields objectForKey:field];
        if ([indexPath compare:topIndex] == NSOrderedAscending) topIndex = indexPath;
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:TRUE];
        [cell setSelected:FALSE animated:TRUE];
    }
    if (incompleteFields.count) [self.tableView scrollToRowAtIndexPath:topIndex atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidUnload {
    [self setFlightTextField:nil];
    [self setConfirmTextField:nil];
    [self setCostTextField:nil];
    [self setExpirationTextField:nil];
    [self setRoundtripSwitch:nil];
    [self setOutboundTextField:nil];
    [self setReturnTextField:nil];
    [self setCheckInReminderSwitch:nil];
    [self setNotesTextField:nil];
    [super viewDidUnload];
}
@end
