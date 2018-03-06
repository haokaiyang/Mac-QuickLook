# Mac-QuickLook [![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)](https://github.com/sindresorhus/awesome)
>List of QuickLook plugins and App

## How to install/uninstall QuickLook plugins

### Using [HomeBrew Cask](http://caskroom.github.io/)

- install : ```brew cask install + <package name>```
- uninstall : ```brew cask uninstall + <package name>```

### Manually
- install : Move the downloaded .qlgenerator file to `~/Library/QuickLook` (only for yourself) or `/Library/QuickLook` (for everyone)
- uninstall : Open `/Library/QuickLook` ,remove package

Then, run `qlmanage -r reload QuickLook

## Plugins

| plugins Name | descript | support file |
| - | - | - |
[AsciiDocQuickLook](https://github.com/clydeclements/AsciiDocQuickLook ) | AsciiDoc|
[BetterZipQL](https://macitbetter.com/BetterZip-Quick-Look-Generator)   |  let you inspect the contents of compressed archives | ZIP, RAR, 7-Zip, TAR, TGZ, TBZ, TXZ, GZip, BZip2, ARJ, LZH, ISO, CHM, CAB, CPIO, DEB, RPM, StuffIt's SIT, BinHex, MacBinary ,dmg,winmail.dat |
[BodymovinQL](https://github.com/fabionuno/BodymovinQL) | A macOS QuickLook plugin to generate previews for Adobe After Effects animations exported as JSON with Bodymovin | Adobe After Effects animations exported as JSON |
[CertQuickLook](https://code.google.com/archive/p/cert-quicklook/) | preview of various unprotected certificate tokens. | X509 certificates, DER or PEM (ASCII-armored) |
[ProvisionQL](https://github.com/ealeksandrov/ProvisionQL)   |  quicklook for apps and provisioning profile files | .ipa, .xcarchive, .mobileprovision, .appex, .provisionprofile |
[QLColorCode](https://github.com/n8gray/QLColorCode)   | A Quick Look plugin for source code with syntax highlighting | Support for lots of languages |
[qlImageSize](https://github.com/Nyx0uf/qlImageSize)   | QuickLook plugin to display the dimensions and size of an image in the title bar instead of the filename. Also preview some unsupported formats like WebP & bpg | .bpm, .bpg, .exr, .icns, .ico, .jpg, .pbm, .pgm, .png, .ppm, .psd, .sgi, .svg, .tga, .tiff, .gif, .webp, .jp2 |
[qlmarkdown](https://github.com/toland/qlmarkdown)    | QuickLook generator for Markdown files | .md, .markdown |
[MultiMarkdown QuickLook](https://github.com/fletcher/MMD-QuickLook)| markdown, OPML |
[QLMobi](https://github.com/bfabiszewski/QLMobi) | Quick Look plugin for Kindle ebook formats| prc, mobi, azw, azw3, azw4 and some pdb files |
[qlstephen](https://github.com/whomwah/qlstephen)     | QLStephen is a QuickLook plugin that lets you view plain text files without a file extension. Files like: README,CHANGELOG,INSTALL... |  |
[QuickLookASE](https://github.com/rsodre/QuickLookASE) | Mac quicklook for ASE files (Adobe Swatch Exchange) | .ase |
[quicklookjson](http://www.sagtau.com/quicklookjson.html) | preview json file | .json |
[QuickLookPrettyJSON](https://github.com/tomnewton/QuickLookPrettyJSON) | preview json file | .json |
[QLVideo](https://github.com/Marginal/QLVideo)         | display thumbnails, static QuickLook previews, cover art and metadata for most types of video files | .asf, .avi, .flv, .mkv, .rm, .webm, .wmf |
[QLAddict](https://github.com/tattali/QLAddict) | A QuickLook plugin that lets you view subtitles .srt files like Addic7ed.com on mac | .src |
[QLCommonMark](https://github.com/digitalmoksha/QLCommonMark) |QuickLook generator for beautifully rendering CommonMark documents on macOS| markdown file |
[QLPrettyPatch](https://github.com/atnan/QLPrettyPatch) |QuickLook generator for patch files | .patch |
[QLFits](https://github.com/onekiloparsec/QLFits) | The macOS quicklook plugin for FITS files | .fits |
[QLAnsilove](https://github.com/ansilove/QLAnsilove) | macOS QuickLook for ANSi, ASCii, and other Text-mode Art | ANSi (.ANS, .CIA, .ICE),Binary (.BIN),Artworx (.ADF),iCE Draw (.IDF),Xbin (.XB),PCBoard (.PCB),Tundra (.TND),ASCII (.ASC),Release info (.NFO),Description in zipfile (.DIZ),Membership in zipfile (.MEM) |
[qlvega](https://github.com/invokesus/qlvega)| QuickLook Plugin for Vega and Vega-Lite | Vega and Vega-Lite files |
[WebPQuickLook](https://github.com/emin/WebPQuickLook) | preview WebP image files | .webp |
[ePub-quicklook](https://github.com/jaketmp/ePub-quicklook)| extract the cover images from EPUB files to use as the file icon, and present a nice overview of the EPUB in QuickLook | .epub |
[QuickNFO](https://github.com/planbnet/QuickNFO) | Quicklook Plugin for NFO files | .nfo |
[QuickJSON](https://github.com/johan/QuickJSON) |  pretty-print (node.js style) JSON | .json |
[quicklook-csv](https://github.com/p2/quicklook-csv)  | A QuickLook plugin for CSV files | csv |
[FictionBook2QL](https://github.com/gonzoua/FictionBook2QL/) | QuickLook generator for FictionBook (fb2) e-book file format  | fb2 |
[QuickLookAPK](https://github.com/hezi/QuickLookAPK)| display Android packages informations| .apk |
[qlMoviePreview](https://github.com/Nyx0uf/qlMoviePreview) | QuickLook plugin to display movie thumbnail and video informations. Also create nice Finder icons from the thumbnail. | mkv |
[qlwoff](https://github.com/Nyx0uf/qlwoff) | QuickLook plugin to preview Web Open Font Format files (woff) | woff |
[ql-bbc4](https://github.com/simongregory/ql-bbc4)| Quicklook plugin for .bbc4 media archives | .bbc4 |
[qlboxnote](https://github.com/louije/qlboxnote)| QuickLook previews generator plugin for .boxnote files. | .boxnote |
[NDSQuickLook](https://github.com/gonzoua/NDSQuickLook) | Quick Look generator for Nintendo DS ROM images | image |
[FGOutlook2011]() | Outlook 2011 for Mac plug-in, to view header message of type olk14Message. | 
[Provisioning](https://github.com/chockenberry/Provisioning) | A Quick Look plug-in for .mobileprovision files | .mobileprovision |
[Starcraft Replay QL](https://code.google.com/archive/p/sc2replay-ql/) | A Quick Look generator to read Starcraft II Replays | MPQ DDS |
[ql-iff](https://github.com/dalton-tulou/ql-iff) | Quick Look plugin for viewing iff pictures | .iff |
[qlBitRate](https://github.com/jordansaints/qlBitRate) |display the bit rate (in kbps) of an MP3 file in the title bar of the QuickLook window | .mp3 |
[StringsFile](https://blog.timac.org/2014/0325-quicklook-plugin-to-preview-strings-files/) | preview .string file | .string|
[ElektrikTrickQuickLook](https://www.thingiverse.com/thing:376361) | Elektriktrick STL, DXF, and GCode QuickLook | STL, DXF, and GCode|
[QuickLookPUZ](https://github.com/DianeWass/QuickLookPUZ) |Mac QuickLook plugin to view crossword puzzle files (puz).| .puz|
[QuarkXPress](http://forums.quark.com/)|preview QuarkXPress projects| .qxp |
[colorxml-quicklook](https://github.com/fabiolecca/colorxml-quicklook) | display XML files with indentation and XML syntax coloring | .xml |
[EPSQLPlugIn](https://www.eternalstorms.at/utilities/epsqlplg/epsqlplg/download.html)|display previews and thumbnails for eps files.| .eps|
[QLEnscript](https://www.dribin.org/dave/blog/archives/2007/11/14/quick_look_enscript/) |preview source code files| Objective-C/C++ C/C++ Perl Python Java Shell scripts Assembly language source file|
[HetimaClipping](http://hetima.com/soft/clippingql-e.html)|This is Cover Flow and Quick Look plugin for text clipping file (.textClipping). and picture clipping file (.pictClipping)| .textClipping, .pictClipping|
[BrushViewQL](http://brushviewer.sourceforge.net/)|see the contents of Photoshop brush files | .abr |




## App
| Name | descript | support file |
| - | - | - |
[Suspicious Package](http://www.mothersruin.com/software/SuspiciousPackage/)| Inspecting macOS Installer Packages) | .pkg |
[QLdds](https://github.com/Marginal/QLdds) | display thumbnails, QuickLook previews and metadata for "DirectDraw Surface" (DDS) texture files. | DirectX 8/9 DDS,DirectX 10 DDS extensions,Cubemaps |
[quicklook-pat](https://github.com/pixelrowdies/quicklook-pat) | Quicklook plugin to view Adobe Photoshop pattern files in Apple's Finder application | .pat |
[AssetCatalogTinkerer](https://github.com/insidegui/AssetCatalogTinkerer)|open .car files and browse/extract their images| .car |
[phew](https://github.com/sveinbjornt/Phew)| FLIF image viewer and QuickLook plugin for macOS | FLIF|
[Animated GIF](sourceforge.net/projects/animgifqlgen/) | preview of Animated GIFs. | .gif |
[ImageFolderQLGenerator](http://hasseg.org/imageFolderQLGenerator/)|This is a Quick Look Plugin (or Quick Look Generator) that creates thumbnails and previews for folders that contain image files| |
[QLTorrent](http://technocrank.com/downloads/) |  isplays the contents of a metainfo “.torrent” file| .torrent |
[quicklook-ipa](https://code.google.com/archive/p/quicklook-ipa/) |display iPhone / iPad / iPod Touch applications| |
[DPX pictures]|displaying DPX pictures | |