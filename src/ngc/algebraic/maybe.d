module ngc.algebraic.maybe;

//import core.stdc;

struct nothing_t {}
immutable nothing_t nothing;

struct Maybe(T) {
     @nogc nothrow:
private:
     union {
	  T value_;
	  nothing_t empty_;
     }
     bool has_value_;

public:
     // constructors
     this(T val) {
	  value_ = val;
	  has_value_ = true;
     }

     this(nothing_t) {
	  empty_ = nothing_t.init;
	  has_value_ = false;
     }

     // copy constructor
     this(ref const Maybe!T that) {
	  has_value_ = that.has_value_;
	  if (has_value_)
	       value_ = cast(T) that.value_;
	  else
	       empty_ = nothing_t.init;
     }

     // opAssign
     ref Maybe!T opAssign(const Maybe!T that) {
	  if (has_value_ && that.has_value_) {
	       value_ = cast(T) that.value_;
	  } else if (that.has_value_) {
	       value_ = cast(T) that.value_;
	       has_value_ = true;
	  } else if (has_value_) {
	       destroy(value_);
	       empty_ = nothing_t.init;
	       has_value_ = false;
	  }
	  return this;
     }

     bool is_some() const { return has_value_; }
     bool is_none() const { return !has_value_;}

     T unwrap() {
	  assert(has_value_, "Tried to get the value of nothing");
	  return value_;
     }
     
     T opUnary(string op : "*")() {
	  return value();
     }

     T value_or(const T that) {
	  if (has_value_) return value_;
	  return cast(T) that;
     }

     T value_orelse(T delegate()  @nogc nothrow fn) {
	  if (has_value_) return value_;
	  return fn();
     }

     T expect(string msg) {
	  assert(has_value_, msg);
	  return value_;
     }

     Maybe!T orelse(Maybe!T delegate()  @nogc nothrow fn) {
	  if (!has_value_) return fn();
	  return this;
     }
     Maybe!U and_then(U)(Maybe!U delegate(T) @nogc nothrow fn) {
	  if (has_value_) return fn(value_);
	  return Maybe!U(nothing);
     }
     // map: Maybe!T -> Maybe!U
     Maybe!U map(U)(U delegate(T)  @nogc nothrow fn) {
	  if (has_value_) return Maybe!U(fn(value_));
	  return Maybe!U(nothing);
     }
     alias unwrap this; // Alias, unwrap this!!!
     bool opCast(T : bool)() { return has_value_; }
     
}
Maybe!T Some(T)(T val)      @nogc nothrow {

     return Maybe!T(val);
}
Maybe!T None(T)()  @nogc nothrow{
	  
    return Maybe!T(nothing);
}
struct Result(T, E) {
     @nogc nothrow:
     private T _val;
     private E _err;
     private bool _ok;

     static Result ok(T val)  { return Result(val, E.init, true); }
     static Result err(E err) { return Result(T.init, err, false); }

     bool is_ok()  { return _ok; }
     bool is_err() { return !_ok; }

     T unwrap() {
	  assert(_ok, "unwrap on Err");
	  return _val;
     }

     E unwrap_err() {
	  assert(!_ok, "unwrap_err on Ok");
	  return _err;
     }

     Result!(U, E) map(U)(U delegate(T) f) {
	  if (_ok) return Result!(U, E).ok(f(_val));
	  return Result!(U, E).err(_err);
     }
}
