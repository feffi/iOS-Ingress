//
//  EarthViewController.m
//  Ingress
//
//  Created by Alex Studnicka on 27.01.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "GLViewController.h"

#import "sphere.h"
#import "resonatorResourceUnit.h"
#import "xmpResourceUnit.h"
#import "shieldResourceUnit.h"

#define IS_4_INCH ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface GLViewController ()

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation GLViewController

@synthesize modelID = _modelID;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	
	if (!self.context) {
		NSLog(@"Error creating context!");
	}
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
	
	self.modelID = self.view.tag;
    
    [self setupGL];
}

- (void)dealloc {
    [self tearDownGL];
    
    self.view = nil;

    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

- (void)setModelID:(int)modelID {
	_modelID = modelID;
	
	[self tearDownGL];
	[self setupGL];
}

- (void)setupGL {
	
	[EAGLContext setCurrentContext:self.context];
	
	switch (self.modelID) {
		case 1: {
			
			glEnable(GL_DEPTH_TEST);
			
			self.effect = [GLKBaseEffect new];
			
			self.effect.light0.enabled = GL_TRUE;
			
			NSError *error;
			NSString *path = [[NSBundle mainBundle] pathForResource:@"borders" ofType:@"png"];
			GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:path options:@{GLKTextureLoaderOriginBottomLeft: @YES} error:&error];
			if (!texture) {
				NSLog(@"Error loading texture: %@", [error localizedDescription]);
			}
			self.effect.texture2d0.enabled = GL_TRUE;
			self.effect.texture2d0.name = texture.name;
			glActiveTexture(GL_TEXTURE0);
			
			glEnableVertexAttribArray(GLKVertexAttribPosition);
			glEnableVertexAttribArray(GLKVertexAttribNormal);
			glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
			glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, sphereVerts);
			glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, sphereNormals);
			glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, sphereTexCoords);
			
			break;
		}
			
		case 2: {
			
			glEnable(GL_DEPTH_TEST);
			
			self.effect = [GLKBaseEffect new];
			
			self.effect.light0.enabled = GL_TRUE;
			
			//253./255.,41./255.,146./255.
			self.effect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
			self.effect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1);
			//			self.effect.light0.specularColor = GLKVector4Make(1, 1, 1, 1);
			
			NSError *error;
			NSString *path = [[NSBundle mainBundle] pathForResource:@"resonatorTexture" ofType:@"png"];
			GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:path options:@{GLKTextureLoaderOriginBottomLeft: @YES} error:&error];
			if (!texture) {
				NSLog(@"Error loading texture: %@", [error localizedDescription]);
			}
			self.effect.texture2d0.enabled = GL_TRUE;
			self.effect.texture2d0.name = texture.name;
			glActiveTexture(GL_TEXTURE0);
			
			glEnableVertexAttribArray(GLKVertexAttribPosition);
			glEnableVertexAttribArray(GLKVertexAttribNormal);
			glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
			glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, resonatorResourceUnitVerts);
			glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, resonatorResourceUnitVerts);
			glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, resonatorResourceUnitTexCoords);
			
			break;
		}
			
		case 3: {
			
			glEnable(GL_DEPTH_TEST);
			
			self.effect = [GLKBaseEffect new];
			
			self.effect.light0.enabled = GL_TRUE;
			
			//253./255.,41./255.,146./255.
			self.effect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
			self.effect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1);
			//			self.effect.light0.specularColor = GLKVector4Make(1, 1, 1, 1);
			
			NSError *error;
			NSString *path = [[NSBundle mainBundle] pathForResource:@"xmpTexture" ofType:@"png"];
			GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:path options:@{GLKTextureLoaderOriginBottomLeft: @YES} error:&error];
			if (!texture) {
				NSLog(@"Error loading texture: %@", [error localizedDescription]);
			}
			self.effect.texture2d0.enabled = GL_TRUE;
			self.effect.texture2d0.name = texture.name;
			glActiveTexture(GL_TEXTURE0);
			
			glEnableVertexAttribArray(GLKVertexAttribPosition);
			glEnableVertexAttribArray(GLKVertexAttribNormal);
			glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
			glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, xmpResourceUnitVerts);
			glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, xmpResourceUnitVerts);
			glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, xmpResourceUnitTexCoords);
			
			break;
		}
			
		case 4: {
			
			glEnable(GL_DEPTH_TEST);
			
			self.effect = [GLKBaseEffect new];
			
			self.effect.light0.enabled = GL_TRUE;
			
			//253./255.,41./255.,146./255.
			self.effect.light0.ambientColor = GLKVector4Make(1, 1, 1, 1);
			self.effect.light0.diffuseColor = GLKVector4Make(1, 1, 1, 1);
			//			self.effect.light0.specularColor = GLKVector4Make(1, 1, 1, 1);
			
			NSError *error;
			NSString *path = [[NSBundle mainBundle] pathForResource:@"shieldTexture" ofType:@"png"];
			GLKTextureInfo *texture = [GLKTextureLoader textureWithContentsOfFile:path options:@{GLKTextureLoaderOriginBottomLeft: @YES} error:&error];
			if (!texture) {
				NSLog(@"Error loading texture: %@", [error localizedDescription]);
			}
			self.effect.texture2d0.enabled = GL_TRUE;
			self.effect.texture2d0.name = texture.name;
			glActiveTexture(GL_TEXTURE0);
			
			glEnableVertexAttribArray(GLKVertexAttribPosition);
			glEnableVertexAttribArray(GLKVertexAttribNormal);
			glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
			glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 0, shieldResourceUnitVerts);
			glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 0, shieldResourceUnitVerts);
			glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 0, shieldResourceUnitTexCoords);
			
			break;
		}
			
	}
	
}

