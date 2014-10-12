//
//  GameScene.m
//  MLH Hack Game
//
//  Created by Stephen Sowole on 04/10/2014.
//  Copyright (c) 2014 Stephen Sowole. All rights reserved.
//

#import "GameScene.h"

#define CIRCLE_DIAMETER 20.0
#define PAD_WIDTH 30.0
#define PAD_HEIGHT 140.0
#define PAD_SEPERATION_ONSCREEN 10
#define PAD_SPEED 40.0
#define SEPARATOR_WIDTH 2.0
#define BALL_SPEED 3.0

@implementation GameScene {
    
    SKShapeNode *leftPad, *rightPad, *ball;
    
    int player1Score, player2Score, numberOfPlayers;
    
    NSString *player1, *player2;
    
    SKLabelNode *myLabel, *player1Label, *player2Label;
    
    SocketIO *socketIO;
}

- (void) didMoveToView:(SKView *)view {
    
    player1Score = 0; player2Score = 0; numberOfPlayers = 0;
    
    player1 = @""; player2 = @"";
    
    [self setGamePhysics];
    
    [self setUpGameScene];
    
    [self addObjectPhysics];
}

- (void) addObjectPhysics {
    
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:CIRCLE_DIAMETER/2];
    ball.physicsBody.friction = 0.0f;
    ball.physicsBody.restitution = 1.0f;
    ball.physicsBody.linearDamping = 0.0f;
    ball.physicsBody.allowsRotation = NO;
    
    leftPad.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:leftPad.path];
    leftPad.physicsBody.restitution = 0.1f;
    leftPad.physicsBody.friction = 0.4f;
    leftPad.physicsBody.dynamic = NO;
    
    rightPad.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:rightPad.path];
    rightPad.physicsBody.restitution = 0.1f;
    rightPad.physicsBody.friction = 0.4f;
    rightPad.physicsBody.dynamic = NO;
}

- (void) setGamePhysics {
    
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    
    CGRect physicsFrame = CGRectMake(-CIRCLE_DIAMETER*6, 50.0, self.frame.size.width + CIRCLE_DIAMETER*12, self.frame.size.height - 120.0);
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:physicsFrame];
    
    self.physicsBody.friction = 0.0f;
}

- (void) setUpGameScene {
    
    [self setBackgroundColor:[SKColor colorWithRed:0.141 green:0.153 blue:0.161 alpha:1.0]];
    
    [self addLeftPad];
    
    [self addRightPad];
    
    [self addExtraFeatures];
    
    [self addBall];

    
    socketIO = [[SocketIO alloc] initWithDelegate:self];
    //[socketIO connectToHost:@"hlxulrdkww.localtunnel.me/respond" onPort:8080 ];
    
    //socketIO.useSecure = YES;
    
    [socketIO connectToHost:@"localhost" onPort:8080];
    
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
    NSArray *array = packet.dataAsJSON;
    
    NSString *player = [[array objectAtIndex:1] valueForKey:@"phone_Number"];
    
    if ([player1 isEqualTo:@""]) {
        
        player1 = player;
        player1Label.text = [NSString stringWithFormat:@"Player 1:\n%@", player];
        
    } else if ([player2 isEqualTo:@""] && ![player isEqualTo:player1]) {
        
        player2 = player;
        player2Label.text = [NSString stringWithFormat:@"Player 2:\n%@", player];
        
    } else {
        
        if ([[array objectAtIndex:1] valueForKey:@"number_Pressed"]) {
            
            int num = [[[array objectAtIndex:1] valueForKey:@"number_Pressed"] intValue];
            
            if ([player isEqualTo:player1]) {
                
                [self moveLeftPad:num];
                
            } else if ([player isEqualTo:player2]) {
                
                [self moveRightPad:num];
                
            }
        }
    }
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
    NSLog(@"data = %@", packet.data);
    // NSLog(@"%@", [packet.data valueForKey:@"phone_number"]);
    /*NSString *player = [packet.data valueForKey:@"phone_number"];
     
     if ([player1 isEqualTo:@""]) {
     
     player1 = player;
     
     } else if ([player2 isEqualTo:@""] && ![player isEqualTo:player1]) {
     
     player2 = player;
     
     } else {
     
     if (player) {
     
     //if ([packet.data valueForKey:@"number_Pressed"]) {
     
     int num = [[packet.data valueForKey:@"number_Pressed"] intValue];
     
     if ([player isEqualTo:player1]) {
     
     [self moveLeftPad:num];
     
     } else if ([player isEqualTo:player2]) {
     
     [self moveRightPad:num];
     }
     }
     }*/
}

