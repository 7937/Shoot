//
//  GameScene.m
//  A game
//
//  Created by 7937 on 16/5/22.
//  Copyright (c) 2016年 apple. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"

static inline CGPoint rwAdd(CGPoint a,CGPoint b){return CGPointMake(a.x+b.x, a.y+b.y);}
static inline CGPoint rwSub(CGPoint a,CGPoint b){return CGPointMake(a.x-b.x, a.y-b.y);}
static inline CGPoint rwMult(CGPoint a,float b){return CGPointMake(a.x*b, a.y*b);}
static inline float rwLength(CGPoint a){return sqrtf(a.x*a.x+a.y*a.y);}
static inline CGPoint rwNormalize(CGPoint a){
    float length = rwLength(a);
    return CGPointMake(a.x/length , a.y/length);
}

static const uint32_t projectileCategory = 0x1 << 0;
static const uint32_t monsterCategory = 0x1 << 1;

@interface  GameScene()<SKPhysicsContactDelegate>{
    int hitCount;
    SKLabelNode *hitLabel;
}
@property (nonatomic) SKSpriteNode *player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;





@end

@implementation GameScene


-(id)initWithSize:(CGSize)size{
    if (self = [super initWithSize:size]) {
        NSLog(@"Size: %@",NSStringFromCGSize(size));
        self.backgroundColor = [UIColor whiteColor];
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player.jpg"];
        self.player.size = CGSizeMake(100, 100);
        self.player.position = CGPointMake(100, 100);
        [self addChild:self.player];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
    
        hitLabel = [SKLabelNode labelNodeWithFontNamed:@""];
        hitLabel.position = CGPointMake(18, self.size.height-18);
        hitLabel.fontColor = [SKColor blackColor];
        hitLabel.fontSize = 18;
        [self addChild:hitLabel];
    }
    return self;
}

- (void)addMonster{
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster.jpg"];
    monster.size = CGSizeMake(50 , 50);
    
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = projectileCategory;
    monster.physicsBody.collisionBitMask = 0;
    //怪物竖直方向位置
    int minY = monster.size.height/2;
    int maxY = self.frame.size.height - monster.size.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() %rangeY) +minY;
    monster.position = CGPointMake(self.frame.size.width+monster.size.width/2, actualY);
    [self addChild:monster];
    
    //怪物速度
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    SKAction *actionMove = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    
    SKAction *loseAction =[SKAction runBlock:^{
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        SKScene *gameOverScene = [[GameOverScene alloc]initWithSize:self.size won:NO];
        [self.view presentScene:gameOverScene transition:reveal];
    }];
        [monster runAction:[SKAction sequence:@[actionMove,loseAction,actionMoveDone]]];
}


- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast{
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1.0) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

- (void)update:(NSTimeInterval)currentTime{
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1.0) {
        timeSinceLast =1.0/60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    [self updateWithTimeSinceLastUpdate:timeSinceLast];

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //选择touch对象
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    //初始化子弹位置
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"bullet.jpg"];
//    projectile.position = self.player.position;
    projectile.position = CGPointMake(self.player.position.x+50, self.player.position.y+16);
    projectile.size = CGSizeMake(10, 10);

    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width/2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    //计算子弹移动偏移量
    CGPoint offset = rwSub(location, projectile.position);
    //子弹后射则不操作
    if (offset.x < 0) return;
    //加上子弹
    [self addChild:projectile];
    //获取子弹射出方向
    CGPoint direction = rwNormalize(offset);
    //让子弹射的够远到达屏幕边缘
    CGPoint shootAmount = rwMult(direction, 1000);
    //子弹位移加到现在位置上
    CGPoint realDest = rwAdd(shootAmount, projectile.position);
    //创建子弹发射动作
    float velocity = 480.0/1.0;
    float realMoveDuration = self.size.width/velocity;
    SKAction *actionMove = [SKAction moveTo:realDest duration:realMoveDuration];
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[actionMove,actionMoveDone]]];
}

//碰撞后调用
-(void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster{
    NSLog(@"Hit");
    hitCount++;
    hitLabel.text = [NSString stringWithFormat:@"%d",hitCount];
//    [self addChild:hitLabel];
    [projectile removeFromParent];
    [monster removeFromParent];
}


-(void)didBeginContact:(SKPhysicsContact *)contact{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else{
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & projectileCategory) !=0 &&(secondBody.categoryBitMask & monsterCategory) !=0) {
        [self projectile:(SKSpriteNode *)firstBody.node didCollideWithMonster:(SKSpriteNode *)secondBody.node];
    }
}


@end
