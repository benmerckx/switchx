package switchx;

using StringTools;

enum UserVersionData {
  UEdge;
  ULatest;
  UStable;
  UNightly(hash:String);
  UOfficial(version:Official);
  
}

abstract Official(String) from String to String {
  public var isPrerelease(get, never):Bool;
    function get_isPrerelease()
      return this.indexOf('-') != -1;
      
  static public function compare(a:Official, b:Official):Int
    return Reflect.compare(b, a);
}

enum ResolvedUserVersionData {
  RNightly(nightly:Nightly);
  ROfficial(version:Official);
}

typedef Nightly = {
  var hash(default, null):String;
  var published(default, null):Date;
}

abstract ResolvedVersion(ResolvedUserVersionData) from ResolvedUserVersionData to ResolvedUserVersionData {
  
  public var id(get, never):String;
  
    function get_id()
      return switch this {
        case RNightly({ hash: v }): v;
        case ROfficial(v): v;
      }
  
  public function toString():String    
    return switch this {
      case RNightly({ hash: v }): 'nightly build $v';
      case ROfficial(v): 'official release $v';
    }
}

abstract UserVersion(UserVersionData) from UserVersionData to UserVersionData {
  
  static var hex = [for (c in '0123456789abcdefABCDEF'.split('')) c.charCodeAt(0) => true];
  
  @:from static function ofResolved(v:ResolvedVersion):UserVersion
    return switch v {
      case ROfficial(version): UOfficial(version);
      case RNightly({ hash: version }): UNightly(version);
    }
  
  static public function isHash(version:String) {
    
    for (i in 0...version.length)
      if (!hex[version.fastCodeAt(i)])
        return false;
        
    return true;
  }  
  
  @:from static public function ofString(s:Null<String>):UserVersion
    return 
      if (s == null) null;
      else switch s {
        case 'auto': null;
        case 'edge' | 'nightly': UEdge;
        case 'latest': ULatest;
        case 'stable': UStable;
        case isHash(_) => true: UNightly(s);
        default: UOfficial(s);//TODO: check if this is valid?
      }
  
}