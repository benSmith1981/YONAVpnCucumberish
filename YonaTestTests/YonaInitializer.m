//
//  YonaInitializer.m
//  Yona
//
//  Created by Ben Smith on 15/03/16.
//  Copyright © 2016 Ben Smith. All rights reserved.
//

//Replace CucumberishExampleUITests with the name of your swift test target

#import "YonaTestUITests-Swift.h"

__attribute__((constructor))
void YonaInit()
{
    [YonaInitializer YonaSwiftInit];
}