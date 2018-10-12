# Copyright 2016 - Silke Hofstra
#
# Licensed under the EUPL, Version 1.1 or -- as soon they will be approved by
# the European Commission -- subsequent versions of the EUPL (the "Licence");
# You may not use this work except in compliance with the Licence.
# You may obtain a copy of the Licence at:
#
# https://joinup.ec.europa.eu/software/page/eupl
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the Licence is distributed on an "AS IS" basis,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
# express or implied.
# See the Licence for the specific language governing
# permissions and limitations under the Licence.
#

require 'pdns_api/config'
require 'pdns_api/override'
require 'pdns_api/zone'

##
# Module for interaction with the PowerDNS HTTP API.
module PDNS
  ##
  # Server object for accessing data for a particular server.
  class Server < API
    ##
    # @return [String] the ID of the server.
    attr_reader :id

    ##
    # Creates a Server object.
    #
    # @param http   [HTTP]   An HTTP object for interaction with the PowerDNS server.
    # @param parent [API]    This object's parent.
    # @param id     [String] ID of the server.
    # @param info   [Hash]   Optional information of the server.
    #
    def initialize(http, parent, id, info = {})
      @class  = :servers
      @http   = http
      @parent = parent
      @id     = id
      @url    = "#{parent.url}/#{@class}/#{id}"
      @info   = info
    end

    ##
    # Flushes cache for a domain.
    #
    # @param domain [String] name of the domain.
    # @return [Hash] result of the action.
    #
    def cache_flush(domain)
      @http.put("#{@url}/cache/flush?domain=#{domain}")
    end

    ##
    # Searches data
    #
    # @param search_term [String] terms to search for.
    # @param max [String] terms to search for.
    # @return [Hash] result of the search.
    #
    def search_data(search_term, max = 0)
      @http.get("#{@url}/search-data?q=#{search_term}")
    end

    ##
    # Searches through the server's log with +search_term+.
    #
    # @param search_term [String] terms to search for.
    # @return [Hash] result of the search.
    #
    def search_log(search_term)
      # TODO: /servers/:server_id/search-log?q=:search_term: GET
    end

    ##
    # Gets the statistics for the server.
    def statistics
      # TODO: /servers/:server_id/statistics: GET
    end

    ##
    # Manipulates the query tracing log.
    #
    # @param domain_regex [String, nil]
    #   Regular expression to match for domain tracing.
    #   Set to nil to turn off tracking.
    #
    # @return [Hash] Regular expression and matching log lines.
    #
    def trace=(domain_regex)
      @http.put("#{@url}/trace", domains: domain_regex)
    end

    ##
    # Retrieves the query tracing log.
    #
    # @return [Hash] Regular expression and matching log lines.
    #
    def trace
      @http.get("#{@url}/trace")
    end

    ##
    # Manipulates failure logging.
    def failures
      # TODO: /servers/:server_id/failures: GET, PUT
    end

    ##
    # Returns existing configuration or creates a +Config+ object.
    #
    # @param name [String, nil]  Name of the configuration option.
    # @param value [String, nil] Value op the configuration option.
    #
    # @return [Hash, Config] Hash containing +Config+ objects or a single +Config+ object.
    #   - If +name+ is not set the current configuration is returned in a hash.
    #   - If +name+ is set a +Config+ object is returned using the provided +name+.
    #   - If +value+ is set as well, a complete config object is returned.
    #
    def config(name = nil, value = nil)
      return Config.new(@http, self, name, value) unless name.nil? || value.nil?
      return Config.new(@http, self, name) unless name.nil?

      # Get all current configuration
      config = @http.get("#{@url}/config")
      config.map { |c| [c[:name], c[:value]] }.to_h
    end

    ##
    # Returns existing or creates an +Override+ object.
    #
    # @param id [Integer, nil] ID of the override.
    #
    # @return [Hash, Override] Hash containing +Override+ objects or a single +Override+ object.
    #   - If +id+ is not set the current servers are returned in a hash
    #     containing +Override+ objects.
    #   - If +id+ is set an +Override+ object with the provided ID is returned.
    #
    def overrides(id = nil)
      return Override.new(@http, self, id) unless id.nil?

      overrides = @http.get("#{@url}/config")
      overrides.map { |o| [o[:id], Override.new(@http, self, o[:id], o)] }.to_h
    end

    ##
    # Returns existing or creates a +Zone+ object.
    #
    # @param id [String, nil] ID of the override.
    #
    # @return [Hash, Zone] Hash containing +Zone+ objects or a single +Zone+ object.
    #   - If +id+ is not set the current servers are returned in a hash
    #     containing +Zone+ objects.
    #   - If +id+ is set a +Server+ object with the provided ID is returned.
    #
    def zones(id = nil)
      return Zone.new(@http, self, id) unless id.nil?

      zones = @http.get("#{@url}/zones")
      zones.map { |z| [z[:id], Zone.new(@http, self, z[:id], z)] }.to_h
    end

    alias override overrides
    alias zone zones
  end
end
