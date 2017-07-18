#
# Cookbook Name:: kafka
# Library:: ChefKafka
#
# Copyright 2014, Heavy Water Operations, LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module ChefKafka

  module Helpers

    def kafka_download_url(version, scala_version)
      uri = nil
      mirror=`curl --stderr /dev/null https://www.apache.org/dyn/closer.cgi\?as_json\=1 | jq -r '.preferred'`

      uri = URI.parse mirror

      uri.path = "/kafka/#{version}/kafka_#{scala_version}-#{version}.tgz"
      uri.to_s
    end

    def kafka_file(uri)
      Pathname.new(URI.parse(uri).path).basename.to_s
    end

    def kafka_suffix_cwd(uri)
      kafka_file(uri).sub(File.extname(kafka_file(uri)), '')
    end

    # Returns the correct ZooKeeper prefix key name based on the desired
    # version of Kafka.
    #
    # @return [String] the correct ZooKeeper prefix name
    def kafka_zk_prefix
      kafka_is_07? ? "zk" : "zookeeper"
    end

    # Returns the correct broker key name based on the desired version of
    # Kafka.
    #
    # @return [String] the correct broker key name
    def kafka_broker_key
      kafka_is_07? ? "brokerid" : "broker.id"
    end

    # Calculates a new broker id that won't overflow a Java Integer.
    #
    # @return [Integer] a new broker id
    def new_kafka_broker_id
      int_bit = 31
      max_java_integer = (2 ** int_bit) - 1
      %x{hostid}.to_i(16) % max_java_integer
    end
  end
end
