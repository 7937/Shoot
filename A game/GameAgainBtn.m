//
//  GameAgainBtn.m
//  A game
//
//  Created by 7937 on 16/5/23.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "GameAgainBtn.h"
#import "GameScene.h"

@implementation GameAgainBtn

-(id)init{
    if (self = [super init]) {
        self.fontName = @"Chalkduster";
        self.text = @"Again";
        self.fontSize = 20;
        self.fontColor = [SKColor blackColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    GameScene * myScene = [[GameScene alloc] initWithSize:self.scene.size];
    [self.scene.view presentScene:myScene transition: reveal];
}

@end
