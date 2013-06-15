//
//  ViewController.m
//  XML Block Parser
//
//  Created by Robert Ryan on 6/14/13.
//  Copyright (c) 2013 Robert Ryan. All rights reserved.
//

#import "ViewController.h"
#import "XMLBlockParser.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSMutableDictionary *currentObject;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self parseTest];
}

- (void)parseTest
{
    self.objects = [NSMutableArray array];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    XMLBlockParser *parser = [[XMLBlockParser alloc] initWithData:data];

    // handler for the parsing of the start of an element, often useful for parsing the attributes included within
    // that opening element tag
    
    parser.beginElementBlock = ^(NSArray *elementNames, NSDictionary *attributeDict) {
        NSString *elementName = [elementNames lastObject];

        if ([elementName isEqualToString:@"Succession"])
        {
            if ([elementNames count] == 1)
            {
                // top level "Succession": create an object

                self.currentObject = [NSMutableDictionary dictionary];
                [self.currentObject setObject:attributeDict[@"SuccessionID"] forKey:@"SuccessionID"];
                [self.objects addObject:self.currentObject];
            }
            else
            {
                // "Succession" in either "LinkedSuccession" or "SeeAlsoSuccession"

                // let's find the array "LinkedSuccession" or "SeeAlsoSuccession" objects

                NSString *container = elementNames[[elementNames count] - 2];
                NSMutableArray *array = self.currentObject[container];
                if (!array)
                {
                    // if not found, then let's create it and add it to our currentObject

                    array = [NSMutableArray array];
                    self.currentObject[container] = array;
                }

                // how add the attributeDict value
                
                [array addObject:attributeDict[@"SuccessionID"]];
            }
        }
    };

    // handler for the characters between opening and closing tags
    
    parser.endElementBlock = ^(NSArray *elementNames, NSString *value) {
        NSString *elementName = [elementNames lastObject];

        if ([elementName isEqualToString:@"Test"])
        {
            NSMutableArray *array = self.currentObject[@"Tests"];
            if (!array)
            {
                array = [NSMutableArray array];
                self.currentObject[@"Tests"] = array;
            }
            [array addObject:value];
        }
    };
    
    [parser parse];

    NSLog(@"objects=%@", self.objects);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