- (void)tearDownGL {
	
	[EAGLContext setCurrentContext:self.context];
	
	self.effect = nil;
	
	glDisableVertexAttribArray(GLKVertexAttribPosition);
	glDisableVertexAttribArray(GLKVertexAttribNormal);
	glDisableVertexAttribArray(GLKVertexAttribTexCoord0);
	
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update {
	
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65), aspect, .1, 100);
    self.effect.transform.projectionMatrix = projectionMatrix;
	
	switch (self.modelID) {
		case 1: {
			
			float zTranslation;
			
			if (IS_4_INCH) {
				zTranslation = -1.5;
			} else {
				zTranslation = -1.25;
			}
			
			GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, zTranslation);
			modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 0, 1, 0);
			self.effect.transform.modelviewMatrix = modelViewMatrix;
			
			_rotation += .3 * self.timeSinceLastUpdate;
			
			break;
		}
		case 2: {
			
			GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -.9);
			modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 0, 1, 0);
			self.effect.transform.modelviewMatrix = modelViewMatrix;
			
			_rotation += .3 * self.timeSinceLastUpdate;
			
			break;
		}
		case 3: {
			
			GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -1.1);
			modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, M_PI/4, 1, 0, 0);
			modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 0, 1, 0);
			self.effect.transform.modelviewMatrix = modelViewMatrix;
			
			_rotation += .3 * self.timeSinceLastUpdate;
			
			break;
		}
		case 4: {
			
			GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0, 0, -1);
			modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 0, 1, 0);
			self.effect.transform.modelviewMatrix = modelViewMatrix;
			
			_rotation += .3 * self.timeSinceLastUpdate;
			
			break;
		}
	}
	
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
	
	[EAGLContext setCurrentContext:self.context];
	
	CGFloat r, g, b, a;
	[self.view.backgroundColor getRed:&r green:&g blue:&b alpha:&a];
	
	glClearColor(r, g, b, a);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	switch (self.modelID) {
		case 1: {
			
			[self.effect prepareToDraw];
			
			glDrawArrays(GL_TRIANGLES, 0, sphereNumVerts);
			
			break;
		}
		case 2: {
			
			[self.effect prepareToDraw];
			
			//	glLineWidth(2.0);
			
			glDrawArrays(GL_TRIANGLES, 0, resonatorResourceUnitNumVerts);
			
			break;
		}
		case 3: {
			
			[self.effect prepareToDraw];
			
			glDrawArrays(GL_TRIANGLES, 0, xmpResourceUnitNumVerts);
			
			break;
		}
		case 4: {
			
			[self.effect prepareToDraw];
			
			glDrawArrays(GL_TRIANGLES, 0, shieldResourceUnitNumVerts);
			
			break;
		}
		default: {
			
			break;
		}
	}
	
}

@end
