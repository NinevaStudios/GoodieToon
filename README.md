# Goodie Toon
This repository contains Goodie Toon shaders, which includes some features that may be useful for someone during their development process.

## Base Type
The Goodie Toon/Base shader is a base type that includes the following settings:
* Main color and texture settings
* Color and texture settings for object shadows
* Ability to change the intensity, smoothness, and offset of the shadows, creating a toon-style look
* Specular and rim settings


## All Types
The following types are included in this shader pack:
* Base - basic shader type
* Transparent - basic shader type with transparency support
* Outline - basic shader type with outline support (the outline width is fixed and does not distort when scaling the object; it uses a vertex extrusion principle without jagged gaps in the outline)
* Selection - basic shader type with outline support and an additional color (a white color with transparency can be overlaid on the main color to create a "selected object" effect)
* Fixed - makes the texture independent of the object's position and scale, with animation support (useful for creating floors or animated water)
* Priority - basic shader type with transparency support and rendering order support (renders the object on top of all others, useful for first-person view)
* Grass - basic shader type with grass geometry generation and mesh tessellation support.
