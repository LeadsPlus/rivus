# encoding: UTF-8

require 'digest/md5'

Gravatar = Struct.new(:email) do
  def url
    hash = Digest::MD5.hexdigest(email.downcase)
    "http://www.gravatar.com/avatar/#{ hash }"
  end
end
