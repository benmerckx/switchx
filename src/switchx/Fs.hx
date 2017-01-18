package switchx;

import haxe.ds.Option;

using haxe.io.Path;
using sys.FileSystem;
using StringTools;

class Fs { 
  
  static public function ensureDir(dir:String) {
    var isDir = dir.endsWith('/') || dir.endsWith('\\');
    
    if (isDir)
      dir = dir.removeTrailingSlashes();
      
    var parent = dir.directory();
    if (parent.removeTrailingSlashes() == dir) return;
    if (!parent.exists())
      ensureDir(parent.addTrailingSlash());
      
    if (isDir && !dir.exists()) 
      dir.createDirectory();
  }
  
  static public function peel(file:String, depth:Int) {
    var start = 0;
    for (i in 0...depth)
      switch file.indexOf('/', start) {
        case -1: 
          return None;
        case v:
          start = v + 1;
      }
    return Some(file.substr(start));
  }
  
  static public function findNearest(name:String, dir:String) {
    
    while (true) 
      if ('$dir/$name'.exists())
        return Some('$dir/$name');
      else
        switch dir.directory() {
          case same if (dir == same): return None;
          case parent: dir = parent; 
        }
    
    return None;
  }
}