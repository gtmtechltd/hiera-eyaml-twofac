require 'base64'
require 'openssl'
require 'digest'
require 'hiera/backend/eyaml/encryptor'
require 'hiera/backend/eyaml/utils'
require 'hiera/backend/eyaml/options'
require 'hiera/backend/eyaml/encryptors/twofac_utils/password'

class Hiera
  module Backend
    module Eyaml
      module Encryptors

        class Twofac < Encryptor

          VERSION = "0.2"

          self.tag = "TWOFAC"
          self.options = {
            :twofac_private_key => { :desc => "Path to twofac private key", 
                                     :type => :string, 
                                     :default => "./keys/private_key.twofac.txt" },
            :twofac_public_key =>  { :desc => "Path to twofac public key",  
                                     :type => :string, 
                                     :default => "./keys/public_key.twofac.pem" },
            :twofac_subject =>     { :desc => "Subject to use for twofac certificate when creating keys",
                                     :type => :string,
                                     :default => "/" },
          }
          
          @@vector = "5geLmxqskV0Ruf1ZeRAwvw=="

          def self.encrypt plaintext
 
            #TODO: delegate this to original pkcs7 plugin
            public_key = self.option :twofac_public_key
            raise StandardError, "twofac_public_key is not defined" unless public_key

            public_key_pem = File.read public_key 
            public_key_x509 = OpenSSL::X509::Certificate.new( public_key_pem )

            cipher = OpenSSL::Cipher::AES.new(256, :CBC)
            OpenSSL::PKCS7::encrypt([public_key_x509], plaintext, cipher, OpenSSL::PKCS7::BINARY).to_der

          end

          def self.decrypt ciphertext

            password = Hiera::Backend::Eyaml::Encryptors::TwofacUtils::Password.obtain

            #TODO: delegate this to original pkcs7 plugin
            public_key = self.option :twofac_public_key
            private_key = self.option :twofac_private_key
            raise StandardError, "twofac_public_key is not defined" unless public_key
            raise StandardError, "twofac_private_key is not defined" unless private_key

            begin
              private_key_input = File.read private_key
            rescue
              raise StandardError, "Unable to read contents of keyfile #{private_key}. Check permissions"
            end

            unless private_key_input.include? "-----BEGIN TWOFAC KEY-----" and private_key_input.include? "-----END TWOFAC KEY-----" 
              raise StandardError, "Keyfile #{private_key} is not a TWOFAC key file"
            end

            begin
              private_key_base64 = private_key_input.split('-----BEGIN TWOFAC KEY-----')[1].split('-----END TWOFAC KEY-----')[0]
              private_key_aes = Base64.decode64(private_key_base64)
              private_key_pem = aes_decrypt( password, private_key_aes)
              private_key_rsa = OpenSSL::PKey::RSA.new( private_key_pem )
            rescue
              password = ""
              private_key_base64 = ""
              private_key_aes = ""
              private_key_pem = ""
              private_key_rsa = ""
              raise StandardError, "Unable to decrypt keyfile #{private_key} with password"
            end

            public_key_pem = File.read public_key
            public_key_x509 = OpenSSL::X509::Certificate.new( public_key_pem )

            begin
              pkcs7 = OpenSSL::PKCS7.new( ciphertext )
              pkcs7.decrypt(private_key_rsa, public_key_x509)
            rescue
              raise StandardError, "Unable to decipher using supplied key"
            end

          end

          def self.create_keys

            password = Hiera::Backend::Eyaml::Encryptors::TwofacUtils::Password.obtain

            #TODO: delegate this to original pkcs7 plugin

            # Try to do equivalent of:
            # openssl req -x509 -nodes -days 100000 -newkey rsa:2048 -keyout privatekey.pem -out publickey.pem -subj '/'

            public_key = self.option :twofac_public_key
            private_key = self.option :twofac_private_key
            subject = self.option :twofac_subject

            key = OpenSSL::PKey::RSA.new(2048)
            Utils.ensure_key_dir_exists private_key
            pem_data = key.to_pem
            aes_data = aes_encrypt( password, pem_data )
            base64_data = Base64.encode64(aes_data).strip
            output_data = ["-----BEGIN TWOFAC KEY-----", base64_data, "-----END TWOFAC KEY-----"].join("\n")

            Utils.write_important_file :filename => private_key, :content => output_data, :mode => 0600

            password = ""
            pem_data = ""
            aes_data = ""
            base64_data = ""

            cert = OpenSSL::X509::Certificate.new()
            cert.subject = OpenSSL::X509::Name.parse(subject)
            cert.serial = 1
            cert.version = 2
            cert.not_before = Time.now
            cert.not_after = if 1.size == 8       # 64bit
              Time.now + 50 * 365 * 24 * 60 * 60
            else                                  # 32bit
              Time.at(0x7fffffff)
            end
            cert.public_key = key.public_key

            ef = OpenSSL::X509::ExtensionFactory.new
            ef.subject_certificate = cert
            ef.issuer_certificate = cert
            cert.extensions = [
              ef.create_extension("basicConstraints","CA:TRUE", true),
              ef.create_extension("subjectKeyIdentifier", "hash"),
            ]
            cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                                   "keyid:always,issuer:always")

            cert.sign key, OpenSSL::Digest::SHA1.new

            Utils.ensure_key_dir_exists public_key
            Utils.write_important_file :filename => public_key, :content => cert.to_pem
            puts "Keys created OK"
          end

          def self.aes_decrypt(password, data)
            key = Digest::SHA256.digest password
            iv = Digest::MD5.digest @@vector
            aes = OpenSSL::Cipher.new('AES-256-CBC')
            aes.decrypt
            aes.key = key
            aes.iv = iv
            aes.update(data) + aes.final
          end

          def self.aes_encrypt(password, data)
            key = Digest::SHA256.digest password
            iv = Digest::MD5.digest @@vector
            aes = OpenSSL::Cipher.new('AES-256-CBC')
            aes.encrypt
            aes.key = key
            aes.iv = iv
            aes.update(data) + aes.final
          end

        end

      end

    end

  end

end

