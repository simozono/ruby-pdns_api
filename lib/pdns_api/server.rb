require 'pdns_api/config'
require 'pdns_api/override'
require 'pdns_api/zone'

# PDNS Server
module PDNS
  # PDNS Server
  class Server < API
    attr_reader :id, :url

    def initialize(t_url, id, info = {})
      @id    = id
      @r_url = "#{t_url}/servers"
      @url   = "#{t_url}/servers/#{id}"
      @info  = info
    end

    ## Server interfaces
    # TODO: /servers/:server_id: ?

    ## Server actions

    def cache(domain)
      # TODO: #{url}/cache/flush?domain=:domain: PUT
    end

    def search_log(search_term)
      # TODO: /servers/:server_id/search-log?q=:search_term: GET
    end

    def statistics
      # TODO: /servers/:server_id/statistics: GET
    end

    def trace
      # TODO: /servers/:server_id/trace: GET, PUT
    end

    def failures
      # TODO: /servers/:server_id/failures: GET, PUT
    end

    ## Server resources

    # Get or set server config
    def config(name = nil, value = nil)
      return Config.new(@url, name, value).create unless name.nil? || value.nil?
      return Config.new(@url, name) unless name.nil?

      # Get all current configuration
      config = @@api.get("#{@url}/config")
      config.map { |c| [c[:name], c[:value]] }.to_h
    end

    # Get or set server overrides, not yet implemented
    def overrides(id = nil)
      return Override.new(@url, id) unless id.nil?

      overrides = @@api.get("#{@url}/config")
      overrides.map { |o| [o[:id], Override.new(@url, o[:id], o)] }.to_h
    end

    # Get zones or create one
    def zones(zone_id = nil)
      return Zone.new(@url, zone_id) unless zone_id.nil?

      zones = @@api.get("#{@url}/zones")
      zones.map { |z| [z[:id], Zone.new(@url, z[:id], z)] }.to_h
    end

    alias override overrides
    alias zone zones
  end
end