require "logger"
require "kafka/connection"
require "kafka/protocol"

module Kafka
  class Broker
    def initialize(host:, port:, node_id: nil, client_id:, logger:)
      @host, @port, @node_id = host, port, node_id

      @connection = Connection.open(
        host: host,
        port: port,
        client_id: client_id,
        logger: logger
      )

      @logger = logger
    end

    def to_s
      "#{@host}:#{@port} (node_id=#{@node_id.inspect})"
    end

    def fetch_metadata(**options)
      api_key = Protocol::TOPIC_METADATA_API_KEY
      request = Protocol::TopicMetadataRequest.new(**options)
      response_class = Protocol::MetadataResponse

      @connection.request(api_key, request, response_class)
    end

    def produce(**options)
      api_key = Protocol::PRODUCE_API_KEY
      request = Protocol::ProduceRequest.new(**options)
      response_class = request.requires_acks? ? Protocol::ProduceResponse : nil

      @connection.request(api_key, request, response_class)
    end
  end
end
