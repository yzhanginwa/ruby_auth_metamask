require 'ecdsa'
require 'digest/keccak'

module RubyAuthMetamask
  # a simple wrapper to carry the v value of signture
  class MySignature
    attr_reader :sig_obj, :v

    def initialize(sig_obj, v_value)
      @sig_obj = sig_obj
      @v = v_value
    end
  end

  class UsersController < ApplicationController
    def signin
      if session[:user_id].nil?
        @message = "ruby_auth_metamask:#{SecureRandom.hex}"
        session[:message] = @message
      else
        redirect_to main_app.root_path
      end
    end

    def verify
      address = sanitize_and_return_address
      my_signature = sanitize_and_return_my_signature
      if address.nil? || my_signature.nil?
        redirect_to main_app.root_path, notice: 'Address or signature is invalid'
        return
      end

      hash = metamask_digest(session[:message])
      if hash.nil?
        redirect_to main_app.root_path, notice: 'User authentication failed'
        return
      end

      public_key = recover_public_key(hash, my_signature)
      if public_key.nil?
        redirect_to main_app.root_path, notice: 'User authentication failed'
        return
      end

      unless verify_public_key_and_address(public_key, address)
        redirect_to main_app.root_path, notice: 'User address does not match public key'
        return
      end

      valid = ECDSA.valid_signature?(public_key, hash, my_signature.sig_obj) rescue false
      redirect_to main_app.root_path, notice: 'User authentication failed' unless valid

      user = User.find_by_address(address) || User.create(address: address)
      session[:user_id] = user.id
      redirect_to main_app.root_path, notice: 'User authentication succeeded'
    end

    private

    def sanitize_and_return_address
      return nil if params[:address].nil?

      params[:address].downcase
    end

    def sanitize_and_return_my_signature
      signature = params[:signature] # 0x0123456789abcdef
      if signature.nil?
        return nil
      elsif signature.size < 3
        return nil
      else
        signature = signature[2..]
      end

      my_signature_from_hex(signature)
    end

    def public_key_to_address(public_key)
      # public_key_string_short = ECDSA::Format::PointOctetString.encode(public_key, compression: true)
      # pub_key_hex = public_key_string_short.unpack1("H*")
      # puts "pub key hex: #{pub_key_hex}"

      public_key_string = ECDSA::Format::PointOctetString.encode(public_key, compression: false)
      calculated_address = Digest::Keccak.digest(public_key_string[1..], 256)
      calculated_address[-20..].unpack1('H*')
    end

    def verify_public_key_and_address(public_key, address)
      "0x#{public_key_to_address(public_key)}".downcase == address.downcase
    end

    METAMASK_HASH_PREFIX = "\x19Ethereum Signed Message:\n".freeze

    def message_for_hashing(raw_message)
      "#{METAMASK_HASH_PREFIX}#{raw_message.size}#{raw_message}"
    end

    def metamask_digest(message)
      return nil if message.nil?

      Digest::Keccak.digest(message_for_hashing(message), 256)
    end

    def recovery_id_from_v(v_value)
      raise 'v needs to be an integerr' unless v_value.is_a? Integer

      rec_id = v_value - 27
      raise "Invalid recovery id: #{rec_id}" if rec_id < 0 || rec_id > 3

      rec_id
    end

    def my_signature_from_hex(signature)
      signature_byte_string = signature

      case signature.size
      when 130
        signature_byte_string = [signature].pack('H*')
      when 65
        # do nothing
      else
        return nil
      end

      signature_bytes = signature_byte_string.unpack('C*')
      r = signature_bytes[0, 32].pack('C*').unpack1('H*').to_i(16)
      s = signature_bytes[32, 32].pack('C*').unpack1('H*').to_i(16)
      v = signature_bytes[64].to_i

      sig_obj = ECDSA::Signature.new(r, s)
      MySignature.new(sig_obj, v)
    end

    def recover_public_key(hash, my_signature)
      keys = ECDSA.recover_public_key(ECDSA::Group::Secp256k1, hash, my_signature.sig_obj).map do |p|
        ECDSA::Format::PointOctetString.encode(p, compression: true)
      end
      key = keys[recovery_id_from_v(my_signature.v)]
      return nil if key.nil?

      ECDSA::Format::PointOctetString.decode(key, ECDSA::Group::Secp256k1)
    end
  end
end
