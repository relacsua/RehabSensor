//
//  OpenGLView.h
//  HomeRehab
//
//  Created by Muhammad Muneer on 22/9/15.
//  Copyright (c) 2015 Muhammad Muneer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface OpenGLView : UIView {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    GLuint _depthRenderBuffer;
    float _yaw;
    float _pitch;
    float _roll;
}

- (void) setYawPitchRoll:(float) yaw pitch:(float)pitch roll:(float)roll;

@end