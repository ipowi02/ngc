module ngc.containers.nonowning;

/// Non-owning allocators and structures.

struct Sink {
     @nogc nothrow:
     char[] buf;
     size_t pos;

     this(char[] buf) in {
	  assert(buf !is null && buf.length > 0);
     } do {
	  this.buf = buf;
	  this.pos = 0;
     }
     bool put(char c) {
	  if (pos >= buf.length) {
	       return false;
	  }
	  buf[pos++] = c;
	  return true;
     }
     char[] result() {
	  return buf[0..pos];
     }
}
struct Arena {
     @nogc nothrow:
     import ngc.algebraic.maybe;
     private size_t align_up(size_t n, size_t alignment) pure {
	  return (n + alignment - 1) & ~(alignment - 1);
     }
     Maybe!(ubyte[]) buf;
     size_t pos;
     this(void[] buffer) in {
	  assert(buffer !is null && buffer.length > 0);
     } do {
	  this.buf = Some(cast(ubyte[]) buffer);
	  this.pos = 0;
     }
     Maybe!(void*) alloc_aligned(size_t size, size_t alignment) {
	  size_t aligned = align_up(pos, alignment);
	  if (aligned + size > buf.length) return None!(void*);
	  pos = aligned + size;
	  return Some(cast(void*) buf.ptr + aligned);
     }
     Maybe!(T*) alloc(T)(size_t N = 1) {
	  return alloc_aligned(T.sizeof * N, T.alignof).map((x) => cast(T*)x);
     }
     void drop() @nogc nothrow {
	  pos  = 0;
	  buf  = None!(ubyte[]);
     }
     @property size_t used()     const @nogc nothrow { return pos; }
     @property Maybe!size_t capacity() @nogc nothrow {
	  return buf.map((b) => b.length);
     }
     @property Maybe!size_t remaining() @nogc nothrow {
	  if (buf.is_none()) return None!size_t;
	  return Some(buf.unwrap().length - pos);
     }
}
