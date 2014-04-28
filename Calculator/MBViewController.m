//
//  MBViewController.m
//  Calculator
//
//  Created by Markus on 23.04.14.
//  Copyright (c) 2014 MBulli. All rights reserved.
//

#import "MBViewController.h"

#import "Utilities.h"

typedef enum : NSUInteger {
    MBCalculatorOperationNone,
    MBCalculatorOperationAdd,
    MBCalculatorOperationSubtract,
    MBCalculatorOperationMultiply,
    MBCalculatorOperationDivide
} MBCalculatorOperation;

@interface MBViewController ()
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *numberButtons;
@property (weak, nonatomic) IBOutlet UITextField *textfield;
@property (weak, nonatomic) IBOutlet UIButton *seperatorButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@property(nonatomic, assign) MBCalculatorOperation lastOperation;
@property(nonatomic, assign) BOOL hasResult;
@property(nonatomic, strong) NSNumber *result;
@property(nonatomic, strong) NSNumber *operandA;
@property(nonatomic, strong) NSString *currentInput;

@property(nonatomic, strong) NSString *memory;
@property(nonatomic, readonly) NSNumberFormatter *formatter;

-(void)executeOperation:(MBCalculatorOperation)operation;
@end

@implementation MBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.hasResult = NO;
    
    // benutzer eingabe deaktivieren
    [self.textfield setEnabled:NO];
    // dezimal trennzeichen lokalisieren
    [self.seperatorButton setTitle:[self.formatter decimalSeparator] forState:UIControlStateNormal];

    for (UIButton *numBtn in self.numberButtons) {
        [numBtn addTarget:self
                   action:@selector(numberButtonTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSNumberFormatter *)formatter
{
    // formatter lazy erzeugen
    static dispatch_once_t onceToken;
    static NSNumberFormatter *_formatter;
    dispatch_once(&onceToken, ^{
        _formatter = [[NSNumberFormatter alloc] init];
        _formatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    
    return _formatter;
}

-(NSString *)currentInput
{
    return self.textfield.text;
}

-(void)setCurrentInput:(NSString *)currentInput
{
    self.textfield.text = currentInput;
}

-(void)executeOperation:(MBCalculatorOperation)operation
{
    if (operation == MBCalculatorOperationNone)
        return;

    self.lastOperation = operation;
    
    // 1. es wurde noch keine Zahl eingegeben
    if (!self.operandA ) {
        self.operandA = [self.formatter numberFromString:self.textfield.text];
        self.textfield.text = nil;
    // 2. es wurde eine Operation ausgewählt nachdem ein Ergebnis berechnet wurde
    } else if(self.result) {
        self.operandA = self.result;
        self.result = nil;
        self.textfield.text = nil;
        
    } else {
        double a = [self.operandA doubleValue];
        double b = [[self.formatter numberFromString:self.textfield.text] doubleValue];
        double x = 0.0;
        
        // breaks nicht vergessen; cases fallen durch
        switch (operation) {
            case MBCalculatorOperationAdd:
                x = a + b;
                break;
            case MBCalculatorOperationSubtract:
                x = a - b;
                break;
            case MBCalculatorOperationMultiply:
                x = a * b;
                break;
            case MBCalculatorOperationDivide:
                x = a / b;
                break;
            case MBCalculatorOperationNone:
            default:
                x = 0.0; // just in case
                break;
        }
        
        NSNumber *result = [NSNumber numberWithDouble:x];
        // NSNumber -stringValue ist nicht lokalisiert
        self.textfield.text = [self.formatter stringFromNumber:result];
        self.hasResult = YES;
        self.result = result;
    }
}

-(void)numberButtonTapped:(id)sender
{
    int tag = [sender tag];
    
    if (self.hasResult) {
        self.textfield.text = nil;
        self.hasResult = NO;
    }
    
    self.textfield.text = [self.textfield.text stringByAppendingString:intToStr(tag)];
}

- (IBAction)seperatorTapped:(id)sender
{
    // constanter pointer auf NSString
    // decSep = @"" wäre ein Compilerfehler
    NSString *const decSep = self.formatter.decimalSeparator;
    
    if (self.hasResult) {
        self.textfield.text = nil;
        self.hasResult = NO;
    }
    
    if ([self.textfield.text length] == 0) {
        self.textfield.text = [NSString stringWithFormat:@"0%@", decSep];
    } else {
        NSRange range = [self.textfield.text rangeOfString:decSep];
        
        // schon eine Ziffer vorhanden und wenn komma nicht gefunden  -> eins hinzufügen
        if (range.length == 0) {
            self.textfield.text = [self.textfield.text stringByAppendingString:decSep];
        }
    }
}

- (IBAction)equalsTapped:(id)sender
{
    if (self.result) {
        self.operandA = self.result;
        self.result = nil;
    }
    
    if (self.operandA) {
        [self executeOperation:self.lastOperation];
    }
}

- (IBAction)plusTapped:(id)sender
{
    [self executeOperation:MBCalculatorOperationAdd];
}

- (IBAction)minusTapped:(id)sender
{
    [self executeOperation:MBCalculatorOperationSubtract];
}

- (IBAction)multiplyTapped:(id)sender
{
    [self executeOperation:MBCalculatorOperationMultiply];
}
- (IBAction)divideTapped:(id)sender
{
    [self executeOperation:MBCalculatorOperationDivide];
}

- (IBAction)invertSignTapped:(id)sender
{
    if ([self.textfield.text hasPrefix:@"-"]) {
        self.textfield.text = [self.textfield.text substringFromIndex:1];
    } else {
        self.textfield.text = [@"-" stringByAppendingString:self.textfield.text];
    }
}

- (IBAction)clearTapped:(id)sender
{
    self.operandA = nil;
    self.result = nil;
    self.hasResult = NO;
    self.textfield.text = nil;
}

@end
