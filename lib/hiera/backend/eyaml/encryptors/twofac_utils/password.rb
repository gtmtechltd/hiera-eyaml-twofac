require 'highline/import'

class Hiera
  module Backend
    module Eyaml
      module Encryptors
      	module TwofacUtils
      	  class Password

            @@password = nil

            def self.obtain

              calling_class = caller[0].split(':').first.split('/').reverse.take(5).join(',')
              raise StandardError "Refusing to supply password" unless calling_class == "twofac.rb,encryptors,eyaml,backend,hiera"
              
              return @@password.dup if @@password
              hl = HighLine.new($stdin, $stderr)
              begin
                @@password = hl.ask("Please enter your twofactor password: ") {|q| q.echo='*' }
              rescue
                raise StandardError "No terminal is available to read password from"
              end
              return @@password.dup
            end

      	  end
      	end
      end
    end
  end
end
