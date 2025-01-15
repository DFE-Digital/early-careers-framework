require "openssl"

module HTTPI
  module Auth

    # = HTTPI::Auth::SSL
    #
    # Provides SSL client authentication.
    class SSL

      VERIFY_MODES = [:none, :peer, :fail_if_no_peer_cert, :client_once]
      CERT_TYPES = [:pem, :der]

      # Fix for
      # httpi/auth/ssl.rb:13: warning: constant OpenSSL::SSL::SSLContext::METHODS is deprecated
      ssl_context = OpenSSL::SSL::SSLContext
      SSL_VERSIONS = if ssl_context.const_defined? :METHODS_MAP
        ssl_context.const_get(:METHODS_MAP).keys
      else
        ssl_context::METHODS.reject { |method| method.match(/server|client/) }
      end.sort.reverse

      # Returns OpenSSL::SSL::*_VERSION values for min_version and max_version
      MIN_MAX_VERSIONS = OpenSSL::SSL.constants.select{|constant| constant =~/_VERSION$/}.map{|version| version.to_s.gsub(/_VERSION$/,'').to_sym}.reverse

      # Returns whether SSL configuration is present.
      def present?
        (verify_mode == :none) || (cert && cert_key) || ca_cert_file || ciphers
      rescue TypeError, Errno::ENOENT
        false
      end

      # Accessor for the cert key file to validate SSL certificates.
      attr_accessor :cert_key_file

      # Accessor for the cert key password to validate SSL certificates.
      attr_accessor :cert_key_password

      # Accessor for the cert file to validate SSL connections.
      attr_accessor :cert_file

      # Accessor for the cacert file to validate SSL certificates.
      attr_accessor :ca_cert_file

      # Accessor for the ca_path to validate SSL certificates.
      attr_accessor :ca_cert_path

      # Certificate store holds trusted CA certificates used to verify peer certificates.
      attr_accessor :cert_store

      # Accessor for the SSL ciphers list.
      attr_reader :ciphers

      # Sets the available symmetric algorithms for encryption and decryption.
      # @see OpenSSL::SSL::SSLContext#ciphers
      # @example
      #   ssl.ciphers = "cipher1:cipher2:..."
      #   ssl.ciphers = [name, ...]
      #   ssl.ciphers = [[name, version, bits, alg_bits], ...]
      def ciphers=(ciphers)
        @ciphers =
          if ciphers
            context = OpenSSL::SSL::SSLContext.new
            context.ciphers = ciphers
            context.ciphers.map(&:first)
          end
      end

      # Returns the cert type to validate SSL certificates PEM|DER.
      def cert_type
        @cert_type ||= :pem
      end

      # Sets the cert type to validate SSL certificates PEM|DER.
      def cert_type=(type)
        unless CERT_TYPES.include? type
          raise ArgumentError, "Invalid SSL cert type #{type.inspect}\n" +
                               "Please specify one of #{CERT_TYPES.inspect}"
        end

        @cert_type = type
      end

      # Returns the SSL verify mode. Defaults to <tt>:peer</tt>.
      def verify_mode
        @verify_mode ||= :peer
      end

      # Sets the SSL verify mode. Expects one of <tt>HTTPI::Auth::SSL::VERIFY_MODES</tt>.
      def verify_mode=(mode)
        unless VERIFY_MODES.include? mode
          raise ArgumentError, "Invalid SSL verify mode #{mode.inspect}\n" +
                               "Please specify one of #{VERIFY_MODES.inspect}"
        end

        @verify_mode = mode
      end

      # Returns the SSL version number. Defaults to <tt>nil</tt> (auto-negotiate).
      def ssl_version
        @ssl_version ||= nil
      end

      # Sets the SSL version number. Expects one of <tt>HTTPI::Auth::SSL::SSL_VERSIONS</tt>.
      def ssl_version=(version)
        unless SSL_VERSIONS.include? version
          raise ArgumentError, "Invalid SSL version #{version.inspect}\n" +
                               "Please specify one of #{SSL_VERSIONS.inspect}"
        end

        @ssl_version = version
      end

      # Returns the SSL min_version number. Defaults to <tt>nil</tt> (auto-negotiate).
      def min_version
        @min_version ||= nil
      end

      # Sets the SSL min_version number. Expects one of <tt>HTTPI::Auth::SSL::MIN_MAX_VERSIONS</tt>.
      def min_version=(version)
        unless MIN_MAX_VERSIONS.include? version
          raise ArgumentError, "Invalid SSL min_version #{version.inspect}\n" +
                               "Please specify one of #{MIN_MAX_VERSIONS.inspect}"
        end

        @min_version = version
      end

      # Returns the SSL min_version number. Defaults to <tt>nil</tt> (auto-negotiate).
      def max_version
        @max_version ||= nil
      end

      # Sets the SSL min_version number. Expects one of <tt>HTTPI::Auth::SSL::MIN_MAX_VERSIONS</tt>.
      def max_version=(version)
        unless MIN_MAX_VERSIONS.include? version
          raise ArgumentError, "Invalid SSL max_version #{version.inspect}\n" +
                               "Please specify one of #{MIN_MAX_VERSIONS.inspect}"
        end

        @max_version = version
      end

      # Returns an <tt>OpenSSL::X509::Certificate</tt> for the +cert_file+.
      def cert
        @cert ||= (OpenSSL::X509::Certificate.new File.read(cert_file) if cert_file)
      end

      # Sets the +OpenSSL+ certificate.
      attr_writer :cert

      # Returns an <tt>OpenSSL::X509::Certificate</tt> for the +ca_cert_file+.
      def ca_cert
        @ca_cert ||= OpenSSL::X509::Certificate.new File.read(ca_cert_file)
      end

      # Sets the +OpenSSL+ ca certificate.
      attr_writer :ca_cert

      # Returns an <tt>OpenSSL::PKey</tt> subclass (usually <tt>OpenSSL::PKey::RSA</tt>) for the +cert_key_file+.
      def cert_key
        @cert_key ||= (OpenSSL::PKey.read(File.read(cert_key_file), cert_key_password) if cert_key_file)
      end

      # Sets the +OpenSSL+ certificate key.
      attr_writer :cert_key

      # Returns the SSL verify mode as a <tt>OpenSSL::SSL::VERIFY_*</tt> constant.
      def openssl_verify_mode
        case verify_mode
          when :none                 then OpenSSL::SSL::VERIFY_NONE
          when :peer                 then OpenSSL::SSL::VERIFY_PEER
          when :fail_if_no_peer_cert then OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
          when :client_once          then OpenSSL::SSL::VERIFY_CLIENT_ONCE
        end
      end

    end
  end
end
