//
//  HelloWorldLayer.mm
//  PESpriteTest
//
//  Created by Jay Elaraj on 5/15/12.
//  Copyright nerdcave.com 2012. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "PESprite.h"

@implementation HelloWorldLayer

+(CCScene *) scene {
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

// multiplies by 2 if iPad
#define ccp_IPAD(__x__, __y__)	(ccpMult(ccp(__x__, __y__), IPAD_SCALE()))

-(id) init {
	if( (self = [super init]) ) {
		CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
		[sharedFileUtils setiPadSuffix:@"-hd"];		// use iPhone retina images for normal iPad (normally specified in your AppDelegate)

		// enable touch
		[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];

		// load the shape data created by PhysicsEditor
		[[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"data/physicsEditorObjects.plist"];

		// create a PESprite just as you would a CCSprite
		PESprite *ship = [PESprite spriteWithFile:@"images/spaceship.png"];
		// required! set this property to its shape name in PhysicsEditor
		ship.physicsEditorName = @"spaceship";

		[self addChild:ship];
		ship.position = ccp_IPAD(400, 100);

		PESprite *satellite = [PESprite spriteWithFile:@"images/satellite.png"];
		satellite.physicsEditorName = @"satellite";
		[self addChild:satellite];
		satellite.position = ccp_IPAD(100, 100);

		PESprite *chair = [PESprite spriteWithFile:@"images/chair.png"];
		chair.physicsEditorName = @"chair";
		[self addChild:chair];
		chair.position = ccp_IPAD(100, 260);

		PESprite *earth = [PESprite spriteWithFile:@"images/earth.png"];
		earth.physicsEditorName = @"earth";
		[self addChild:earth];
		earth.position = ccp_IPAD(450, 260);

		CGSize winSize = [[CCDirector sharedDirector] winSize];
		infoLabel = [CCLabelTTF labelWithString:@"Drag images to test collisions" fontName:@"Arial" fontSize:30];
		infoLabel.anchorPoint = ccp(.5, 0);
		infoLabel.position = ccp(winSize.width / 2, 0);
		[infoLabel setColor:ccWHITE];
		[self addChild:infoLabel];
	}
	return self;
}


-(void) checkSelectedSpriteCollision {
	CCNode *node = nil;
	BOOL hit = NO;
	CCARRAY_FOREACH([self children], node) {
		if (selectedSprite != node && [node isKindOfClass:[PESprite class]]) {
			PESprite *sprite = (PESprite*)node;
			// test for intersection
			if ([selectedSprite intersectsTarget:sprite]) {
				[infoLabel setString:[NSString stringWithFormat:@"%@ and %@ HIT!", selectedSprite.physicsEditorName, sprite.physicsEditorName]];
				hit = YES;
			}
		}
	}
	if (!hit) {
		[infoLabel setString:@""];
	}
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
	CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
	CCNode *node = nil;
	CCARRAY_FOREACH([self children], node) {
		if (CGRectContainsPoint(node.boundingBox, touchLocation)) {
			if ([node isKindOfClass:[PESprite class]]) {
				selectedSprite = (PESprite*)node;
				break;
			}
		}
	}    
	return YES;    
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {       
	CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
	CGPoint prevTouchLocation = [touch previousLocationInView:touch.view];
	prevTouchLocation = [[CCDirector sharedDirector] convertToGL:prevTouchLocation];
	prevTouchLocation = [self convertToNodeSpace:prevTouchLocation];

	CGPoint touchDiff = ccpSub(touchLocation, prevTouchLocation);
	selectedSprite.position = ccpAdd(selectedSprite.position, touchDiff);
	[self checkSelectedSpriteCollision];
}



-(void) dealloc {
	[super dealloc];
}

@end
