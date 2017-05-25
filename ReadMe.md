# CCNXML

Simple basic handling of XML files for both reading and manual creation. You can specify your own mapping prefix, set attributes on each element, add and remove child items, iterate over children and so on.

__UPDATE (August 13th, 2014): THIS REPOSITORY HAS BEEN RENAMED (and all its sources refactored) FROM `CNXML` TO `CCNXML`!__


## Installation
#### Via CocoaPods
Just add `pod 'CCNXML'` to your podfile.


#### Via Git SubModule
`cd` into your project directory and execute:
```
git submodule add https://github.com/phranck/CCNXML.git $DIR_WHERE_YOUR_SUBMODULES_ARE_PLACED
```

You have to replace the `$DIR_WHERE_YOUR_SUBMODULES_ARE_PLACED` with the real path where your submodules are placed.


#### Via Drag&Drop
Just drag the `CCNXML.h`, `CCNXMLReader.*`, `CCNXMLElement.*` and `*CCNXMLAdditions.*` files into your project.


## Requirements
`CCNXML` was written using ARC and runs on 10.7+ and iOS 6+.


## Contribution
The code is provided as-is, and it is far off being complete or free of bugs. If you like this component feel free to support it. Make changes related to your needs, extend it or just use it in your own project. Feedbacks are very welcome. Just contact me at [opensource@cocoanaut.com](mailto:opensource@cocoanaut.com) or send me a [ping on Twitter](http://twitter.com/TheCocoaNaut).


## Documentation
The complete documentation you will find on [CocoaDocs](http://cocoadocs.org/docsets/CCNXML/).


## License
This software is published under the [MIT License](http://cocoanaut.mit-license.org).
