class ::Hash

  def additive_merge!(other)
    other.each do |k, v|
      if self[k].is_a?(Hash) && v.is_a?(Hash)
        v.each do |_k, _v|
          if self[k].has_key?(_k)
            if self[k][_k].is_a?(Array) && _v.is_a?(Array)
              self[k][_k] = self[k][_k] + _v
            elsif self[k][_k].is_a?(Hash) && _v.is_a?(Hash)
              self[k][_k].additive_merge!(_v)
            else
              self[k][_k] = _v  
            end
          else
            self[k][_k] = _v 
          end
        end
      elsif !self[k]
        self[k] = v 
      end
    end
  end

  def subtractive_merge!(other)
    other.each do |k, v|
      if self[k].is_a?(Hash) && v.is_a?(Hash)
        v.each do |_k, _v|
          if self[k].has_key?(_k)
            if self[k][_k].is_a?(Array) && _v.is_a?(Array)
              self[k][_k] = self[k][_k] - _v
            elsif self[k][_k].is_a?(Hash) && _v.is_a?(Hash)
              self[k].delete(_k)
            else
              self[k].delete_if {|__k, __v| __v == _v}  
            end      
          end
        end
      end
    end
    self
  end

end 

class Moment

  def self.new(*opt)
    if opt.empty?
      @native = Native(`moment()`)
    else
      @native = Native(`moment.apply(null, #{opt})`)
    end
  end

end

class String
  def to_snake_case
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end

  def to_camel_case
    self.split('_').collect(&:capitalize).join
  end

  def constantize
    self.split('::').inject(Object) {|o,c| o.const_get c}
  end
end

class Object
  
  def try(*a, &b)       
    try!(*a, &b) if a.empty? || respond_to?(a.first)
  end  
     
   # Same as #try, but will raise a NoMethodError exception if the receiver is not +nil+ and   
   # does not implement the tried method.    
     
  def try!(*a, &b)    
   if a.empty? && block_given?   
     if b.arity == 0   
       instance_eval(&b)   
     else    
       yield self    
     end   
   else    
     public_send(*a, &b)   
   end   
  end
end

class NilClass

  def try(*args)
    nil      
  end  
     
  def try!(*args)   
   nil   
  end

end

class HTTP
  def send(method, url, options, block)
    @method   = method
    @url      = url
    @payload  = options.delete :payload
    @handler  = block

    @settings.update options

    settings, payload = @settings.to_n, @payload

    %x{
      if (#{@method == "get" && @payload != nil}) {
        payload = #{@payload.to_n};
        #{settings}.data = $.param(payload);
      }
      else if (typeof(#{payload}) === 'string') {
        #{settings}.data = payload;
      }
      else if (payload != nil) {
        settings.data = payload.$to_json();
        settings.contentType = 'application/json';
      }
      settings.url  = #@url;
      settings.type = #{@method.upcase};
      settings.success = function(data, status, xhr) {
        return #{ succeed `data`, `status`, `xhr` };
      };
      settings.error = function(xhr, status, error) {
        return #{ fail `xhr`, `status`, `error` };
      };
      $.ajax(settings);
    }

    @handler ? self : promise
  end
end