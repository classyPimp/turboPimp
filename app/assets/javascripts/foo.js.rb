(function(Opal) {
  Opal.dynamic_require_severity = "error";
  var self = Opal.top, $scope = Opal, nil = Opal.nil, $breaker = Opal.breaker, $slice = Opal.slice, $klass = Opal.klass;

  Opal.add_stubs(['$alert']);
  return (function($base, $super) {
    function $Foo(){};
    var self = $Foo = $klass($base, $super, 'Foo', $Foo);

    var def = self.$$proto, $scope = self.$$scope;

    return (Opal.defs(self, '$foo', function() {
      var self = this;

      return self.$alert("FOOOOOOO");
    }), nil) && 'foo'
  })(self, null)
})(Opal);