- (void) moveLeftPad:(int)moveNum {
    
    if (![player1 isEqualTo:@""] && ![player2 isEqualTo:@""] && ball.physicsBody.velocity.dy == 0 && ball.physicsBody.velocity.dx == 0) {
    
        if (arc4random() % 2 == 1) {
            
            if (arc4random() % 2 == 1) {
            
                [ball.physicsBody applyImpulse:CGVectorMake(BALL_SPEED, -BALL_SPEED/6)];
                
            } else {
                
                [ball.physicsBody applyImpulse:CGVectorMake(BALL_SPEED, BALL_SPEED/6)];
            }
            
        } else {
            
            if (arc4random() % 2 == 1) {
                
                [ball.physicsBody applyImpulse:CGVectorMake(-BALL_SPEED, -BALL_SPEED/6)];
                
            } else {
                
                [ball.physicsBody applyImpulse:CGVectorMake(-BALL_SPEED, BALL_SPEED/6)];
            }
        }
    }
    
    if (moveNum == 5 || moveNum == 2) {
        
        if (leftPad.position.y < self.frame.size.height - PAD_HEIGHT/2) {
        
            leftPad.position = CGPointMake(leftPad.position.x, leftPad.position.y + PAD_SPEED);
        }
        
    } else if (moveNum == 8 || moveNum == 0) {
        
        if (leftPad.position.y > 0) {
        
            leftPad.position = CGPointMake(leftPad.position.x, leftPad.position.y - PAD_SPEED);
        }
    }
}

- (void) moveRightPad:(int)moveNum {
    
    if (![player1 isEqualTo:@""] && ![player2 isEqualTo:@""] && ball.physicsBody.velocity.dy == 0 && ball.physicsBody.velocity.dx == 0) {
        
        if (arc4random() % 2 == 1) {
            
            if (arc4random() % 2 == 1) {
                
                [ball.physicsBody applyImpulse:CGVectorMake(BALL_SPEED, -BALL_SPEED/6)];
                
            } else {
                
                [ball.physicsBody applyImpulse:CGVectorMake(BALL_SPEED, BALL_SPEED/6)];
            }
            
        } else {
            
            if (arc4random() % 2 == 1) {
                
                [ball.physicsBody applyImpulse:CGVectorMake(-BALL_SPEED, -BALL_SPEED/6)];
                
            } else {
                
                [ball.physicsBody applyImpulse:CGVectorMake(-BALL_SPEED, BALL_SPEED/6)];
            }
        }
    }
    
    if (moveNum == 5 || moveNum == 2) {
        
        if (rightPad.position.y < self.frame.size.height - PAD_HEIGHT/2) {
            
            rightPad.position = CGPointMake(rightPad.position.x, rightPad.position.y + PAD_SPEED);
        }
        
    } else if (moveNum == 8 || moveNum == 0) {
        
        if (leftPad.position.y > 0) {
            
            rightPad.position = CGPointMake(rightPad.position.x, rightPad.position.y - PAD_SPEED);
        }
    }
}

- (void) socketIODidConnect:(SocketIO *)socket
{
    NSLog(@"we did connected");
    [socketIO sendEvent:@"join" withData:@"iOSuser"];
}

- (void) addExtraFeatures {
    
    myLabel = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Medium"];
    
    myLabel.text = [NSString stringWithFormat:@"%i     %i", player1Score, player2Score];
    
    myLabel.fontSize = 80.0;
    
    myLabel.fontColor = [SKColor grayColor];
    
    myLabel.position = CGPointMake(CGRectGetMidX(self.frame),self.frame.size.height/1.3);
    
    [self addChild:myLabel];
    
    CGRect box = CGRectMake(0.0f, 0.0f, SEPARATOR_WIDTH, self.frame.size.height);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, box);
    
    SKShapeNode *separator = [SKShapeNode node];
    separator.path = path;
    CGPathRelease(path);
    separator.fillColor = [SKColor whiteColor];
    separator.lineWidth = 1.0f;
    
    separator.position = CGPointMake((self.frame.size.width/2 - SEPARATOR_WIDTH/2), 0);
    
    [self addChild:separator];
    
    player1Label = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Medium"];
    player1Label.text = [NSString stringWithFormat:@"Player 1:\nWaiting For Connection"];
    player1Label.fontSize = 20.0;
    player1Label.position = CGPointMake(leftPad.position.x + 100.0, self.frame.size.height/8);
    [self addChild:player1Label];
    
    player2Label = [SKLabelNode labelNodeWithFontNamed:@"AppleSDGothicNeo-Medium"];
    player2Label.text = [NSString stringWithFormat:@"Player 2:\nWaiting For Connection"];
    player2Label.fontSize = 20.0;
    player2Label.position = CGPointMake(rightPad.position.x - 100.0, self.frame.size.height/8);
    [self addChild:player2Label];
    
}

