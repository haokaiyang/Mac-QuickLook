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
[ProvisionQL](https://github.com/ealeksandrov/ProvisionQL)   |  quicklook for apps and provisioning profile files | .ipa, .xcarchive,.mobileprovision |
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
[QuickLookAPK](https://github.com/hezi/QuickLookAPK)| display Android packages informations| .apk |
[qlMoviePreview](https://github.com/Nyx0uf/qlMoviePreview) | QuickLook plugin to display movie thumbnail and video informations. Also create nice Finder icons from the thumbnail. | mkv |
[qlwoff](https://github.com/Nyx0uf/qlwoff) | QuickLook plugin to preview Web Open Font Format files (woff) | woff |
[ql-bbc4](https://github.com/simongregory/ql-bbc4)| Quicklook plugin for .bbc4 media archives | .bbc4 |
[qlboxnote](https://github.com/louije/qlboxnote)| QuickLook previews generator plugin for .boxnote files. | .boxnote |

## App
| Name | descript | support file |
| - | - | - |
[Suspicious Package](http://www.mothersruin.com/software/SuspiciousPackage/)| Inspecting macOS Installer Packages) | .pkg |
[QLdds](https://github.com/Marginal/QLdds) | display thumbnails, QuickLook previews and metadata for "DirectDraw Surface" (DDS) texture files. | DirectX 8/9 DDS,DirectX 10 DDS extensions,Cubemaps |
[quicklook-pat](https://github.com/pixelrowdies/quicklook-pat) | Quicklook plugin to view Adobe Photoshop pattern files in Apple's Finder application | .pat |
[AssetCatalogTinkerer](https://github.com/insidegui/AssetCatalogTinkerer)|open .car files and browse/extract their images| .car |
[phew](https://github.com/sveinbjornt/Phew)| FLIF image viewer and QuickLook plugin for macOS | FLIF|
