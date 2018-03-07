//
//  ZipFile.h
//  Objective-Zip
//
//  Created by Gianluca Bertani on 25/12/09.
//  Copyright 2009-10 Flying Dolphin Studio. All rights reserved.
//	Modified by Geoff Pado on 29/10/10.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions 
//  are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the name of Gianluca Bertani nor the names of its contributors 
//    may be used to endorse or promote products derived from this software 
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>

struct zipFile__;
struct unzFile__;

typedef enum {
	ZipFileModeUnzip,
	ZipFileModeCreate,
	ZipFileModeAppend
} ZipFileMode;

typedef enum {
	ZipCompressionLevelDefault= -1,
	ZipCompressionLevelNone= 0,
	ZipCompressionLevelFastest= 1,
	ZipCompressionLevelBest= 9
} ZipCompressionLevel;	

@class ZipReadStream;
@class ZipWriteStream;
@class ZipFileInfo;

@interface ZipFile : NSObject {
@private
	struct zipFile__ * _zipFile;
	struct unzFile__ * _unzFile;
}

@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) ZipFileMode mode;
@property (nonatomic, readonly) NSUInteger filesCount;
@property (nonatomic, readonly) NSArray *containedFiles;

+ (id)zipFileWithFileName:(NSString *)fileName mode:(ZipFileMode)mode error:(NSError **)outError;
+ (id)zipFileWithURL:(NSURL *)url mode:(ZipFileMode)mode error:(NSError **)outError;

- (id)initWithFileName:(NSString *)fileName mode:(ZipFileMode)mode;
- (id)initWithFileName:(NSString *)fileName mode:(ZipFileMode)mode error:(NSError **)outError;

- (ZipWriteStream *)writeFileInZipWithName:(NSString *)fileNameInZip compressionLevel:(ZipCompressionLevel)compressionLevel error:(NSError **)writeFileError;
- (ZipWriteStream *)writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(ZipCompressionLevel)compressionLevel error:(NSError **)writeFileError;
- (ZipWriteStream *)writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(ZipCompressionLevel)compressionLevel password:(NSString *)password crc32:(NSUInteger)crc32 error:(NSError **)writeFileError;

- (BOOL)goToFirstFileInZip:(NSError **)readFileError;
- (BOOL)goToNextFileInZip:(NSError **)readFileError;
- (BOOL)locateFileInZip:(NSString *)fileNameInZip error:(NSError **)readFileError;

- (ZipFileInfo *)getCurrentFileInZipInfo:(NSError **)readFileError;

- (ZipReadStream *)readCurrentFileInZip:(NSError **)readFileError;
- (ZipReadStream *)readCurrentFileInZipWithPassword:(NSString *)password error:(NSError **)readFileError;

- (void) close;

@end
