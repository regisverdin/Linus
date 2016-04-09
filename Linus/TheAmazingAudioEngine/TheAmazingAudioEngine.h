//  ALTERED BY REGIS VERDIN


//  TheAmazingAudioEngine.h
//  TheAmazingAudioEngine
//
//  Created by Michael Tyson on 23/03/2016.
//  Copyright © 2016 A Tasty Pixel. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "AEBufferStack.h"
#import "AETypes.h"
#import "AEModule.h"
#import "AEAudioUnitModule.h"
#import "AEAudioUnitInputModule.h"
#import "AEAudioFilePlayerModule.h"
#import "AEOscillatorModule.h"
#import "AEBandpassModule.h"
#import "AEDelayModule.h"
#import "AEDistortionModule.h"
#import "AEDynamicsProcessorModule.h"
#import "AEHighPassModule.h"
#import "AEHighShelfModule.h"
#import "AELowPassModule.h"
#import "AELowShelfModule.h"
#import "AENewTimePitchModule.h"
#import "AEParametricEqModule.h"
#import "AEPeakLimiterModule.h"
#import "AEVarispeedModule.h"
#import "AEFileRecorderModule.h"
#if TARGET_OS_IPHONE
#import "AEReverbModule.h"
#endif

#import "AERenderer.h"
#import "AEAudioUnitOutput.h"

#import "AEUtilities.h"
#import "AEAudioBufferListUtilities.h"
#import "AEDSPUtilities.h"
#import "AEMessageQueue.h"
#import "AETime.h"
#import "AEArray.h"
#import "AEManagedValue.h"
#import "AEIOAudioUnit.h"

