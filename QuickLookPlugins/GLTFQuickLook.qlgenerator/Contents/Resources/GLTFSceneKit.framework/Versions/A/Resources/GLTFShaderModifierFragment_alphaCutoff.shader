//
//  GLTFShaderModifierFragment_alphaCutOff.shader
//  GLTFSceneKit
//
//  Created by magicien on 2017/08/29.
//  Copyright © 2017 DarkHorse. All rights reserved.
//

#pragma arguments

float alphaCutOff;

#pragma body

_output.color.a = _output.color.a >= alphaCutoff ? 1.0 : 0.0
