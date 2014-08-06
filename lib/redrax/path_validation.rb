module Redrax
  module PathValidation
    def validate_path_elements(*args)
      msg = compile_errors(
        identify_errors(*args)
      )

      raise(ArgumentError, msg) if msg
    end

    NAME_BY_POSITION = [:container_name, :file_name]

    def identify_errors(*args)
      [].tap { |errors|
        args.each_with_index { |a, i|
          if a == ""
            errors << [NAME_BY_POSITION[i], "is blank"]
          end
          if a.nil?
            errors << [NAME_BY_POSITION[i], "is nil"]
          end
        }
      }
    end

    def compile_errors(errors)
      unless errors.empty?
        raise ArgumentError, errors.each_with_object("") { |e, msg|
          msg << "#{e.join(" ")}\n"
        }
      end
    end
  end
end
