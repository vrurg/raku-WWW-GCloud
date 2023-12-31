# CHANGELOG

  - **v0.0.7**

  - **v0.0.6**
    
      - Use [`JSON::Class:auth<zef:vrurg>`](https://raku.land/zef:vrurg/JSON::Class) as the marshalling framework
    
      - Set `:enums-as-value` [`JSON::Class:auth<zef:vrurg>`](https://raku.land/zef:vrurg/JSON::Class) configuration option by default for all `is gc-record` types

  - **v0.0.5**
    
      - Fix type mapping for chained inheritance cases, i.e. when `Child2` is wrapping `Child1` which, in turn, wraps around a `Base` `WWW::GCloud::Record` class.

  - **v0.0.4**
    
      - Mostly fix serialization of enums
    
      - Added `gc-enum` trait to mark enums meant for serialization
    
      - Added `gc-ctx-wrap`/`gc-context-wrap` methods to `WWW::GCloud::Config`

  - **v0.0.3**
    
      - Fix deserialization of nominalizables and comples hashes or arrays when there are type maps specified

  - **v0.0.2**
    
      - Lock-protect access to API objects hash
