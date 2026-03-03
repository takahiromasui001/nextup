require 'open-uri'

class Items::TitleFetcher
  TIMEOUT_SECONDS = 5
  ALLOWED_SCHEMES = %w[http https].freeze
  PRIVATE_RANGES = [
    IPAddr.new('127.0.0.0/8'),
    IPAddr.new('10.0.0.0/8'),
    IPAddr.new('172.16.0.0/12'),
    IPAddr.new('192.168.0.0/16'),
    IPAddr.new('::1/128')
  ].freeze

  def initialize(url)
    @url = url
  end

  def fetch
    return nil if @url.blank?

    uri = validate_uri(@url)
    return nil unless uri

    html = URI.open(uri, read_timeout: TIMEOUT_SECONDS, open_timeout: TIMEOUT_SECONDS, &:read)
    extract_title(html)
  rescue StandardError
    nil
  end

  private

  def validate_uri(url)
    uri = URI.parse(url)
    return nil unless ALLOWED_SCHEMES.include?(uri.scheme)
    return nil if private_address?(uri.host)

    uri
  rescue URI::InvalidURIError
    nil
  end

  def private_address?(host)
    ip = IPAddr.new(Resolv.getaddress(host))
    PRIVATE_RANGES.any? { |range| range.include?(ip) }
  rescue Resolv::ResolvError, IPAddr::InvalidAddressError
    true
  end

  def extract_title(html)
    return nil unless html

    match = html.match(/<title[^>]*>([^<]+)<\/title>/i)
    match&.[](1)&.strip&.then { |t| CGI.unescapeHTML(t) }
  end
end
