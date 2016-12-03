//
//  GameOverScene.m
//  A game
//
//  Created by 7937 on 16/5/22.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "GameOverScene.h"
#import "GameScene.h"
#import "GameAgainBtn.h"

@implementation GameOverScene

-(id)initWithSize:(CGSize)size won:(BOOL)won{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [UIColor whiteColor];
        NSString *message;
        if (won) {
            message = @"you won!";
        }else{
            message = @"you lose :[";
        }
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        
        GameAgainBtn *againBtn = [[GameAgainBtn alloc]init];
        againBtn.position = CGPointMake(self.size.width/2, self.size.height/3);
        
        [self addChild:againBtn];
        
        [self addChild:label];
        [self runAction:[SKAction sequence:@[[SKAction waitForDuration:3.0]]]];
    }
    return self;
}

-(void)agianTheGame{
    GameScene *againScene = [[GameScene alloc]initWithSize:self.size];
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    [self.view presentScene:againScene transition:reveal];
}

@end
