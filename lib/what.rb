module What

  VERSION = "0.1.0"

  module Colors
    def black(str)      "\e[30m#{str}\e[0m" end
    def red(str)        "\e[31m#{str}\e[0m" end
    def green(str)      "\e[32m#{str}\e[0m" end
    def brown(str)      "\e[33m#{str}\e[0m" end
    def blue(str)       "\e[34m#{str}\e[0m" end
    def magenta(str)    "\e[35m#{str}\e[0m" end
    def cyan(str)       "\e[36m#{str}\e[0m" end
    def gray(str)       "\e[37m#{str}\e[0m" end

    def bg_black(str)   "\e[40m#{str}\e[0m" end
    def bg_red(str)     "\e[41m#{str}\e[0m" end
    def bg_green(str)   "\e[42m#{str}\e[0m" end
    def bg_brown(str)   "\e[43m#{str}\e[0m" end
    def bg_blue(str)    "\e[44m#{str}\e[0m" end
    def bg_magenta(str) "\e[45m#{str}\e[0m" end
    def bg_cyan(str)    "\e[46m#{str}\e[0m" end
    def bg_gray(str)    "\e[47m#{str}\e[0m" end

    def bold(str)       "\e[1m#{str}\e[21m" end
    def italic(str)     "\e[3m#{str}\e[23m" end
    def underline(str)  "\e[4m#{str}\e[24m" end
    def blink(str)      "\e[5m#{str}\e[25m" end
    def reverse(str)    "\e[7m#{str}\e[27m" end
  end

  module NoColors
    def black(str)      str end
    def red(str)        str end
    def green(str)      str end
    def brown(str)      str end
    def blue(str)       str end
    def magenta(str)    str end
    def cyan(str)       str end
    def gray(str)       str end

    def bg_black(str)   str end
    def bg_red(str)     str end
    def bg_green(str)   str end
    def bg_brown(str)   str end
    def bg_blue(str)    str end
    def bg_magenta(str) str end
    def bg_cyan(str)    str end
    def bg_gray(str)    str end

    def bold(str)       str end
    def italic(str)     str end
    def underline(str)  str end
    def blink(str)      str end
    def reverse(str)    str end
  end

  def What.where(program)
    if search_path = ENV["PATH"]
      paths = search_path.split(File::PATH_SEPARATOR)
      paths.each do |path|
        path.tr!('\\','/')
        candidate = File.join(path, program)
        return candidate if File.executable?(candidate)
        if pathext = ENV["PATHEXT"]
          pathexts = pathext.split(File::PATH_SEPARATOR)
          pathexts.each do |ext|
            candidate = File.join(path, program + ext)
            return candidate if File.executable?(candidate)
          end
        end
      end
    end
    nil
  end

  def What.pager
    env_pager = ENV["PAGER"]
    if pager = env_pager || where("less") || where("more")
      pager.tr!('/','\\')
      args = []
      args << "-r" if pager =~ /\bless\b/
      File.popen([pager, *args], "w") do |io|
        if (pager =~ /more\.com/i && ENV["ConEmuANSI"] == "ON") || args.include?("-r")
          io.extend(Colors)
        else
          io.extend(NoColors)
        end
        yield(io)
      end
    else
      io = STDOUT.dup
      io.extend(NoColors)
      yield(io)
    end
  end

  def What.instance_what?(klass, method = nil)
    methods = []
    if Symbol === method
      methods = [klass.instance_method(method)].group_by { |m| m.owner }
    else
      methods = klass.instance_methods.map { |m| klass.instance_method(m) }.group_by { |m| m.owner }
      rejected = [ Kernel, Object, BasicObject ]
      if method == false || method == nil
        methods.delete_if { |key| rejected.include?(key) }
      end
    end
    What.pager { |io| describe(methods, io) }
  end

  def What.about(object, method = nil)
    methods = []
    if Symbol === method
      methods = [object.method(method)].group_by { |m| m.owner }
    else
      methods = object.methods.map { |m| object.method(m) }.group_by { |m| m.owner }
      rejected = [ Kernel, Object, BasicObject ]
      if method == false || method == nil
        methods.delete_if { |key| rejected.include?(key) }
      end
    end
    What.pager { |io| describe(methods, io) }
  end

  def What.describe(methods, io)
    first = true
    methods.each do |k, ms|
      ms = ms.sort_by { |m| m.name }
      io.puts unless first
      first = false
      io.puts "#{io.green(io.bold(k.to_s))} (#{io.green(k.class.to_s)})"
      ms.each do |m|
        prefix = (UnboundMethod === m) ? "#" : ""
        io.print "    #{io.blue(io.bold(prefix + m.name.to_s))}"
        if m.arity == -1 && m.parameters.empty?
          io.print "(...)"
        elsif m.arity != 0
          param_name = "a"
          parms = m.parameters.map do |type, name|
            if name.nil?
              name = param_name
              param_name = param_name.next
            end
            case type
            when :opt
              "#{name} = ?"
            when :rest
              "*#{name}"
            when :block
              "&#{name}"
            else
              "name"
            end
          end
          io.print "(" + parms.join(", ") + ((m.arity < 0) ? ", ...)" : ")")
        end
        if m.respond_to?(:super_method) && sm = m.super_method
          io.puts ", overrides #{sm}"
        end
        line_feeded = false
        if s = m.source_location
          io.print " #{s[0]}:#{s[1]}"
          begin
            lns = IO.read(s[0]).lines.to_a
            ln = s[1]-1
            found = false
            while ln >= 0 && ln >= s[1]-6 && !found
              endline = ln
              while lns[ln] =~ /^\s*#/
                beginline = ln
                found = true
                ln -= 1
              end
              if found
                doc = lns[beginline..endline]
                indent = doc.map { |ln| ln[/^\s*/].size }.min
                io.puts
                io.puts doc.map { |ln| "        " + io.green(ln[indent..-1].chomp) }
                line_feeded = true
              end
              ln -= 1
            end
          rescue Errno::ENOENT
          end
        end
        io.puts unless line_feeded
      end
    end
    nil
  end
end

module Kernel
  def what?(method = false)
    What.about(self, method)
  end
end

class Module
  def instance_what?(method = false)
    What.instance_what?(self, method)
  end
end