- (void) addLeftPad {
    
    CGRect box = CGRectMake(0.0f, 0.0f, PAD_WIDTH, PAD_HEIGHT);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, box);
    
    leftPad = [SKShapeNode node];
    leftPad.path = path;
    CGPathRelease(path);
    leftPad.fillColor = [SKColor grayColor];
    leftPad.lineWidth = 2.0f;
    leftPad.strokeColor = leftPad.fillColor;
    
    leftPad.position = CGPointMake((self.frame.size.width/PAD_SEPERATION_ONSCREEN), self.frame.size.height/2  - PAD_HEIGHT/2);
    
    [self addChild:leftPad];
}

- (void) addRightPad {
    
    CGRect box = CGRectMake(0.0f, 0.0f, PAD_WIDTH, PAD_HEIGHT);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, box);
    
    rightPad = [SKShapeNode node];
    rightPad.path = path;
    CGPathRelease(path);
    rightPad.fillColor = [SKColor grayColor];
    rightPad.lineWidth = 1.0f;
    rightPad.strokeColor = rightPad.fillColor;
    
    rightPad.position = CGPointMake((self.frame.size.width/PAD_SEPERATION_ONSCREEN) * (PAD_SEPERATION_ONSCREEN - 1) - PAD_WIDTH, self.frame.size.height/2 - PAD_HEIGHT/2);
    
    [self addChild:rightPad];
}

- (void) addBall {
    
    CGRect box = CGRectMake(0.0f, 0.0f, CIRCLE_DIAMETER, CIRCLE_DIAMETER);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, box);
    
    ball = [SKShapeNode node];
    ball.path = path;
    CGPathRelease(path);
    ball.fillColor = [SKColor grayColor];
    ball.lineWidth = 1.0f;
    //ball.strokeColor = ball.fillColor;
    
    ball.position = CGPointMake(self.frame.size.width/2 - CIRCLE_DIAMETER/2, self.frame.size.height/2 - CIRCLE_DIAMETER/2);
    
    [self addChild:ball];
}

- (void) updateScoreAndReset {
    
    myLabel.text = [NSString stringWithFormat:@"%i     %i", player1Score, player2Score];
    ball.position = CGPointMake(self.frame.size.width/2 - CIRCLE_DIAMETER/2, self.frame.size.height/2);
    [ball.physicsBody setVelocity:CGVectorMake(0.0f, 0.0f)];
    
    rightPad.position = CGPointMake((self.frame.size.width/PAD_SEPERATION_ONSCREEN) * (PAD_SEPERATION_ONSCREEN - 1) - PAD_WIDTH, self.frame.size.height/2 - PAD_HEIGHT/2);
    
    leftPad.position = CGPointMake((self.frame.size.width/PAD_SEPERATION_ONSCREEN), self.frame.size.height/2  - PAD_HEIGHT/2);
}

- (void) update:(NSTimeInterval)currentTime {
    
    if (ball.position.x > self.frame.size.width) {
        
        player1Score++;
        
        [self updateScoreAndReset];
        
    } else if (ball.position.x < 0) {
        
        player2Score++;
        
        [self updateScoreAndReset];
    }
    
    [self fixGradientBugs];
}

- (void) fixGradientBugs {
    
    if (ball.physicsBody.velocity.dy == 0 && ball.physicsBody.velocity.dx != 0) {
        
        [ball.physicsBody applyImpulse:CGVectorMake(0, 3)];
    }
    
    if (ball.physicsBody.velocity.dy != 0 && ball.physicsBody.velocity.dx == 0) {
        
        [ball.physicsBody applyImpulse:CGVectorMake(3, 0)];
    }
}

@end
